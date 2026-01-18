# Reference: fastapi-service

## Overview

This skill generates a production-ready FastAPI backend service with Dapr integration for pub/sub messaging (Kafka) and state management (PostgreSQL). The generated service includes health checks, Kubernetes manifests, and Dockerfile.

**Constitution Compliance:**
- Article III: Minimal SKILL.md (~95 tokens)
- Article IV: Script-based execution, minimal output
- Article V: Uses standard tools (Python, Docker, kubectl)
- Article VI: FastAPI backend requirement

## Prerequisites

- Python 3.11+
- Docker (for building images)
- Kubernetes cluster (for deployment)
- Dapr installed (via `dapr-k8s-setup` skill)
- Kafka deployed (via `kafka-k8s-setup` skill)
- PostgreSQL deployed (via `postgresql-k8s-setup` skill)

## Generated Project Structure

```
<output-dir>/
├── src/
│   ├── __init__.py
│   └── main.py           # FastAPI application
├── tests/
│   ├── __init__.py
│   └── test_main.py      # Basic tests
├── k8s/
│   └── deployment.yaml   # K8s Deployment + Service
├── Dockerfile
└── requirements.txt
```

## Script Details

### generate.sh

**Purpose**: Generate FastAPI project from templates

**Arguments**:
| Arg | Required | Description |
|-----|----------|-------------|
| `$1` | Yes | Service name (lowercase, alphanumeric, hyphens) |
| `$2` | Yes | Output directory |

**Generated Files**:
- `src/main.py`: FastAPI app with Dapr integration
- `requirements.txt`: Python dependencies
- `Dockerfile`: Container build instructions
- `k8s/deployment.yaml`: Kubernetes manifests
- `tests/test_main.py`: Basic health check tests

### deploy.sh

**Purpose**: Build Docker image and deploy to Kubernetes

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | Yes | - | Project directory |
| `$2` | No | `default` | Kubernetes namespace |

**Actions**:
1. Validates project structure
2. Builds Docker image (uses Minikube daemon if available)
3. Deploys to Kubernetes
4. Waits for deployment ready

### validate.sh

**Purpose**: Verify deployed service is healthy

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | Yes | - | Service name |
| `$2` | No | `default` | Kubernetes namespace |

**Checks**:
1. Deployment exists
2. Pod is running
3. Dapr sidecar injected
4. Service exists
5. Health endpoint returns 200

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| POST | `/publish/{topic}` | Publish to Kafka via Dapr |
| GET | `/state/{key}` | Get state from PostgreSQL via Dapr |
| POST | `/state/{key}` | Save state to PostgreSQL via Dapr |
| POST | `/events` | Handle incoming Kafka events |

## Examples

### Generate Service
```bash
./scripts/generate.sh learnflow-backend ./backend
```

### Local Development
```bash
cd ./backend
pip install -r requirements.txt
uvicorn src.main:app --reload --port 8080
```

### Build and Deploy
```bash
./scripts/deploy.sh ./backend default
```

### Validate Deployment
```bash
./scripts/validate.sh learnflow-backend default
```

### Test API Endpoints
```bash
# Health check
curl http://localhost:8080/health

# Publish message (requires Dapr)
curl -X POST http://localhost:8080/publish/events \
  -H "Content-Type: application/json" \
  -d '{"message": "hello"}'

# Save state (requires Dapr)
curl -X POST http://localhost:8080/state/user-123 \
  -H "Content-Type: application/json" \
  -d '{"name": "John"}'

# Get state (requires Dapr)
curl http://localhost:8080/state/user-123
```

### Run Tests
```bash
cd ./backend
pip install pytest
pytest tests/
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_PORT` | `8080` | Application port |
| `DAPR_HTTP_PORT` | `3500` | Dapr sidecar port |
| `PUBSUB_NAME` | `kafka-pubsub` | Dapr pub/sub component name |
| `STATESTORE_NAME` | `statestore` | Dapr state store component name |

## Kubernetes Annotations

The generated deployment includes Dapr annotations:

```yaml
annotations:
  dapr.io/enabled: "true"
  dapr.io/app-id: "<service-name>"
  dapr.io/app-port: "8080"
  dapr.io/enable-api-logging: "true"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Dapr sidecar not injected | Verify `dapr-k8s-setup` deployed, check namespace |
| Pub/sub error | Verify Kafka is running, check component scopes |
| State store error | Verify PostgreSQL is running, check connection string |
| Image pull error | Use `imagePullPolicy: IfNotPresent` for local images |
| Health check failing | Check container logs: `kubectl logs -l app=<name>` |

## Related Skills

- `kafka-k8s-setup`: Required for pub/sub functionality
- `postgresql-k8s-setup`: Required for state store functionality
- `dapr-k8s-setup`: Required for Dapr sidecar injection
- `nextjs-frontend`: Frontend that calls this backend
