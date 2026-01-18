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
