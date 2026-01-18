---
id: 006
title: FastAPI Service Skill Creation
stage: general
date: 2025-01-18
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: master
user: Asim
command: user-request
labels: ["skills", "fastapi", "python", "backend", "dapr"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .claude/skills/fastapi-service/SKILL.md
  - .claude/skills/fastapi-service/REFERENCE.md
  - .claude/skills/fastapi-service/scripts/generate.sh
  - .claude/skills/fastapi-service/scripts/deploy.sh
  - .claude/skills/fastapi-service/scripts/validate.sh
  - .claude/skills/README.md (updated)
tests:
  - Generated tests in tests/test_main.py
  - Manual validation via ./scripts/validate.sh
---

## Prompt

(Continued from dapr-k8s-setup, proceeding to application layer skills)

## Response snapshot

Created the `fastapi-service` skill for generating Dapr-enabled FastAPI backend services.

**Files Created:**

1. **SKILL.md** (~95 tokens) - Minimal agent instructions:
   - Purpose: Generate FastAPI service with Dapr integration
   - Usage: Natural language trigger
   - Execution: `./scripts/generate.sh <name> <dir>`
   - Validation checklist

2. **REFERENCE.md** - Deep documentation:
   - Generated project structure
   - API endpoints (health, pub/sub, state)
   - Environment variables
   - Kubernetes annotations for Dapr
   - Troubleshooting guide

3. **scripts/generate.sh** - Project generator:
   - Creates project structure (src/, tests/, k8s/)
   - Generates main.py with Dapr integration
   - Generates requirements.txt (FastAPI, Dapr SDK)
   - Generates Dockerfile
   - Generates K8s deployment + service manifests
   - Generates basic tests

4. **scripts/deploy.sh** - Build and deploy:
   - Builds Docker image (uses Minikube daemon if available)
   - Deploys to Kubernetes
   - Waits for deployment ready

5. **scripts/validate.sh** - Verification:
   - Checks deployment exists
   - Checks pod running
   - Checks Dapr sidecar (if Dapr installed)
   - Checks health endpoint returns 200

## Outcome

- Impact: First application-layer skill, generates backend services
- Tests: Generated tests + validate.sh for deployment verification
- Files: 5 files created, 1 updated
- Next prompts: Create nextjs-frontend skill
- Reflection: Generator creates fully functional service with Dapr integration

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual review PASS
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Generate actual LearnFlow backend service
