#!/bin/bash
# dapr-k8s-setup - Remove Dapr from Kubernetes
# Usage: ./teardown.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-dapr-system}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="$SCRIPT_DIR/../components"

log() { echo "[dapr-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

log "Removing Dapr components..."
kubectl delete -f "$COMPONENTS_DIR/" --ignore-not-found=true 2>/dev/null || true

log "Uninstalling Dapr from Kubernetes..."
if command -v dapr >/dev/null 2>&1; then
    dapr uninstall -k --all || log "WARN: dapr uninstall returned non-zero"
else
    log "WARN: Dapr CLI not found, removing manually..."
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
fi

log "Waiting for namespace deletion..."
kubectl wait namespace/"$NAMESPACE" --for=delete --timeout=120s 2>/dev/null || true

echo "SUCCESS: Dapr teardown complete"
