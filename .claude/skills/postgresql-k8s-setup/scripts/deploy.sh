#!/bin/bash
# postgresql-k8s-setup - Deploy PostgreSQL on Kubernetes
# Usage: ./deploy.sh [namespace] [password]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="$SCRIPT_DIR/../manifests"
NAMESPACE="${1:-database}"
POSTGRES_PASSWORD="${2:-$(openssl rand -base64 12)}"

# --- Functions ---
log() { echo "[postgresql-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

check_prerequisites() {
    command -v kubectl >/dev/null 2>&1 || error "kubectl not found"
    kubectl cluster-info >/dev/null 2>&1 || error "Cannot connect to Kubernetes cluster"
}

create_namespace() {
    log "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
}

deploy_postgresql() {
    log "Deploying PostgreSQL"

    # Substitute password in manifest and apply
    sed "s/\${POSTGRES_PASSWORD}/$POSTGRES_PASSWORD/g" "$MANIFESTS_DIR/postgresql.yaml" | \
        kubectl apply -f - -n "$NAMESPACE"

    log "Waiting for PostgreSQL to be ready..."
    kubectl wait pod -l app=postgresql \
        --for=condition=Ready \
        --timeout=300s \
        -n "$NAMESPACE" || error "PostgreSQL failed to start"
}

# --- Main ---
main() {
    log "Starting PostgreSQL deployment to namespace: $NAMESPACE"

    check_prerequisites
    create_namespace
    deploy_postgresql

    echo "SUCCESS: PostgreSQL deployed to $NAMESPACE"
    echo "  Host: postgresql.$NAMESPACE.svc.cluster.local"
    echo "  Port: 5432"
    echo "  Database: learnflow"
    echo "  User: hackathon"
    echo "  Password: $POSTGRES_PASSWORD"
}

trap 'error "Deployment failed at line $LINENO"' ERR
main
