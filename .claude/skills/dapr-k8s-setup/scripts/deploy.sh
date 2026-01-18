#!/bin/bash
# dapr-k8s-setup - Install Dapr on Kubernetes
# Usage: ./deploy.sh [namespace]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="$SCRIPT_DIR/../components"
NAMESPACE="${1:-dapr-system}"
DAPR_VERSION="1.12"

# --- Functions ---
log() { echo "[dapr-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

check_prerequisites() {
    command -v kubectl >/dev/null 2>&1 || error "kubectl not found"
    kubectl cluster-info >/dev/null 2>&1 || error "Cannot connect to Kubernetes cluster"
}

install_dapr_cli() {
    if command -v dapr >/dev/null 2>&1; then
        log "Dapr CLI already installed: $(dapr version --output json 2>/dev/null | grep -o '"cli":"[^"]*"' || echo 'unknown')"
        return 0
    fi

    log "Installing Dapr CLI..."
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        powershell -Command "irm https://get.dapr.io/install.ps1 | iex"
    else
        curl -fsSL https://raw.githubusercontent.com/dapr/cli/master/install/install.sh | bash
    fi
}

install_dapr_runtime() {
    log "Installing Dapr runtime v$DAPR_VERSION on Kubernetes..."

    dapr init -k --runtime-version "$DAPR_VERSION" --wait || {
        # If already installed, just verify
        if dapr status -k >/dev/null 2>&1; then
            log "Dapr already installed, verifying..."
        else
            error "Dapr installation failed"
        fi
    }

    log "Waiting for Dapr services to be ready..."
    kubectl wait deployment/dapr-operator \
        --for=condition=Available \
        --timeout=300s \
        -n "$NAMESPACE" || error "Dapr operator not ready"

    kubectl wait deployment/dapr-sidecar-injector \
        --for=condition=Available \
        --timeout=300s \
        -n "$NAMESPACE" || error "Dapr sidecar injector not ready"
}

deploy_components() {
    log "Deploying Dapr components..."

    # Create default namespace for components if not exists
    kubectl create namespace default --dry-run=client -o yaml | kubectl apply -f -

    # Deploy Kafka pub/sub component
    if kubectl get svc hackathon-kafka-kafka-bootstrap -n kafka >/dev/null 2>&1; then
        log "Configuring Kafka pub/sub component..."
        kubectl apply -f "$COMPONENTS_DIR/kafka-pubsub.yaml"
    else
        log "WARN: Kafka not found in 'kafka' namespace, skipping pub/sub component"
    fi

    # Deploy PostgreSQL state store component
    if kubectl get svc postgresql -n database >/dev/null 2>&1; then
        log "Configuring PostgreSQL state store component..."
        kubectl apply -f "$COMPONENTS_DIR/postgresql-statestore.yaml"
    else
        log "WARN: PostgreSQL not found in 'database' namespace, skipping state store component"
    fi
}

# --- Main ---
main() {
    log "Starting Dapr installation"

    check_prerequisites
    install_dapr_cli
    install_dapr_runtime
    deploy_components

    echo "SUCCESS: Dapr installed with components"
    echo "  Runtime version: $DAPR_VERSION"
    echo "  Namespace: $NAMESPACE"
    dapr status -k 2>/dev/null || true
}

trap 'error "Installation failed at line $LINENO"' ERR
main
