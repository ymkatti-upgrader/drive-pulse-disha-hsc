import { useEffect, useMemo, useState } from 'react'
import { AlertCircle, Calendar, ChevronRight, Plus, Save, UserRound } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAudits, isInProgressAuditStatus } from '../audits/AuditContext'
import { filterByUserAccess, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { DataRow, PageHeader, SearchBar, Stepper } from '../components/UI'
import { requireSupabase } from '../supabaseClient'

const AUDIT_TYPE = 'Disha HanSaChu Audit'
const LOCATIONS = ['BL06A Sales', 'BL06A Service', 'BL06B', 'BL06D', 'BL06E']
const DEPARTMENTS = ['Sales', 'Service', 'U-Trust', 'VAS', 'Accessories', 'Other']

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
  return role.includes('disha hsc pic') || role.includes('branch pic') || role.includes('branch disha pic') || userType.includes('auditor')
}

function canonicalDepartment(value) {
  const normalized = normalizedText(value)
  if (normalized === 'service') return 'Service & Parts'
  if (normalized === 'u-trust') return 'Used Car'
  if (normalized === 'vas') return 'Value Chain'
  if (normalized === 'accessories') return 'Accessory'
  return value
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
  const scopedAudits = filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  const [auditorOptions, setAuditorOptions] = useState([])
  const [validationError, setValidationError] = useState('')
  const [form, setForm] = useState({
    location: '',
    departments: [],
    otherDepartment: '',
    auditorId: '',
    startDate: new Date().toISOString().slice(0, 10),
  })

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

  const selectedDepartments = form.departments
  const selectedAuditor = auditorOptions.find(option => option.value === form.auditorId) || null
  const otherDepartmentSelected = selectedDepartments.includes('Other')
  const otherDepartmentValid = !otherDepartmentSelected || Boolean(form.otherDepartment.trim())

  function updateDepartments(department) {
    setValidationError('')
    setForm(current => {
      const departments = current.departments.includes(department)
        ? current.departments.filter(item => item !== department)
        : [...current.departments, department]
      return {
        ...current,
        departments,
        otherDepartment: department === 'Other' && !departments.includes('Other') ? '' : current.otherDepartment,
      }
    })
  }

  function continueToChecklist() {
    const issues = []
    if (!form.location) issues.push('Location is required.')
    if (!selectedDepartments.length) issues.push('At least one department is required.')
    if (!form.auditorId) issues.push('Auditor name is required.')
    if (!form.startDate) issues.push('Audit start date is required.')
    if (!otherDepartmentValid) issues.push('Specify department is required when Other is selected.')

    if (issues.length) {
      setValidationError(issues[0])
      return
    }

    const auditId = `AUD-${Date.now()}`
    const departmentValues = selectedDepartments.filter(item => item !== 'Other')
    const departments = [...departmentValues, ...(otherDepartmentSelected && form.otherDepartment.trim() ? [form.otherDepartment.trim()] : [])]
    const canonicalDepartments = departments.map(canonicalDepartment)

    createAudit({
      id: auditId,
      audit_type: AUDIT_TYPE,
      location: form.location,
      departments,
      department: canonicalDepartments.join(', '),
      other_department: otherDepartmentSelected ? form.otherDepartment.trim() : '',
      auditor_id: selectedAuditor?.value || '',
      auditor_name: selectedAuditor?.label || '',
      start_date: form.startDate,
      date: form.startDate,
      score: null,
      progress: 0,
      priority: 'Medium',
      status: 'In Progress',
    })
    navigate(`/audits/${auditId}/conduct`)
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
    <PageHeader eyebrow="AUDIT MANAGEMENT" title="Audits" description="Plan, assign and monitor HanSaChu audits." action={<button className="primary-button"><Plus size={17} /> New audit</button>} />
    <div className="tabs"><button className="active">All audits <span>{scopedAudits.length}</span></button><button>Upcoming <span>{upcoming}</span></button><button>In progress <span>{inProgress}</span></button><button>Completed <span>{completed}</span></button></div>
    <div className="two-column-form">
      <section className="card panel">
        <div className="panel-head"><div><span className="eyebrow">CREATE NEW</span><h2>Audit details</h2></div></div>
        <Stepper steps={['Details', 'Checklist', 'Assign']} active={0} />
        <div className="form-grid">
          <label className="wide">Audit Type<input value={AUDIT_TYPE} readOnly /></label>
          <label className="wide">Location<select value={form.location} onChange={event => setForm(current => ({ ...current, location: event.target.value }))}><option value="">Select location</option>{LOCATIONS.map(item => <option key={item} value={item}>{item}</option>)}</select></label>
          <div className="wide">
            <span>Department</span>
            <div className="department-grid">
              {DEPARTMENTS.map(item => <label key={item} className="department-option"><input type="checkbox" checked={selectedDepartments.includes(item)} onChange={() => updateDepartments(item)} /> <span>{item}</span></label>)}
            </div>
            {otherDepartmentSelected && <input className="wide-input" value={form.otherDepartment} onChange={event => setForm(current => ({ ...current, otherDepartment: event.target.value }))} placeholder="Specify department" />}
          </div>
          <label className="wide">Auditor Name
            <div className="input-icon"><UserRound size={17} /><select value={form.auditorId} onChange={event => setForm(current => ({ ...current, auditorId: event.target.value }))}><option value="">Select auditor</option>{auditorOptions.map(item => <option key={item.id} value={item.value}>{item.label}</option>)}</select></div>
          </label>
          <label>Audit Start Date<div className="input-icon"><Calendar size={17} /><input type="date" value={form.startDate} onChange={event => setForm(current => ({ ...current, startDate: event.target.value }))} /></div></label>
        </div>
        {validationError && <div className="audit-checklist-note" role="alert"><AlertCircle size={18} /><span>{validationError}</span></div>}
        <div className="form-footer"><button className="secondary-button"><Save size={17} /> Save draft</button><button className="primary-button" onClick={continueToChecklist}>Continue to checklist <ChevronRight size={17} /></button></div>
      </section>
      <section>
        <div className="list-toolbar"><SearchBar placeholder="Search audits" /></div>
        <div className="card data-list">
          {scopedAudits.map(a => {
            const title = a.audit_type || a.title || AUDIT_TYPE
            const departments = Array.isArray(a.departments) ? a.departments : String(a.department || '').split(',').map(part => part.trim()).filter(Boolean)
            const subtitle = [a.location, departments.join(', '), a.start_date || a.date].filter(Boolean).join(' - ')
            const canDelete = isSystemAdmin(user) && isInProgressAuditStatus(a.status)
            return <DataRow key={a.id} title={title} subtitle={`${a.id} - ${subtitle || 'No details'}`} meta={a.score ? `${a.score}%` : null} status={a.status} onClick={() => isInProgressAuditStatus(a.status) && navigate(`/audits/${a.id}/conduct`)} onDelete={canDelete ? () => handleDeleteAudit(a.id) : undefined} />
          })}
        </div>
      </section>
    </div>
  </>
}
