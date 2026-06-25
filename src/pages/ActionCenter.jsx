import { AlertTriangle, ArrowRight, Bell, CheckCircle2, Clock3, ShieldAlert, Target, TrendingUp } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAudits } from '../audits/AuditContext'
import { canAccessAuditModule, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { PageHeader, StatusBadge } from '../components/UI'
import { requireSupabase } from '../supabaseClient'

const emptyActionForm = {
  rootCause: '',
  correctiveActionPlan: '',
  preventiveActionPlan: '',
  actionTaken: '',
  closureRemarks: '',
  actualClosureDate: '',
  status: 'Open',
  closureEvidenceFiles: [],
}

function normalizeText(value) {
  return String(value || '').trim().toLowerCase()
}

function cleanText(value) {
  return String(value ?? '')
    .replace(/[\u00c2\ufffd]/g, '')
    .replace(/\u00c3\u201a/g, '')
    .replace(/\s*\u00b7\s*/g, ' | ')
    .replace(/\s+/g, ' ')
    .replace(/\s*-\s*-\s*/g, ' - ')
    .trim()
}

function isUuid(value) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(String(value || '').trim())
}

function formatDate(value) {
  const text = cleanText(value)
  if (!text || text === '-') return ''
  return text.slice(0, 10)
}

function safeJoin(parts, separator = ' | ') {
  return parts.map(cleanText).filter(part => part && part !== '-' && !isUuid(part)).join(separator)
}

function cleanDisplayValue(value, fallback = 'Not available') {
  const text = cleanText(value)
  if (!text || text === '-' || isUuid(text)) return fallback
  return text
}

function shortDepartment(value) {
  const text = cleanDisplayValue(value, '')
  if (!text) return 'Not available'
  const departments = text.split(',').map(part => cleanText(part)).filter(Boolean)
  const visible = departments.slice(0, 2).join(', ')
  return departments.length > 2 ? `${visible}...` : visible
}

function getDisplayName(value) {
  const text = cleanText(value)
  if (!text || isUuid(text)) return 'Not available'
  return text.split(/\s*(?:\||\u00b7|,)\s*/).map(cleanText).find(part => part && !isUuid(part)) || 'Not available'
}

function getPicParts(value) {
  const parts = cleanText(value).split(/\s*(?:\||\u00b7|,)\s*/).map(cleanText).filter(Boolean)
  return {
    name: getDisplayName(value),
    role: parts.find(part => /pic|hod|admin|auditor|functional/i.test(part) && !isUuid(part)) || '',
    location: parts.find(part => /^BL/i.test(part)) || '',
  }
}

function getAuditDisplayId(value) {
  const text = cleanText(value)
  if (!text || isUuid(text)) return 'Not available'
  return text
}

function getSubQuestionLabel(value) {
  const text = cleanText(value).replace(/^Q/i, '')
  if (!text || text === '-') return 'Not available'
  return `Q${text}`
}

function auditBelongsToUser(audit, user) {
  if (!audit || !user) return false
  const userName = normalizeText(user.employee_name || user.name || user.full_name)
  return [audit.created_by, audit.createdBy, audit.auditor_id, audit.auditorId, audit.auditor_user_id, audit.auditorUserId].some(value => value && value === user.id)
    || [audit.auditor_name, audit.auditorName, audit.owner, audit.createdByName].some(value => normalizeText(value) && normalizeText(value) === userName)
}

function responseBelongsToPic(item, user) {
  return item.pic_for_ng_user_id === user?.id || (user?.mobile_no && item.pic_for_ng_mobile === user.mobile_no)
}

function responseBelongsToAuditor(item, audit, user) {
  return item.responded_by === user?.id || auditBelongsToUser(audit, user)
}

function isCompletedStatus(status) {
  return ['completed', 'closed'].includes(normalizeText(status))
}

function isInProgressStatus(status) {
  return normalizeText(status) === 'in progress'
}

function isOverdue(item) {
  if (!item.closingDate || isCompletedStatus(item.status)) return false
  const dueDate = new Date(item.closingDate)
  if (Number.isNaN(dueDate.getTime())) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return dueDate < today
}

function ActionCard({ title, count, meta, tone, onClick, icon: Icon }) {
  return <button className={`action-summary ${tone}`} onClick={onClick}><span><Icon size={18} /></span><div><strong>{count}</strong><small>{title}</small><p>{meta}</p></div><ArrowRight size={16} /></button>
}

