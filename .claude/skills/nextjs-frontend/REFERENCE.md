# Reference: nextjs-frontend

## Overview

This skill generates a production-ready Next.js 14 frontend application with TypeScript, configured to connect to the FastAPI backend service. The generated app includes Kubernetes manifests for cloud-native deployment.

**Constitution Compliance:**
- Article III: Minimal SKILL.md (~95 tokens)
- Article IV: Script-based execution, minimal output
- Article V: Uses standard tools (Node.js, Docker, kubectl)
- Article VI: Next.js frontend requirement

## Prerequisites

- Node.js 20+
- npm or yarn
- Docker (for building images)
- Kubernetes cluster (for deployment)
- Backend service deployed (via `fastapi-service` skill)

## Generated Project Structure

```
<output-dir>/
├── src/
│   ├── app/
│   │   ├── layout.tsx      # Root layout
│   │   ├── page.tsx        # Home page
│   │   └── globals.css     # Global styles
│   ├── components/         # Reusable components
│   └── lib/
│       └── api.ts          # API client functions
├── k8s/
│   └── deployment.yaml     # K8s Deployment + Service
├── public/                 # Static assets
├── Dockerfile              # Multi-stage build
├── next.config.js          # Next.js configuration
├── tsconfig.json           # TypeScript config
├── package.json
├── .env.example
└── .gitignore
```

## Script Details

### generate.sh

**Purpose**: Generate Next.js project from templates

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | Yes | - | App name (lowercase, alphanumeric, hyphens) |
| `$2` | Yes | - | Output directory |
| `$3` | No | `http://localhost:8080` | Backend API URL |

**Generated Files**:
- `src/app/`: App router pages and layouts
- `src/lib/api.ts`: API client with typed functions
- `Dockerfile`: Multi-stage production build
- `k8s/deployment.yaml`: Kubernetes manifests
- Configuration files (tsconfig, next.config, etc.)

### deploy.sh

**Purpose**: Build Docker image and deploy to Kubernetes

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | Yes | - | Project directory |
| `$2` | No | `default` | Kubernetes namespace |

### validate.sh

**Purpose**: Verify deployed app is running

**Arguments**:
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| `$1` | Yes | - | App name |
| `$2` | No | `default` | Kubernetes namespace |

## Features

### Home Page
- Displays backend health status
- Shows connection to API URL
- Feature cards for Kafka, PostgreSQL, Kubernetes

### API Client (`src/lib/api.ts`)
- `checkHealth()`: Health check endpoint
- `publishMessage(topic, message)`: Publish to Kafka via Dapr
- `getState(key)`: Get state from PostgreSQL via Dapr
- `saveState(key, value)`: Save state to PostgreSQL via Dapr

## Examples

### Generate App
```bash
./scripts/generate.sh learnflow-frontend ./frontend http://localhost:8080
```

### Local Development
```bash
cd ./frontend
npm install
npm run dev
# Open http://localhost:3000
```

### Build and Deploy
```bash
./scripts/deploy.sh ./frontend default
```

### Validate Deployment
```bash
./scripts/validate.sh learnflow-frontend default
```

### Access in Cluster
```bash
# Port forward
kubectl port-forward svc/learnflow-frontend 3000:80 -n default

# Or expose via ingress
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:8080` | Backend API URL |

## Kubernetes Configuration

The generated deployment:
- Uses standalone output mode for optimal container size
- Includes liveness and readiness probes
- Configures API URL via environment variable
- Sets appropriate resource limits

```yaml
env:
  - name: NEXT_PUBLIC_API_URL
    value: "http://learnflow-backend"
```

## Docker Build

Multi-stage build for production:
1. **deps**: Install dependencies
2. **builder**: Build Next.js application
3. **runner**: Minimal production image

Final image size: ~100MB (Alpine-based)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Check Node.js version (requires 20+) |
| API connection error | Verify backend URL and CORS settings |
| Image too large | Ensure using standalone output mode |
| Pod OOMKilled | Increase memory limits in deployment |
| Static assets missing | Check COPY commands in Dockerfile |

## Related Skills

- `fastapi-service`: Backend service this frontend connects to
- `kafka-k8s-setup`: Messaging infrastructure
- `postgresql-k8s-setup`: Database infrastructure
- `dapr-k8s-setup`: Service mesh for backend
