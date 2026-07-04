import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import { requireSupabase, supabase } from '../supabaseClient'

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

function humanizeAuditStatus(status) {
  const value = normalizedText(status)
  if (value === 'scheduled') return 'Scheduled'
  if (value === 'in_progress' || value === 'in progress') return 'In Progress'
  if (value === 'submitted') return 'Submitted'
  if (value === 'completed') return 'Completed'
  return status || 'Draft'
}

function mapAuditRow(audit = {}, lookups = {}) {
  const location = lookups.locations?.get(audit.location_id)
  const department = lookups.departments?.get(audit.department_id)
  const auditor = lookups.users?.get(audit.auditor_id)
  return {
    id: audit.id,
    auditId: audit.audit_number || audit.audit_no || audit.id,
    auditNumber: audit.audit_number || audit.audit_no || '',
    audit_no: audit.audit_no || audit.audit_number || '',
    audit_number: audit.audit_number || audit.audit_no || '',
    audit_type: audit.title || '',
    title: audit.title || '',
    locationId: audit.location_id || '',
    location: location?.name || location?.code || '',
    departmentId: audit.department_id || '',
    department: department?.name || '',
    departments: department?.name ? [department.name] : [],
    auditor_id: audit.auditor_id || '',
    auditor_name: auditor?.employee_name || '',
    start_date: audit.scheduled_date || '',
    date: audit.scheduled_date || '',
    scheduled_date: audit.scheduled_date || '',
    startedAt: audit.started_at || '',
    submittedAt: audit.submitted_at || '',
    completedAt: audit.completed_at || '',
    created_at: audit.created_at || '',
    updated_at: audit.updated_at || '',
    status: humanizeAuditStatus(audit.status),
    score: audit.score ?? null,
    progress: normalizedText(audit.status) === 'submitted' || normalizedText(audit.status) === 'completed' ? 100 : normalizedText(audit.status) === 'in_progress' ? 50 : 0,
    created_by: audit.created_by || '',
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

  useEffect(() => {
    let cancelled = false

    async function loadAudits() {
      if (!supabase) return
      try {
        const client = requireSupabase()
        const stableSelect = 'id, audit_no, audit_number, title, location_id, department_id, auditor_id, scheduled_date, started_at, submitted_at, completed_at, status, score, created_by, created_at, updated_at'
        const legacySelect = 'id, audit_no, title, location_id, department_id, auditor_id, scheduled_date, started_at, submitted_at, completed_at, status, score, created_by, created_at, updated_at'
        let auditsPromise = client.from('audits').select(stableSelect).order('created_at', { ascending: false })
        const [auditsResult, locationsResult, departmentsResult, usersResult] = await Promise.all([
          auditsPromise,
          client.from('locations').select('id, code, name'),
          client.from('departments').select('id, name'),
          client.from('app_users').select('id, employee_name'),
        ])
        const finalAuditsResult = auditsResult.error && /column .* does not exist/i.test(auditsResult.error.message || '')
          ? await client.from('audits').select(legacySelect).order('created_at', { ascending: false })
          : auditsResult
        const anyError = [finalAuditsResult, locationsResult, departmentsResult, usersResult].find(result => result.error)
        if (anyError?.error) throw anyError.error

        const lookups = {
          locations: new Map((locationsResult.data || []).map(item => [item.id, item])),
          departments: new Map((departmentsResult.data || []).map(item => [item.id, item])),
          users: new Map((usersResult.data || []).map(item => [item.id, item])),
        }
        const nextAudits = (finalAuditsResult.data || []).map(item => mapAuditRow(item, lookups))
        if (!cancelled) {
          localStorage.setItem(AUDIT_KEY, JSON.stringify(nextAudits))
          setAudits(nextAudits)
        }
      } catch (error) {
        console.error('Unable to load audits from backend', error)
      }
    }

    loadAudits()
    return () => {
      cancelled = true
    }
  }, [])

  const deleteAudit = useCallback(async auditId => {
    try {
      if (supabase) {
        const client = requireSupabase()
        const { error } = await client.from('audits').delete().eq('id', auditId)
        if (error) return { error }
      }
      commit(current => current.filter(item => item.id !== auditId))
      return { error: null }
    } catch (error) {
      return { error }
    }
  }, [commit])

  const submitAudit = useCallback(async (auditId, updates) => {
    commit(current => current.map(item => item.id === auditId ? {
      ...item,
      status: 'Submitted',
      score: updates.score,
      progress: 100,
      submittedAt: new Date().toISOString(),
      submittedBy: updates.submittedBy || item.owner,
      ...updates,
    } : item))
    try {
      if (supabase) {
        const client = requireSupabase()
        const { error } = await client
          .from('audits')
          .update({
            status: 'submitted',
            score: updates.score ?? null,
            submitted_at: new Date().toISOString(),
          })
          .eq('id', auditId)
        if (error) return { error }
      }
      return { error: null }
    } catch (error) {
      return { error }
    }
  }, [commit])

  const createAudit = useCallback(audit => {
    const nextAudit = {
      ...audit,
      id: audit.id || `AUD-${Date.now()}`,
      auditId: audit.auditNumber || audit.audit_number || audit.audit_no || audit.auditId || audit.id || '',
      auditNumber: audit.auditNumber || audit.audit_number || audit.audit_no || '',
      status: audit.status || 'In Progress',
    }
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
