import { useEffect, useMemo, useState } from 'react'
import { AlertCircle, Calendar, ChevronRight, Plus, Save, UserRound } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAudits, isInProgressAuditStatus } from '../audits/AuditContext'
import { canAccessAuditModule, canManageDishaWorkflow, filterByUserAccess, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { DataRow, PageHeader, SearchBar, StatusBadge, Stepper } from '../components/UI'
import { requireSupabase } from '../supabaseClient'

const AUDIT_TYPE = 'Disha HanSaChu Audit'
const LOCATIONS = ['BL06A Sales', 'BL06A Service', 'BL06B', 'BL06D', 'BL06E']
const CREATION_DRAFT_KEY = 'disha-hsc-audit-creation-draft'

function normalizedText(value) {
  return String(value || '').trim().toLowerCase()
}

function uniqueById(rows) {
  const seen = new Set()
  return rows.filter(row => {
    if (!row?.id || seen.has(row.id)) return false
    seen.add(row.id)
    return true
  })
}

function isAuditorRole(mapping = {}) {
  const role = normalizedText(mapping.role)
  const userType = normalizedText(mapping.user_type)
  return role.includes('disha hsc pic') || role.includes('branch pic') || role.includes('branch disha pic') || role.includes('branch disha hsc pic') || role.includes('ng pic') || userType.includes('auditor') || userType.includes('ng pic')
}

function buildAuditorOptions(users, mappingsByUser) {
  const mapped = (users || [])
    .filter(user => normalizedText(user.active) !== 'false')
    .map(user => {
      const mappings = mappingsByUser.get(user.id) || []
      const qualifyingMappings = mappings.filter(isAuditorRole)
      if (!qualifyingMappings.length) return null
      return {
        id: user.id,
        value: user.id,
        label: user.employee_name || user.mobile_no || user.id,
      }
    })
    .filter(Boolean)

  if (mapped.length) return uniqueById(mapped)

  return uniqueById((users || [])
    .filter(user => normalizedText(user.active) !== 'false')
    .map(user => ({
      id: user.id,
      value: user.id,
      label: user.employee_name || user.mobile_no || user.id,
    })))
}

export default function AuditCreation() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits, createAudit, deleteAudit } = useAudits()
  const canSeeAllWorkflowData = canManageDishaWorkflow(user)
  const scopedAudits = canSeeAllWorkflowData ? audits : filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  const canEditAudit = canAccessAuditModule(user) || isSystemAdmin(user)
  const [auditorOptions, setAuditorOptions] = useState([])
  const [validationError, setValidationError] = useState('')
  const [auditId, setAuditId] = useState('')
  const [form, setForm] = useState({
    location: '',
    auditorId: '',
    startDate: new Date().toISOString().slice(0, 10),
  })

  useEffect(() => {
    try {
      const stored = JSON.parse(localStorage.getItem(CREATION_DRAFT_KEY))
      if (!stored || typeof stored !== 'object') return
      if (stored.auditId) setAuditId(stored.auditId)
      setForm(current => ({
        location: stored.location || current.location,
        auditorId: stored.auditorId || current.auditorId,
        startDate: stored.startDate || current.startDate,
      }))
    } catch {
      // ignore malformed local draft
    }
  }, [])

  useEffect(() => {
    let cancelled = false

    async function loadAuditors() {
      try {
        const client = requireSupabase()
        const [usersResult, mappingsResult] = await Promise.all([
          client.from('app_users').select('id, employee_name, mobile_no, active'),
          client.from('user_access_mappings').select('user_id, role, department, location, user_type, active').eq('active', true),
        ])
        if (usersResult.error) throw usersResult.error
        if (mappingsResult.error) throw mappingsResult.error

        const mappingsByUser = new Map()
        for (const mapping of mappingsResult.data || []) {
          if (!mappingsByUser.has(mapping.user_id)) mappingsByUser.set(mapping.user_id, [])
          mappingsByUser.get(mapping.user_id).push(mapping)
        }

        const nextOptions = buildAuditorOptions(usersResult.data || [], mappingsByUser)
        if (!cancelled) setAuditorOptions(nextOptions)
      } catch (error) {
        if (!cancelled) setAuditorOptions([])
        console.error('Unable to load auditor options', error)
      }
    }

    loadAuditors()
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    if (!user?.id || form.auditorId) return
    if (auditorOptions.some(option => option.value === user.id)) {
      setForm(current => ({ ...current, auditorId: user.id }))
    }
  }, [user?.id, auditorOptions, form.auditorId])

  const selectedAuditor = auditorOptions.find(option => option.value === form.auditorId) || null

  function saveCreationDraft() {
    if (!canEditAudit) return
    const nextAuditId = auditId || `AUD-${Date.now()}`
    setAuditId(nextAuditId)
    const draft = {
      id: nextAuditId,
      audit_type: AUDIT_TYPE,
      location: form.location,
      departments: [],
      department: '',
      other_department: '',
      auditor_id: selectedAuditor?.value || '',
      auditor_name: selectedAuditor?.label || '',
      start_date: form.startDate,
      date: form.startDate,
      score: null,
      progress: 0,
      priority: 'Medium',
      status: 'Draft',
    }
    localStorage.setItem(CREATION_DRAFT_KEY, JSON.stringify({
      auditId: nextAuditId,
      location: form.location,
      auditorId: form.auditorId,
      startDate: form.startDate,
      savedAt: new Date().toISOString(),
    }))
    createAudit(draft)
    setValidationError('')
  }

  function continueToChecklist() {
    if (!canEditAudit) return
    const issues = []
    if (!form.location) issues.push('Location is required.')
    if (!form.auditorId) issues.push('Auditor name is required.')
    if (!form.startDate) issues.push('Audit start date is required.')

    if (issues.length) {
      setValidationError(issues[0])
      return
    }

    const nextAuditId = auditId || `AUD-${Date.now()}`
    setAuditId(nextAuditId)
    createAudit({
      id: nextAuditId,
      audit_type: AUDIT_TYPE,
      location: form.location,
      departments: [],
      department: '',
      other_department: '',
      auditor_id: selectedAuditor?.value || '',
      auditor_name: selectedAuditor?.label || '',
      start_date: form.startDate,
      date: form.startDate,
      score: null,
      progress: 0,
      priority: 'Medium',
      status: 'In Progress',
    })
    localStorage.setItem(CREATION_DRAFT_KEY, JSON.stringify({
      auditId: nextAuditId,
      location: form.location,
      auditorId: form.auditorId,
      startDate: form.startDate,
      savedAt: new Date().toISOString(),
    }))
    navigate(`/audits/${nextAuditId}/conduct`)
  }

  const upcoming = scopedAudits.filter(item => normalizedText(item.status) === 'scheduled').length
  const inProgress = scopedAudits.filter(item => isInProgressAuditStatus(item.status)).length
  const completed = scopedAudits.filter(item => normalizedText(item.status) === 'completed' || normalizedText(item.status) === 'submitted').length

  async function handleDeleteAudit(auditId) {
    const confirmed = window.confirm('Are you sure you want to delete this audit? This cannot be undone.')
    if (!confirmed) return
    deleteAudit(auditId)
  }

  return <>
    <PageHeader eyebrow="AUDIT MANAGEMENT" title="Audits" description="Plan, assign and monitor HanSaChu audits." action={canEditAudit ? <button className="primary-button"><Plus size={17} /> New audit</button> : <StatusBadge>Read-only View</StatusBadge>} />
    <div className="tabs"><button className="active">All audits <span>{scopedAudits.length}</span></button><button>Upcoming <span>{upcoming}</span></button><button>In progress <span>{inProgress}</span></button><button>Completed <span>{completed}</span></button></div>
    <div className="two-column-form">
      {canEditAudit && <section className="card panel">
        <div className="panel-head"><div><span className="eyebrow">CREATE NEW</span><h2>Audit details</h2></div></div>
        <Stepper steps={['Details', 'Checklist', 'Assign']} active={0} />
        <div className="form-grid">
          <label className="wide">Audit Type<input value={AUDIT_TYPE} readOnly /></label>
          <label className="wide">Location<select value={form.location} onChange={event => setForm(current => ({ ...current, location: event.target.value }))}><option value="">Select location</option>{LOCATIONS.map(item => <option key={item} value={item}>{item}</option>)}</select></label>
          <label className="wide">Auditor Name
            <div className="input-icon"><UserRound size={17} /><select value={form.auditorId} onChange={event => setForm(current => ({ ...current, auditorId: event.target.value }))}><option value="">Select auditor</option>{auditorOptions.map(item => <option key={item.id} value={item.value}>{item.label}</option>)}</select></div>
          </label>
          <label>Audit Start Date<div className="input-icon"><Calendar size={17} /><input type="date" value={form.startDate} onChange={event => setForm(current => ({ ...current, startDate: event.target.value }))} /></div></label>
        </div>
        {validationError && <div className="audit-checklist-note" role="alert"><AlertCircle size={18} /><span>{validationError}</span></div>}
        <div className="form-footer"><button className="secondary-button" type="button" onClick={saveCreationDraft}><Save size={17} /> Save draft</button><button className="primary-button" type="button" onClick={continueToChecklist}>Continue to checklist <ChevronRight size={17} /></button></div>
      </section>}
      <section>
        <div className="list-toolbar"><SearchBar placeholder="Search audits" /></div>
        <div className="card data-list">
          {scopedAudits.map(a => {
            const title = a.audit_type || a.title || AUDIT_TYPE
            const subtitle = [a.location, a.start_date || a.date].filter(Boolean).join(' - ')
            const canDelete = isSystemAdmin(user) && isInProgressAuditStatus(a.status)
            return <DataRow key={a.id} title={title} subtitle={`${a.id} - ${subtitle || 'No details'}`} meta={a.score ? `${a.score}%` : null} status={a.status} onClick={() => navigate(`/audits/${a.id}/conduct`)} onDelete={canDelete ? () => handleDeleteAudit(a.id) : undefined} />
          })}
        </div>
      </section>
    </div>
  </>
}
