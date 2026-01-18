#!/bin/bash
# kafka-k8s-setup - Remove Kafka deployment
# Usage: ./teardown.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-kafka}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="$SCRIPT_DIR/../manifests"

log() { echo "[kafka-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

log "Removing Kafka cluster..."
kubectl delete -f "$MANIFESTS_DIR/kafka-cluster.yaml" -n "$NAMESPACE" --ignore-not-found=true

log "Waiting for Kafka resources to be deleted..."
kubectl wait kafka/hackathon-kafka --for=delete --timeout=120s -n "$NAMESPACE" 2>/dev/null || true

log "Removing Strimzi operator..."
kubectl delete -f "https://strimzi.io/install/latest?namespace=$NAMESPACE" -n "$NAMESPACE" --ignore-not-found=true

log "Removing namespace (if empty)..."
# Only delete namespace if no other resources exist
REMAINING=$(kubectl get all -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
if [[ "$REMAINING" -eq 0 ]]; then
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
    log "Namespace $NAMESPACE deleted"
else
    log "Namespace $NAMESPACE retained (other resources exist)"
fi

echo "SUCCESS: Kafka teardown complete"
