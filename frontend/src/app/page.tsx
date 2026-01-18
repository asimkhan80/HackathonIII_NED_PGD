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

      <div style={{ marginTop: '3rem', textAlign: 'center', color: '#666' }}>
        <p>Built with Agent-First Development</p>
        <p style={{ fontSize: '0.875rem', marginTop: '0.5rem' }}>
          Hackathon III: Reusable Intelligence and Cloud-Native Mastery
        </p>
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
