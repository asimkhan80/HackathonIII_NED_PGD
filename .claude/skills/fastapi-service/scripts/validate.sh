#!/bin/bash
# fastapi-service - Validate FastAPI service deployment
# Usage: ./validate.sh <service-name> [namespace]

set -euo pipefail

SERVICE_NAME="${1:-}"
NAMESPACE="${2:-default}"

log() { echo "[fastapi-service] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

[[ -n "$SERVICE_NAME" ]] || error "Service name required"

# Check deployment exists
log "Checking deployment..."
kubectl get deployment "$SERVICE_NAME" -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Deployment not found: $SERVICE_NAME"

# Check pod is running
log "Checking pod status..."
POD_STATUS=$(kubectl get pod -l app="$SERVICE_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
[[ "$POD_STATUS" == "Running" ]] || error "Pod not running (status: $POD_STATUS)"

# Check Dapr sidecar is injected
log "Checking Dapr sidecar..."
CONTAINERS=$(kubectl get pod -l app="$SERVICE_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.items[0].spec.containers[*].name}' 2>/dev/null)
[[ "$CONTAINERS" == *"daprd"* ]] || log "WARN: Dapr sidecar not detected (may be expected if Dapr not installed)"

# Check service exists
log "Checking service..."
kubectl get svc "$SERVICE_NAME" -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Service not found: $SERVICE_NAME"

# Check health endpoint (via port-forward)
log "Checking health endpoint..."
POD_NAME=$(kubectl get pod -l app="$SERVICE_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.items[0].metadata.name}')
HEALTH_STATUS=$(kubectl exec "$POD_NAME" -n "$NAMESPACE" -c "$SERVICE_NAME" -- \
    curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health 2>/dev/null || echo "000")
[[ "$HEALTH_STATUS" == "200" ]] || error "Health check failed (status: $HEALTH_STATUS)"

echo "SUCCESS: FastAPI service validation passed"
echo "  Service: $SERVICE_NAME"
echo "  Namespace: $NAMESPACE"
echo "  Pod: Running"
echo "  Health: OK"
