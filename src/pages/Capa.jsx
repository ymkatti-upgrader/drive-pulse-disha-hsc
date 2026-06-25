import { AlertTriangle, CheckCircle2, Clock3, Search, Target } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAudits } from '../audits/AuditContext'
import { canAccessAuditModule, filterByUserAccess, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { PageHeader, Progress, StatCard, StatusBadge } from '../components/UI'
import { useCapas } from '../capa/CapaContext'
import { requireSupabase } from '../supabaseClient'

const filters = ['All', 'Open', 'Root Cause Analysis', 'Countermeasure Planned', 'Approval Pending', 'Implementation In Progress', 'Evidence Uploaded', 'Verification Pending', 'Closed', 'Yokoten Shared']

function normalizeText(value) {
  return String(value || '').trim().toLowerCase()
}

function auditBelongsToUser(audit, user) {
  if (!audit || !user) return false
  const userName = normalizeText(user.employee_name || user.name || user.full_name)
  return [audit.created_by, audit.createdBy, audit.auditor_id, audit.auditorId, audit.auditor_user_id, audit.auditorUserId].some(value => value && value === user.id)
    || [audit.auditor_name, audit.auditorName, audit.owner, audit.createdByName].some(value => normalizeText(value) && normalizeText(value) === userName)
}

function responseBelongsToPic(row, user) {
  return row.pic_for_ng_user_id === user?.id || (user?.mobile_no && row.pic_for_ng_mobile === user.mobile_no)
}

function responseBelongsToAuditor(row, audit, user) {
  return row.responded_by === user?.id || auditBelongsToUser(audit, user)
}

export default function CapaTracker() {
  const { capas } = useCapas()
  const { audits } = useAudits()
  const { user } = useAuth()
  const [filter, setFilter] = useState('All')
  const [search, setSearch] = useState('')
  const [assignedNgRows, setAssignedNgRows] = useState([])
  const [assignedNgError, setAssignedNgError] = useState('')
  const navigate = useNavigate()
  const scopedCapas = filterByUserAccess(user, capas, capa => ({ department: capa.departmentOwner || capa.department || capa.area, location: capa.location || capa.locationAspect }))

  useEffect(() => {
    let cancelled = false

    async function loadAssignedNgRows() {
      if (!user?.id) {
        setAssignedNgRows([])
        return
      }

        setAssignedNgError('')
        try {
          const client = requireSupabase()
          const adminView = isSystemAdmin(user)
          const auditorView = canAccessAuditModule(user)
          let query = client
            .from('audit_responses')
            .select('id, audit_id, checklist_id, dq_question_num, sub_question_num, sub_question_text, current_condition_observed, tentative_closing_date, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, result, status, created_at, updated_at, audit_location, root_cause, corrective_action_plan, preventive_action_plan, action_taken, closure_remarks, actual_closure_date, responded_by')
            .eq('result', 'NG')

        if (!adminView && !auditorView) {
          const assignedFilters = [
            `pic_for_ng_user_id.eq.${user.id}`,
            user.mobile_no ? `pic_for_ng_mobile.eq.${user.mobile_no}` : '',
          ].filter(Boolean).join(',')
          query = query.or(assignedFilters || `pic_for_ng_user_id.eq.${user.id}`)
        }

        const { data, error } = await query
        if (error) throw error
        if (!cancelled) {
          const scopedRows = adminView ? data || [] : (data || []).filter(row => {
            const audit = audits.find(item => item.id === row.audit_id)
            return responseBelongsToPic(row, user) || (auditorView && responseBelongsToAuditor(row, audit, user))
          })
          setAssignedNgRows(scopedRows)
        }
      } catch (error) {
        if (!cancelled) {
          setAssignedNgRows([])
          setAssignedNgError(error?.message || 'Unable to load assigned NG improvements.')
        }
      }
    }

    loadAssignedNgRows()
    return () => {
      cancelled = true
    }
  }, [user, audits])

  const assignedImprovements = useMemo(() => assignedNgRows.map(row => {
    const audit = audits.find(item => item.id === row.audit_id) || {}
    const department = audit.department || (Array.isArray(audit.departments) ? audit.departments.join(', ') : audit.departments) || '-'
    const location = audit.location || row.audit_location || '-'
    return {
      capaId: `NG-${row.id}`,
      id: `NG-${row.id}`,
      finding: row.sub_question_text || 'Assigned NG improvement',
      auditId: row.audit_id || '-',
      dishaQuestionNo: row.dq_question_num || '-',
      subQuestionNo: row.sub_question_num || '',
      departmentOwner: department,
      department,
      location,
      locationAspect: location,
      targetDate: row.tentative_closing_date || '-',
      createdDate: String(row.created_at || row.updated_at || '').slice(0, 10) || '-',
      status: row.status || 'Open',
      progress: row.status === 'Completed' ? 100 : row.status === 'In Progress' ? 50 : 0,
      riskLevel: 'Critical',
      area: department,
      chapter: `Q${row.sub_question_num || '-'}`,
      autoGenerated: true,
      currentCondition: row.current_condition_observed || '',
      rootCause: row.root_cause || '',
      correctiveActionPlan: row.corrective_action_plan || '',
      preventiveActionPlan: row.preventive_action_plan || '',
      actionTaken: row.action_taken || row.closure_remarks || '',
      actualClosureDate: row.actual_closure_date || '',
      pic: row.pic_for_ng_name || row.pic_for_ng_mobile || '-',
      source: 'audit_response',
    }
  }), [assignedNgRows, audits])

  const improvementRows = useMemo(() => [...assignedImprovements, ...scopedCapas], [assignedImprovements, scopedCapas])
  const activeCapas = improvementRows.filter(capa => !['Cancelled', 'Closed', 'Completed', 'Yokoten Shared'].includes(capa.status))

  const rows = useMemo(() => {
    const query = search.trim().toLowerCase()
    return improvementRows.filter(capa => filter === 'All' || capa.status === filter).filter(capa => !query || [capa.capaId, capa.finding, capa.auditId, capa.dishaQuestionNo, capa.subQuestionNo, capa.departmentOwner, capa.status, capa.pic].some(value => String(value).toLowerCase().includes(query)))
  }, [improvementRows, filter, search])

  return <>
    <PageHeader eyebrow="TOYOTA IMPROVEMENT MANAGEMENT" title="Improvement Tracker" description="Manage observations from gap identification through verification and Yokoten sharing." />
    <div className="stats-grid compact">
      <StatCard label="Open actions" value={String(activeCapas.length).padStart(2, '0')} meta="Active improvement actions" icon={Target} />
      <StatCard label="Auto-generated" value={String(improvementRows.filter(capa => capa.autoGenerated).length).padStart(2, '0')} meta="Created from audit gaps" icon={Clock3} tone="amber" />
      <StatCard label="Verification pending" value={String(improvementRows.filter(capa => capa.status === 'Verification Pending').length).padStart(2, '0')} meta="Ready for auditor" icon={CheckCircle2} tone="green" />
      <StatCard label="Critical findings" value={String(activeCapas.filter(capa => capa.riskLevel === 'Critical').length).padStart(2, '0')} meta="Immediate attention" icon={AlertTriangle} tone="dark" />
    </div>

    <div className="tabs">{filters.map(item => <button className={filter === item ? 'active' : ''} onClick={() => setFilter(item)} key={item}>{item} <span>{item === 'All' ? improvementRows.length : improvementRows.filter(capa => capa.status === item).length}</span></button>)}</div>
    <div className="search-bar capa-search"><Search size={18} /><input value={search} onChange={event => setSearch(event.target.value)} placeholder="Search improvement ID, audit, question or department" /></div>
    {assignedNgError && <div className="audit-checklist-note" role="alert"><AlertTriangle size={18} /><span>{assignedNgError}</span></div>}

    <div className="card capa-table">
      <div className="capa-table-head auto-capa-head"><span>Finding</span><span>Audit reference</span><span>Department</span><span>Target date</span><span>Status</span></div>
      {rows.length ? rows.map(capa => <button className="capa-row auto-capa-row" key={capa.capaId} onClick={() => capa.source === 'audit_response' ? navigate('/action-center') : navigate(`/improvements/${capa.capaId}`)}>
        <div><div className="id-line"><strong>{capa.capaId}</strong><span className={`severity ${String(capa.riskLevel).toLowerCase()}`}>{capa.riskLevel}</span>{capa.autoGenerated && <span className="auto-badge">AUTO</span>}</div><b>{capa.finding}</b><small>{capa.area} · {capa.chapter}</small></div>
        <div><b>{capa.auditId}</b><small>{capa.dishaQuestionNo}{capa.subQuestionNo ? ` Â· Q${capa.subQuestionNo}` : ''}</small></div>
        <div><b>{capa.departmentOwner}</b><small>{capa.locationAspect}</small></div>
        <div><b>{capa.targetDate}</b><small>Created {capa.createdDate}</small></div>
        <div><StatusBadge>{capa.status}</StatusBadge><Progress value={capa.progress || 0} /></div>
      </button>) : <div className="capa-empty"><Target /><strong>No assigned NG improvements found.</strong><span>Audit gaps will appear here automatically.</span></div>}
    </div>
  </>
}
