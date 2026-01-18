#!/bin/bash
# nextjs-frontend - Generate Next.js frontend application
# Usage: ./generate.sh <app-name> <output-dir> [backend-url]

set -euo pipefail

APP_NAME="${1:-}"
OUTPUT_DIR="${2:-}"
BACKEND_URL="${3:-http://localhost:8080}"

# --- Functions ---
log() { echo "[nextjs-frontend] $1"; }
error() { echo "FAILURE: $1" >&2; exit 1; }

validate_inputs() {
    [[ -n "$APP_NAME" ]] || error "App name required"
    [[ -n "$OUTPUT_DIR" ]] || error "Output directory required"
    [[ "$APP_NAME" =~ ^[a-z][a-z0-9-]*$ ]] || error "Invalid app name"
}

create_project_structure() {
    log "Creating project structure at $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"/{src/{app,components,lib},k8s,public}
}

generate_package_json() {
    log "Generating package.json"
    cat > "$OUTPUT_DIR/package.json" << JSONEOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.1.0",
    "react": "^18",
    "react-dom": "^18"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "eslint": "^8",
    "eslint-config-next": "14.1.0",
    "typescript": "^5"
  }
}
JSONEOF
}

generate_next_config() {
    log "Generating next.config.js"
    cat > "$OUTPUT_DIR/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080',
  },
}

module.exports = nextConfig
EOF
}

generate_tsconfig() {
    log "Generating tsconfig.json"
    cat > "$OUTPUT_DIR/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF
}

generate_layout() {
    log "Generating layout.tsx"
    cat > "$OUTPUT_DIR/src/app/layout.tsx" << 'EOF'
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'LearnFlow',
  description: 'AI-Powered Learning Platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOF
}

generate_globals_css() {
    log "Generating globals.css"
    cat > "$OUTPUT_DIR/src/app/globals.css" << 'EOF'
* {
  box-sizing: border-box;
  padding: 0;
  margin: 0;
}

html, body {
  max-width: 100vw;
  overflow-x: hidden;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

body {
  background: linear-gradient(to bottom right, #1a1a2e, #16213e);
  color: #ffffff;
  min-height: 100vh;
}

a {
  color: inherit;
  text-decoration: none;
}
EOF
}

generate_page() {
    log "Generating page.tsx"
    cat > "$OUTPUT_DIR/src/app/page.tsx" << 'EOF'
'use client'

import { useState, useEffect } from 'react'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'

export default function Home() {
  const [status, setStatus] = useState<string>('checking...')
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    checkBackendHealth()
  }, [])

  const checkBackendHealth = async () => {
    try {
      const res = await fetch(`${API_URL}/health`)
      if (res.ok) {
        const data = await res.json()
        setStatus(data.status)
      } else {
        setError(`Backend returned ${res.status}`)
      }
    } catch (err) {
      setError('Cannot connect to backend')
    }
  }

  return (
    <main style={{ padding: '2rem', maxWidth: '800px', margin: '0 auto' }}>
      <h1 style={{ fontSize: '3rem', marginBottom: '1rem' }}>
        LearnFlow
      </h1>
      <p style={{ fontSize: '1.25rem', color: '#a0a0a0', marginBottom: '2rem' }}>
        AI-Powered Learning Platform
      </p>

      <div style={{
        background: 'rgba(255,255,255,0.1)',
        padding: '1.5rem',
        borderRadius: '8px',
        marginBottom: '2rem'
      }}>
        <h2 style={{ marginBottom: '1rem' }}>Backend Status</h2>
        {error ? (
          <p style={{ color: '#ff6b6b' }}>{error}</p>
        ) : (
          <p style={{ color: '#51cf66' }}>Status: {status}</p>
        )}
        <p style={{ fontSize: '0.875rem', color: '#666', marginTop: '0.5rem' }}>
          API: {API_URL}
        </p>
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
        gap: '1rem'
      }}>
        <FeatureCard
          title="Kafka Pub/Sub"
          description="Real-time messaging via Dapr"
        />
        <FeatureCard
          title="PostgreSQL State"
          description="Persistent state management"
        />
        <FeatureCard
          title="Kubernetes"
          description="Cloud-native deployment"
        />
      </div>
    </main>
  )
}

function FeatureCard({ title, description }: { title: string; description: string }) {
  return (
    <div style={{
      background: 'rgba(255,255,255,0.05)',
      padding: '1rem',
      borderRadius: '8px',
      border: '1px solid rgba(255,255,255,0.1)'
    }}>
      <h3 style={{ marginBottom: '0.5rem' }}>{title}</h3>
      <p style={{ fontSize: '0.875rem', color: '#a0a0a0' }}>{description}</p>
    </div>
  )
}
EOF
}

generate_api_lib() {
    log "Generating API library"
    cat > "$OUTPUT_DIR/src/lib/api.ts" << 'EOF'
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'

export async function checkHealth(): Promise<{ status: string }> {
  const res = await fetch(`${API_URL}/health`)
  return res.json()
}

export async function publishMessage(topic: string, message: object): Promise<void> {
  await fetch(`${API_URL}/publish/${topic}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(message),
  })
}

export async function getState(key: string): Promise<{ key: string; value: string | null }> {
  const res = await fetch(`${API_URL}/state/${key}`)
  return res.json()
}

export async function saveState(key: string, value: object): Promise<void> {
  await fetch(`${API_URL}/state/${key}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(value),
  })
}
EOF
}

generate_dockerfile() {
    log "Generating Dockerfile"
    cat > "$OUTPUT_DIR/Dockerfile" << 'EOF'
FROM node:20-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
EOF
}

generate_k8s_manifests() {
    log "Generating Kubernetes manifests"
    cat > "$OUTPUT_DIR/k8s/deployment.yaml" << YAMLEOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  labels:
    app: $APP_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
        - name: $APP_NAME
          image: $APP_NAME:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
          env:
            - name: NEXT_PUBLIC_API_URL
              value: "http://learnflow-backend"
          livenessProbe:
            httpGet:
              path: /
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: 3000
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
  name: $APP_NAME
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 3000
  selector:
    app: $APP_NAME
YAMLEOF
}

generate_env_example() {
    log "Generating .env.example"
    cat > "$OUTPUT_DIR/.env.example" << EOF
NEXT_PUBLIC_API_URL=$BACKEND_URL
EOF
}

generate_gitignore() {
    log "Generating .gitignore"
    cat > "$OUTPUT_DIR/.gitignore" << 'EOF'
# dependencies
/node_modules

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*

# local env files
.env*.local
.env

# typescript
*.tsbuildinfo
next-env.d.ts
EOF
}

# --- Main ---
main() {
    validate_inputs
    create_project_structure
    generate_package_json
    generate_next_config
    generate_tsconfig
    generate_layout
    generate_globals_css
    generate_page
    generate_api_lib
    generate_dockerfile
    generate_k8s_manifests
    generate_env_example
    generate_gitignore

    echo "SUCCESS: Next.js app generated at $OUTPUT_DIR"
    echo "  App: $APP_NAME"
    echo "  Backend URL: $BACKEND_URL"
    echo "  Next steps:"
    echo "    cd $OUTPUT_DIR"
    echo "    npm install"
    echo "    npm run dev"
}

trap 'error "Generation failed at line $LINENO"' ERR
main
