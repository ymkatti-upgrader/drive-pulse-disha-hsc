import { ArrowRight, Bell, CheckCircle2, Clock3, Plus, ShieldAlert, Target, TrendingUp, X } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAudits } from '../audits/AuditContext'
import { canAccessAuditModule, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { PageHeader, StatusBadge } from '../components/UI'
import { requireSupabase } from '../supabaseClient'

const causeCategories = ['Manpower', 'Method', 'Machine / Equipment', 'Material', 'Environment', 'Measurement / Monitoring', 'Others']
const actionStatuses = ['Open', 'In Progress', 'Completed']
const supportStatuses = ['Pending', 'In Progress', 'Completed']
const supportDepartments = ['Sales', 'Service', 'U-Trust', 'VAS', 'Accessories', 'HR', 'Admin', 'Finance', 'Accounts', 'CRE / Customer Relations', 'Body & Paint', 'Parts', 'IT', 'Others']
const expenseCategories = ['Repair', 'Replacement', 'Facility Improvement', 'Tools / Equipment', 'Vendor Support', 'Customer Support', 'Safety / Compliance', 'Others']
const CEO_EXPENSE_APPROVAL_THRESHOLD = 10000

const emptyActionForm = {
  causeCategory: '',
  rootCause: '',
  actionPlanItems: [],
  actionTaken: '',
  closureRemarks: '',
  actualClosureDate: '',
  closureEvidenceFiles: [],
  collaborationRequired: false,
  collaboratorUserId: '',
  supportDepartment: '',
  supportRequired: '',
  supportRemarks: '',
  supportStatus: 'Pending',
  monetarySupportRequired: false,
  expectedExpenseAmount: '',
  expensePurpose: '',
  expenseCategory: '',
  reviewComments: '',
  extensionRequestedDate: '',
  extensionReason: '',
}

function normalizeText(value) {
  return String(value || '').trim().toLowerCase()
}

function normalizeMobile(value) {
  const digits = String(value || '')
    .replace(/\s+/g, '')
    .replace(/^\+91/, '')
    .replace(/^91(?=\d{10,}$)/, '')
    .replace(/\D/g, '')
  if (!digits) return ''
  return digits.length > 10 ? digits.slice(-10) : digits
}

function cleanText(value) {
  return String(value ?? '')
    .replace(/[\u00c2\ufffd]/g, '')
    .replace(/\u00c3\u201a/g, '')
    .replace(/\s*\u00b7\s*/g, ' | ')
    .replace(/\s+/g, ' ')
    .trim()
}

function isUuid(value) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(String(value || '').trim())
}

function cleanDisplayValue(value, fallback = 'Not available') {
  const text = cleanText(value)
  if (!text || text === '-' || isUuid(text)) return fallback
  return text
}

function formatDate(value) {
  const text = cleanText(value)
  if (!text || text === '-' || isUuid(text)) return ''
  return text.slice(0, 10)
}

function safeJoin(parts, separator = ' | ') {
  return parts.map(part => cleanDisplayValue(part, '')).filter(Boolean).join(separator)
}

function getDisplayName(value) {
  const text = cleanText(value)
  if (!text || isUuid(text)) return 'Not available'
  return text.split(/\s*(?:\||\u00b7|,)\s*/).map(cleanText).find(part => part && !isUuid(part)) || 'Not available'
}

function shortDepartment(value) {
  const text = cleanDisplayValue(value, '')
  if (!text) return 'Not available'
  const departments = text.split(',').map(part => cleanText(part)).filter(Boolean)
  return departments.length > 2 ? `${departments.slice(0, 2).join(', ')}...` : departments.join(', ')
}

function getSubQuestionLabel(value) {
  const text = cleanText(value).replace(/^Q/i, '')
  return text && text !== '-' ? `Q${text}` : 'Not available'
}

function hasRole(user, terms) {
  return (user?.access || []).some(mapping => {
    const role = normalizeText(mapping.role)
    const userType = normalizeText(mapping.user_type)
    return terms.some(term => role.includes(term) || userType.includes(term))
  })
}

function isAssignedToUser(row, currentUser) {
  if (!row || !currentUser) return false
  if (row.pic_for_ng_user_id && row.pic_for_ng_user_id === currentUser.id) return true
  const rowMobile = normalizeMobile(row.pic_for_ng_mobile)
  const userMobile = normalizeMobile(currentUser.mobile_no || currentUser.mobile)
  if (rowMobile && userMobile && rowMobile === userMobile) return true
  const rowName = normalizeText(row.pic_for_ng_name || row.pic_for_ng)
  const userName = normalizeText(currentUser.employee_name || currentUser.name || currentUser.full_name)
  return Boolean(rowName && userName && rowName === userName)
}

function isCollaboratorForUser(row, currentUser) {
  if (!row || !currentUser) return false
  if (row.collaborator_user_id && row.collaborator_user_id === currentUser.id) return true
  const rowMobile = normalizeMobile(row.collaborator_mobile)
  const userMobile = normalizeMobile(currentUser.mobile_no || currentUser.mobile)
  return Boolean(rowMobile && userMobile && rowMobile === userMobile)
}

