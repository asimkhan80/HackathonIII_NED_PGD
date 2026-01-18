# Reference: postgresql-k8s-setup

## Overview

This skill deploys PostgreSQL 16 on Kubernetes using a StatefulSet with persistent storage. Designed for the LearnFlow application backend.

**Constitution Compliance:**
- Article III: Minimal SKILL.md (~85 tokens)
- Article IV: Script-based execution, minimal output
- Article V: Works with kubectl (agent-agnostic)
- Article VI: Kubernetes-native, declarative deployment

## Prerequisites

- Kubernetes cluster (Minikube, Kind, or cloud-managed)
- `kubectl` configured with cluster access
- Storage class available for PVC (or default)
- `openssl` for password generation (optional)

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Kubernetes Cluster                   │
│  ┌─────────────────────────────────────────────┐    │
│  │            Namespace: database               │    │
│  │                                              │    │
│  │  ┌────────────────────────────────────┐     │    │
│  │  │      StatefulSet: postgresql       │     │    │
│  │  │  ┌──────────────────────────────┐  │     │    │
│  │  │  │   Pod: postgresql-0          │  │     │    │
│  │  │  │   ┌────────────────────────┐ │  │     │    │
│  │  │  │   │  postgres:16-alpine    │ │  │     │    │
│  │  │  │   │  Port: 5432            │ │  │     │    │
│  │  │  │   └────────────────────────┘ │  │     │    │
│  │  │  └──────────────────────────────┘  │     │    │
│  │  └────────────────────────────────────┘     │    │
│  │                    │                         │    │
│  │                    ▼                         │    │
│  │  ┌────────────────────────────────────┐     │    │
│  │  │       Service: postgresql          │     │    │
│  │  │       ClusterIP:5432               │     │    │
│  │  └────────────────────────────────────┘     │    │
│  │                    │                         │    │
│  │                    ▼                         │    │
│  │  ┌────────────────────────────────────┐     │    │
│  │  │      PVC: postgresql-pvc (1Gi)     │     │    │
│  │  └────────────────────────────────────┘     │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

## Script Details

### deploy.sh

**Purpose**: Deploy PostgreSQL with persistent storage

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `database` | Kubernetes namespace |
| `$2` | No | auto-generated | PostgreSQL password |

**Exit Codes**:
| Code | Meaning |
|------|---------|
| 0 | Success - PostgreSQL deployed |
| 1 | Failure - see error message |

### validate.sh

**Purpose**: Verify PostgreSQL deployment is healthy

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `database` | Kubernetes namespace |

**Checks Performed**:
1. Pod exists and is Running
2. Pod readiness probe passing
3. PVC is Bound
4. Service exists
5. Database accepts connections

### teardown.sh

**Purpose**: Remove PostgreSQL deployment completely

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | No | `database` | Kubernetes namespace |

## Database Configuration

| Setting | Value |
|---------|-------|
| Image | `postgres:16-alpine` |
| Database | `learnflow` |
| User | `hackathon` |
| Password | Auto-generated or provided |
| Port | `5432` |
| Storage | `1Gi` PVC |

**Resource Limits**:
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 500m |
| Memory | 256Mi | 512Mi |

## Examples

### Basic Deployment
```bash
./scripts/deploy.sh
# Output includes connection details and generated password
```

### Custom Namespace and Password
```bash
./scripts/deploy.sh production MySecurePass123
```

### Validate Deployment
```bash
./scripts/validate.sh database
# Output: SUCCESS: PostgreSQL validation passed
```

### Connect from Another Pod
```bash
# Connection string
postgresql://hackathon:<password>@postgresql.database.svc.cluster.local:5432/learnflow

# Using psql from within cluster
kubectl run psql-client --rm -it --image=postgres:16-alpine -- \
    psql -h postgresql.database -U hackathon -d learnflow
```

### Port Forward for Local Access
```bash
kubectl port-forward svc/postgresql 5432:5432 -n database

# Then connect locally
psql -h localhost -U hackathon -d learnflow
```

### Create Additional Database
```bash
POD=$(kubectl get pod -l app=postgresql -n database -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -n database -- psql -U hackathon -d learnflow -c "CREATE DATABASE mydb;"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| PVC pending | Check storage class: `kubectl get sc` |
| Pod CrashLoopBackOff | Check logs: `kubectl logs -l app=postgresql -n database` |
| Connection refused | Verify service: `kubectl get svc -n database` |
| Authentication failed | Check secret: `kubectl get secret postgresql-secret -n database -o yaml` |
| Disk full | Increase PVC size or clean old data |

## Related Skills

- `kafka-k8s-setup`: Message broker (often used with PostgreSQL)
- `dapr-k8s-setup`: State store configuration for Dapr
- `fastapi-service`: Backend that connects to PostgreSQL
