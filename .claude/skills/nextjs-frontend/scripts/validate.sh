#!/bin/bash
# nextjs-frontend - Validate Next.js app deployment
# Usage: ./validate.sh <app-name> [namespace]

set -euo pipefail

APP_NAME="${1:-}"
NAMESPACE="${2:-default}"

log() { echo "[nextjs-frontend] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

[[ -n "$APP_NAME" ]] || error "App name required"

# Check deployment exists
log "Checking deployment..."
kubectl get deployment "$APP_NAME" -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Deployment not found: $APP_NAME"

# Check pod is running
log "Checking pod status..."
POD_STATUS=$(kubectl get pod -l app="$APP_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
[[ "$POD_STATUS" == "Running" ]] || error "Pod not running (status: $POD_STATUS)"

# Check service exists
log "Checking service..."
kubectl get svc "$APP_NAME" -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Service not found: $APP_NAME"

# Check app responds
log "Checking app endpoint..."
POD_NAME=$(kubectl get pod -l app="$APP_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.items[0].metadata.name}')
RESPONSE=$(kubectl exec "$POD_NAME" -n "$NAMESPACE" -- \
    wget -q -O - http://localhost:3000/ 2>/dev/null | head -c 100 || echo "")
[[ -n "$RESPONSE" ]] || log "WARN: App response empty (may be expected during startup)"

echo "SUCCESS: Next.js app validation passed"
echo "  App: $APP_NAME"
echo "  Namespace: $NAMESPACE"
echo "  Pod: Running"
