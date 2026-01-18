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
    title="learnflow-backend",
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
