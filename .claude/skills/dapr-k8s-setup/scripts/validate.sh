#!/bin/bash
# dapr-k8s-setup - Validate Dapr installation
# Usage: ./validate.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-dapr-system}"

log() { echo "[dapr-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

# Check Dapr CLI
log "Checking Dapr CLI..."
command -v dapr >/dev/null 2>&1 || error "Dapr CLI not found"

# Check Dapr status
log "Checking Dapr runtime status..."
dapr status -k >/dev/null 2>&1 || error "Dapr status check failed"

# Check control plane pods
log "Checking Dapr control plane..."
DAPR_PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
[[ "$DAPR_PODS" -ge 4 ]] || error "Expected at least 4 Dapr pods, found $DAPR_PODS"

# Check all pods are running
RUNNING_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
[[ "$RUNNING_PODS" -eq "$DAPR_PODS" ]] || error "Not all Dapr pods are running ($RUNNING_PODS/$DAPR_PODS)"

# Check sidecar injector
log "Checking sidecar injector..."
INJECTOR_READY=$(kubectl get deployment dapr-sidecar-injector -n "$NAMESPACE" \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
[[ "$INJECTOR_READY" -ge 1 ]] || error "Sidecar injector not ready"

# Check components
log "Checking Dapr components..."
COMPONENTS=$(kubectl get components -A --no-headers 2>/dev/null | wc -l)
log "Found $COMPONENTS Dapr components"

echo "SUCCESS: Dapr validation passed"
echo "  Namespace: $NAMESPACE"
echo "  Pods: $RUNNING_PODS running"
echo "  Components: $COMPONENTS configured"
dapr status -k 2>/dev/null || true
