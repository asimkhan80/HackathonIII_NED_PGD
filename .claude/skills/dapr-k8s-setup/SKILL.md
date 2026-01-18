# Skill: dapr-k8s-setup

## Purpose
Install Dapr runtime on Kubernetes with Kafka pub/sub and PostgreSQL state store components.

## Usage
```
Install Dapr on my Kubernetes cluster with Kafka and PostgreSQL
```

## Execution
```bash
./scripts/deploy.sh [namespace]
```

## Inputs
- `namespace`: Dapr system namespace (default: `dapr-system`)

## Outputs
- Success: `SUCCESS: Dapr installed with components`
- Failure: `FAILURE: <error message>`

## Validation
- [ ] `dapr status -k` shows all services running
- [ ] `kubectl get components -A` shows configured components
