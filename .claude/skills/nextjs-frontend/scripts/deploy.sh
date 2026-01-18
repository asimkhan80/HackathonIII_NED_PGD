#!/bin/bash
# nextjs-frontend - Build and deploy Next.js app to Kubernetes
# Usage: ./deploy.sh <project-dir> [namespace]

set -euo pipefail

PROJECT_DIR="${1:-}"
NAMESPACE="${2:-default}"

log() { echo "[nextjs-frontend] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

validate_inputs() {
    [[ -n "$PROJECT_DIR" ]] || error "Project directory required"
    [[ -d "$PROJECT_DIR" ]] || error "Directory not found: $PROJECT_DIR"
    [[ -f "$PROJECT_DIR/package.json" ]] || error "package.json not found"
    [[ -f "$PROJECT_DIR/Dockerfile" ]] || error "Dockerfile not found"
}

get_app_name() {
    grep -o '"name": "[^"]*"' "$PROJECT_DIR/package.json" | head -1 | cut -d'"' -f4
}

build_image() {
    local app_name="$1"
    log "Building Docker image: $app_name"

    # Check if using minikube
    if command -v minikube >/dev/null 2>&1 && minikube status >/dev/null 2>&1; then
        log "Using Minikube Docker daemon"
        eval $(minikube docker-env)
    fi

    docker build -t "$app_name:latest" "$PROJECT_DIR"
}

deploy_to_k8s() {
    local app_name="$1"
    log "Deploying to Kubernetes namespace: $NAMESPACE"

    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    kubectl apply -f "$PROJECT_DIR/k8s/" -n "$NAMESPACE"

    log "Waiting for deployment to be ready..."
    kubectl wait deployment/"$app_name" \
        --for=condition=Available \
        --timeout=300s \
        -n "$NAMESPACE" || error "Deployment failed"
}

main() {
    validate_inputs

    local app_name
    app_name=$(get_app_name)
    log "Deploying app: $app_name"

    build_image "$app_name"
    deploy_to_k8s "$app_name"

    echo "SUCCESS: $app_name deployed to $NAMESPACE"
    echo "  Service: $app_name.$NAMESPACE.svc.cluster.local"
}

trap 'error "Deployment failed at line $LINENO"' ERR
main
