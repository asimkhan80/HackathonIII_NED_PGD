"""
LearnFlow - AI-Powered Learning Platform Demo
Hackathon III: Reusable Intelligence and Cloud-Native Mastery

This Gradio app demonstrates the LearnFlow architecture built with:
- Kubernetes (Kind cluster)
- Apache Kafka (Strimzi with KRaft)
- PostgreSQL (State Store)
- Dapr (Pub/Sub & State Management)
- FastAPI (Backend)
- Next.js (Frontend)
"""

import gradio as gr
import json
from datetime import datetime
import random

# Simulated state store (in production, this is PostgreSQL via Dapr)
state_store = {}

# Simulated message queue (in production, this is Kafka via Dapr)
message_queue = []

def save_state(key: str, value: str) -> str:
    """Simulate Dapr state store save operation."""
    if not key or not value:
        return "Error: Key and value are required"

    state_store[key] = {
        "value": value,
        "timestamp": datetime.now().isoformat(),
        "version": state_store.get(key, {}).get("version", 0) + 1
    }

    return f"""State Saved Successfully!

Key: {key}
Value: {value}
Timestamp: {state_store[key]['timestamp']}
Version: {state_store[key]['version']}

In Production:
- Dapr sidecar receives the request
- State is persisted to PostgreSQL
- Automatic key prefixing applied
"""

def get_state(key: str) -> str:
    """Simulate Dapr state store get operation."""
    if not key:
        return "Error: Key is required"

    if key in state_store:
        data = state_store[key]
        return f"""State Retrieved!

Key: {key}
Value: {data['value']}
Timestamp: {data['timestamp']}
Version: {data['version']}

In Production:
- Dapr queries PostgreSQL
- Automatic deserialization
- Consistent read guarantee
"""
    return f"Key '{key}' not found in state store"

def list_states() -> str:
    """List all stored states."""
    if not state_store:
        return "State store is empty"

    result = "Current State Store Contents:\n" + "="*40 + "\n\n"
    for key, data in state_store.items():
        result += f"Key: {key}\n"
        result += f"  Value: {data['value']}\n"
        result += f"  Version: {data['version']}\n"
        result += f"  Updated: {data['timestamp']}\n\n"
    return result

def publish_message(topic: str, message: str) -> str:
    """Simulate Kafka pub/sub publish operation."""
    if not topic or not message:
        return "Error: Topic and message are required"

    event = {
        "id": f"evt-{random.randint(1000, 9999)}",
        "topic": topic,
        "message": message,
        "timestamp": datetime.now().isoformat(),
        "source": "learnflow-demo"
    }
    message_queue.append(event)

    return f"""Message Published to Kafka!

Event ID: {event['id']}
Topic: {topic}
Message: {message}
Timestamp: {event['timestamp']}

In Production:
- Dapr publishes to Kafka via Strimzi
- KRaft consensus ensures durability
- Consumer groups handle distribution
"""

def view_messages() -> str:
    """View published messages."""
    if not message_queue:
        return "No messages in queue"

    result = "Message Queue (Recent Events):\n" + "="*40 + "\n\n"
    for event in message_queue[-10:]:  # Show last 10
        result += f"Event: {event['id']}\n"
        result += f"  Topic: {event['topic']}\n"
        result += f"  Message: {event['message']}\n"
        result += f"  Time: {event['timestamp']}\n\n"
    return result

def get_architecture() -> str:
    """Return architecture description."""
    return """
LearnFlow Cloud-Native Architecture
====================================

                    +------------------+
                    |   Next.js 14     |
                    |   Frontend       |
                    |   (Port 30080)   |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    |   FastAPI        |
                    |   Backend        |
                    |   (Port 30081)   |
                    +--------+---------+
                             |
              +--------------+--------------+
              |                             |
              v                             v
    +------------------+          +------------------+
    |   Dapr Sidecar   |          |   Dapr Sidecar   |
    |   (Pub/Sub)      |          |   (State Store)  |
    +--------+---------+          +--------+---------+
             |                             |
             v                             v
    +------------------+          +------------------+
    |   Apache Kafka   |          |   PostgreSQL     |
    |   (Strimzi/KRaft)|          |   (StatefulSet)  |
    |   Namespace:kafka|          |  Namespace:database
    +------------------+          +------------------+


Infrastructure Layer (Kubernetes - Kind Cluster)
================================================
- Control Plane: learnflow-control-plane
- Namespaces: default, kafka, database, dapr-system
- Port Mappings: 30080 (frontend), 30081 (backend)

Key Technologies:
- Strimzi Operator v4.0.0 with KRaft (No Zookeeper)
- Dapr Runtime v1.16 for service mesh
- PostgreSQL 15 for persistent state
- Next.js 14 with standalone output
- FastAPI with async Dapr client
"""

