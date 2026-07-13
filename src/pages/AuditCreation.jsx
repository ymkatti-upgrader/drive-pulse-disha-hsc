import { useEffect, useMemo, useState } from 'react'
import { AlertCircle, Calendar, ChevronRight, Plus, Save, UserRound } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAudits, isInProgressAuditStatus } from '../audits/AuditContext'
import { canAccessAuditModule, canManageDishaWorkflow, filterByUserAccess, getUserAccess, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { DataRow, PageHeader, StatusBadge, Stepper } from '../components/UI'
import { requireSupabase } from '../supabaseClient'

const AUDIT_TYPE = 'Disha HanSaChu Audit'
const CREATION_DRAFT_KEY = 'disha-hsc-audit-creation-draft'

function normalizedText(value) {
  return String(value || '').trim().toLowerCase()
}

function isUuid(value) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(String(value || '').trim())
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

function buildAuditFunctionOptions(departments, user, canSeeAllWorkflowData) {
  const active = (departments || [])
    .filter(item => normalizedText(item.status) === 'active')
    .map(item => ({ id: item.id, value: item.id, label: item.name || item.id }))

  if (canSeeAllWorkflowData || isSystemAdmin(user)) return active

  const scope = [...new Set(getUserAccess(user).map(item => normalizedText(item.department)).filter(Boolean))]
  if (!scope.length || scope.some(value => ['all', 'group'].includes(value))) return active

  const scopeAliases = new Set(scope.flatMap(value => {
    const withoutPrefix = value.replace(/^dctc\s*-\s*/i, '')
    const withoutAccounts = withoutPrefix.replace(/\s*&\s*accounts$/i, '').trim()
    return [value, withoutPrefix, withoutAccounts].filter(Boolean)
  }))

  return active.filter(option => scopeAliases.has(normalizedText(option.label)))
}

export default function AuditCreation() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits, createAudit, deleteAudit } = useAudits()
  const canSeeAllWorkflowData = canManageDishaWorkflow(user)
  const scopedAudits = canSeeAllWorkflowData ? audits : filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  const canEditAudit = canAccessAuditModule(user) || isSystemAdmin(user)
  const [auditorOptions, setAuditorOptions] = useState([])
  const [locationOptions, setLocationOptions] = useState([])
  const [auditFunctionOptions, setAuditFunctionOptions] = useState([])
  const [validationError, setValidationError] = useState('')
  const [savingAudit, setSavingAudit] = useState(false)
  const [auditId, setAuditId] = useState('')
  const [search, setSearch] = useState('')
  const [form, setForm] = useState({
    locationId: '',
    auditorId: '',
    startDate: new Date().toISOString().slice(0, 10),
    auditFunctionId: '',
  })

  useEffect(() => {
    try {
      const stored = JSON.parse(localStorage.getItem(CREATION_DRAFT_KEY))
      if (!stored || typeof stored !== 'object') return
      if (stored.auditId && isUuid(stored.auditId)) setAuditId(stored.auditId)
      setForm(current => ({
        locationId: stored.locationId || current.locationId,
        auditorId: stored.auditorId || current.auditorId,
        startDate: stored.startDate || current.startDate,
        auditFunctionId: stored.auditFunctionId || current.auditFunctionId,
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
        const [usersResult, mappingsResult, locationsResult, departmentsResult] = await Promise.all([
          client.from('app_users').select('id, employee_name, mobile_no, active'),
          client.from('user_access_mappings').select('user_id, role, department, location, user_type, active').eq('active', true),
          client.from('locations').select('id, code, name, visibility').order('code', { ascending: true }),
          client.from('departments').select('id, name, status').order('name', { ascending: true }),
        ])
        if (usersResult.error) throw usersResult.error
        if (mappingsResult.error) throw mappingsResult.error
        if (locationsResult.error) throw locationsResult.error
        if (departmentsResult.error) throw departmentsResult.error

        const mappingsByUser = new Map()
        for (const mapping of mappingsResult.data || []) {
          if (!mappingsByUser.has(mapping.user_id)) mappingsByUser.set(mapping.user_id, [])
          mappingsByUser.get(mapping.user_id).push(mapping)
        }

        const nextOptions = buildAuditorOptions(usersResult.data || [], mappingsByUser)
        if (!cancelled) {
          setAuditorOptions(nextOptions)
          setLocationOptions((locationsResult.data || []).map(item => ({
            id: item.id,
            value: item.id,
            label: [item.code, item.name].filter(Boolean).join(' - ') || item.name || item.code || item.id,
            name: item.name || item.code || '',
          })))
          setAuditFunctionOptions(buildAuditFunctionOptions(departmentsResult.data || [], user, canSeeAllWorkflowData))
        }
      } catch (error) {
        if (!cancelled) {
          setAuditorOptions([])
          setLocationOptions([])
          setAuditFunctionOptions([])
        }
        console.error('Unable to load auditor options', error)
      }
    }

    loadAuditors()
    return () => {
      cancelled = true
    }
  }, [canSeeAllWorkflowData, user])

  useEffect(() => {
    if (!user?.id || form.auditorId) return
    if (auditorOptions.some(option => option.value === user.id)) {
      setForm(current => ({ ...current, auditorId: user.id }))
    }
  }, [user?.id, auditorOptions, form.auditorId])

  const selectedAuditor = auditorOptions.find(option => option.value === form.auditorId) || null
  const selectedLocation = locationOptions.find(option => option.value === form.locationId) || null
  const selectedAuditFunction = auditFunctionOptions.find(option => option.value === form.auditFunctionId) || null

  async function saveAuditRecord(nextStatus) {
    if (!canEditAudit || savingAudit) return null
    const issues = []
    if (!form.locationId) issues.push('Location is required.')
    if (!form.auditorId) issues.push('Auditor name is required.')
    if (!form.startDate) issues.push('Audit start date is required.')
    if (!form.auditFunctionId) issues.push('Audit function is required.')
    if (issues.length) {
      setValidationError(issues[0])
      return null
    }

    setSavingAudit(true)
    setValidationError('')
    try {
      const client = requireSupabase()
      let savedAudit = null

      if (!auditId) {
        const { data, error } = await client.rpc('create_audit_with_number', {
          p_title: AUDIT_TYPE,
          p_location_id: form.locationId,
          p_department_id: null,
          p_auditor_id: form.auditorId,
          p_scheduled_date: form.startDate,
          p_created_by: user.id,
          p_audit_function_id: form.auditFunctionId,
          p_status: nextStatus === 'In Progress' ? 'in_progress' : 'scheduled',
        })
        if (error) throw error
        savedAudit = Array.isArray(data) ? data[0] : data
      } else {
        const { data, error } = await client
          .from('audits')
          .update({
            title: AUDIT_TYPE,
            location_id: form.locationId,
            auditor_id: form.auditorId,
            audit_function_id: form.auditFunctionId,
            scheduled_date: form.startDate,
            status: nextStatus === 'In Progress' ? 'in_progress' : 'scheduled',
          })
          .eq('id', auditId)
          .select('id, audit_no, audit_number, title, location_id, department_id, audit_function_id, auditor_id, scheduled_date, status, score, created_at, updated_at')
          .single()
        if (error) throw error
        savedAudit = data
      }

      const nextAuditId = savedAudit?.id || auditId
      setAuditId(nextAuditId)
      localStorage.setItem(CREATION_DRAFT_KEY, JSON.stringify({
        auditId: nextAuditId,
        locationId: form.locationId,
        auditorId: form.auditorId,
        startDate: form.startDate,
        auditFunctionId: form.auditFunctionId,
        savedAt: new Date().toISOString(),
      }))
      createAudit({
        id: nextAuditId,
        auditId: savedAudit?.audit_number || savedAudit?.audit_no || nextAuditId,
        auditNumber: savedAudit?.audit_number || savedAudit?.audit_no || '',
        audit_number: savedAudit?.audit_number || savedAudit?.audit_no || '',
        audit_no: savedAudit?.audit_no || savedAudit?.audit_number || '',
        audit_type: AUDIT_TYPE,
        title: AUDIT_TYPE,
        locationId: form.locationId,
        location: selectedLocation?.name || selectedLocation?.label || '',
        auditFunctionId: form.auditFunctionId,
        auditFunction: selectedAuditFunction?.label || 'Not Assigned',
        auditor_id: selectedAuditor?.value || '',
        auditor_name: selectedAuditor?.label || '',
        start_date: form.startDate,
        date: form.startDate,
        scheduled_date: form.startDate,
        score: savedAudit?.score ?? null,
        progress: nextStatus === 'In Progress' ? 50 : 0,
        priority: 'Medium',
        status: nextStatus,
      })
      return nextAuditId
    } catch (error) {
      setValidationError(error?.message || 'Unable to save audit.')
      return null
    } finally {
      setSavingAudit(false)
    }
  }

  async function saveCreationDraft() {
    await saveAuditRecord('Draft')
  }

  async function continueToChecklist() {
    const nextAuditId = await saveAuditRecord('In Progress')
    if (nextAuditId) {
      localStorage.removeItem(CREATION_DRAFT_KEY)
      navigate(`/audits/${nextAuditId}/conduct`)
    }
  }

  function startNewAudit() {
    localStorage.removeItem(CREATION_DRAFT_KEY)
    setAuditId('')
    setValidationError('')
    setForm({
      locationId: '',
      auditorId: '',
      startDate: new Date().toISOString().slice(0, 10),
      auditFunctionId: '',
    })
  }

  const upcoming = scopedAudits.filter(item => normalizedText(item.status) === 'scheduled').length
  const inProgress = scopedAudits.filter(item => isInProgressAuditStatus(item.status)).length
  const completed = scopedAudits.filter(item => normalizedText(item.status) === 'completed' || normalizedText(item.status) === 'submitted').length

  const rows = useMemo(() => {
    const query = search.trim().toLowerCase()
    return query
      ? scopedAudits.filter(item => [
        item.auditNumber,
        item.auditId,
        item.audit_type,
        item.title,
        item.location,
        item.auditFunction,
      ].some(value => String(value || '').toLowerCase().includes(query)))
      : scopedAudits
  }, [scopedAudits, search])

  async function handleDeleteAudit(auditId) {
    const confirmed = window.confirm('Are you sure you want to delete this audit? This cannot be undone.')
    if (!confirmed) return
    const { error } = await deleteAudit(auditId)
    if (error) {
      setValidationError(error.message || 'Unable to delete audit.')
    }
  }

  return <>
    <PageHeader eyebrow="AUDIT MANAGEMENT" title="Audits" description="Plan, assign and monitor HanSaChu audits." action={canEditAudit ? <button className="primary-button" type="button" onClick={startNewAudit}><Plus size={17} /> New audit</button> : <StatusBadge>Read-only View</StatusBadge>} />
    <div className="tabs"><button className="active">All audits <span>{scopedAudits.length}</span></button><button>Upcoming <span>{upcoming}</span></button><button>In progress <span>{inProgress}</span></button><button>Completed <span>{completed}</span></button></div>
    <div className="two-column-form">
      {canEditAudit && <section className="card panel">
        <div className="panel-head"><div><span className="eyebrow">CREATE NEW</span><h2>Audit details</h2></div></div>
        <Stepper steps={['Details', 'Checklist', 'Assign']} active={0} />
        <div className="form-grid">
          <label className="wide">Audit Type<input value={AUDIT_TYPE} readOnly /></label>
          <label className="wide">Location<select value={form.locationId} onChange={event => setForm(current => ({ ...current, locationId: event.target.value }))}><option value="">Select location</option>{locationOptions.map(item => <option key={item.id} value={item.value}>{item.label}</option>)}</select></label>
          <label className="wide">Audit Start Date
            <div className="input-icon audit-creation-icon-field audit-creation-date-field"><Calendar size={17} /><input type="date" value={form.startDate} onChange={event => setForm(current => ({ ...current, startDate: event.target.value }))} /></div>
          </label>
          <label className="wide">Audit Function <span aria-hidden="true">*</span>
            <select required value={form.auditFunctionId} onChange={event => setForm(current => ({ ...current, auditFunctionId: event.target.value }))}>
              <option value="">Select audit function</option>
              {auditFunctionOptions.map(item => <option key={item.id} value={item.value}>{item.label}</option>)}
            </select>
          </label>
          <label className="wide">Auditor Name
            <div className="input-icon audit-creation-icon-field"><UserRound size={17} /><select value={form.auditorId} onChange={event => setForm(current => ({ ...current, auditorId: event.target.value }))}><option value="">Select auditor</option>{auditorOptions.map(item => <option key={item.id} value={item.value}>{item.label}</option>)}</select></div>
          </label>
        </div>
        {validationError && <div className="audit-checklist-note" role="alert"><AlertCircle size={18} /><span>{validationError}</span></div>}
        <div className="form-footer"><button className="secondary-button" type="button" onClick={saveCreationDraft} disabled={savingAudit}><Save size={17} /> Save draft</button><button className="primary-button" type="button" onClick={continueToChecklist} disabled={savingAudit}>Continue to checklist <ChevronRight size={17} /></button></div>
      </section>}
      <section>
        <div className="list-toolbar"><div className="search-bar"><input value={search} onChange={event => setSearch(event.target.value)} placeholder="Search by audit number, audit name or location" /></div></div>
        <div className="card data-list">
          {rows.map(a => {
            const title = a.audit_type || a.title || AUDIT_TYPE
            const subtitle = [a.location, a.auditFunction || 'Not Assigned', a.start_date || a.date].filter(Boolean).join(' - ')
            const canDelete = isSystemAdmin(user) && isInProgressAuditStatus(a.status)
            return <DataRow key={a.id} title={title} subtitle={`${a.auditNumber || a.auditId || a.id} - ${subtitle || 'No details'}`} meta={a.score ? `${a.score}%` : null} status={a.status} onClick={() => navigate(`/audits/${a.id}/conduct`)} onDelete={canDelete ? () => handleDeleteAudit(a.id) : undefined} />
          })}
        </div>
      </section>
    </div>
  </>
}
