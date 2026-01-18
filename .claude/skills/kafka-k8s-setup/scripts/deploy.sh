#!/bin/bash
# kafka-k8s-setup - Deploy Kafka on Kubernetes using Strimzi
# Usage: ./deploy.sh [namespace]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="$SCRIPT_DIR/../manifests"
NAMESPACE="${1:-kafka}"
STRIMZI_VERSION="0.38.0"

# --- Functions ---
log() { echo "[kafka-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

check_prerequisites() {
    command -v kubectl >/dev/null 2>&1 || error "kubectl not found"
    kubectl cluster-info >/dev/null 2>&1 || error "Cannot connect to Kubernetes cluster"
}

create_namespace() {
    log "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
}

install_strimzi_operator() {
    log "Installing Strimzi operator v$STRIMZI_VERSION"
    kubectl apply -f "https://strimzi.io/install/latest?namespace=$NAMESPACE" -n "$NAMESPACE"

    log "Waiting for Strimzi operator to be ready..."
    kubectl wait deployment/strimzi-cluster-operator \
        --for=condition=Available \
        --timeout=300s \
        -n "$NAMESPACE" || error "Strimzi operator failed to start"
}

deploy_kafka_cluster() {
    log "Deploying Kafka cluster"
    kubectl apply -f "$MANIFESTS_DIR/kafka-cluster.yaml" -n "$NAMESPACE"

    log "Waiting for Kafka cluster to be ready (this may take a few minutes)..."
    kubectl wait kafka/hackathon-kafka \
        --for=condition=Ready \
        --timeout=600s \
        -n "$NAMESPACE" || error "Kafka cluster failed to start"
}

# --- Main ---
main() {
    log "Starting Kafka deployment to namespace: $NAMESPACE"

    check_prerequisites
    create_namespace
    install_strimzi_operator
    deploy_kafka_cluster

    echo "SUCCESS: Kafka deployed to $NAMESPACE"
    echo "  Bootstrap: hackathon-kafka-kafka-bootstrap.$NAMESPACE:9092"
}

trap 'error "Deployment failed at line $LINENO"' ERR
main
