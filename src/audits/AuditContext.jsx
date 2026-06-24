import { createContext, useCallback, useContext, useMemo, useState } from 'react'

const AUDIT_KEY = 'disha-hsc-audits'
const AuditContext = createContext(null)

function normalizedText(value) {
  return String(value || '').trim().toLowerCase()
}

export function isInProgressAuditStatus(status) {
  return ['in progress', 'in_progress'].includes(normalizedText(status))
}

function readAudits() {
  try {
    const stored = JSON.parse(localStorage.getItem(AUDIT_KEY))
    return Array.isArray(stored) ? stored : []
  } catch {
    return []
  }
}

export function AuditProvider({ children }) {
  const [audits, setAudits] = useState(readAudits)

  const commit = useCallback(updater => {
    setAudits(current => {
      const next = typeof updater === 'function' ? updater(current) : updater
      localStorage.setItem(AUDIT_KEY, JSON.stringify(next))
      return next
    })
  }, [])

  const deleteAudit = useCallback(auditId => {
    commit(current => current.filter(item => item.id !== auditId))
  }, [commit])

  const submitAudit = useCallback((auditId, updates) => {
    commit(current => current.map(item => item.id === auditId ? {
      ...item,
      status: 'Submitted',
      score: updates.score,
      progress: 100,
      submittedAt: new Date().toISOString(),
      submittedBy: updates.submittedBy || item.owner,
      ...updates,
    } : item))
  }, [commit])

  const createAudit = useCallback(audit => {
    const nextAudit = { ...audit, id: audit.id || `AUD-${Date.now()}`, status: audit.status || 'In Progress' }
    commit(current => {
      const index = current.findIndex(item => item.id === nextAudit.id)
      if (index < 0) return [nextAudit, ...current]
      const next = [...current]
      next[index] = { ...current[index], ...nextAudit }
      return next
    })
  }, [commit])

  const value = useMemo(() => ({ audits, submitAudit, createAudit, deleteAudit }), [audits, submitAudit, createAudit, deleteAudit])
  return <AuditContext.Provider value={value}>{children}</AuditContext.Provider>
}

export function useAudits() {
  const context = useContext(AuditContext)
  if (!context) throw new Error('useAudits must be used inside AuditProvider')
  return context
}
