#!/bin/bash
# fastapi-service - Generate FastAPI service with Dapr integration
# Usage: ./generate.sh <service-name> <output-dir>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

SERVICE_NAME="${1:-}"
OUTPUT_DIR="${2:-}"

# --- Functions ---
log() { echo "[fastapi-service] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

validate_inputs() {
    [[ -n "$SERVICE_NAME" ]] || error "Service name required"
    [[ -n "$OUTPUT_DIR" ]] || error "Output directory required"
    [[ "$SERVICE_NAME" =~ ^[a-z][a-z0-9-]*$ ]] || error "Invalid service name (use lowercase, alphanumeric, hyphens)"
}

create_project_structure() {
    log "Creating project structure at $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"/{src,tests,k8s}
}

generate_main_app() {
    log "Generating main.py"
    cat > "$OUTPUT_DIR/src/main.py" << 'PYEOF'
"""FastAPI application with Dapr integration."""
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dapr.clients import DaprClient
import uvicorn

# Configuration
APP_PORT = int(os.getenv("APP_PORT", "8080"))
DAPR_HTTP_PORT = int(os.getenv("DAPR_HTTP_PORT", "3500"))
PUBSUB_NAME = os.getenv("PUBSUB_NAME", "kafka-pubsub")
STATESTORE_NAME = os.getenv("STATESTORE_NAME", "statestore")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    yield


app = FastAPI(
    title="${SERVICE_NAME}",
    description="Dapr-enabled FastAPI service",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


@app.get("/ready")
async def readiness_check():
    """Readiness check endpoint."""
    return {"status": "ready"}


@app.post("/publish/{topic}")
async def publish_message(topic: str, message: dict):
    """Publish message to Kafka via Dapr."""
    try:
        with DaprClient() as client:
            client.publish_event(
                pubsub_name=PUBSUB_NAME,
                topic_name=topic,
                data=message,
                data_content_type="application/json",
            )
        return {"status": "published", "topic": topic}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/state/{key}")
async def get_state(key: str):
    """Get state from PostgreSQL via Dapr."""
    try:
        with DaprClient() as client:
            state = client.get_state(store_name=STATESTORE_NAME, key=key)
            if state.data:
                return {"key": key, "value": state.data.decode()}
            return {"key": key, "value": None}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/state/{key}")
async def save_state(key: str, value: dict):
    """Save state to PostgreSQL via Dapr."""
    try:
        with DaprClient() as client:
            client.save_state(
                store_name=STATESTORE_NAME,
                key=key,
                value=str(value),
            )
        return {"status": "saved", "key": key}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/dapr/subscribe")
async def subscribe():
    """Dapr subscription configuration."""
    return [
        {
            "pubsubname": PUBSUB_NAME,
            "topic": "events",
            "route": "/events",
        }
    ]


@app.post("/events")
async def handle_event(event: dict):
    """Handle incoming Kafka events."""
    print(f"Received event: {event}")
    return {"status": "processed"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
PYEOF
    # Replace placeholder
    sed -i "s/\${SERVICE_NAME}/$SERVICE_NAME/g" "$OUTPUT_DIR/src/main.py" 2>/dev/null || \
        sed "s/\${SERVICE_NAME}/$SERVICE_NAME/g" "$OUTPUT_DIR/src/main.py" > "$OUTPUT_DIR/src/main.py.tmp" && \
        mv "$OUTPUT_DIR/src/main.py.tmp" "$OUTPUT_DIR/src/main.py"
}

generate_requirements() {
    log "Generating requirements.txt"
    cat > "$OUTPUT_DIR/requirements.txt" << 'EOF'
fastapi>=0.109.0
uvicorn[standard]>=0.27.0
dapr>=1.12.0
dapr-ext-fastapi>=1.12.0
pydantic>=2.5.0
python-multipart>=0.0.6
httpx>=0.26.0
EOF
}

generate_dockerfile() {
    log "Generating Dockerfile"
    cat > "$OUTPUT_DIR/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY src/ ./src/

# Expose port
EXPOSE 8080

# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
EOF
}

generate_k8s_manifests() {
    log "Generating Kubernetes manifests"
    cat > "$OUTPUT_DIR/k8s/deployment.yaml" << YAMLEOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $SERVICE_NAME
  labels:
    app: $SERVICE_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $SERVICE_NAME
  template:
    metadata:
      labels:
        app: $SERVICE_NAME
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "$SERVICE_NAME"
        dapr.io/app-port: "8080"
        dapr.io/enable-api-logging: "true"
    spec:
      containers:
        - name: $SERVICE_NAME
          image: $SERVICE_NAME:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          env:
            - name: APP_PORT
              value: "8080"
            - name: PUBSUB_NAME
              value: "kafka-pubsub"
            - name: STATESTORE_NAME
              value: "statestore"
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            requests:
              memory: 128Mi
              cpu: 100m
            limits:
              memory: 256Mi
              cpu: 500m
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: $SERVICE_NAME
YAMLEOF
}

generate_tests() {
    log "Generating tests"
    cat > "$OUTPUT_DIR/tests/__init__.py" << 'EOF'
EOF
    cat > "$OUTPUT_DIR/tests/test_main.py" << 'EOF'
"""Tests for FastAPI application."""
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_ready():
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json()["status"] == "ready"
EOF
}

generate_init() {
    log "Generating __init__.py"
    touch "$OUTPUT_DIR/src/__init__.py"
}

# --- Main ---
main() {
    validate_inputs
    create_project_structure
    generate_main_app
    generate_requirements
    generate_dockerfile
    generate_k8s_manifests
    generate_tests
    generate_init

    echo "SUCCESS: FastAPI service generated at $OUTPUT_DIR"
    echo "  Service: $SERVICE_NAME"
    echo "  Next steps:"
    echo "    cd $OUTPUT_DIR"
    echo "    pip install -r requirements.txt"
    echo "    uvicorn src.main:app --reload"
}

trap 'error "Generation failed at line $LINENO"' ERR
main
