#!/bin/bash
# postgresql-k8s-setup - Validate PostgreSQL deployment
# Usage: ./validate.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-database}"

log() { echo "[postgresql-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

# Check pod exists and is running
log "Checking PostgreSQL pod..."
POD_STATUS=$(kubectl get pod -l app=postgresql -n "$NAMESPACE" \
    -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
[[ "$POD_STATUS" == "Running" ]] || error "PostgreSQL pod not running (status: $POD_STATUS)"

# Check pod is ready
log "Checking pod readiness..."
POD_READY=$(kubectl get pod -l app=postgresql -n "$NAMESPACE" \
    -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")
[[ "$POD_READY" == "True" ]] || error "PostgreSQL pod not ready"

# Check PVC is bound
log "Checking PVC..."
PVC_STATUS=$(kubectl get pvc postgresql-pvc -n "$NAMESPACE" \
    -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
[[ "$PVC_STATUS" == "Bound" ]] || error "PVC not bound (status: $PVC_STATUS)"

# Check service exists
log "Checking service..."
kubectl get svc postgresql -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "PostgreSQL service not found"

# Test database connectivity
log "Testing database connectivity..."
POD_NAME=$(kubectl get pod -l app=postgresql -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- pg_isready -U hackathon -d learnflow >/dev/null 2>&1 || \
    error "Database not accepting connections"

echo "SUCCESS: PostgreSQL validation passed"
echo "  Namespace: $NAMESPACE"
echo "  Pod: Running and Ready"
echo "  PVC: Bound"
echo "  Service: Available"
echo "  Database: Accepting connections"
