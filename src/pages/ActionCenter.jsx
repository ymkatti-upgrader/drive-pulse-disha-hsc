import { AlertTriangle, ArrowRight, Bell, CheckCircle2, Clock3, Filter, ShieldAlert, Target, TrendingUp } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAudits } from '../audits/AuditContext'
import { isSystemAdmin, useAuth } from '../auth/AuthContext'
import { PageHeader, StatusBadge } from '../components/UI'
import { useNotifications } from '../notifications/NotificationContext'
import { requireSupabase } from '../supabaseClient'

const filters = ['Today', 'This Week', 'Overdue', 'Critical']
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

function categoryTone(category) {
  if (category.includes('Audit')) return 'blue'
  if (category.includes('Improvement')) return 'red'
  if (category.includes('Verification')) return 'amber'
  if (category.includes('AI Sensei')) return 'green'
  return 'blue'
}

function priorityTone(priority) {
  return priority.toLowerCase()
}

function ActionCard({ title, count, meta, tone, onClick, icon: Icon }) {
  return <button className={`action-summary ${tone}`} onClick={onClick}><span><Icon size={18} /></span><div><strong>{count}</strong><small>{title}</small><p>{meta}</p></div><ArrowRight size={16} /></button>
}

function NotificationRow({ item, onOpen }) {
  return <button className={`action-row ${item.read ? 'read' : ''}`} onClick={() => onOpen(item)}>
    <div className={`action-priority ${priorityTone(item.priority)}`}>{item.priority}</div>
    <div className="action-main">
      <div><strong>{item.title}</strong><StatusBadge>{item.category}</StatusBadge></div>
      <p>{item.detail}</p>
      <small>{item.dateTime} · {item.status}</small>
    </div>
    <ArrowRight size={16} />
  </button>
}

