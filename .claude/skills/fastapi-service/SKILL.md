# Skill: fastapi-service

## Purpose
Generate a Dapr-enabled FastAPI backend service with Kafka pub/sub and PostgreSQL integration.

## Usage
```
Create a FastAPI backend service for LearnFlow
```

## Execution
```bash
./scripts/generate.sh <service-name> <output-dir>
```

## Inputs
- `service-name`: Name of the service (e.g., `learnflow-backend`)
- `output-dir`: Directory to generate project (e.g., `./backend`)

## Outputs
- Success: `SUCCESS: FastAPI service generated at <path>`
- Failure: `FAILURE: <error message>`

## Validation
- [ ] `cd <output-dir> && pip install -r requirements.txt`
- [ ] `uvicorn main:app --reload` starts successfully
