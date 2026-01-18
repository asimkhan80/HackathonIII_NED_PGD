# Reference: dapr-k8s-setup

## Overview

This skill installs Dapr (Distributed Application Runtime) on Kubernetes and configures building block components for Kafka pub/sub and PostgreSQL state store. Dapr provides a portable, event-driven runtime for microservices.

**Constitution Compliance:**
- Article III: Minimal SKILL.md (~90 tokens)
- Article IV: Script-based execution, minimal output
- Article V: Works with kubectl + dapr CLI (agent-agnostic)
- Article VI: Kubernetes-native, Service Runtime requirement

## Prerequisites

- Kubernetes cluster (Minikube, Kind, or cloud-managed)
- `kubectl` configured with cluster access
- Internet access (to install Dapr CLI and images)
- **Optional**: `kafka-k8s-setup` skill deployed (for pub/sub)
- **Optional**: `postgresql-k8s-setup` skill deployed (for state store)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Kubernetes Cluster                          │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │              Namespace: dapr-system                      │     │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐    │     │
│  │  │   dapr-     │ │   dapr-     │ │    dapr-        │    │     │
│  │  │  operator   │ │  placement  │ │ sidecar-injector│    │     │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘    │     │
│  │  ┌─────────────┐ ┌─────────────┐                        │     │
│  │  │   dapr-     │ │   dapr-     │                        │     │
│  │  │   sentry    │ │  dashboard  │                        │     │
│  │  └─────────────┘ └─────────────┘                        │     │
│  └─────────────────────────────────────────────────────────┘     │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │                  Namespace: default                      │     │
│  │                                                          │     │
│  │  ┌──────────────────┐    ┌──────────────────┐           │     │
│  │  │   Component:     │    │   Component:     │           │     │
│  │  │  kafka-pubsub    │    │   statestore     │           │     │
│  │  │  (pubsub.kafka)  │    │ (state.postgres) │           │     │
│  │  └────────┬─────────┘    └────────┬─────────┘           │     │
│  │           │                       │                      │     │
│  └───────────┼───────────────────────┼──────────────────────┘     │
│              │                       │                            │
│              ▼                       ▼                            │
│  ┌───────────────────┐   ┌───────────────────┐                   │
│  │  Namespace: kafka │   │ Namespace: database│                   │
│  │  (Kafka cluster)  │   │  (PostgreSQL)      │                   │
│  └───────────────────┘   └───────────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
```

## Script Details

### deploy.sh

**Purpose**: Install Dapr runtime and configure components

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `dapr-system` | Dapr system namespace |

**Actions**:
1. Installs Dapr CLI (if not present)
2. Initializes Dapr on Kubernetes
3. Waits for control plane ready
4. Deploys Kafka pub/sub component (if Kafka exists)
5. Deploys PostgreSQL state store (if PostgreSQL exists)

### validate.sh

**Purpose**: Verify Dapr installation is healthy

**Checks**:
1. Dapr CLI available
2. Dapr status reports healthy
3. All control plane pods running
4. Sidecar injector ready
5. Components configured

### teardown.sh

**Purpose**: Uninstall Dapr completely

**Actions**:
1. Removes Dapr components
2. Runs `dapr uninstall -k`
3. Waits for namespace deletion

## Components

### kafka-pubsub.yaml

Pub/sub component using Kafka:

| Setting | Value |
|---------|-------|
| Type | `pubsub.kafka` |
| Brokers | `hackathon-kafka-kafka-bootstrap.kafka:9092` |
| Consumer Group | `learnflow-group` |
| Auth | None (internal) |
| Scopes | `learnflow-backend`, `learnflow-worker` |

### postgresql-statestore.yaml

State store component using PostgreSQL:

| Setting | Value |
|---------|-------|
| Type | `state.postgresql` |
| Host | `postgresql.database.svc.cluster.local` |
| Database | `learnflow` |
| Table | `dapr_state` |
| Scopes | `learnflow-backend` |

## Examples

### Basic Installation
```bash
./scripts/deploy.sh
# Installs Dapr and configures available components
```

### Check Status
```bash
dapr status -k
```

### List Components
```bash
kubectl get components -A
```

### Enable Dapr on a Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    metadata:
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "my-app"
        dapr.io/app-port: "8080"
```

### Publish Message (from app)
```python
# Using Dapr SDK
from dapr.clients import DaprClient

with DaprClient() as d:
    d.publish_event(
        pubsub_name='kafka-pubsub',
        topic_name='orders',
        data=json.dumps({'orderId': '123'})
    )
```

### Save State (from app)
```python
from dapr.clients import DaprClient

with DaprClient() as d:
    d.save_state(
        store_name='statestore',
        key='user-123',
        value=json.dumps({'name': 'John'})
    )
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Sidecar not injecting | Check namespace has `dapr.io/enabled` label or pod has annotation |
| Component not found | Verify component namespace and app scope |
| Kafka connection failed | Ensure Kafka is deployed via `kafka-k8s-setup` |
| State store error | Check PostgreSQL connection string and credentials |
| CLI not found | Re-run deploy.sh to install CLI |

## Related Skills

- `kafka-k8s-setup`: Required for pub/sub component
- `postgresql-k8s-setup`: Required for state store component
- `fastapi-service`: Backend service using Dapr sidecars
