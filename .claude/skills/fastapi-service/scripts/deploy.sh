#!/bin/bash
# fastapi-service - Build and deploy FastAPI service to Kubernetes
# Usage: ./deploy.sh <project-dir> [namespace]

set -euo pipefail

PROJECT_DIR="${1:-}"
NAMESPACE="${2:-default}"

# --- Functions ---
log() { echo "[fastapi-service] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

validate_inputs() {
    [[ -n "$PROJECT_DIR" ]] || error "Project directory required"
    [[ -d "$PROJECT_DIR" ]] || error "Directory not found: $PROJECT_DIR"
    [[ -f "$PROJECT_DIR/Dockerfile" ]] || error "Dockerfile not found"
    [[ -f "$PROJECT_DIR/k8s/deployment.yaml" ]] || error "Kubernetes manifests not found"
}

get_service_name() {
    grep -o 'name: [a-z][a-z0-9-]*' "$PROJECT_DIR/k8s/deployment.yaml" | head -1 | cut -d' ' -f2
}

build_image() {
    local service_name="$1"
    log "Building Docker image: $service_name"

    # Check if using minikube
    if command -v minikube >/dev/null 2>&1 && minikube status >/dev/null 2>&1; then
        log "Using Minikube Docker daemon"
        eval $(minikube docker-env)
    fi

    docker build -t "$service_name:latest" "$PROJECT_DIR"
}

deploy_to_k8s() {
    log "Deploying to Kubernetes namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    kubectl apply -f "$PROJECT_DIR/k8s/" -n "$NAMESPACE"

    log "Waiting for deployment to be ready..."
    local service_name
    service_name=$(get_service_name)
    kubectl wait deployment/"$service_name" \
        --for=condition=Available \
        --timeout=300s \
        -n "$NAMESPACE" || error "Deployment failed"
}

# --- Main ---
main() {
    validate_inputs

    local service_name
    service_name=$(get_service_name)
    log "Deploying service: $service_name"

    build_image "$service_name"
    deploy_to_k8s

    echo "SUCCESS: $service_name deployed to $NAMESPACE"
    echo "  Service: $service_name.$NAMESPACE.svc.cluster.local"
}

trap 'error "Deployment failed at line $LINENO"' ERR
main
