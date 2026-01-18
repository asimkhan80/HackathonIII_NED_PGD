---
id: 004
title: PostgreSQL K8s Setup Skill Creation
stage: general
date: 2025-01-18
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: master
user: Asim
command: user-request
labels: ["skills", "postgresql", "kubernetes", "database", "infrastructure"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .claude/skills/postgresql-k8s-setup/SKILL.md
  - .claude/skills/postgresql-k8s-setup/REFERENCE.md
  - .claude/skills/postgresql-k8s-setup/scripts/deploy.sh
  - .claude/skills/postgresql-k8s-setup/scripts/validate.sh
  - .claude/skills/postgresql-k8s-setup/scripts/teardown.sh
  - .claude/skills/postgresql-k8s-setup/manifests/postgresql.yaml
  - .claude/skills/README.md (updated)
tests:
  - Manual validation via ./scripts/validate.sh
---

## Prompt

yes

(User confirmed to continue with the next skill after kafka-k8s-setup)

## Response snapshot

Created the `postgresql-k8s-setup` skill for deploying PostgreSQL 16 on Kubernetes with persistent storage.

**Files Created:**

1. **SKILL.md** (~85 tokens) - Minimal agent instructions:
   - Purpose: Deploy PostgreSQL with persistent storage
   - Usage: Natural language trigger
   - Execution: `./scripts/deploy.sh [namespace] [password]`
   - Validation checklist

2. **REFERENCE.md** - Deep documentation:
   - Architecture diagram (StatefulSet + PVC + Service)
   - Prerequisites and configuration
   - Script details with arguments/exit codes
   - Connection examples and troubleshooting

3. **scripts/deploy.sh** - Main deployment script:
   - Creates namespace
   - Substitutes password in manifest
   - Deploys StatefulSet, Service, PVC, Secret, ConfigMap
   - Waits for pod ready state

4. **scripts/validate.sh** - Verification script:
   - Checks pod status and readiness
   - Verifies PVC bound state
   - Checks service exists
   - Tests database connectivity via pg_isready

5. **scripts/teardown.sh** - Cleanup script:
   - Removes all PostgreSQL resources
   - Optionally removes namespace

6. **manifests/postgresql.yaml** - Kubernetes manifest:
   - Secret for credentials
   - ConfigMap for PGDATA
   - PVC (1Gi storage)
   - StatefulSet with liveness/readiness probes
   - ClusterIP Service

## Outcome

- Impact: Second infrastructure skill, provides database for LearnFlow
- Tests: validate.sh provides deterministic verification including pg_isready
- Files: 6 files created, 1 updated
- Next prompts: Create dapr-k8s-setup skill
- Reflection: Follows same pattern as kafka-k8s-setup; SKILL.md under 100 tokens

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual review PASS
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Test deploy.sh on Minikube with default storage class
