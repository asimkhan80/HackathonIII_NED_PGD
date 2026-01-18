#!/bin/bash
# postgresql-k8s-setup - Remove PostgreSQL deployment
# Usage: ./teardown.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-database}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="$SCRIPT_DIR/../manifests"

log() { echo "[postgresql-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

log "Removing PostgreSQL resources..."

# Delete all resources from manifest
kubectl delete -f "$MANIFESTS_DIR/postgresql.yaml" -n "$NAMESPACE" --ignore-not-found=true

log "Waiting for pod termination..."
kubectl wait pod -l app=postgresql --for=delete --timeout=60s -n "$NAMESPACE" 2>/dev/null || true

# Optionally remove namespace if empty
log "Checking namespace..."
REMAINING=$(kubectl get all -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
if [[ "$REMAINING" -eq 0 ]]; then
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
    log "Namespace $NAMESPACE deleted"
else
    log "Namespace $NAMESPACE retained (other resources exist)"
fi

echo "SUCCESS: PostgreSQL teardown complete"