export default function ActionCenter() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits } = useAudits()
  const { notifications, markRead } = useNotifications()
  const [filter, setFilter] = useState('Today')
  const [assignedNgItems, setAssignedNgItems] = useState([])
  const [assignedLoading, setAssignedLoading] = useState(false)
  const [assignedError, setAssignedError] = useState('')
  const [editingNgId, setEditingNgId] = useState('')
  const [actionForm, setActionForm] = useState(emptyActionForm)
  const [actionSaving, setActionSaving] = useState(false)
  const [actionMessage, setActionMessage] = useState('')
  const [refreshAssignedNg, setRefreshAssignedNg] = useState(0)

  const filtered = useMemo(() => {
    const now = new Date()
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
    const weekAgo = startOfDay - 6 * 24 * 60 * 60 * 1000
    return notifications.filter(item => {
      if (filter === 'Today') return item.timestamp >= startOfDay
      if (filter === 'This Week') return item.timestamp >= weekAgo
      if (filter === 'Overdue') return item.priority === 'Critical' || item.title.toLowerCase().includes('overdue')
      if (filter === 'Critical') return item.priority === 'Critical'
      return true
    })
  }, [filter, notifications])

  const grouped = useMemo(() => ({
    pending: filtered.filter(item => ['Root Cause Pending', 'Countermeasure Pending', 'Approval Pending', 'Verification Pending', 'AI Suggestion Awaiting Review'].some(term => item.title.includes(term)) || ['Improvement Action Notifications', 'AI Sensei Notifications', 'Verification Notifications'].includes(item.category)),
    overdue: filtered.filter(item => item.title.includes('Overdue') || item.title.includes('Failed') || item.title.includes('Reopened')),
    approvals: filtered.filter(item => item.title.includes('Approval') || item.title.includes('Yokoten Approved') || item.title.includes('AI Suggestion Accepted')),
    verifications: filtered.filter(item => item.category === 'Verification Notifications'),
    audits: filtered.filter(item => item.category === 'Audit Notifications'),
  }), [filtered])

  useEffect(() => {
    let cancelled = false

    async function loadAssignedNgItems() {
      if (!user?.id) {
        setAssignedNgItems([])
        return
      }

      setAssignedLoading(true)
      setAssignedError('')
      try {
        const client = requireSupabase()
        const adminView = isSystemAdmin(user)
        let query = client
          .from('audit_responses')
          .select('id, audit_id, dq_question_num, sub_question_num, sub_question_text, current_condition_observed, tentative_closing_date, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, result, status, updated_at, audit_location, root_cause, corrective_action_plan, preventive_action_plan, action_taken, closure_remarks, closure_evidence_files, actual_closure_date')
          .eq('result', 'NG')
          .not('status', 'in', '("Closed","Completed","closed","completed")')

        if (!adminView) {
          const filters = [
            `pic_for_ng_user_id.eq.${user.id}`,
            user.mobile_no ? `pic_for_ng_mobile.eq.${user.mobile_no}` : '',
          ].filter(Boolean).join(',')
          query = query.or(filters || `pic_for_ng_user_id.eq.${user.id}`)
        }

        const { data, error } = await query

        if (error) throw error
        if (!cancelled) setAssignedNgItems(data || [])
      } catch (error) {
        if (!cancelled) {
          setAssignedNgItems([])
          setAssignedError(error?.message || 'Unable to load assigned NG items.')
        }
      } finally {
        if (!cancelled) setAssignedLoading(false)
      }
    }

    loadAssignedNgItems()
    return () => {
      cancelled = true
    }
  }, [user, refreshAssignedNg])

  const assignedNgCards = useMemo(() => assignedNgItems.map(item => ({
    id: item.id,
    auditId: item.audit_id || '-',
    location: audits.find(audit => audit.id === item.audit_id)?.location || item.audit_location || '-',
    department: audits.find(audit => audit.id === item.audit_id)?.department || audits.find(audit => audit.id === item.audit_id)?.departments || '-',
    dq: item.dq_question_num || '-',
    subQuestion: item.sub_question_num || '-',
    question: item.sub_question_text || '-',
    condition: item.current_condition_observed || '-',
    closingDate: item.tentative_closing_date || '-',
    pic: item.pic_for_ng_name || item.pic_for_ng_user_id || '-',
    status: item.status || 'Open',
    rootCause: item.root_cause || '',
    correctiveActionPlan: item.corrective_action_plan || '',
    preventiveActionPlan: item.preventive_action_plan || '',
    actionTaken: item.action_taken || '',
    closureRemarks: item.closure_remarks || '',
    closureEvidenceFiles: Array.isArray(item.closure_evidence_files) ? item.closure_evidence_files : [],
    actualClosureDate: item.actual_closure_date || '',
  })), [assignedNgItems, audits])

  function openNotification(item) {
    markRead(item.id)
    navigate(item.actionLink)
  }

  function openActionForm(item) {
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
    if (nextStatus === 'Completed') {
      if (!actionForm.correctiveActionPlan.trim()) pending.push('Corrective Action Plan missing')
      if (!actionForm.actionTaken.trim() && !actionForm.closureRemarks.trim()) pending.push('Action Taken / Closure Remarks missing')
      if (!actionForm.actualClosureDate) pending.push('Actual Closure Date missing')
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
      const { error } = await client.rpc('submit_ng_action_closure', {
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
      if (error) throw error
      setActionMessage(nextStatus === 'Completed' ? 'Action submitted as Completed' : 'Action updated')
      setActionForm(current => ({ ...current, status: nextStatus }))
      setRefreshAssignedNg(current => current + 1)
      if (nextStatus === 'Completed') setEditingNgId('')
    } catch (error) {
      setActionMessage(error?.message || 'Unable to update NG action.')
    } finally {
      setActionSaving(false)
    }
  }

  return <div className="action-center-page">
    <PageHeader eyebrow="ACTION CENTER" title="Notification & Action Center" description="One place to see what needs attention now, this week and beyond." action={<button className="secondary-button" onClick={() => navigate('/dashboard')}><TrendingUp size={18} /> Back to Dashboard</button>} />

    <section className="action-filters card">
      <div className="action-filters-head"><Filter size={18} /><strong>Filters</strong></div>
      <div className="action-filter-group">{filters.map(item => <button key={item} className={filter === item ? 'active' : ''} onClick={() => setFilter(item)}>{item}</button>)}</div>
    </section>

    <section className="action-summary-grid">
      <ActionCard title="My Pending Actions" count={grouped.pending.length} meta="Needs attention" tone="blue" icon={Target} onClick={() => setFilter('Today')} />
      <ActionCard title="My Overdue Actions" count={grouped.overdue.length} meta="Past due or failed" tone="red" icon={AlertTriangle} onClick={() => setFilter('Overdue')} />
      <ActionCard title="My Approvals" count={grouped.approvals.length} meta="Waiting decisions" tone="amber" icon={ShieldAlert} onClick={() => setFilter('This Week')} />
      <ActionCard title="My Verifications" count={grouped.verifications.length} meta="Auditor review queue" tone="green" icon={CheckCircle2} onClick={() => navigate('/verification')} />
      <ActionCard title="My Audits" count={grouped.audits.length} meta="Audit workload" tone="blue" icon={Clock3} onClick={() => navigate('/audits/new')} />
    </section>

    <section className="card action-section-card">
      <div className="panel-head"><div><span className="eyebrow">ASSIGNED NG</span><h2>NG items assigned to me</h2></div><Bell /></div>
      {assignedLoading ? <div className="action-empty">Loading assigned NG items...</div> : assignedError ? <div className="action-empty">{assignedError}</div> : assignedNgCards.length === 0 ? <div className="action-empty">No assigned NG items found.</div> : <div className="audit-review-table">
        <div className="audit-review-row head">
          <span>Audit</span>
          <span>DQ</span>
          <span>Sub</span>
          <span>Question</span>
          <span>Condition</span>
        </div>
        {assignedNgCards.map(item => <div key={item.id} className="action-row">
          <div className="action-priority critical">{item.status}</div>
          <div className="action-main">
            <div><strong>{item.auditId}</strong><StatusBadge>{item.pic}</StatusBadge></div>
            <p>{item.location} · {item.department}</p>
            <small>{item.dq} · Q{item.subQuestion}</small>
            <small>{item.question}</small>
            <small>{item.condition}</small>
            <small>{item.closingDate}</small>
            {editingNgId === item.id && <div className="form-grid wide">
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
                  <button className="secondary-button" type="button" onClick={() => saveNgAction(actionForm.status === 'Completed' ? 'Completed' : 'In Progress')} disabled={actionSaving}>Save Progress</button>
                  <button className="primary-button" type="button" onClick={() => saveNgAction('Completed')} disabled={actionSaving}>Submit Completed</button>
                </div>
              </div>
            </div>}
          </div>
          <div>
            <button className="secondary-button" type="button" onClick={() => navigate(`/audits/${item.auditId}/conduct${item.dq !== '-' ? `?dq=${encodeURIComponent(item.dq)}` : ''}`)}>Open Audit</button>
            <button className="primary-button" type="button" onClick={() => openActionForm(item)}>Update Action</button>
          </div>
        </div>)}
      </div>}
    </section>

    <section className="action-sections-grid">
      <article className="card action-section-card">
        <div className="panel-head"><div><span className="eyebrow">MY PENDING ACTIONS</span><h2>Tasks that need a response</h2></div><Bell /></div>
        {grouped.pending.length === 0 ? <div className="action-empty">No pending actions found for the selected filter.</div> : grouped.pending.map(item => <NotificationRow key={item.id} item={item} onOpen={openNotification} />)}
      </article>

      <article className="card action-section-card">
        <div className="panel-head"><div><span className="eyebrow">MY OVERDUE ACTIONS</span><h2>Items that need escalation</h2></div><AlertTriangle /></div>
        {grouped.overdue.length === 0 ? <div className="action-empty">No overdue items found for the selected filter.</div> : grouped.overdue.map(item => <NotificationRow key={item.id} item={item} onOpen={openNotification} />)}
      </article>

      <article className="card action-section-card">
        <div className="panel-head"><div><span className="eyebrow">MY APPROVALS</span><h2>Pending leadership decisions</h2></div><ShieldAlert /></div>
        {grouped.approvals.length === 0 ? <div className="action-empty">No approvals found for the selected filter.</div> : grouped.approvals.map(item => <NotificationRow key={item.id} item={item} onOpen={openNotification} />)}
      </article>

      <article className="card action-section-card">
        <div className="panel-head"><div><span className="eyebrow">MY VERIFICATIONS</span><h2>Waiting for auditor closure review</h2></div><CheckCircle2 /></div>
        {grouped.verifications.length === 0 ? <div className="action-empty">No verification items found for the selected filter.</div> : grouped.verifications.map(item => <NotificationRow key={item.id} item={item} onOpen={openNotification} />)}
      </article>

      <article className="card action-section-card">
        <div className="panel-head"><div><span className="eyebrow">MY AUDITS</span><h2>Audit related notifications</h2></div><Clock3 /></div>
        {grouped.audits.length === 0 ? <div className="action-empty">No audit items found for the selected filter.</div> : grouped.audits.map(item => <NotificationRow key={item.id} item={item} onOpen={openNotification} />)}
      </article>
    </section>
  </div>
}
