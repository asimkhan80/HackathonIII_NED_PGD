# Skill: kafka-k8s-setup

## Purpose
Deploy Apache Kafka with Zookeeper on Kubernetes using Strimzi operator.

## Usage
```
Deploy Kafka on my Kubernetes cluster
```

## Execution
```bash
./scripts/deploy.sh [namespace]
```

## Inputs
- `namespace`: Kubernetes namespace (default: `kafka`)

## Outputs
- Success: `SUCCESS: Kafka deployed to <namespace>`
- Failure: `FAILURE: <error message>`

## Validation
- [ ] `kubectl get pods -n kafka` shows running pods
- [ ] `kubectl get kafka -n kafka` shows Ready state