def get_skills_info() -> str:
    """Return information about reusable skills."""
    return """
Reusable Skills Library
=======================

This project demonstrates Agent-First Development where AI agents
generate all infrastructure and application code using reusable Skills.

Available Skills:
-----------------

1. kafka-k8s-setup
   - Deploys Strimzi Kafka Operator
   - Creates Kafka cluster with KRaft mode
   - Configures topics and listeners

2. postgresql-k8s-setup
   - Deploys PostgreSQL StatefulSet
   - Creates secrets and persistent volumes
   - Initializes database schema

3. dapr-k8s-setup
   - Installs Dapr runtime via Helm
   - Configures Kafka pub/sub component
   - Sets up PostgreSQL state store

4. fastapi-service
   - Generates Dapr-enabled FastAPI backend
   - Includes health/ready endpoints
   - Pub/sub and state store integration

5. nextjs-frontend
   - Creates Next.js 14 application
   - Standalone Docker build
   - API client integration

Agent-First Development Mandate:
--------------------------------
"All code changes must be made by an AI agent through skills.
 Human involvement is limited to intent and verification."

 - Article II, Hackathon III Constitution
"""

# Create the Gradio interface
with gr.Blocks(title="LearnFlow Demo", theme=gr.themes.Soft()) as demo:
    gr.Markdown("""
    # LearnFlow - AI-Powered Learning Platform

    **Hackathon III: Reusable Intelligence and Cloud-Native Mastery**

    This demo showcases the LearnFlow architecture built with Kubernetes, Kafka, PostgreSQL, and Dapr.
    All infrastructure and application code was generated by AI agents using reusable Skills.

    [GitHub Repository](https://github.com/asimkhan80/HackathonIII_NED_PGD)
    """)

    with gr.Tabs():
        # Architecture Tab
        with gr.Tab("Architecture"):
            gr.Markdown("### Cloud-Native Architecture Overview")
            arch_output = gr.Code(value=get_architecture(), language=None, label="System Architecture")

        # State Store Tab
        with gr.Tab("State Store (PostgreSQL)"):
            gr.Markdown("### Dapr State Management with PostgreSQL")
            gr.Markdown("Simulate saving and retrieving state via Dapr's state store API.")

            with gr.Row():
                with gr.Column():
                    state_key = gr.Textbox(label="Key", placeholder="user-preference")
                    state_value = gr.Textbox(label="Value", placeholder="dark-mode")
                    with gr.Row():
                        save_btn = gr.Button("Save State", variant="primary")
                        get_btn = gr.Button("Get State")
                        list_btn = gr.Button("List All")

                with gr.Column():
                    state_output = gr.Textbox(label="Result", lines=12)

            save_btn.click(save_state, inputs=[state_key, state_value], outputs=state_output)
            get_btn.click(get_state, inputs=[state_key], outputs=state_output)
            list_btn.click(list_states, outputs=state_output)

        # Pub/Sub Tab
        with gr.Tab("Pub/Sub (Kafka)"):
            gr.Markdown("### Dapr Pub/Sub with Apache Kafka")
            gr.Markdown("Simulate publishing messages to Kafka topics via Dapr.")

            with gr.Row():
                with gr.Column():
                    topic = gr.Textbox(label="Topic", placeholder="learning-events")
                    message = gr.Textbox(label="Message", placeholder="User completed lesson 1", lines=3)
                    with gr.Row():
                        publish_btn = gr.Button("Publish Message", variant="primary")
                        view_btn = gr.Button("View Queue")

                with gr.Column():
                    pubsub_output = gr.Textbox(label="Result", lines=12)

            publish_btn.click(publish_message, inputs=[topic, message], outputs=pubsub_output)
            view_btn.click(view_messages, outputs=pubsub_output)

        # Skills Tab
        with gr.Tab("Reusable Skills"):
            gr.Markdown("### Agent-First Development with Reusable Skills")
            skills_output = gr.Code(value=get_skills_info(), language=None, label="Skills Library")

        # API Reference Tab
        with gr.Tab("API Reference"):
            gr.Markdown("""
            ### LearnFlow Backend API

            When running locally, the API is available at `http://localhost:30081`

            #### Endpoints

            | Method | Endpoint | Description |
            |--------|----------|-------------|
            | GET | `/health` | Health check |
            | GET | `/ready` | Readiness check |
            | POST | `/publish/{topic}` | Publish to Kafka |
            | GET | `/state/{key}` | Get state value |
            | POST | `/state/{key}` | Save state value |
            | POST | `/events` | Handle Kafka events |

            #### Example Usage

            ```bash
            # Health check
            curl http://localhost:30081/health

            # Save state
            curl -X POST http://localhost:30081/state/user1 \\
              -H "Content-Type: application/json" \\
              -d '{"value": "premium"}'

            # Get state
            curl http://localhost:30081/state/user1
            ```
            """)

    gr.Markdown("""
    ---
    **Built with:** Kubernetes | Apache Kafka | PostgreSQL | Dapr | FastAPI | Next.js

    **Agent-First Development** - All code generated by AI agents using reusable Skills
    """)

if __name__ == "__main__":
    demo.launch()