function isExpenseApprover(user) {
  return isSystemAdmin(user) || hasRole(user, ['group disha', 'group functional hod', 'functional hod', 'ceo'])
}

function getExpenseApprovalRole(user) {
  if (isSystemAdmin(user)) return 'System Admin'
  if (hasRole(user, ['ceo'])) return 'CEO'
  if (hasRole(user, ['group functional hod', 'functional hod'])) return 'Group Functional HOD'
  return 'Group DISHA HSC PIC'
}

function expenseStatus(row = {}) {
  const text = cleanText(row.expense_approval_status)
  if (text) return text
  return row.monetary_support_required ? 'Pending Approval' : 'Not Required'
}

function formatMoney(value) {
  const amount = Number(value)
  if (!Number.isFinite(amount) || amount <= 0) return 'Not available'
  return `INR ${amount.toLocaleString('en-IN')}`
}

function personOptionLabel(person) {
  const name = cleanDisplayValue(person.employee_name || person.name || person.full_name || person.mobile_no)
  const meta = safeJoin([person.department, person.location, person.mobile_no], ' - ')
  return meta ? `${name} - ${meta}` : name
}

function auditBelongsToUser(audit, user) {
  if (!audit || !user) return false
  const userName = normalizeText(user.employee_name || user.name || user.full_name)
  return [audit.created_by, audit.createdBy, audit.auditor_id, audit.auditorId, audit.auditor_user_id, audit.auditorUserId].some(value => value && value === user.id)
    || [audit.auditor_name, audit.auditorName, audit.owner, audit.createdByName].some(value => normalizeText(value) && normalizeText(value) === userName)
}

function getSimpleStatus(status, row = {}) {
  const value = normalizeText(status)
  if (!value || ['open', 'assigned', 'assigned to ng pic', 'ng identified'].includes(value)) return 'Assigned'
  if (['root cause updated', 'action plan created', 'planning'].includes(value)) return 'Planning'
  if (['in progress', 'collaboration in progress', 'co-assigned'].includes(value)) return 'In Progress'
  if (['closure requested', 'submitted for review', 'pending approval'].includes(value)) return 'Submitted for Review'
  if (['rejected', 'send back', 'sent back', 'reassigned', 'reassigned by group disha', 'rejected by ceo'].includes(value)) return 'Reassigned'
  if (['completed', 'closed', 'closed by ceo', 'approved', 'approved closed'].includes(value)) return 'Closed'
  return 'Assigned'
}

function buildAssignedFilters(currentUser) {
  const filters = []
  if (currentUser?.id) filters.push(`pic_for_ng_user_id.eq.${currentUser.id}`)
  const mobileCandidates = [
    currentUser?.mobile_no,
    currentUser?.mobile,
    normalizeMobile(currentUser?.mobile_no || currentUser?.mobile || ''),
  ].map(value => String(value || '').trim()).filter(Boolean)
  mobileCandidates.forEach(value => {
    if (!filters.includes(`pic_for_ng_mobile.eq.${value}`)) filters.push(`pic_for_ng_mobile.eq.${value}`)
  })
  return filters.join(',')
}

function isClosedStatus(status) {
  return getSimpleStatus(status) === 'Closed'
}

function isOverdue(item) {
  if (!item.targetDate || isClosedStatus(item.status)) return false
  const due = new Date(item.targetDate)
  if (Number.isNaN(due.getTime())) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return due < today
}

function ActionCard({ title, count, meta, tone, onClick, icon: Icon }) {
  return <button className={`action-summary ${tone}`} onClick={onClick}><span><Icon size={17} /></span><div><strong>{count}</strong><small>{title}</small><p>{meta}</p></div><ArrowRight size={15} /></button>
}

function buildEmptyPlanRow() {
  return { id: `plan-${Date.now()}`, action: '', responsiblePerson: '', targetDate: '', status: 'Open' }
}

