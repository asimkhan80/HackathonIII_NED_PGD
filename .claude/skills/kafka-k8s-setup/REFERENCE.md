# Reference: kafka-k8s-setup

## Overview

This skill deploys Apache Kafka on Kubernetes using the Strimzi operator. Strimzi provides a way to run Apache Kafka on Kubernetes in various deployment configurations.

**Constitution Compliance:**
- Article III: Minimal SKILL.md (~80 tokens)
- Article IV: Script-based execution, minimal output
- Article V: Works with kubectl (agent-agnostic)
- Article VI: Kubernetes-native, declarative deployment

## Prerequisites

- Kubernetes cluster (Minikube, Kind, or cloud-managed)
- `kubectl` configured with cluster access
- Minimum 2GB RAM available in cluster
- Internet access (to pull Strimzi images)

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Kubernetes Cluster                   │
│  ┌─────────────────────────────────────────────┐    │
│  │              Namespace: kafka                │    │
│  │  ┌─────────────────────────────────────┐    │    │
│  │  │     Strimzi Cluster Operator        │    │    │
│  │  └─────────────────────────────────────┘    │    │
│  │                    │                         │    │
│  │                    ▼                         │    │
│  │  ┌─────────────────────────────────────┐    │    │
│  │  │         hackathon-kafka             │    │    │
│  │  │  ┌───────────┐  ┌───────────────┐   │    │    │
│  │  │  │  Kafka    │  │   Zookeeper   │   │    │    │
│  │  │  │  Broker   │  │               │   │    │    │
│  │  │  └───────────┘  └───────────────┘   │    │    │
│  │  │  ┌───────────────────────────────┐  │    │    │
│  │  │  │     Entity Operator          │  │    │    │
│  │  │  │  (Topic + User Operator)     │  │    │    │
│  │  │  └───────────────────────────────┘  │    │    │
│  │  └─────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

## Script Details

### deploy.sh

**Purpose**: Deploy Kafka cluster using Strimzi operator

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `kafka` | Kubernetes namespace |

**Environment Variables**:
| Variable | Default | Description |
|----------|---------|-------------|
| `STRIMZI_VERSION` | `0.38.0` | Strimzi operator version |

**Exit Codes**:
| Code | Meaning |
|------|---------|
| 0 | Success - Kafka deployed |
| 1 | Failure - see error message |

### validate.sh

**Purpose**: Verify Kafka deployment is healthy

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `kafka` | Kubernetes namespace |

**Exit Codes**:
| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | Validation failed |

### teardown.sh

**Purpose**: Remove Kafka deployment completely

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `kafka` | Kubernetes namespace |

## Manifests

### kafka-cluster.yaml

Single-node Kafka cluster optimized for development:
- 1 Kafka broker (ephemeral storage)
- 1 Zookeeper node (ephemeral storage)
- Internal listeners on ports 9092 (plain) and 9093 (TLS)
- Entity Operator for topic/user management

**Resource Requirements**:
| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Kafka | 250m | 500m | 512Mi | 1Gi |
| Zookeeper | 100m | 250m | 256Mi | 512Mi |

## Examples

### Basic Deployment
```bash
./scripts/deploy.sh
# Output: SUCCESS: Kafka deployed to kafka
```

### Custom Namespace
```bash
./scripts/deploy.sh my-kafka-ns
# Output: SUCCESS: Kafka deployed to my-kafka-ns
```

### Validate Deployment
```bash
./scripts/validate.sh kafka
# Output: SUCCESS: Kafka validation passed
```

### Connect to Kafka
```bash
# From within cluster
kafka-console-producer.sh --broker-list hackathon-kafka-kafka-bootstrap.kafka:9092 --topic test

# Port-forward for local access
kubectl port-forward svc/hackathon-kafka-kafka-bootstrap 9092:9092 -n kafka
```

### Create a Topic
```bash
kubectl apply -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: my-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: hackathon-kafka
spec:
  partitions: 3
  replicas: 1
EOF
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Operator not starting | Check cluster has enough resources: `kubectl describe pod -n kafka` |
| Kafka pods pending | Verify PVC/storage class or use ephemeral storage |
| Connection refused | Ensure using correct bootstrap service: `hackathon-kafka-kafka-bootstrap` |
| Timeout waiting for ready | Increase timeout or check events: `kubectl get events -n kafka` |

## Related Skills

- `postgresql-k8s-setup`: Database deployment (uses similar pattern)
- `dapr-k8s-setup`: Dapr sidecar injection for Kafka pub/sub
- `fastapi-kafka-producer`: FastAPI service that produces to Kafka
