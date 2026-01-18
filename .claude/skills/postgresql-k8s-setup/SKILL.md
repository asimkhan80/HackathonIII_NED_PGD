# Skill: postgresql-k8s-setup

## Purpose
Deploy PostgreSQL database on Kubernetes with persistent storage.

## Usage
```
Deploy PostgreSQL on my Kubernetes cluster
```

## Execution
```bash
./scripts/deploy.sh [namespace] [password]
```

## Inputs
- `namespace`: Kubernetes namespace (default: `database`)
- `password`: PostgreSQL password (default: auto-generated)

## Outputs
- Success: `SUCCESS: PostgreSQL deployed to <namespace>`
- Failure: `FAILURE: <error message>`

## Validation
- [ ] `kubectl get pods -n database` shows running pod
- [ ] `kubectl get pvc -n database` shows bound PVC
