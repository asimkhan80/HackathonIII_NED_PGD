---
id: 005
title: Dapr K8s Setup Skill Creation
stage: general
date: 2025-01-18
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: master
user: Asim
command: user-request
labels: ["skills", "dapr", "kubernetes", "pubsub", "statestore", "infrastructure"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .claude/skills/dapr-k8s-setup/SKILL.md
  - .claude/skills/dapr-k8s-setup/REFERENCE.md
  - .claude/skills/dapr-k8s-setup/scripts/deploy.sh
  - .claude/skills/dapr-k8s-setup/scripts/validate.sh
  - .claude/skills/dapr-k8s-setup/scripts/teardown.sh
  - .claude/skills/dapr-k8s-setup/components/kafka-pubsub.yaml
  - .claude/skills/dapr-k8s-setup/components/postgresql-statestore.yaml
  - .claude/skills/README.md (updated)
tests:
  - Manual validation via ./scripts/validate.sh
  - dapr status -k
---

## Prompt

(Continued from postgresql-k8s-setup, proceeding to next infrastructure skill)

## Response snapshot

Created the `dapr-k8s-setup` skill for installing Dapr runtime on Kubernetes with pre-configured building block components.

**Files Created:**

1. **SKILL.md** (~90 tokens) - Minimal agent instructions:
   - Purpose: Install Dapr with Kafka pub/sub and PostgreSQL state store
   - Usage: Natural language trigger
   - Execution: `./scripts/deploy.sh [namespace]`
   - Validation via dapr status -k

2. **REFERENCE.md** - Deep documentation:
   - Architecture diagram showing control plane and components
   - Component configurations (kafka-pubsub, statestore)
   - Usage examples with Dapr SDK (Python)
   - Troubleshooting guide

3. **scripts/deploy.sh** - Main deployment script:
   - Installs Dapr CLI if not present
   - Initializes Dapr on Kubernetes (v1.12)
   - Waits for control plane ready
   - Auto-detects and configures Kafka/PostgreSQL components

4. **scripts/validate.sh** - Verification script:
   - Checks Dapr CLI availability
   - Verifies control plane pods (≥4)
   - Checks sidecar injector ready
   - Counts configured components

5. **scripts/teardown.sh** - Cleanup script:
   - Removes Dapr components
   - Uninstalls Dapr from Kubernetes
   - Waits for namespace deletion

6. **components/kafka-pubsub.yaml** - Kafka pub/sub component:
   - Connects to hackathon-kafka-kafka-bootstrap.kafka:9092
   - Consumer group: learnflow-group
   - Scoped to learnflow-backend, learnflow-worker

7. **components/postgresql-statestore.yaml** - State store component:
   - Connects to postgresql.database:5432
   - Table: dapr_state
   - Scoped to learnflow-backend

## Outcome

- Impact: Third infrastructure skill, enables microservice communication patterns
- Tests: validate.sh + dapr status -k for verification
- Files: 7 files created, 1 updated
- Next prompts: Create fastapi-service skill for backend
- Reflection: Components auto-detect existing Kafka/PostgreSQL deployments

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual review PASS
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Test full stack (Kafka + PostgreSQL + Dapr) on Minikube