export default function ActionCenter() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits } = useAudits()
  const [activeTab, setActiveTab] = useState('assigned')
  const [ngItems, setNgItems] = useState([])
  const [people, setPeople] = useState([])
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
  const reviewerView = hasRole(user, ['group disha', 'group disha hsc pic', 'system admin', 'super admin'])
  const expenseApproverView = isExpenseApprover(user)

  useEffect(() => {
    let cancelled = false
    async function loadPeople() {
      try {
        const client = requireSupabase()
        const { data, error: loadError } = await client.from('app_users').select('*').eq('active', true)
        if (loadError) throw loadError
        if (!cancelled) setPeople(data || [])
      } catch {
        if (!cancelled) setPeople([])
      }
    }
    loadPeople()
    return () => { cancelled = true }
  }, [])

  useEffect(() => {
    let cancelled = false

    async function loadNgItems() {
      const currentUser = user
      if (!currentUser?.id) {
        setNgItems([])
        return
      }

      setLoading(true)
      setError('')
      try {
        const client = requireSupabase()
        console.log('Disha current user', currentUser)
        console.log('Disha role/userType', currentUser?.role, currentUser?.user_type)
        console.log('Assigned NG query user id', currentUser?.id)
        console.log('Assigned NG query mobile', currentUser?.mobile_no)
        console.log('Assigned NG query name', currentUser?.employee_name)

        const stableSelect = 'id, audit_id, checklist_id, dq_question_num, sub_question_num, result, current_condition_observed, tentative_closing_date, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, status, responded_by, created_at, updated_at, sub_question_text, audit_location, pic_for_ng'
        const allNgResult = await client
          .from('audit_responses')
          .select(stableSelect)
          .eq('result', 'NG')
        if (allNgResult.error) throw allNgResult.error

        if (!cancelled) {
          const rows = allNgResult.data || []
          console.log('All NG rows count', rows?.length)
          console.log('Sample NG rows', rows?.slice(0, 5))
          const assignedRows = rows.filter(item => isAssignedToUser(item, currentUser))
          const statusCounts = rows.reduce((counts, item) => {
            const status = getSimpleStatus(item.status, item)
            counts[status] = (counts[status] || 0) + 1
            return counts
          }, {})
          console.log('Total NG rows fetched', rows?.length)
          console.log('Assigned to me rows', assignedRows?.length)
          console.log('Filter status counts', statusCounts)
          if (!assignedRows.length) console.warn('No assigned NG items found for user', currentUser)
          setNgItems(rows)
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
    return () => { cancelled = true }
  }, [adminView, auditorView, reviewerView, expenseApproverView, user, audits, refreshKey])

  const hubCards = useMemo(() => ngItems.map(item => {
    const audit = audits.find(auditItem => auditItem.id === item.audit_id) || {}
    const fullDepartment = audit.department || (Array.isArray(audit.departments) ? audit.departments.join(', ') : audit.departments) || ''
    const status = getSimpleStatus(item.status, item)
    const targetDate = formatDate(item.tentative_closing_date) || 'Not available'
    const card = {
      id: item.id,
      rawAuditId: item.audit_id || '',
      auditId: isUuid(item.audit_id) ? 'Not available' : cleanDisplayValue(item.audit_id),
      location: cleanDisplayValue(audit.location || item.audit_location),
      department: shortDepartment(fullDepartment),
      fullDepartment: cleanDisplayValue(fullDepartment),
      auditType: cleanDisplayValue(audit.audit_type || audit.auditType),
      auditorName: cleanDisplayValue(audit.auditor_name || audit.auditorName || audit.owner),
      dq: cleanDisplayValue(item.dq_question_num),
      subQuestion: getSubQuestionLabel(item.sub_question_num),
      question: cleanDisplayValue(item.sub_question_text),
      condition: cleanDisplayValue(item.current_condition_observed),
      assignedPic: getDisplayName(item.pic_for_ng_name || item.pic_for_ng_user_id),
      targetDate,
      status,
      causeCategory: cleanText(item.cause_category),
      rootCause: cleanText(item.root_cause),
      actionPlanItems: Array.isArray(item.action_plan_items) ? item.action_plan_items : [],
      correctiveActionPlan: cleanText(item.corrective_action_plan),
      preventiveActionPlan: cleanText(item.preventive_action_plan),
      actionTaken: cleanText(item.action_taken),
      closureRemarks: cleanText(item.closure_remarks),
      closureEvidenceFiles: Array.isArray(item.closure_evidence_files) ? item.closure_evidence_files : [],
      actualClosureDate: formatDate(item.actual_closure_date),
      collaborationRequired: Boolean(item.collaboration_required),
      collaboratorUserId: item.collaborator_user_id || '',
      collaboratorName: cleanText(item.collaborator_name),
      collaboratorMobile: cleanText(item.collaborator_mobile),
      supportDepartment: cleanText(item.support_department),
      supportRequired: cleanText(item.support_required),
      supportRemarks: cleanText(item.support_remarks),
      supportStatus: cleanText(item.support_status) || 'Pending',
      monetarySupportRequired: Boolean(item.monetary_support_required),
      expectedExpenseAmount: item.expected_expense_amount || '',
      expensePurpose: cleanText(item.expense_purpose),
      expenseCategory: cleanText(item.expense_category),
      expenseApprovalStatus: expenseStatus(item),
      groupDishaApprovalStatus: cleanText(item.group_disha_approval_status) || 'Pending',
      functionalHodApprovalStatus: cleanText(item.functional_hod_approval_status) || 'Pending',
      ceoApprovalRequired: Boolean(item.ceo_approval_required),
      ceoApprovalStatus: cleanText(item.ceo_approval_status) || 'Pending',
      extensionRequestStatus: cleanText(item.extension_request_status),
      extensionRequestedDate: formatDate(item.extension_requested_date),
      extensionReason: cleanText(item.extension_reason),
      reviewComments: cleanText(item.review_comments),
      isAssigned: isAssignedToUser(item, user),
      isCollaborator: isCollaboratorForUser(item, user),
      isRaisedByMe: item.responded_by === user?.id || auditBelongsToUser(audit, user),
    }
    return { ...card, overdue: isOverdue(card), closed: status === 'Closed', reviewReady: status === 'Submitted for Review' || cleanText(item.extension_request_status) === 'Pending', expensePending: expenseStatus(item) === 'Pending Approval' }
  }), [ngItems, audits, user])

  const assignedCards = useMemo(() => hubCards.filter(item => item.isAssigned && !item.closed), [hubCards])
  const raisedCards = useMemo(() => hubCards.filter(item => item.isRaisedByMe), [hubCards])
  const collaborationCards = useMemo(() => hubCards.filter(item => item.isCollaborator || (adminView && item.collaborationRequired)), [adminView, hubCards])
  const reviewCards = useMemo(() => hubCards.filter(item => item.reviewReady), [hubCards])
  const completedCards = useMemo(() => hubCards.filter(item => item.closed), [hubCards])
  const allCards = hubCards

  const visibleTabs = useMemo(() => {
    const tabs = []
    if (!adminView) tabs.push({ key: 'assigned', label: 'Assigned to Me', count: assignedCards.length })
    if (auditorView || adminView) tabs.push({ key: 'raised', label: 'Raised by Me', count: raisedCards.length })
    tabs.push({ key: 'collaboration', label: 'Collaboration', count: collaborationCards.length })
    if (reviewerView || adminView) tabs.push({ key: 'review', label: 'Review Queue', count: reviewCards.length })
    if (expenseApproverView) tabs.push({ key: 'expense', label: 'Expense Approvals', count: hubCards.filter(item => item.expensePending).length })
    tabs.push({ key: 'completed', label: 'Completed / Closed', count: completedCards.length })
    if (adminView) tabs.push({ key: 'all', label: 'All NG Actions', count: allCards.length })
    return tabs
  }, [adminView, auditorView, reviewerView, expenseApproverView, assignedCards, raisedCards, collaborationCards, reviewCards, completedCards, allCards, hubCards])

  useEffect(() => {
    if (visibleTabs.length && !visibleTabs.some(tab => tab.key === activeTab)) setActiveTab(visibleTabs[0].key)
  }, [activeTab, visibleTabs])

  useEffect(() => {
    if (!auditorView || activeTab !== 'assigned') return
    if (assignedCards.length || !raisedCards.length) return
    if (visibleTabs.some(tab => tab.key === 'raised')) setActiveTab('raised')
  }, [activeTab, auditorView, assignedCards.length, raisedCards.length, visibleTabs])

  const hubRows = useMemo(() => {
    if (activeTab === 'raised') return hubCards.filter(item => item.isRaisedByMe)
    if (activeTab === 'collaboration') return hubCards.filter(item => item.isCollaborator || (adminView && item.collaborationRequired))
    if (activeTab === 'review') return hubCards.filter(item => item.reviewReady)
    if (activeTab === 'expense') return hubCards.filter(item => item.expensePending)
    if (activeTab === 'completed') return hubCards.filter(item => item.closed)
    if (activeTab === 'all') return hubCards
    return adminView ? hubCards.filter(item => !item.closed) : hubCards.filter(item => item.isAssigned && !item.closed)
  }, [activeTab, adminView, hubCards])

  const filteredPeople = useMemo(() => {
    const selectedDepartment = normalizeText(actionForm.supportDepartment)
    if (!selectedDepartment) return people
    const filtered = people.filter(person => normalizeText(person.department || person.department_name || person.departmentOwner).includes(selectedDepartment))
    return filtered.length ? filtered : people
  }, [people, actionForm.supportDepartment])

  function openActionForm(item) {
    if (!adminView && !item.isAssigned && !item.isCollaborator) {
      setActionMessage('Only the assigned PIC, collaborator, or System Admin can update this action.')
      return
    }
    setEditingNgId(item.id)
    setActionMessage('')
    setActionForm({
      ...emptyActionForm,
      causeCategory: item.causeCategory || '',
      rootCause: item.rootCause || '',
      actionPlanItems: item.actionPlanItems.length ? item.actionPlanItems : [],
      actionTaken: item.actionTaken || '',
      closureRemarks: item.closureRemarks || '',
      actualClosureDate: item.actualClosureDate || '',
      closureEvidenceFiles: item.closureEvidenceFiles || [],
      collaborationRequired: item.collaborationRequired || false,
      collaboratorUserId: item.collaboratorUserId || '',
      supportDepartment: item.supportDepartment || '',
      supportRequired: item.supportRequired || '',
      supportRemarks: item.supportRemarks || '',
      supportStatus: item.supportStatus || 'Pending',
      monetarySupportRequired: item.monetarySupportRequired || false,
      expectedExpenseAmount: item.expectedExpenseAmount || '',
      expensePurpose: item.expensePurpose || '',
      expenseCategory: item.expenseCategory || '',
      reviewComments: item.reviewComments || '',
      extensionRequestedDate: item.extensionRequestedDate || '',
      extensionReason: item.extensionReason || '',
    })
  }

  function updateActionForm(field, value) {
    setActionForm(current => ({ ...current, [field]: value }))
  }

  function updatePlanRow(index, field, value) {
    setActionForm(current => ({ ...current, actionPlanItems: current.actionPlanItems.map((row, rowIndex) => rowIndex === index ? { ...row, [field]: value } : row) }))
  }

  function removePlanRow(index) {
    setActionForm(current => ({ ...current, actionPlanItems: current.actionPlanItems.filter((_, rowIndex) => rowIndex !== index) }))
  }

  function addPlanRow() {
    setActionForm(current => ({ ...current, actionPlanItems: [...current.actionPlanItems, buildEmptyPlanRow()] }))
  }

  function handleClosureEvidence(event) {
    const files = Array.from(event.target.files || []).map(file => ({ name: file.name, size: file.size, type: file.type, capturedAt: new Date().toISOString() }))
    if (files.length) setActionForm(current => ({ ...current, closureEvidenceFiles: [...(current.closureEvidenceFiles || []), ...files] }))
    event.target.value = ''
  }

  function validateAction(nextStatus) {
    const pending = []
    const hasProgress = actionForm.rootCause.trim() || actionForm.causeCategory || actionForm.actionPlanItems.some(row => cleanText(row.action)) || actionForm.actionTaken.trim() || actionForm.closureRemarks.trim()
    if (nextStatus === 'Submitted for Review') {
      if (!actionForm.causeCategory) pending.push('Cause Category missing')
      if (!actionForm.rootCause.trim()) pending.push('Main Root Cause missing')
      if (!actionForm.actionPlanItems.some(row => cleanText(row.action))) pending.push('At least one Action Plan row missing')
      if (!actionForm.actionTaken.trim() && !actionForm.closureRemarks.trim()) pending.push('Action Taken / Closure Remarks missing')
      if (!actionForm.actualClosureDate) pending.push('Actual Closure Date missing')
    } else if (!hasProgress) {
      pending.push('Enter at least one root cause, action plan, or action taken field before saving progress')
    }
    return pending
  }

  async function saveAction(nextStatus = 'Planning') {
    if (!editingNgId || !user?.id) return
    const pending = validateAction(nextStatus)
    if (pending.length) {
      setActionMessage(pending.join('\n'))
      return
    }

    const collaborator = people.find(person => person.id === actionForm.collaboratorUserId) || null
    const expectedExpenseAmount = Number(actionForm.expectedExpenseAmount || 0)
    setActionSaving(true)
    setActionMessage('')
    try {
      const client = requireSupabase()
      const { error: saveError } = await client.rpc('submit_disha_action_update', {
        p_response_id: editingNgId,
        p_user_id: user.id,
        p_status: nextStatus,
        p_cause_category: actionForm.causeCategory || null,
        p_root_cause: actionForm.rootCause || null,
        p_action_plan_items: actionForm.actionPlanItems || [],
        p_action_taken: actionForm.actionTaken || null,
        p_closure_remarks: actionForm.closureRemarks || null,
        p_actual_closure_date: actionForm.actualClosureDate || null,
        p_closure_evidence_files: actionForm.closureEvidenceFiles || [],
        p_collaboration_required: Boolean(actionForm.collaborationRequired),
        p_collaborator_user_id: collaborator?.id || null,
        p_collaborator_name: collaborator?.employee_name || null,
        p_collaborator_mobile: collaborator?.mobile_no || null,
        p_support_department: actionForm.supportDepartment || null,
        p_support_required: actionForm.supportRequired || null,
        p_support_remarks: actionForm.supportRemarks || null,
        p_support_status: actionForm.supportStatus || null,
        p_monetary_support_required: Boolean(actionForm.monetarySupportRequired),
        p_expected_expense_amount: Number.isFinite(expectedExpenseAmount) && expectedExpenseAmount > 0 ? expectedExpenseAmount : null,
        p_expense_purpose: actionForm.expensePurpose || null,
        p_expense_category: actionForm.expenseCategory || null,
        p_ceo_approval_required: Boolean(actionForm.monetarySupportRequired && expectedExpenseAmount >= CEO_EXPENSE_APPROVAL_THRESHOLD),
        p_extension_requested_date: actionForm.extensionRequestedDate || null,
        p_extension_reason: actionForm.extensionReason || null,
      })
      if (saveError) throw saveError
      setActionMessage(nextStatus === 'Submitted for Review' ? 'Submitted for review' : 'Progress saved')
      setRefreshKey(current => current + 1)
      if (nextStatus === 'Submitted for Review') setEditingNgId('')
    } catch (saveError) {
      setActionMessage(saveError?.message || 'Unable to update action.')
    } finally {
      setActionSaving(false)
    }
  }

  async function approveExpense(item, decision) {
    const comments = actionForm.reviewComments || item.reviewComments || ''
    if (decision === 'Rejected' && !comments.trim()) {
      setActionMessage('Comments are required to reject an expense request.')
      setEditingNgId(item.id)
      return
    }
    setActionSaving(true)
    setActionMessage('')
    try {
      const client = requireSupabase()
      const { error: approvalError } = await client.rpc('approve_expense_request', {
        p_response_id: item.id,
        p_user_id: user.id,
        p_role: getExpenseApprovalRole(user),
        p_decision: decision,
        p_comments: comments || null,
      })
      if (approvalError) throw approvalError
      setActionMessage(decision === 'Approved' ? 'Expense approved' : 'Expense rejected')
      setEditingNgId('')
      setRefreshKey(current => current + 1)
    } catch (approvalError) {
      setActionMessage(approvalError?.message || 'Unable to update expense approval.')
    } finally {
      setActionSaving(false)
    }
  }

  async function reviewAction(item, decision) {
    const comments = actionForm.reviewComments || item.reviewComments || ''
    if (decision === 'Send Back' && !comments.trim()) {
      setActionMessage('Review comments are required to send back.')
      setEditingNgId(item.id)
      return
    }
    setActionSaving(true)
    setActionMessage('')
    try {
      const client = requireSupabase()
      const { error: reviewError } = await client.rpc('review_disha_action', {
        p_response_id: item.id,
        p_user_id: user.id,
        p_decision: decision,
        p_review_comments: comments || null,
      })
      if (reviewError) throw reviewError
      setActionMessage(decision === 'Approve Closure' ? 'Closure approved' : 'Action sent back')
      setEditingNgId('')
      setRefreshKey(current => current + 1)
    } catch (reviewError) {
      setActionMessage(reviewError?.message || 'Unable to complete review.')
    } finally {
      setActionSaving(false)
    }
  }

  return <div className="action-center-page">
    <PageHeader eyebrow="DISHA ACTION HUB" title="Disha Action Hub" description="Simple journey: Understand Issue -> Root Cause -> Support / Collaboration -> Action Plan -> Evidence & Submit." action={<button className="secondary-button" onClick={() => navigate('/dashboard')}><TrendingUp size={17} /> Back to Dashboard</button>} />

    <section className="action-summary-grid">
      <ActionCard title="Assigned to Me" count={hubCards.filter(item => item.isAssigned && !item.closed).length} meta="My open actions" tone="blue" icon={Target} onClick={() => setActiveTab('assigned')} />
      <ActionCard title="Collaboration" count={hubCards.filter(item => item.isCollaborator || (adminView && item.collaborationRequired)).length} meta="Support requested" tone="amber" icon={Clock3} onClick={() => setActiveTab('collaboration')} />
      <ActionCard title="Review Queue" count={hubCards.filter(item => item.reviewReady).length} meta="Submitted or extension" tone="green" icon={CheckCircle2} onClick={() => setActiveTab('review')} />
      {expenseApproverView && <ActionCard title="Expense Approvals" count={hubCards.filter(item => item.expensePending).length} meta="Pending expense requests" tone="amber" icon={ShieldAlert} onClick={() => setActiveTab('expense')} />}
      <ActionCard title="Completed / Closed" count={hubCards.filter(item => item.closed).length} meta="Closed cases" tone="blue" icon={ShieldAlert} onClick={() => setActiveTab('completed')} />
      {adminView && <ActionCard title="All NG Actions" count={hubCards.length} meta="Admin view" tone="blue" icon={Bell} onClick={() => setActiveTab('all')} />}
    </section>

    <section className="card action-section-card">
      <div className="panel-head"><div><span className="eyebrow">SIMPLIFIED ACTION JOURNEY</span><h2>NG action items</h2></div><Bell /></div>
      <div className="tabs">{visibleTabs.map(tab => <button className={activeTab === tab.key ? 'active' : ''} onClick={() => setActiveTab(tab.key)} key={tab.key}>{tab.label} <span>{tab.count}</span></button>)}</div>
      {loading ? <div className="action-empty">Loading Disha Action Hub...</div> : error ? <div className="action-empty">{error}</div> : hubRows.length === 0 ? <div className="action-empty">{activeTab === 'assigned' ? 'No NG actions assigned to you.' : 'No NG actions found for this view.'}</div> : <div className="audit-review-table">
        {hubRows.map(item => {
          const canUpdate = adminView || item.isAssigned || item.isCollaborator
          const canReview = reviewerView || adminView
          return <div key={item.id} className="action-row">
            <div className={`action-priority ${item.overdue ? 'critical' : item.closed ? 'normal' : 'high'}`}>{item.overdue ? 'Overdue' : item.status}</div>
            <div className="action-main">
              <div><strong>{safeJoin([item.dq, item.subQuestion])}</strong><StatusBadge>{item.status}</StatusBadge></div>
              <p>Question: {item.question}</p>
              <small>Location: {item.location}</small>
              <small>Department: {item.department}</small>
              <small>Assigned PIC: {item.assignedPic}</small>
              <small>Target Date: {item.targetDate}</small>
              <small>Condition: {item.condition}</small>
              {activeTab === 'expense' && <>
                <small>Support Department: {item.supportDepartment || 'Not available'}</small>
                <small>Expected Expense: {formatMoney(item.expectedExpenseAmount)}</small>
                <small>Expense Purpose: {item.expensePurpose || 'Not available'}</small>
                <small>Expense Approval: {item.expenseApprovalStatus}</small>
              </>}
              {detailNgId === item.id && <section className="capa-detail-fields">
                <div><span>Audit</span><strong>{item.auditId}</strong></div>
                <div><span>Location</span><strong>{item.location}</strong></div>
                <div><span>Department</span><strong>{item.fullDepartment}</strong></div>
                <div><span>Auditor</span><strong>{item.auditorName}</strong></div>
                <div><span>DQ</span><strong>{safeJoin([item.dq, item.subQuestion])}</strong></div>
                <div><span>Question</span><strong>{item.question}</strong></div>
                <div><span>Current Condition / Gap</span><strong>{item.condition}</strong></div>
                <div><span>Target Date</span><strong>{item.targetDate}</strong></div>
                <div><span>Cause Category</span><strong>{item.causeCategory || 'Not available'}</strong></div>
                <div><span>Root Cause</span><strong>{item.rootCause || 'Not available'}</strong></div>
                <div><span>Support Department</span><strong>{item.supportDepartment || 'Not available'}</strong></div>
                <div><span>Support Status</span><strong>{item.supportStatus || 'Not available'}</strong></div>
                <div><span>Expense Approval</span><strong>{item.expenseApprovalStatus}</strong></div>
                <div><span>Expected Expense</span><strong>{formatMoney(item.expectedExpenseAmount)}</strong></div>
                <div><span>Action Taken</span><strong>{item.actionTaken || item.closureRemarks || 'Not available'}</strong></div>
                <div><span>Actual Closure Date</span><strong>{item.actualClosureDate || 'Not available'}</strong></div>
              </section>}
              {editingNgId === item.id && <section className="form-grid wide">
                <div className="wide audit-checklist-note"><span>Step 1 - Understand Issue: {safeJoin([item.dq, item.subQuestion])} | {item.condition} | Target: {item.targetDate}</span></div>
                <label>Step 2 - Cause Category
                  <select value={actionForm.causeCategory} onChange={event => updateActionForm('causeCategory', event.target.value)}>
                    <option value="">Select category</option>
                    {causeCategories.map(category => <option key={category}>{category}</option>)}
                  </select>
                </label>
                <label className="wide">Main Root Cause
                  <textarea rows="3" value={actionForm.rootCause} onChange={event => updateActionForm('rootCause', event.target.value)} placeholder="Enter confirmed root cause" />
                </label>
                <div className="wide">
                  <div className="panel-head compact-head"><div><span className="eyebrow">STEP 3</span><h2>Support / Collaboration Requirement</h2></div></div>
                  <label className="inline-checkbox"><input type="checkbox" checked={actionForm.collaborationRequired} onChange={event => updateActionForm('collaborationRequired', event.target.checked)} /> Need support from another department?</label>
                </div>
                {actionForm.collaborationRequired && <>
                  <label>Support Department
                    <select value={actionForm.supportDepartment} onChange={event => updateActionForm('supportDepartment', event.target.value)}>
                      <option value="">Select department</option>
                      {supportDepartments.map(department => <option key={department}>{department}</option>)}
                    </select>
                  </label>
                  <label>Support PIC
                    <select value={actionForm.collaboratorUserId} onChange={event => updateActionForm('collaboratorUserId', event.target.value)}>
                      <option value="">Select support PIC</option>
                      {filteredPeople.map(person => <option key={person.id} value={person.id}>{personOptionLabel(person)}</option>)}
                    </select>
                  </label>
                  <label className="wide">Support Required<textarea rows="2" value={actionForm.supportRequired} onChange={event => updateActionForm('supportRequired', event.target.value)} placeholder="Describe what support is required from this department/PIC." /></label>
                  {(item.isCollaborator || adminView) && <>
                    <label className="wide">Support Remarks<textarea rows="2" value={actionForm.supportRemarks} onChange={event => updateActionForm('supportRemarks', event.target.value)} /></label>
                    <label>Support Status<select value={actionForm.supportStatus} onChange={event => updateActionForm('supportStatus', event.target.value)}>{supportStatuses.map(status => <option key={status}>{status}</option>)}</select></label>
                  </>}
                </>}
                <div className="wide">
                  <label className="inline-checkbox"><input type="checkbox" checked={actionForm.monetarySupportRequired} onChange={event => updateActionForm('monetarySupportRequired', event.target.checked)} /> Monetary Support Required?</label>
                  {actionForm.monetarySupportRequired && <div className="form-grid wide expense-grid">
                    <label>Expected Expense Amount
                      <span className="currency-input"><b>INR</b><input type="number" min="0" value={actionForm.expectedExpenseAmount} onChange={event => updateActionForm('expectedExpenseAmount', event.target.value)} /></span>
                    </label>
                    <label>Expense Category
                      <select value={actionForm.expenseCategory} onChange={event => updateActionForm('expenseCategory', event.target.value)}>
                        <option value="">Select category</option>
                        {expenseCategories.map(category => <option key={category}>{category}</option>)}
                      </select>
                    </label>
                    <label className="wide">Expense Purpose<textarea rows="2" value={actionForm.expensePurpose} onChange={event => updateActionForm('expensePurpose', event.target.value)} /></label>
                    <div className="wide approval-status-line"><span>Expense Approval Status</span><StatusBadge>{item.expenseApprovalStatus || 'Not Required'}</StatusBadge></div>
                  </div>}
                </div>
                <div className="wide">
                  <div className="panel-head"><div><span className="eyebrow">STEP 4</span><h2>Action Plan</h2></div><button className="secondary-button" type="button" onClick={addPlanRow}><Plus size={14} /> Add Action</button></div>
                  {actionForm.actionPlanItems.length === 0 ? <div className="action-empty">No action rows yet.</div> : actionForm.actionPlanItems.map((row, index) => <div className="form-grid wide" key={row.id || index}>
                    <label className="wide">Action<input value={row.action || ''} onChange={event => updatePlanRow(index, 'action', event.target.value)} /></label>
                    <label>Responsible Person<input value={row.responsiblePerson || ''} onChange={event => updatePlanRow(index, 'responsiblePerson', event.target.value)} /></label>
                    <label>Target Date<input type="date" value={row.targetDate || ''} onChange={event => updatePlanRow(index, 'targetDate', event.target.value)} /></label>
                    <label>Status<select value={row.status || 'Open'} onChange={event => updatePlanRow(index, 'status', event.target.value)}>{actionStatuses.map(status => <option key={status}>{status}</option>)}</select></label>
                    <button className="secondary-button" type="button" onClick={() => removePlanRow(index)}><X size={14} /> Remove</button>
                  </div>)}
                </div>
                <label className="wide">Step 5 - Action Taken / Closure Remarks
                  <textarea rows="3" value={actionForm.actionTaken} onChange={event => updateActionForm('actionTaken', event.target.value)} />
                </label>
                <label>Actual Closure Date<input type="date" value={actionForm.actualClosureDate} onChange={event => updateActionForm('actualClosureDate', event.target.value)} /></label>
                <label>Evidence Upload<input type="file" multiple onChange={handleClosureEvidence} /></label>
                <label>Request Extension Date<input type="date" value={actionForm.extensionRequestedDate} onChange={event => updateActionForm('extensionRequestedDate', event.target.value)} /></label>
                <label className="wide">Extension Reason<textarea rows="2" value={actionForm.extensionReason} onChange={event => updateActionForm('extensionReason', event.target.value)} /></label>
                {(canReview || item.reviewReady) && <label className="wide">Review Comments<textarea rows="2" value={actionForm.reviewComments} onChange={event => updateActionForm('reviewComments', event.target.value)} /></label>}
                {actionMessage && <div className="wide audit-checklist-note" role="alert"><span>{actionMessage}</span></div>}
                <div className="wide form-footer">
                  <button className="secondary-button" type="button" onClick={() => setEditingNgId('')} disabled={actionSaving}>Cancel</button>
                  <div>
                    {canUpdate && <button className="secondary-button" type="button" onClick={() => saveAction(actionForm.actionPlanItems.length ? 'In Progress' : 'Planning')} disabled={actionSaving}>Save Progress</button>}
                    {canUpdate && <button className="primary-button" type="button" onClick={() => saveAction('Submitted for Review')} disabled={actionSaving}>Submit for Review</button>}
                    {canReview && item.reviewReady && <button className="primary-button" type="button" onClick={() => reviewAction(item, 'Approve Closure')} disabled={actionSaving}>Approve Closure</button>}
                    {canReview && item.reviewReady && <button className="secondary-button" type="button" onClick={() => reviewAction(item, 'Send Back')} disabled={actionSaving}>Send Back</button>}
                    {expenseApproverView && activeTab === 'expense' && item.expensePending && <button className="primary-button" type="button" onClick={() => approveExpense(item, 'Approved')} disabled={actionSaving}>Approve Expense</button>}
                    {expenseApproverView && activeTab === 'expense' && item.expensePending && <button className="secondary-button" type="button" onClick={() => approveExpense(item, 'Rejected')} disabled={actionSaving}>Reject Expense</button>}
                  </div>
                </div>
              </section>}
            </div>
            <div>
              <button className="secondary-button" type="button" onClick={() => setDetailNgId(current => current === item.id ? '' : item.id)}>View Details</button>
              {canUpdate ? <button className="primary-button" type="button" onClick={() => openActionForm(item)}>Update Action</button> : <button className="secondary-button" type="button" onClick={() => setDetailNgId(item.id)}>View Progress</button>}
              {canReview && item.reviewReady && <button className="primary-button" type="button" onClick={() => openActionForm(item)}>Review</button>}
              {expenseApproverView && activeTab === 'expense' && item.expensePending && <button className="primary-button" type="button" onClick={() => openActionForm(item)}>Approve</button>}
            </div>
          </div>
        })}
      </div>}
    </section>
  </div>
}
