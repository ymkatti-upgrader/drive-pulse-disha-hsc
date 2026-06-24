import { createContext, useCallback, useContext, useMemo, useState } from 'react'

const YOKOTEN_KEY = 'disha-hsc-yokoten'
const YokotenContext = createContext(null)

function dateKey(date) {
  return `${date.getFullYear()}${String(date.getMonth() + 1).padStart(2, '0')}${String(date.getDate()).padStart(2, '0')}`
}

function formatDate(date) {
  return new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }).format(date)
}

function readStories() {
  try {
    const stored = JSON.parse(localStorage.getItem(YOKOTEN_KEY))
    return Array.isArray(stored) ? stored : []
  } catch {
    return []
  }
}

export function YokotenProvider({ children }) {
  const [stories, setStories] = useState(readStories)

  const upsertStory = useCallback(story => {
    setStories(current => {
      const now = new Date()
      const existingIndex = current.findIndex(item => item.sourceImprovementId === story.sourceImprovementId)
      const sequence = current.filter(item => item.id.startsWith(`YKT-${dateKey(now)}-`)).length + 1
      const record = {
        ...story,
        id: existingIndex >= 0 ? current[existingIndex].id : `YKT-${dateKey(now)}-${String(sequence).padStart(3, '0')}`,
        sharedDate: existingIndex >= 0 ? current[existingIndex].sharedDate : formatDate(now),
        createdAt: existingIndex >= 0 ? current[existingIndex].createdAt : now.toISOString().slice(0, 10),
      }
      const next = existingIndex >= 0 ? current.map((item, index) => index === existingIndex ? record : item) : [record, ...current]
      localStorage.setItem(YOKOTEN_KEY, JSON.stringify(next))
      return next
    })
  }, [])

  const value = useMemo(() => ({ stories, upsertStory }), [stories, upsertStory])
  return <YokotenContext.Provider value={value}>{children}</YokotenContext.Provider>
}

export function useYokoten() {
  const context = useContext(YokotenContext)
  if (!context) throw new Error('useYokoten must be used inside YokotenProvider')
  return context
}