export default function ActionCenter() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits } = useAudits()
  const [activeTab, setActiveTab] = useState('assigned')
  const [ngItems, setNgItems] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [editingNgId, setEditingNgId] = useState('')
  const [detailNgId, setDetailNgId] = useState('')
  const [actionForm, setActionForm] = useState(emptyActionForm)
  const [actionSaving, setActionSaving] = useState(false)
  const [actionMessage, setActionMessage] = useState('')
  const [refreshKey, setRefreshKey] = useState(0)
  const adminView = isSystemAdmin(user)
  const auditorView = canAccessAuditModule(user)

  useEffect(() => {
    let cancelled = false

    async function loadNgItems() {
      if (!user?.id) {
        setNgItems([])
        return
      }

      setLoading(true)
      setError('')
      try {
        const client = requireSupabase()
        let query = client
          .from('audit_responses')
          .select('id, audit_id, checklist_id, dq_question_num, sub_question_num, sub_question_text, current_condition_observed, tentative_closing_date, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, result, status, updated_at, audit_location, root_cause, corrective_action_plan, preventive_action_plan, action_taken, closure_remarks, closure_evidence_files, actual_closure_date, completed_at, completed_by, responded_by')
          .eq('result', 'NG')

        if (!adminView && !auditorView) {
          const assignedFilters = [
            `pic_for_ng_user_id.eq.${user.id}`,
            user.mobile_no ? `pic_for_ng_mobile.eq.${user.mobile_no}` : '',
          ].filter(Boolean).join(',')
          query = query.or(assignedFilters || `pic_for_ng_user_id.eq.${user.id}`)
        }

        const { data, error: fetchError } = await query
        if (fetchError) throw fetchError

        if (!cancelled) {
          const scopedRows = adminView ? data || [] : (data || []).filter(item => {
            const audit = audits.find(auditItem => auditItem.id === item.audit_id)
            return responseBelongsToPic(item, user) || (auditorView && responseBelongsToAuditor(item, audit, user))
          })
          setNgItems(scopedRows)
        }
      } catch (loadError) {
        if (!cancelled) {
          setNgItems([])
          setError(loadError?.message || 'Unable to load Disha Action Hub.')
        }
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    loadNgItems()
    return () => {
      cancelled = true
    }
  }, [adminView, auditorView, user, audits, refreshKey])

  const hubCards = useMemo(() => ngItems.map(item => {
    const audit = audits.find(auditItem => auditItem.id === item.audit_id) || {}
    const fullDepartment = audit.department || (Array.isArray(audit.departments) ? audit.departments.join(', ') : audit.departments) || ''
    const picParts = getPicParts(item.pic_for_ng_name || item.pic_for_ng_user_id || '')
    const card = {
      id: item.id,
      rawAuditId: item.audit_id || '',
      auditId: getAuditDisplayId(item.audit_id),
      location: cleanDisplayValue(audit.location || item.audit_location),
      department: shortDepartment(fullDepartment),
      fullDepartment: cleanDisplayValue(fullDepartment),
      auditType: cleanDisplayValue(audit.audit_type || audit.auditType),
      auditorName: cleanDisplayValue(audit.auditor_name || audit.auditorName || audit.owner),
      auditStartDate: formatDate(audit.audit_start_date || audit.auditStartDate || audit.scheduledDate || audit.createdAt) || 'Not available',
      dq: cleanDisplayValue(item.dq_question_num),
      subQuestion: getSubQuestionLabel(item.sub_question_num),
      question: cleanDisplayValue(item.sub_question_text),
      condition: cleanDisplayValue(item.current_condition_observed),
      closingDate: formatDate(item.tentative_closing_date) || 'Not available',
      pic: picParts.name,
      picRole: picParts.role,
      picLocation: picParts.location,
      status: cleanDisplayValue(item.status, 'Open'),
      rootCause: cleanText(item.root_cause),
      correctiveActionPlan: cleanText(item.corrective_action_plan),
      preventiveActionPlan: cleanText(item.preventive_action_plan),
      actionTaken: cleanText(item.action_taken),
      closureRemarks: cleanText(item.closure_remarks),
      closureEvidenceFiles: Array.isArray(item.closure_evidence_files) ? item.closure_evidence_files : [],
      actualClosureDate: formatDate(item.actual_closure_date),
      completedAt: formatDate(item.completed_at),
      completedBy: item.completed_by || '',
      respondedBy: item.responded_by || '',
      isAssigned: responseBelongsToPic(item, user),
      isRaisedByMe: responseBelongsToAuditor(item, audit, user),
    }
    return { ...card, overdue: isOverdue(card), completed: isCompletedStatus(card.status), inProgress: isInProgressStatus(card.status) }
  }), [ngItems, audits, user])

  const visibleTabs = useMemo(() => {
    const tabs = []
    if (!adminView) tabs.push({ key: 'assigned', label: 'Assigned to Me', count: hubCards.filter(item => item.isAssigned).length })
    if (auditorView || adminView) tabs.push({ key: 'raised', label: 'Raised by Me / Auditor View', count: hubCards.filter(item => item.isRaisedByMe).length })
    if (adminView) tabs.push({ key: 'all', label: 'All NG Actions', count: hubCards.length })
    tabs.push({ key: 'inProgress', label: 'In Progress', count: hubCards.filter(item => item.inProgress).length })
    tabs.push({ key: 'completed', label: 'Completed / Closed', count: hubCards.filter(item => item.completed).length })
    tabs.push({ key: 'overdue', label: 'Overdue', count: hubCards.filter(item => item.overdue).length })
    return tabs
  }, [adminView, auditorView, hubCards])

  useEffect(() => {
    if (visibleTabs.length && !visibleTabs.some(tab => tab.key === activeTab)) {
      setActiveTab(visibleTabs[0].key)
    }
  }, [activeTab, visibleTabs])

  const hubRows = useMemo(() => {
    if (activeTab === 'raised') return hubCards.filter(item => item.isRaisedByMe)
    if (activeTab === 'all') return hubCards
    if (activeTab === 'inProgress') return hubCards.filter(item => item.inProgress)
    if (activeTab === 'completed') return hubCards.filter(item => item.completed)
    if (activeTab === 'overdue') return hubCards.filter(item => item.overdue)
    return hubCards.filter(item => adminView || item.isAssigned)
  }, [activeTab, adminView, hubCards])

  function openActionForm(item) {
    if (!adminView && !item.isAssigned) {
      setActionMessage('Only the assigned NG PIC or System Admin can update this action.')
      return
    }
    setEditingNgId(item.id)
    setActionMessage('')
    setActionForm({
      rootCause: item.rootCause || '',
      correctiveActionPlan: item.correctiveActionPlan || '',
      preventiveActionPlan: item.preventiveActionPlan || '',
      actionTaken: item.actionTaken || '',
      closureRemarks: item.closureRemarks || '',
      actualClosureDate: item.actualClosureDate || '',
      status: item.status || 'Open',
      closureEvidenceFiles: item.closureEvidenceFiles || [],
    })
  }

  function updateActionForm(field, value) {
    setActionForm(current => ({ ...current, [field]: value }))
  }

  function handleClosureEvidence(event) {
    const files = Array.from(event.target.files || []).map(file => ({
      name: file.name,
      size: file.size,
      type: file.type,
      capturedAt: new Date().toISOString(),
    }))
    if (files.length) {
      setActionForm(current => ({ ...current, closureEvidenceFiles: [...(current.closureEvidenceFiles || []), ...files] }))
    }
    event.target.value = ''
  }

  function validateNgAction(nextStatus) {
    const pending = []
    const hasAnyActionField = [
      actionForm.rootCause,
      actionForm.correctiveActionPlan,
      actionForm.preventiveActionPlan,
      actionForm.actionTaken,
      actionForm.closureRemarks,
    ].some(value => value.trim())

    if (nextStatus === 'Completed') {
      if (!actionForm.rootCause.trim()) pending.push('Root Cause missing')
      if (!actionForm.correctiveActionPlan.trim()) pending.push('Corrective Action Plan missing')
      if (!actionForm.actionTaken.trim() && !actionForm.closureRemarks.trim()) pending.push('Action Taken / Closure Remarks missing')
      if (!actionForm.actualClosureDate) pending.push('Actual Closure Date missing')
    } else if (nextStatus === 'In Progress' && !hasAnyActionField) {
      pending.push('Enter at least one action field before saving In Progress')
    }
    return pending
  }

  async function saveNgAction(nextStatus = actionForm.status) {
    if (!editingNgId || !user?.id) return
    const pending = validateNgAction(nextStatus)
    if (pending.length) {
      setActionMessage(pending.join('\n'))
      return
    }

    setActionSaving(true)
    setActionMessage('')
    try {
      const client = requireSupabase()
      const { error: saveError } = await client.rpc('submit_ng_action_closure', {
        p_response_id: editingNgId,
        p_user_id: user.id,
        p_root_cause: actionForm.rootCause || null,
        p_corrective_action_plan: actionForm.correctiveActionPlan || null,
        p_preventive_action_plan: actionForm.preventiveActionPlan || null,
        p_action_taken: actionForm.actionTaken || null,
        p_closure_remarks: actionForm.closureRemarks || null,
        p_actual_closure_date: actionForm.actualClosureDate || null,
        p_status: nextStatus,
        p_closure_evidence_files: actionForm.closureEvidenceFiles || [],
      })
      if (saveError) throw saveError
      setActionMessage(nextStatus === 'Completed' ? 'Action submitted as Completed' : 'Action updated')
      setActionForm(current => ({ ...current, status: nextStatus }))
      setRefreshKey(current => current + 1)
      if (nextStatus === 'Completed') setEditingNgId('')
    } catch (saveError) {
      setActionMessage(saveError?.message || 'Unable to update NG action.')
    } finally {
      setActionSaving(false)
    }
  }

  return <div className="action-center-page">
    <PageHeader eyebrow="DISHA ACTION HUB" title="Disha Action Hub" description="Convert NG points into root cause, corrective action, preventive action, evidence and closure tracking." action={<button className="secondary-button" onClick={() => navigate('/dashboard')}><TrendingUp size={18} /> Back to Dashboard</button>} />

    <section className="action-summary-grid">
      <ActionCard title="Assigned to Me" count={hubCards.filter(item => item.isAssigned).length} meta="My NG actions" tone="blue" icon={Target} onClick={() => setActiveTab('assigned')} />
      <ActionCard title="In Progress" count={hubCards.filter(item => item.inProgress).length} meta="Action work started" tone="amber" icon={Clock3} onClick={() => setActiveTab('inProgress')} />
      <ActionCard title="Completed / Closed" count={hubCards.filter(item => item.completed).length} meta="Closure submitted" tone="green" icon={CheckCircle2} onClick={() => setActiveTab('completed')} />
      <ActionCard title="Overdue" count={hubCards.filter(item => item.overdue).length} meta="Past tentative date" tone="red" icon={AlertTriangle} onClick={() => setActiveTab('overdue')} />
      {adminView && <ActionCard title="All NG Actions" count={hubCards.length} meta="Admin view" tone="blue" icon={ShieldAlert} onClick={() => setActiveTab('all')} />}
    </section>

    <section className="card action-section-card">
      <div className="panel-head"><div><span className="eyebrow">NG ACTION WORKFLOW</span><h2>Audit NG action items</h2></div><Bell /></div>
      <div className="tabs">{visibleTabs.map(tab => <button className={activeTab === tab.key ? 'active' : ''} onClick={() => setActiveTab(tab.key)} key={tab.key}>{tab.label} <span>{tab.count}</span></button>)}</div>
      {loading ? <div className="action-empty">Loading Disha Action Hub...</div> : error ? <div className="action-empty">{error}</div> : hubRows.length === 0 ? <div className="action-empty">No NG actions found for this view.</div> : <div className="audit-review-table">
        <div className="audit-review-row head">
          <span>Audit</span>
          <span>DQ</span>
          <span>Sub</span>
          <span>Issue</span>
          <span>Status</span>
        </div>
        {hubRows.map(item => {
          const canUpdate = adminView || item.isAssigned
          return <div key={item.id} className="action-row">
            <div className={`action-priority ${item.overdue ? 'critical' : item.completed ? 'normal' : 'high'}`}>{item.overdue ? 'Overdue' : item.status}</div>
            <div className="action-main">
              <div><strong>Status: {item.status}</strong>{item.actualClosureDate && <StatusBadge>Closed {item.actualClosureDate}</StatusBadge>}</div>
              <p>Audit: {item.auditId}</p>
              <small>Location: {item.location}</small>
              <small>Department: {item.department}</small>
              <small>DQ: {safeJoin([item.dq, item.subQuestion])}</small>
              <small>Question: {item.question}</small>
              <small>Condition: {item.condition}</small>
              <small>Assigned PIC: {item.pic}</small>
              <small>Target Date: {item.closingDate}{item.actualClosureDate ? ` | Actual Closure Date: ${item.actualClosureDate}` : ''}</small>
              {detailNgId === item.id && <section className="capa-detail-fields">
                <div><span>Audit</span><strong>{item.auditId}</strong></div>
                <div><span>Location</span><strong>{item.location}</strong></div>
                <div><span>Department</span><strong>{item.fullDepartment}</strong></div>
                <div><span>Auditor</span><strong>{item.auditorName}</strong></div>
                <div><span>Audit Type</span><strong>{item.auditType}</strong></div>
                <div><span>Audit Start Date</span><strong>{item.auditStartDate}</strong></div>
                <div><span>DQ Number</span><strong>{item.dq}</strong></div>
                <div><span>Sub-question Number</span><strong>{item.subQuestion}</strong></div>
                <div><span>Sub-question Text</span><strong>{item.question}</strong></div>
                <div><span>Assigned PIC</span><strong>{item.pic}</strong></div>
                {item.picRole && <div><span>Role</span><strong>{item.picRole}</strong></div>}
                {item.picLocation && <div><span>PIC Location</span><strong>{item.picLocation}</strong></div>}
                <div><span>Current Condition / Gap Observed</span><strong>{item.condition}</strong></div>
                <div><span>Tentative Closing Date</span><strong>{item.closingDate}</strong></div>
                <div><span>Root Cause</span><strong>{item.rootCause || 'Not available'}</strong></div>
                <div><span>Corrective Action Plan</span><strong>{item.correctiveActionPlan || 'Not available'}</strong></div>
                <div><span>Preventive Action Plan</span><strong>{item.preventiveActionPlan || 'Not available'}</strong></div>
                <div><span>Action Taken / Closure Remarks</span><strong>{item.actionTaken || item.closureRemarks || 'Not available'}</strong></div>
                <div><span>Actual Closure Date</span><strong>{item.actualClosureDate || 'Not available'}</strong></div>
                <div><span>Current Status</span><strong>{item.status}</strong></div>
              </section>}
              {editingNgId === item.id && <section className="form-grid wide">
                <label className="wide">Root Cause
                  <textarea rows="2" value={actionForm.rootCause} onChange={event => updateActionForm('rootCause', event.target.value)} placeholder="Enter root cause" />
                </label>
                <label className="wide">Corrective Action Plan
                  <textarea rows="2" value={actionForm.correctiveActionPlan} onChange={event => updateActionForm('correctiveActionPlan', event.target.value)} placeholder="Enter corrective action plan" />
                </label>
                <label className="wide">Preventive Action Plan
                  <textarea rows="2" value={actionForm.preventiveActionPlan} onChange={event => updateActionForm('preventiveActionPlan', event.target.value)} placeholder="Optional preventive action" />
                </label>
                <label className="wide">Action Taken
                  <textarea rows="2" value={actionForm.actionTaken} onChange={event => updateActionForm('actionTaken', event.target.value)} placeholder="Enter action taken" />
                </label>
                <label className="wide">Closure Remarks
                  <textarea rows="2" value={actionForm.closureRemarks} onChange={event => updateActionForm('closureRemarks', event.target.value)} placeholder="Enter closure remarks" />
                </label>
                <label>Status
                  <select value={actionForm.status} onChange={event => updateActionForm('status', event.target.value)}>
                    <option>Open</option>
                    <option>In Progress</option>
                    <option>Completed</option>
                  </select>
                </label>
                <label>Actual Closure Date
                  <input type="date" value={actionForm.actualClosureDate} onChange={event => updateActionForm('actualClosureDate', event.target.value)} />
                </label>
                <label className="wide">Closure Evidence
                  <input type="file" multiple onChange={handleClosureEvidence} />
                  {(actionForm.closureEvidenceFiles || []).length > 0 && <small>{actionForm.closureEvidenceFiles.map(file => file.name || file).join(', ')}</small>}
                </label>
                {actionMessage && <div className="wide audit-checklist-note" role="alert"><span>{actionMessage}</span></div>}
                <div className="wide form-footer">
                  <button className="secondary-button" type="button" onClick={() => setEditingNgId('')} disabled={actionSaving}>Cancel</button>
                  <div>
                    <button className="secondary-button" type="button" onClick={() => saveNgAction(actionForm.status)} disabled={actionSaving}>Save Progress</button>
                    <button className="primary-button" type="button" onClick={() => saveNgAction('Completed')} disabled={actionSaving}>Submit Completed</button>
                  </div>
                </div>
              </section>}
            </div>
            <div>
              <button className="secondary-button" type="button" onClick={() => navigate(`/audits/${item.rawAuditId}/conduct${item.dq !== 'Not available' ? `?dq=${encodeURIComponent(item.dq)}` : ''}`)}>Open Audit</button>
              <button className="secondary-button" type="button" onClick={() => setDetailNgId(current => current === item.id ? '' : item.id)}>View Details</button>
              {canUpdate ? <button className="primary-button" type="button" onClick={() => openActionForm(item)}>Update Action</button> : <span className="action-empty">View only</span>}
            </div>
          </div>
        })}
      </div>}
    </section>
  </div>
}
