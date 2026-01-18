# Skill: nextjs-frontend

## Purpose
Generate a Next.js frontend application with API integration for the LearnFlow backend.

## Usage
```
Create a Next.js frontend for LearnFlow
```

## Execution
```bash
./scripts/generate.sh <app-name> <output-dir> [backend-url]
```

## Inputs
- `app-name`: Name of the app (e.g., `learnflow-frontend`)
- `output-dir`: Directory to generate project
- `backend-url`: Backend API URL (default: `http://localhost:8080`)

## Outputs
- Success: `SUCCESS: Next.js app generated at <path>`
- Failure: `FAILURE: <error message>`

## Validation
- [ ] `cd <output-dir> && npm install`
- [ ] `npm run dev` starts successfully
