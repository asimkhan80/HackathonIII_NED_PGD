#!/bin/bash
# kafka-k8s-setup - Validate Kafka deployment
# Usage: ./validate.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-kafka}"

log() { echo "[kafka-k8s-setup] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

# Check Strimzi operator
log "Checking Strimzi operator..."
kubectl get deployment strimzi-cluster-operator -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Strimzi operator not found"

OPERATOR_READY=$(kubectl get deployment strimzi-cluster-operator -n "$NAMESPACE" \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
[[ "$OPERATOR_READY" -ge 1 ]] || error "Strimzi operator not ready"

# Check Kafka cluster
log "Checking Kafka cluster..."
kubectl get kafka hackathon-kafka -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Kafka cluster not found"

KAFKA_READY=$(kubectl get kafka hackathon-kafka -n "$NAMESPACE" \
    -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")
[[ "$KAFKA_READY" == "True" ]] || error "Kafka cluster not ready"

# Check pods
log "Checking pods..."
KAFKA_PODS=$(kubectl get pods -n "$NAMESPACE" -l strimzi.io/cluster=hackathon-kafka \
    --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
[[ "$KAFKA_PODS" -ge 2 ]] || error "Expected at least 2 running pods (kafka + zookeeper)"

# Check bootstrap service
log "Checking bootstrap service..."
kubectl get svc hackathon-kafka-kafka-bootstrap -n "$NAMESPACE" >/dev/null 2>&1 || \
    error "Bootstrap service not found"

echo "SUCCESS: Kafka validation passed"
echo "  Namespace: $NAMESPACE"
echo "  Operator: Ready"
echo "  Cluster: Ready"
echo "  Pods: $KAFKA_PODS running"
