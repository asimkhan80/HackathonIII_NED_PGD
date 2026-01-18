---
id: 007
title: Next.js Frontend Skill Creation
stage: general
date: 2025-01-18
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: master
user: Asim
command: user-request
labels: ["skills", "nextjs", "frontend", "react", "typescript"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .claude/skills/nextjs-frontend/SKILL.md
  - .claude/skills/nextjs-frontend/REFERENCE.md
  - .claude/skills/nextjs-frontend/scripts/generate.sh
  - .claude/skills/nextjs-frontend/scripts/deploy.sh
  - .claude/skills/nextjs-frontend/scripts/validate.sh
  - .claude/skills/README.md (updated)
tests:
  - Manual validation via ./scripts/validate.sh
  - npm run dev starts successfully
---

## Prompt

(Continued from fastapi-service, completing Article VI stack)

## Response snapshot

Created the `nextjs-frontend` skill for generating Next.js 14 frontend applications with TypeScript.

**Files Created:**

1. **SKILL.md** (~95 tokens) - Minimal agent instructions:
   - Purpose: Generate Next.js frontend with backend integration
   - Usage: Natural language trigger
   - Execution: `./scripts/generate.sh <name> <dir> [backend-url]`
   - Validation checklist

2. **REFERENCE.md** - Deep documentation:
   - Generated project structure
   - API client functions
   - Docker multi-stage build
   - Kubernetes deployment
   - Troubleshooting guide

3. **scripts/generate.sh** - Project generator:
   - Creates Next.js 14 App Router structure
   - Generates TypeScript configuration
   - Creates home page with backend health check
   - Generates API client library (api.ts)
   - Creates multi-stage Dockerfile
   - Generates K8s deployment manifests

4. **scripts/deploy.sh** - Build and deploy:
   - Builds Docker image (uses Minikube daemon if available)
   - Deploys to Kubernetes
   - Waits for deployment ready

5. **scripts/validate.sh** - Verification:
   - Checks deployment exists
   - Checks pod running
   - Checks service exists
   - Verifies app responds

## Outcome

- Impact: Final Article VI component, completes full-stack skills
- Tests: validate.sh + npm run dev for verification
- Files: 5 files created, 1 updated
- Next prompts: Test full stack deployment, create LearnFlow application
- Reflection: Generator creates production-ready Next.js 14 with standalone output

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual review PASS
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Generate LearnFlow frontend and test with backend
