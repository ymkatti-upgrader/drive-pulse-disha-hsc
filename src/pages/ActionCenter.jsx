import { ArrowRight, Bell, CheckCircle2, Clock3, Download, Eye, FileImage, FileText, Plus, ShieldAlert, Target, TrendingUp, Upload, X } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAudits } from '../audits/AuditContext'
import { canAccessScope, canManageDishaWorkflow, canViewAuditModule, getRoleProfile, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { PageHeader, StatusBadge } from '../components/UI'
import { requireSupabase } from '../supabaseClient'

const causeCategories = ['Manpower', 'Method', 'Machine / Equipment', 'Material', 'Environment', 'Measurement / Monitoring', 'Others']
const actionStatuses = ['Open', 'In Progress', 'Completed']
const supportStatuses = ['Pending', 'In Progress', 'Completed']
const supportDepartments = ['Sales', 'Service', 'U-Trust', 'VAS', 'Accessories', 'HR', 'Admin', 'Finance', 'Accounts', 'CRE / Customer Relations', 'Body & Paint', 'Parts', 'IT', 'Others']
const expenseCategories = ['Repair', 'Replacement', 'Facility Improvement', 'Tools / Equipment', 'Vendor Support', 'Customer Support', 'Safety / Compliance', 'Others']
const QUOTATION_BUCKET = 'quotation-files'
const SUPPORTED_QUOTATION_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf']
const SUPPORTED_QUOTATION_EXTENSIONS = ['jpg', 'jpeg', 'png', 'pdf']
const MAX_QUOTATION_FILES = 10
const MAX_QUOTATION_FILE_SIZE = 10 * 1024 * 1024

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
  quotationFiles: [],
  newQuotationFiles: [],
}

function cleanFileList(value) {
  return Array.isArray(value) ? value.filter(Boolean) : []
}

function normalizeText(value) {
  return String(value || '').trim().toLowerCase()
}

function matchesUserText(value, terms) {
  const text = normalizeText(value)
  if (!text) return false
  return terms.some(term => text.includes(normalizeText(term)))
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

function hasMeaningfulValue(value) {
  const text = cleanText(value)
  return Boolean(text && text !== '-' && !isUuid(text))
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

function getCurrentUserIds(currentUser) {
  return [currentUser?.id, currentUser?.user_id].map(value => String(value || '').trim()).filter(Boolean)
}

function hasAssignedPic(row) {
  return Boolean(row?.assigned_pic_user_id || row?.pic_for_ng_user_id || cleanText(row?.pic_for_ng_mobile))
}

function isAssignedToUser(row, currentUser) {
  if (!row || !currentUser) return false
  const userIds = getCurrentUserIds(currentUser)
  if (row.assigned_pic_user_id && userIds.includes(row.assigned_pic_user_id)) return true
  if (row.pic_for_ng_user_id && userIds.includes(row.pic_for_ng_user_id)) return true
  const rowMobile = normalizeMobile(row.pic_for_ng_mobile)
  const userMobile = normalizeMobile(currentUser.mobile_no || currentUser.mobile)
  return Boolean(rowMobile && userMobile && rowMobile === userMobile)
}

function isCollaboratorForUser(row, currentUser) {
  if (!row || !currentUser) return false
  const userId = currentUser.id || currentUser.user_id || ''
  if (row.collaborator_user_id && row.collaborator_user_id === userId) return true
  const rowMobile = normalizeMobile(row.collaborator_mobile)
  const userMobile = normalizeMobile(currentUser.mobile_no || currentUser.mobile)
  return Boolean(rowMobile && userMobile && rowMobile === userMobile)
}

function isExpenseApprover(user) {
  return isSystemAdmin(user) || hasRole(user, ['group disha hsc pic', 'group disha pic', 'ceo'])
}

function getExpenseApprovalRole(user, row = {}) {
  const groupApproved = cleanText(row.groupDishaApprovalStatus || row.group_disha_review_status || row.group_disha_approval_status) === 'approved by group disha'
  const groupRejected = cleanText(row.groupDishaApprovalStatus || row.group_disha_review_status || row.group_disha_approval_status).includes('rejected')
  const groupPending = !groupApproved && !groupRejected

  if (isSystemAdmin(user)) return groupPending ? 'Group Disha HSC PIC' : 'CEO'
  if (groupPending && hasRole(user, ['group disha hsc pic', 'group disha pic'])) return 'Group Disha HSC PIC'
  if (groupApproved && hasRole(user, ['ceo'])) return 'CEO'
  if (hasRole(user, ['group disha hsc pic', 'group disha pic'])) return 'Group Disha HSC PIC'
  if (hasRole(user, ['ceo'])) return 'CEO'
  return 'Viewer'
}

function expenseStatus(row = {}) {
  const text = cleanText(row.expense_approval_status)
  if (text && !['Pending Approval', 'Pending CEO Approval', 'Pending Group Disha HSC PIC Approval', 'Pending Group DISHA Review'].includes(text)) return text

  const groupStatus = normalizeText(row.group_disha_review_status || row.group_disha_approval_status)
  const ceoStatus = normalizeText(row.ceo_review_status || row.ceo_approval_status)

  if (!row.monetary_support_required && !row.expense_approval_required) return 'Not Required'
  if (ceoStatus === 'approved') return 'CEO Approved'
  if (ceoStatus === 'rejected by ceo' || ceoStatus === 'rejected') return 'CEO Rejected'
  if (ceoStatus === 'resubmitted for ceo approval' || ceoStatus === 'resubmitted') return 'Resubmitted for CEO Approval'
  if (groupStatus === 'approved') return 'Pending CEO Approval'
  if (groupStatus === 'rejected by group disha' || groupStatus === 'rejected') return 'Rejected by Group DISHA'
  if (groupStatus === 'resubmitted for group review' || groupStatus === 'resubmitted') return 'Resubmitted for Group DISHA Review'
  return 'Pending Group DISHA Review'
}

function groupDishaApprovalStatus(row = {}) {
  const text = normalizeText(row.group_disha_review_status || row.group_disha_approval_status)
  if (text === 'approved') return 'Approved by Group DISHA'
  if (text === 'rejected by group disha' || text === 'rejected') return 'Rejected by Group DISHA'
  if (text === 'resubmitted for group review' || text === 'resubmitted') return 'Resubmitted for Group DISHA Review'
  if (text === 'pending group review' || text === 'pending') return 'Pending Group DISHA Review'
  return row.monetary_support_required || row.expense_approval_required ? 'Pending Group DISHA Review' : 'Not Required'
}

function ceoApprovalStatus(row = {}) {
  const text = normalizeText(row.ceo_review_status || row.ceo_approval_status)
  if (text === 'approved') return 'CEO Approved'
  if (text === 'rejected by ceo' || text === 'rejected') return 'CEO Rejected'
  if (text === 'pending ceo approval' || text === 'pending') return 'Pending CEO Approval'
  if (text === 'resubmitted for ceo approval' || text === 'resubmitted') return 'Resubmitted for CEO Approval'
  if (!row.monetary_support_required && !row.expense_approval_required) return 'Not Required'
  if (normalizeText(row.group_disha_review_status || row.group_disha_approval_status) === 'rejected by group disha') return 'Not Required'
  if (normalizeText(row.group_disha_review_status || row.group_disha_approval_status) === 'approved') return 'Pending CEO Approval'
  return 'Not Required'
}

function currentFinancialStage(row = {}) {
  const expense = expenseStatus(row)
  if (expense === 'CEO Approved') return 'CEO Approved'
  if (expense === 'CEO Rejected') return 'Returned by CEO'
  if (expense === 'Pending CEO Approval' || expense === 'Resubmitted for CEO Approval') return 'CEO Review'
  if (expense === 'Rejected by Group DISHA') return 'Returned by Group DISHA'
  if (expense === 'Pending Group DISHA Review' || expense === 'Resubmitted for Group DISHA Review') return 'Group DISHA Review'
  if (expense === 'Not Required') return 'Not Required'
  return 'Submitted'
}

function currentApprover(row = {}) {
  const expense = expenseStatus(row)
  if (['Pending CEO Approval', 'Resubmitted for CEO Approval'].includes(expense)) return 'CEO'
  if (['Pending Group DISHA Review', 'Resubmitted for Group DISHA Review'].includes(expense)) return 'Group DISHA HSC PIC'
  if (expense === 'CEO Approved') return 'Auditor Verification'
  return 'PIC'
}

function buildApprovalTimeline(row = {}) {
  const expense = expenseStatus(row)
  const group = groupDishaApprovalStatus(row)
  const ceo = ceoApprovalStatus(row)
  return [
    { label: 'Submitted', tone: 'blue', active: Boolean(row.monetary_support_required) },
    {
      label: group,
      tone: group.includes('Rejected') ? 'red' : group.includes('Approved') ? 'green' : 'amber',
      active: row.monetary_support_required,
    },
    {
      label: ceo,
      tone: ceo.includes('Rejected') ? 'red' : ceo.includes('Approved') ? 'green' : ceo.includes('Pending') || ceo.includes('Resubmitted') ? 'amber' : 'neutral',
      active: row.monetary_support_required && group === 'Approved by Group DISHA',
    },
    {
      label: row.verification_status && cleanText(row.verification_status) !== 'not started' ? 'Verification Pending' : 'Verification',
      tone: cleanText(row.verification_status).includes('pending') ? 'amber' : cleanText(row.verification_status) === 'verified' ? 'green' : 'neutral',
      active: expense === 'CEO Approved',
    },
    { label: cleanText(row.closure_status) === 'closed' ? 'Closed' : 'Closed', tone: cleanText(row.closure_status) === 'closed' ? 'green' : 'neutral', active: cleanText(row.closure_status) === 'closed' },
  ]
}

function buildApprovalHistory(row = {}) {
  const raw = Array.isArray(row.approval_history) ? row.approval_history : []
  const mapped = raw.map(entry => ({
    id: entry.id || `${entry.level}-${entry.timestamp}`,
    level: cleanDisplayValue(entry.level || entry.role || '', 'Approval'),
    decision: cleanDisplayValue(entry.decision || entry.new_status || '', 'Updated'),
    remarks: cleanDisplayValue(entry.remarks || '', 'No remarks'),
    previousStatus: cleanDisplayValue(entry.previous_status || '', 'Not available'),
    newStatus: cleanDisplayValue(entry.new_status || '', 'Not available'),
    at: formatDate(entry.timestamp || ''),
  }))

  if (mapped.length) return mapped

  const fallback = []
  if (row.group_disha_review_status || row.group_disha_approval_status) {
    fallback.push({
      id: 'group-current',
      level: 'Group Review',
      decision: groupDishaApprovalStatus(row),
      remarks: cleanDisplayValue(row.group_disha_review_remarks || row.group_disha_comments || row.group_disha_approval_remarks, 'No remarks'),
      previousStatus: 'Submitted',
      newStatus: groupDishaApprovalStatus(row),
      at: formatDate(row.group_disha_review_date || row.group_disha_approved_at || ''),
    })
  }
  if (row.ceo_review_status || row.ceo_approval_status) {
    fallback.push({
      id: 'ceo-current',
      level: 'CEO Review',
      decision: ceoApprovalStatus(row),
      remarks: cleanDisplayValue(row.ceo_review_remarks || row.ceo_comments, 'No remarks'),
      previousStatus: groupDishaApprovalStatus(row),
      newStatus: ceoApprovalStatus(row),
      at: formatDate(row.ceo_review_date || row.ceo_approved_at || ''),
    })
  }
  return fallback
}

function getExpenseDraftStatus(item = {}, form = {}) {
  if (expenseStatus(item) !== 'Not Required') return expenseStatus(item)
  if (!form.monetarySupportRequired) return 'Not Required'

  const amountText = String(form.expectedExpenseAmount ?? '').trim()
  const hasAmount = amountText && Number.isFinite(Number(amountText)) && Number(amountText) >= 0
  const hasCategory = Boolean(cleanText(form.expenseCategory))
  const hasPurpose = Boolean(cleanText(form.expensePurpose))

  if (hasAmount && hasCategory && hasPurpose) return 'Ready to Send for Approval'
  return 'Expense Draft'
}

function formatMoney(value) {
  const amount = Number(value)
  if (!Number.isFinite(amount) || amount < 0) return 'Not available'
  return `INR ${amount.toLocaleString('en-IN')}`
}

function formatFileSize(bytes) {
  const value = Number(bytes)
  if (!Number.isFinite(value) || value <= 0) return 'Size unavailable'
  if (value >= 1024 * 1024) return `${(value / (1024 * 1024)).toFixed(1)} MB`
  if (value >= 1024) return `${Math.round(value / 1024)} KB`
  return `${value} B`
}

function getFileExtension(fileName) {
  const parts = String(fileName || '').toLowerCase().split('.')
  return parts.length > 1 ? parts.pop() : ''
}

function isPreviewableImage(file = {}) {
  return String(file.type || file.mime_type || '').startsWith('image/')
    || ['jpg', 'jpeg', 'png'].includes(getFileExtension(file.file_name || file.name))
}

function isPdfFile(file = {}) {
  return String(file.type || file.mime_type || '') === 'application/pdf'
    || getFileExtension(file.file_name || file.name) === 'pdf'
}

function createStoragePath(responseId, fileName) {
  const safeName = String(fileName || 'attachment')
    .replace(/[^a-zA-Z0-9._-]/g, '-')
    .replace(/-+/g, '-')
  return `${responseId}/${Date.now()}-${safeName}`
}

function parseStoredJson(storage, key) {
  if (!storage) return null
  try {
    const raw = storage.getItem(key)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

function getStoredUserCandidate() {
  if (typeof window === 'undefined') return null
  const keys = ['current_user', 'disha-hsc-auth', 'user', 'currentUser', 'authUser']
  for (const key of keys) {
    const localCandidate = parseStoredJson(window.localStorage, key)
    if (localCandidate) return localCandidate
    const sessionCandidate = parseStoredJson(window.sessionStorage, key)
    if (sessionCandidate) return sessionCandidate
  }
  return null
}

function normalizeCurrentUser(authUser, storedUser) {
  const source = authUser || storedUser || null
  if (!source) return null
  const access = Array.isArray(source.access) ? source.access : Array.isArray(source.mappings) ? source.mappings : []
  const primaryAccess = access[0] || {}
  return {
    ...source,
    id: source.id || source.user_id || '',
    user_id: source.user_id || source.id || '',
    mobile: source.mobile || source.mobile_no || source.phone || '',
    mobile_no: source.mobile_no || source.mobile || source.phone || '',
    role: source.role || primaryAccess.role || '',
    user_type: source.user_type || primaryAccess.user_type || '',
    location: source.location || primaryAccess.location || '',
    department: source.department || primaryAccess.department || '',
    access,
  }
}

function personOptionLabel(person) {
  const name = cleanDisplayValue(person.employee_name || person.name || person.full_name || person.mobile_no)
  const meta = safeJoin([person.department, person.location, person.mobile_no], ' - ')
  return meta ? `${name} - ${meta}` : name
}

function auditBelongsToUser(audit, user) {
  if (!audit || !user) return false
  const userId = user.id || user.user_id || ''
  const userName = normalizeText(user.employee_name || user.name || user.full_name)
  return [audit.created_by, audit.createdBy, audit.auditor_id, audit.auditorId, audit.auditor_user_id, audit.auditorUserId].some(value => value && value === userId)
    || [audit.auditor_name, audit.auditorName, audit.owner, audit.createdByName].some(value => normalizeText(value) && normalizeText(value) === userName)
}

function resolveActionQuestion(item) {
  return cleanText(item.sub_question_text || item.audit_question || item.evaluation_item || item.checkpoint || item.question_text || '')
}

function resolveActionLocation(item, audit = {}) {
  return cleanText(item.audit_location || item.location_name || audit.location || audit.location_name || '')
}

function resolveActionDepartment(item, audit = {}) {
  const auditDepartment = Array.isArray(audit.departments) ? audit.departments.join(', ') : audit.departments
  return cleanText(item.audit_department || item.department_name || audit.department || auditDepartment || '')
}

function isValidNgAction(item, audit = {}) {
  if (!item || item.is_void === true) return false
  const hasWorkflowStatus = normalizeText(item.result) === 'ng' || hasMeaningfulValue(item.action_status) || hasMeaningfulValue(item.status)
  const hasQuestion = Boolean(resolveActionQuestion(item)) || hasMeaningfulValue(item.checklist_id) || hasMeaningfulValue(item.dq_question_num) || hasMeaningfulValue(item.sub_question_num)
  const hasPicAssignment = hasAssignedPic(item)
  const hasAuditId = Boolean(cleanText(item.audit_uuid || item.audit_id))
  return hasWorkflowStatus && hasQuestion && hasPicAssignment && hasAuditId
}

function getSimpleStatus(status, row = {}) {
  const value = normalizeText(status)
  if (!value || ['open', 'assigned', 'assigned to ng pic', 'ng identified'].includes(value)) return 'Assigned'
  if (['root cause updated', 'action plan created', 'planning'].includes(value)) return 'Planning'
  if (['in progress', 'collaboration in progress', 'co-assigned'].includes(value)) return 'In Progress'
  if (['closure requested', 'submitted for review', 'pending approval', 'pending ceo approval'].includes(value)) return 'Submitted for Review'
  if (['rejected', 'send back', 'sent back', 'reassigned', 'reassigned by group disha', 'rejected by ceo'].includes(value)) return 'Reassigned'
  if (['completed', 'closed', 'closed by ceo', 'approved', 'approved closed'].includes(value)) return 'Closed'
  return 'Assigned'
}

function getCompactStatusLabel(status) {
  const simple = getSimpleStatus(status)
  if (simple === 'Submitted for Review') return 'Review'
  if (simple === 'In Progress') return 'Progress'
  if (simple === 'Assigned') return 'Assigned'
  if (simple === 'Reassigned') return 'Reassigned'
  if (simple === 'Planning') return 'Planning'
  if (simple === 'Closed') return 'Closed'
  return simple
}

function getProcessFlowStage(status) {
  const simple = getSimpleStatus(status)
  if (simple === 'Assigned') return 0
  if (simple === 'Planning') return 1
  if (simple === 'In Progress') return 2
  if (simple === 'Submitted for Review') return 3
  if (simple === 'Closed') return 5
  if (simple === 'Reassigned') return 6
  return 0
}

function isReviewQueueItem(item) {
  if (!item) return false
  const status = getSimpleStatus(item.action_status || item.status, item)
  if (status === 'Closed') return false
  const extensionPending = normalizeText(item.extension_request_status) === 'pending'
  const verificationPending = ['pending', 'verification pending'].includes(normalizeText(item.verification_status))
  return ['Submitted for Review'].includes(status)
    || normalizeText(item.action_status || item.status) === 'pending review'
    || normalizeText(item.action_status || item.status) === 'closure requested'
    || extensionPending
    || verificationPending
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

function getTabConfig(roleId, counts) {
  const baseTabs = {
    assigned: { key: 'assigned', label: 'Assigned Actions', count: counts.assigned, tone: 'blue', icon: Target, meta: 'My open actions' },
    raised: { key: 'raised', label: 'Raised by Me', count: counts.raised, tone: 'amber', icon: Bell, meta: 'Created by me' },
    collaboration: { key: 'collaboration', label: 'Collaboration', count: counts.collaboration, tone: 'amber', icon: Clock3, meta: 'Support requested' },
    review: { key: 'review', label: 'Review Queue', count: counts.review, tone: 'green', icon: CheckCircle2, meta: 'Submitted or extension' },
    verification: { key: 'verification', label: 'Verification', count: counts.verification, tone: 'green', icon: ShieldAlert, meta: 'Evidence awaiting review' },
    financialReview: { key: 'financial-review', label: 'Financial Approvals', count: counts.financialReview, tone: 'amber', icon: ShieldAlert, meta: 'Group DISHA technical scrutiny' },
    financialApproval: { key: 'financial-approval', label: 'Financial Approvals', count: counts.financialApproval, tone: 'amber', icon: ShieldAlert, meta: 'CEO final monetary approvals' },
    expense: { key: 'expense', label: 'Expense Approvals', count: counts.expense, tone: 'amber', icon: ShieldAlert, meta: 'Monetary review queue' },
    completed: { key: 'completed', label: 'Completed', count: counts.completed, tone: 'blue', icon: ShieldAlert, meta: 'Closed cases' },
    all: { key: 'all', label: counts.allLabel, count: counts.all, tone: 'blue', icon: Bell, meta: counts.allMeta },
  }

  const roleTabs = {
    'system-admin': ['assigned', 'raised', 'collaboration', 'review', 'verification', 'financialReview', 'financialApproval', 'expense', 'completed', 'all'],
    ceo: ['financialApproval', 'completed', 'all'],
    'group-disha': ['review', 'financialReview', 'completed'],
    'group-functional-hod': ['assigned', 'collaboration', 'completed', 'all'],
    'location-functional-hod': ['assigned', 'collaboration', 'completed'],
    'branch-auditor': ['review', 'verification', 'completed'],
    viewer: [],
  }

  return (roleTabs[roleId] || roleTabs.viewer).map(key => baseTabs[key]).filter(Boolean)
}

export default function ActionCenter() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits } = useAudits()
  const roleProfile = useMemo(() => getRoleProfile(user), [user])
  const assignedOnlyOwnerView = roleProfile.id === 'location-functional-hod'
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
  const currentUser = useMemo(() => normalizeCurrentUser(user, getStoredUserCandidate()), [user])
  const adminView = canManageDishaWorkflow(currentUser)
  const auditorView = canViewAuditModule(currentUser)
  const reviewerView = canManageDishaWorkflow(currentUser)
  const expenseApproverView = isExpenseApprover(currentUser)
  const auditLookup = useMemo(() => {
    const map = new Map()
    audits.forEach(item => {
      ;[item.id, item.auditId, item.auditNumber, item.audit_no, item.audit_number].forEach(key => {
        if (key) map.set(String(key), item)
      })
    })
    return map
  }, [audits])

  function canActOnExpense(item) {
    // `item` here is a mapped hubCard (camelCase fields), not a raw DB row —
    // use its already-computed expenseApprovalStatus rather than re-deriving
    // via expenseStatus(), which reads snake_case DB column names and would
    // silently fall through to 'Not Required' on a camelCase object.
    const overallStatus = item.expenseApprovalStatus
    if (!item.monetarySupportRequired || ['CEO Approved', 'Not Required'].includes(overallStatus)) return false
    if (['Pending CEO Approval', 'Resubmitted for CEO Approval'].includes(item.ceoApprovalStatus || overallStatus)) {
      return isSystemAdmin(currentUser) || hasRole(currentUser, ['ceo'])
    }
    return isSystemAdmin(currentUser) || hasRole(currentUser, ['group disha hsc pic', 'group disha pic'])
  }

  useEffect(() => {
    let cancelled = false
    async function loadPeople() {
      try {
        const client = requireSupabase()
        const { data, error: loadError } = await client
          .from('app_users')
          .select('id, employee_name, mobile_no, active')
          .eq('active', true)
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
      const activeUser = currentUser
      if (!activeUser?.id && !activeUser?.user_id) {
        setNgItems([])
        return
      }

      setLoading(true)
      setError('')
      try {
        const client = requireSupabase()
        const stableSelect = 'id, audit_id, audit_uuid, checklist_id, dq_question_num, sub_question_num, result, current_condition_observed, tentative_closing_date, action_status, assigned_pic_user_id, submitted_for_review_at, closure_status, verification_status, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, responded_by, created_at, updated_at, sub_question_text, audit_location, audit_department, pic_for_ng, cause_category, root_cause, action_plan_items, corrective_action_plan, preventive_action_plan, action_taken, closure_remarks, closure_evidence_files, actual_closure_date, collaboration_required, collaborator_user_id, collaborator_name, collaborator_mobile, support_department, support_required, support_remarks, support_status, monetary_support_required, expected_expense_amount, expense_purpose, expense_category, expense_approval_required, expense_approver_role, expense_approval_status, group_disha_approval_status, group_disha_approved_by, group_disha_approved_at, group_disha_approval_remarks, group_disha_comments, group_disha_review_required, group_disha_review_status, group_disha_reviewed_by, group_disha_review_date, group_disha_review_remarks, ceo_approval_required, ceo_approval_status, ceo_approved_by, ceo_approved_at, ceo_comments, ceo_review_status, ceo_reviewed_by, ceo_review_date, ceo_review_remarks, approval_level, approval_history, extension_request_status, extension_requested_date, extension_reason, review_comments, quotation_files, is_void, void_reason'
        const legacySelect = 'id, audit_id, checklist_id, dq_question_num, sub_question_num, result, current_condition_observed, tentative_closing_date, action_status, assigned_pic_user_id, submitted_for_review_at, closure_status, verification_status, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, responded_by, created_at, updated_at, sub_question_text, audit_location, audit_department, pic_for_ng, cause_category, root_cause, action_plan_items, corrective_action_plan, preventive_action_plan, action_taken, closure_remarks, closure_evidence_files, actual_closure_date, collaboration_required, collaborator_user_id, collaborator_name, collaborator_mobile, support_department, support_required, support_remarks, support_status, monetary_support_required, expected_expense_amount, expense_purpose, expense_category, expense_approval_required, expense_approver_role, expense_approval_status, group_disha_approval_status, group_disha_approved_by, group_disha_approved_at, group_disha_approval_remarks, ceo_approval_required, ceo_approval_status, ceo_approved_by, ceo_approved_at, ceo_comments, extension_request_status, extension_requested_date, extension_reason, review_comments, quotation_files, is_void, void_reason'
        let allNgResult = await client
          .from('audit_responses')
          .select(stableSelect)
          .eq('result', 'NG')

        if (allNgResult.error && /column .* does not exist/i.test(allNgResult.error.message || '')) {
          allNgResult = await client
            .from('audit_responses')
            .select(legacySelect)
            .eq('result', 'NG')
        }

        if (allNgResult.error) throw allNgResult.error

        if (!cancelled) {
          const fetchedRows = allNgResult.data || []
          const nonVoidRows = fetchedRows.filter(item => item.is_void !== true)
          const validRows = nonVoidRows.filter(item => {
            const auditUuid = item.audit_uuid || ''
            if (!auditUuid) return false
            const audit = auditLookup.get(auditUuid)
            if (!audit || String(audit.status || '').trim().toLowerCase() === 'draft') return false
            if (!canAccessScope(currentUser, { department: item.audit_department || audit.department || '', location: item.audit_location || audit.location || '' })) return false
            return isValidNgAction(item, audit)
          })
          const assignedRows = validRows.filter(item => isAssignedToUser(item, activeUser))
          console.info('FETCHED ROWS', {
            totalFetched: fetchedRows.length,
            afterVoidFilter: nonVoidRows.length,
          })
          console.info('VALID ROWS', {
            validCount: validRows.length,
          })
          console.info('ASSIGNED ROWS', {
            assignedCount: assignedRows.length,
            currentUserId: activeUser.id || activeUser.user_id || '',
            currentUserMobile: normalizeMobile(activeUser.mobile_no || activeUser.mobile),
          })
          console.info('FIRST 5 ROWS WITH ASSIGNMENT FIELDS', fetchedRows.slice(0, 5).map(row => ({
            id: row.id,
            audit_id: row.audit_id,
            audit_uuid: row.audit_uuid,
            sub_question_text: row.sub_question_text,
            audit_location: row.audit_location,
            audit_department: row.audit_department,
            assigned_pic_user_id: row.assigned_pic_user_id,
            pic_for_ng_user_id: row.pic_for_ng_user_id,
            pic_for_ng_name: row.pic_for_ng_name,
            pic_for_ng_mobile: row.pic_for_ng_mobile,
            action_status: row.action_status,
            is_void: row.is_void,
          })))
          setNgItems(assignedOnlyOwnerView ? assignedRows : validRows)
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
  }, [adminView, auditorView, reviewerView, expenseApproverView, user, currentUser, refreshKey, auditLookup, assignedOnlyOwnerView])

  const hubCards = useMemo(() => ngItems.map(item => {
    const audit = auditLookup.get(item.audit_uuid || item.audit_id) || {}
    const fullDepartment = resolveActionDepartment(item, audit)
    const workflowStatus = item.action_status || item.closure_status || ''
    const status = getSimpleStatus(workflowStatus, item)
    const targetDate = formatDate(item.tentative_closing_date) || 'Not available'
    const card = {
      id: item.id,
      rawAuditId: item.audit_uuid || item.audit_id || '',
      auditId: cleanDisplayValue(audit.auditNumber || audit.auditId || audit.audit_number || audit.audit_no || item.audit_id),
      location: cleanDisplayValue(resolveActionLocation(item, audit)),
      department: shortDepartment(resolveActionDepartment(item, audit)),
      fullDepartment: cleanDisplayValue(fullDepartment),
      auditType: cleanDisplayValue(audit.audit_type || audit.auditType),
      auditorName: cleanDisplayValue(audit.auditor_name || audit.auditorName || audit.owner),
      dq: cleanDisplayValue(item.dq_question_num),
      subQuestion: getSubQuestionLabel(item.sub_question_num),
      question: cleanDisplayValue(resolveActionQuestion(item)),
      condition: cleanDisplayValue(item.current_condition_observed),
      assignedPic: getDisplayName(item.pic_for_ng_name || item.assigned_pic_user_id),
      targetDate,
      status,
      actionStatus: cleanText(item.action_status) || status,
      assignedPicUserId: item.assigned_pic_user_id || '',
      submittedForReviewAt: cleanText(item.submitted_for_review_at),
      closureStatus: cleanText(item.closure_status),
      verificationStatus: cleanText(item.verification_status),
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
      expenseApprovalRequired: Boolean(item.expense_approval_required ?? item.monetary_support_required),
      expenseApproverRole: cleanText(item.expense_approver_role) || (cleanText(item.group_disha_review_status || item.group_disha_approval_status) === 'approved' ? 'CEO' : 'Group Disha HSC PIC'),
      expenseApprovalStatus: expenseStatus(item),
      groupDishaApprovalStatus: groupDishaApprovalStatus(item),
      groupDishaReviewRequired: Boolean(item.group_disha_review_required ?? item.monetary_support_required),
      groupDishaReviewStatus: cleanText(item.group_disha_review_status || item.group_disha_approval_status),
      groupDishaReviewedBy: item.group_disha_reviewed_by || item.group_disha_approved_by || '',
      groupDishaReviewDate: formatDate(item.group_disha_review_date || item.group_disha_approved_at),
      groupDishaReviewRemarks: cleanText(item.group_disha_review_remarks || item.group_disha_comments || item.group_disha_approval_remarks),
      ceoApprovalRequired: Boolean(item.ceo_approval_required ?? item.expense_approval_required ?? item.monetary_support_required),
      ceoApprovalStatus: ceoApprovalStatus(item),
      ceoReviewStatus: cleanText(item.ceo_review_status || item.ceo_approval_status),
      ceoReviewedBy: item.ceo_reviewed_by || item.ceo_approved_by || '',
      ceoReviewDate: formatDate(item.ceo_review_date || item.ceo_approved_at),
      ceoReviewRemarks: cleanText(item.ceo_review_remarks || item.ceo_comments),
      approvalLevel: cleanText(item.approval_level) || 'group review',
      approvalHistory: Array.isArray(item.approval_history) ? item.approval_history : [],
      currentStage: currentFinancialStage(item),
      currentApprover: currentApprover(item),
      approvalTimeline: buildApprovalTimeline(item),
      approvalTrail: buildApprovalHistory(item),
      extensionRequestStatus: cleanText(item.extension_request_status),
      extensionRequestedDate: formatDate(item.extension_requested_date),
      extensionReason: cleanText(item.extension_reason),
      reviewComments: cleanText(item.review_comments),
      quotationFiles: cleanFileList(item.quotation_files).map(file => ({
        file_name: cleanText(file?.file_name || file?.name),
        file_url: cleanText(file?.file_url || file?.url),
        storage_path: cleanText(file?.storage_path),
        uploaded_by: cleanText(file?.uploaded_by),
        uploaded_date: cleanText(file?.uploaded_date || file?.uploaded_at),
        mime_type: cleanText(file?.mime_type || file?.type),
        file_size: Number(file?.file_size || file?.size || 0) || 0,
      })),
      isAssigned: isAssignedToUser(item, currentUser),
      isCollaborator: isCollaboratorForUser(item, currentUser),
      isRaisedByMe: item.responded_by === (currentUser?.id || currentUser?.user_id) || auditBelongsToUser(audit, currentUser),
      reviewQueue: isReviewQueueItem(item),
    }
    return {
      ...card,
      overdue: isOverdue(card),
      closed: status === 'Closed',
      reviewReady: card.reviewQueue,
      expensePending: card.monetarySupportRequired && !['CEO Approved', 'Not Required'].includes(expenseStatus(item)),
      groupReviewPending: card.monetarySupportRequired && ['Pending Group DISHA Review', 'Resubmitted for Group DISHA Review'].includes(card.groupDishaApprovalStatus),
      ceoReviewPending: card.monetarySupportRequired && ['Pending CEO Approval', 'Resubmitted for CEO Approval'].includes(card.ceoApprovalStatus),
      canResubmitExpense: card.monetarySupportRequired && ['Rejected by Group DISHA', 'CEO Rejected'].includes(card.expenseApprovalStatus),
    }
  }), [ngItems, audits, currentUser])

  const assignedCards = useMemo(() => hubCards.filter(item => item.isAssigned && !item.closed), [hubCards])
  const raisedCards = useMemo(() => hubCards.filter(item => item.isRaisedByMe), [hubCards])
  const collaborationCards = useMemo(() => hubCards.filter(item => item.isCollaborator || (adminView && item.collaborationRequired)), [adminView, hubCards])
  const reviewCards = useMemo(() => hubCards.filter(item => item.reviewReady), [hubCards])
  const verificationCards = useMemo(() => hubCards.filter(item => ['Evidence Uploaded', 'Verification Pending'].includes(item.status) || ['pending', 'verification pending'].includes(normalizeText(item.verificationStatus))), [hubCards])
  const groupReviewCards = useMemo(() => hubCards.filter(item => item.groupReviewPending && canActOnExpense(item)), [hubCards, currentUser])
  const ceoReviewCards = useMemo(() => hubCards.filter(item => item.ceoReviewPending && canActOnExpense(item)), [hubCards, currentUser])
  const expenseCards = useMemo(() => [...groupReviewCards, ...ceoReviewCards], [groupReviewCards, ceoReviewCards])
  const completedCards = useMemo(() => hubCards.filter(item => item.closed), [hubCards])
  const allCards = hubCards

  const visibleTabs = useMemo(() => {
    return getTabConfig(roleProfile.id, {
      assigned: assignedCards.length,
      raised: raisedCards.length,
      collaboration: collaborationCards.length,
      review: reviewCards.length,
      verification: verificationCards.length,
      financialReview: groupReviewCards.length,
      financialApproval: ceoReviewCards.length,
      expense: expenseCards.length,
      completed: completedCards.length,
      all: allCards.length,
      allLabel: roleProfile.id === 'system-admin'
        ? 'Full Action Center'
        : roleProfile.id === 'ceo'
          ? 'Executive Monitoring'
          : roleProfile.id === 'group-functional-hod'
            ? 'Department-wide Action Center'
            : 'All NG Actions',
      allMeta: roleProfile.id === 'ceo'
        ? 'Cross-location executive oversight'
        : roleProfile.id === 'group-functional-hod'
          ? 'Department scope across all locations'
          : 'Admin view',
    })
  }, [roleProfile.id, assignedCards.length, raisedCards.length, collaborationCards.length, reviewCards.length, verificationCards.length, groupReviewCards.length, ceoReviewCards.length, expenseCards.length, completedCards.length, allCards.length])
  const hasActionAccess = visibleTabs.length > 0

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
    if (activeTab === 'review') return hubCards.filter(item => item.reviewQueue)
    if (activeTab === 'verification') return hubCards.filter(item => ['Evidence Uploaded', 'Verification Pending'].includes(item.status) || ['pending', 'verification pending'].includes(normalizeText(item.verificationStatus)))
    if (activeTab === 'financial-review') return groupReviewCards
    if (activeTab === 'financial-approval') return ceoReviewCards
    if (activeTab === 'expense') return expenseCards
    if (activeTab === 'completed') return hubCards.filter(item => item.closed)
    if (activeTab === 'all') return hubCards
    return hubCards.filter(item => item.isAssigned && !item.closed)
  }, [activeTab, adminView, ceoReviewCards, expenseCards, groupReviewCards, hubCards])

  useEffect(() => {
    if (activeTab === 'review' && hubCards.length && !hubRows.length) {
      console.warn('No rows after role filter. Check user id/mobile/name mapping.')
    }
  }, [activeTab, hubCards.length, hubRows.length])

  const filteredPeople = useMemo(() => {
    const selectedDepartment = normalizeText(actionForm.supportDepartment)
    if (!selectedDepartment) return people
    const filtered = people.filter(person => normalizeText(person.department || person.department_name || person.departmentOwner).includes(selectedDepartment))
    return filtered.length ? filtered : people
  }, [people, actionForm.supportDepartment])

  useEffect(() => () => {
    cleanFileList(actionForm.newQuotationFiles).forEach(file => {
      if (file.previewUrl) URL.revokeObjectURL(file.previewUrl)
    })
  }, [actionForm.newQuotationFiles])

  function openActionForm(item) {
    const canOpenForApproval = expenseApproverView && ['expense', 'financial-review', 'financial-approval'].includes(activeTab)
    if (!adminView && !item.isAssigned && !item.isCollaborator && !canOpenForApproval) {
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
      quotationFiles: cleanFileList(item.quotationFiles),
      newQuotationFiles: [],
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

  function handleQuotationFiles(event) {
    const selectedFiles = Array.from(event.target.files || [])
    event.target.value = ''
    if (!selectedFiles.length) return

    setActionMessage('')
    setActionForm(current => {
      const existingCount = cleanFileList(current.quotationFiles).length + cleanFileList(current.newQuotationFiles).length
      const accepted = []
      const errors = []

      selectedFiles.forEach(file => {
        const extension = getFileExtension(file.name)
        const mimeType = String(file.type || '').toLowerCase()
        if (!SUPPORTED_QUOTATION_TYPES.includes(mimeType) && !SUPPORTED_QUOTATION_EXTENSIONS.includes(extension)) {
          errors.push(`${file.name}: only JPG, JPEG, PNG, and PDF are allowed.`)
          return
        }
        if (file.size > MAX_QUOTATION_FILE_SIZE) {
          errors.push(`${file.name}: file size exceeds 10 MB.`)
          return
        }
        if (existingCount + accepted.length >= MAX_QUOTATION_FILES) {
          errors.push(`${file.name}: maximum 10 files allowed.`)
          return
        }
        accepted.push({
          id: `${Date.now()}-${file.name}-${accepted.length}`,
          file,
          name: file.name,
          size: file.size,
          type: file.type,
          previewUrl: isPreviewableImage(file) ? URL.createObjectURL(file) : '',
        })
      })

      if (errors.length) {
        setActionMessage(errors.join('\n'))
      }

      return accepted.length
        ? { ...current, newQuotationFiles: [...cleanFileList(current.newQuotationFiles), ...accepted] }
        : current
    })
  }

  function removePendingQuotationFile(fileId) {
    setActionForm(current => {
      const target = cleanFileList(current.newQuotationFiles).find(file => file.id === fileId)
      if (target?.previewUrl) URL.revokeObjectURL(target.previewUrl)
      return { ...current, newQuotationFiles: cleanFileList(current.newQuotationFiles).filter(file => file.id !== fileId) }
    })
  }

  function removeSavedQuotationFile(storagePath) {
    setActionForm(current => ({
      ...current,
      quotationFiles: cleanFileList(current.quotationFiles).filter(file => file.storage_path !== storagePath),
    }))
  }

  function previewQuotationFile(file) {
    const targetUrl = file.previewUrl || file.file_url
    if (!targetUrl) return
    window.open(targetUrl, '_blank', 'noopener,noreferrer')
  }

  function downloadQuotationFile(file) {
    const targetUrl = file.previewUrl || file.file_url
    if (!targetUrl) return
    const anchor = document.createElement('a')
    anchor.href = targetUrl
    anchor.download = file.file_name || file.name || 'quotation-file'
    anchor.target = '_blank'
    anchor.rel = 'noopener noreferrer'
    anchor.click()
  }

  async function uploadQuotationFiles(responseId) {
    const pendingFiles = cleanFileList(actionForm.newQuotationFiles)
    if (!pendingFiles.length) return cleanFileList(actionForm.quotationFiles)

    const client = requireSupabase()
    const uploadedFiles = []

    for (const pending of pendingFiles) {
      const storagePath = createStoragePath(responseId, pending.name)
      const { error: uploadError } = await client.storage.from(QUOTATION_BUCKET).upload(storagePath, pending.file, {
        cacheControl: '3600',
        upsert: false,
      })
      if (uploadError) throw uploadError

      const { data: publicUrlData } = client.storage.from(QUOTATION_BUCKET).getPublicUrl(storagePath)
      uploadedFiles.push({
        file_name: pending.name,
        file_url: publicUrlData?.publicUrl || '',
        storage_path: storagePath,
        uploaded_by: currentUser?.id || currentUser?.user_id || '',
        uploaded_date: new Date().toISOString(),
        mime_type: pending.type || '',
        file_size: pending.size || 0,
      })
    }

    return [...cleanFileList(actionForm.quotationFiles), ...uploadedFiles]
  }

  async function deleteRemovedQuotationFiles(originalFiles, nextFiles) {
    const removedPaths = cleanFileList(originalFiles)
      .map(file => file?.storage_path)
      .filter(Boolean)
      .filter(storagePath => !cleanFileList(nextFiles).some(file => file.storage_path === storagePath))

    if (!removedPaths.length) return
    const client = requireSupabase()
    const { error: deleteError } = await client.storage.from(QUOTATION_BUCKET).remove(removedPaths)
    if (deleteError) throw deleteError
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

  function validateExpenseRequest() {
    const pending = []
    if (!actionForm.monetarySupportRequired) {
      pending.push('Enable monetary support before sending for approval')
      return pending
    }
    const amountText = String(actionForm.expectedExpenseAmount ?? '').trim()
    if (!amountText || !Number.isFinite(Number(amountText)) || Number(amountText) < 0) {
      pending.push('Expected Expense Amount missing')
    }
    if (!actionForm.expenseCategory) pending.push('Expense Category missing')
    if (!actionForm.expensePurpose.trim()) pending.push('Expense Purpose missing')
    return pending
  }

  async function saveAction(nextStatus = 'Planning') {
    if (!editingNgId || !(currentUser?.id || currentUser?.user_id)) return
    const pending = validateAction(nextStatus)
    if (pending.length) {
      setActionMessage(pending.join('\n'))
      return
    }

    const collaborator = people.find(person => person.id === actionForm.collaboratorUserId) || null
    const hasExpectedExpenseAmount = String(actionForm.expectedExpenseAmount ?? '').trim() !== ''
    const expectedExpenseAmount = hasExpectedExpenseAmount ? Number(actionForm.expectedExpenseAmount) : null
    const currentItem = hubCards.find(item => item.id === editingNgId)
    let quotationFiles = cleanFileList(actionForm.quotationFiles)
    setActionSaving(true)
    setActionMessage('')
    try {
      const client = requireSupabase()
      quotationFiles = await uploadQuotationFiles(editingNgId)
      const { error: saveError } = await client.rpc('submit_disha_action_update', {
        p_response_id: editingNgId,
        p_user_id: currentUser.id || currentUser.user_id,
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
        p_expected_expense_amount: Number.isFinite(expectedExpenseAmount) && expectedExpenseAmount >= 0 ? expectedExpenseAmount : null,
        p_expense_purpose: actionForm.expensePurpose || null,
        p_expense_category: actionForm.expenseCategory || null,
        p_ceo_approval_required: Boolean(actionForm.monetarySupportRequired),
        p_extension_requested_date: actionForm.extensionRequestedDate || null,
        p_extension_reason: actionForm.extensionReason || null,
        p_quotation_files: quotationFiles,
      })
      if (saveError) throw saveError
      await deleteRemovedQuotationFiles(currentItem?.quotationFiles, quotationFiles)
      setActionMessage(nextStatus === 'Submitted for Review' ? 'Submitted for review' : 'Progress saved')
      cleanFileList(actionForm.newQuotationFiles).forEach(file => {
        if (file.previewUrl) URL.revokeObjectURL(file.previewUrl)
      })
      setRefreshKey(current => current + 1)
      if (nextStatus === 'Submitted for Review') setEditingNgId('')
    } catch (saveError) {
      if (quotationFiles.length > cleanFileList(actionForm.quotationFiles).length) {
        try {
          const uploadedPaths = quotationFiles
            .filter(file => !cleanFileList(actionForm.quotationFiles).some(saved => saved.storage_path === file.storage_path))
            .map(file => file.storage_path)
            .filter(Boolean)
          if (uploadedPaths.length) {
            const client = requireSupabase()
            await client.storage.from(QUOTATION_BUCKET).remove(uploadedPaths)
          }
        } catch {
          // Keep the original error visible; orphan cleanup can be retried manually.
        }
      }
      setActionMessage(saveError?.message || 'Unable to update action.')
    } finally {
      setActionSaving(false)
    }
  }

  async function sendExpenseForApproval() {
    if (!editingNgId || !(currentUser?.id || currentUser?.user_id)) return
    const pending = validateExpenseRequest()
    if (pending.length) {
      setActionMessage(pending.join('\n'))
      return
    }

    const collaborator = people.find(person => person.id === actionForm.collaboratorUserId) || null
    const hasExpectedExpenseAmount = String(actionForm.expectedExpenseAmount ?? '').trim() !== ''
    const expectedExpenseAmount = hasExpectedExpenseAmount ? Number(actionForm.expectedExpenseAmount) : null
    const currentItem = hubCards.find(item => item.id === editingNgId)
    let quotationFiles = cleanFileList(actionForm.quotationFiles)
    setActionSaving(true)
    setActionMessage('')
    try {
      const client = requireSupabase()
      quotationFiles = await uploadQuotationFiles(editingNgId)
      const { error: saveError } = await client.rpc('submit_disha_action_update', {
        p_response_id: editingNgId,
        p_user_id: currentUser.id || currentUser.user_id,
        p_status: currentItem?.actionStatus || currentItem?.status || 'Planning',
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
        p_monetary_support_required: true,
        p_expected_expense_amount: Number.isFinite(expectedExpenseAmount) && expectedExpenseAmount >= 0 ? expectedExpenseAmount : null,
        p_expense_purpose: actionForm.expensePurpose || null,
        p_expense_category: actionForm.expenseCategory || null,
        p_ceo_approval_required: true,
        p_extension_requested_date: actionForm.extensionRequestedDate || null,
        p_extension_reason: actionForm.extensionReason || null,
        p_quotation_files: quotationFiles,
      })
      if (saveError) throw saveError
      await deleteRemovedQuotationFiles(currentItem?.quotationFiles, quotationFiles)
      setActionMessage(currentItem?.canResubmitExpense ? 'Resubmitted for approval' : 'Sent for approval')
      cleanFileList(actionForm.newQuotationFiles).forEach(file => {
        if (file.previewUrl) URL.revokeObjectURL(file.previewUrl)
      })
      setRefreshKey(current => current + 1)
      setEditingNgId('')
    } catch (saveError) {
      if (quotationFiles.length > cleanFileList(actionForm.quotationFiles).length) {
        try {
          const uploadedPaths = quotationFiles
            .filter(file => !cleanFileList(actionForm.quotationFiles).some(saved => saved.storage_path === file.storage_path))
            .map(file => file.storage_path)
            .filter(Boolean)
          if (uploadedPaths.length) {
            const client = requireSupabase()
            await client.storage.from(QUOTATION_BUCKET).remove(uploadedPaths)
          }
        } catch {
          // Keep the original error visible; orphan cleanup can be retried manually.
        }
      }
      setActionMessage(saveError?.message || 'Unable to send for approval.')
    } finally {
      setActionSaving(false)
    }
  }

  async function approveExpense(item, decision) {
    if (!(currentUser?.id || currentUser?.user_id)) return
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
        p_user_id: currentUser.id || currentUser.user_id,
        p_role: getExpenseApprovalRole(currentUser, item),
        p_decision: decision,
        p_comments: comments || null,
      })
      if (approvalError) throw approvalError
      setActionMessage(decision === 'Approved'
        ? (['Pending CEO Approval', 'Resubmitted for CEO Approval'].includes(item.ceoApprovalStatus) ? 'CEO approval recorded' : 'Forwarded to CEO after Group DISHA approval')
        : (['Pending CEO Approval', 'Resubmitted for CEO Approval'].includes(item.ceoApprovalStatus) ? 'CEO rejection recorded' : 'Returned to PIC by Group DISHA'))
      setEditingNgId('')
      setRefreshKey(current => current + 1)
    } catch (approvalError) {
      setActionMessage(approvalError?.message || 'Unable to update expense approval.')
    } finally {
      setActionSaving(false)
    }
  }

  async function reviewAction(item, decision) {
    if (!(currentUser?.id || currentUser?.user_id)) return
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
        p_user_id: currentUser.id || currentUser.user_id,
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

    <section className="card action-section-card">
      <div className="panel-head"><div><span className="eyebrow">SIMPLIFIED ACTION JOURNEY</span><h2>NG action items</h2></div><Bell /></div>
      {hasActionAccess && <section className="action-summary-grid">
        {visibleTabs.map(tab => <ActionCard key={tab.key} title={tab.label} count={tab.count} meta={tab.meta} tone={tab.tone} icon={tab.icon} onClick={() => setActiveTab(tab.key)} />)}
      </section>}
      {!hasActionAccess && <div className="action-empty">No Action Center tabs are available for this role.</div>}
      {hasActionAccess && <div className="tabs">{visibleTabs.map(tab => <button className={activeTab === tab.key ? 'active' : ''} onClick={() => setActiveTab(tab.key)} key={tab.key}>{tab.label} <span>{tab.count}</span></button>)}</div>}
      {hasActionAccess && (loading ? <div className="action-empty">{activeTab === 'review' ? 'Loading review items...' : 'Loading Disha Action Hub...'}</div> : error ? <div className="action-empty">{error}</div> : hubRows.length === 0 ? <div className="action-empty">{activeTab === 'review' ? 'No items pending for review.' : activeTab === 'assigned' ? 'No valid NG action items assigned.' : 'No NG actions found for this view.'}</div> : <div className="audit-review-table">
        {hubRows.map(item => {
          const canUpdate = adminView || item.isAssigned || item.isCollaborator
          const canReview = reviewerView || adminView
          const statusTone = item.overdue ? 'critical' : item.closed ? 'normal' : 'high'
          const statusLabel = item.overdue ? 'Overdue' : item.status
          const compactStatus = getCompactStatusLabel(item.status)
          const processFlowStage = getProcessFlowStage(item.status)
          return <div key={item.id} className="action-row">
            <div className="action-main">
              <div className="action-row-header">
                <StatusBadge>{compactStatus}</StatusBadge>
                <div className="action-header-copy">
                  <strong>{item.auditId || item.rawAuditId || 'Not available'}</strong>
                  <span>{safeJoin([item.dq, item.subQuestion])}</span>
                </div>
                <div className="action-header-meta">
                  <span>Target: {item.targetDate}</span>
                  {item.overdue && <span className={`action-priority ${statusTone}`}>{statusLabel}</span>}
                </div>
              </div>
              <div className="action-section-block">
                <span className="action-section-label">Question</span>
                <p className="action-question">Question: {item.question}</p>
              </div>
              <div className="action-section-block">
                <span className="action-section-label">Condition / Gap</span>
                <p className="action-condition">{item.condition}</p>
              </div>
              <div className="action-section-block">
                <span className="action-section-label">Assignment & Action Summary</span>
                <small className="action-meta">Location: {item.location} • Department: {item.department} • Assigned PIC: {item.assignedPic}</small>
                <small className="action-meta">Root Cause: {item.rootCause || 'Not available'}</small>
                <small className="action-meta">Action Plan Status: {item.reviewReady ? 'Ready for review' : item.status}</small>
                <small className="action-meta">Closure Submitted Date: {item.actualClosureDate || 'Not available'}</small>
              </div>
              {['expense', 'financial-review', 'financial-approval'].includes(activeTab) && <>
                <small>Support Department: {item.supportDepartment || 'Not available'}</small>
                <small>Expected Expense: {formatMoney(item.expectedExpenseAmount)}</small>
                <small>Expense Purpose: {item.expensePurpose || 'Not available'}</small>
                <small>Expense Approval: {item.expenseApprovalStatus}</small>
                <small>Current Stage: {item.currentStage}</small>
                <small>Current Approver: {item.currentApprover}</small>
                <small>Quotation Status: {item.quotationFiles.length ? 'Quotation Attached' : 'No Quotation Attached'}</small>
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
                <div><span>Current Stage</span><strong>{item.currentStage}</strong></div>
                <div><span>Current Approver</span><strong>{item.currentApprover}</strong></div>
                <div><span>Group DISHA Recommendation</span><strong>{item.groupDishaApprovalStatus || 'Not available'}</strong></div>
                <div><span>Group DISHA Remarks</span><strong>{item.groupDishaReviewRemarks || 'Not available'}</strong></div>
                <div><span>CEO Review Status</span><strong>{item.ceoApprovalStatus || 'Not available'}</strong></div>
                <div><span>CEO Remarks</span><strong>{item.ceoReviewRemarks || 'Not available'}</strong></div>
                <div><span>Expected Expense</span><strong>{formatMoney(item.expectedExpenseAmount)}</strong></div>
                <div><span>Quotation Status</span><strong>{item.quotationFiles.length ? 'Quotation Attached' : 'No Quotation Attached'}</strong></div>
                <div><span>Action Taken</span><strong>{item.actionTaken || item.closureRemarks || 'Not available'}</strong></div>
                <div><span>Actual Closure Date</span><strong>{item.actualClosureDate || 'Not available'}</strong></div>
              </section>}
              {detailNgId === item.id && item.monetarySupportRequired && <section className="action-quotation-panel">
                <div className="panel-head compact-head">
                  <div>
                    <span className="eyebrow">QUOTATION / SUPPORTING DOCUMENTS</span>
                    <h2>Attachments for approval</h2>
                  </div>
                  <StatusBadge>{item.quotationFiles.length ? 'Quotation Attached' : 'No Quotation Attached'}</StatusBadge>
                </div>
                {!item.quotationFiles.length ? <div className="action-empty">No quotation attached. CEO approval can still proceed.</div> : <div className="quotation-list">
                  {item.quotationFiles.map(file => <div key={file.storage_path || file.file_url || file.file_name} className="quotation-file-card">
                    <div className="quotation-file-main">
                      <span className="quotation-file-icon">{isPdfFile(file) ? <FileText size={16} /> : <FileImage size={16} />}</span>
                      <div>
                        <strong>{file.file_name || 'Attachment'}</strong>
                        <small>{formatFileSize(file.file_size)} | {file.uploaded_date ? new Date(file.uploaded_date).toLocaleString('en-IN') : 'Uploaded date unavailable'}</small>
                      </div>
                    </div>
                    <div className="quotation-file-actions">
                      {isPreviewableImage(file) && <button className="secondary-button" type="button" onClick={() => previewQuotationFile(file)}><Eye size={14} /> Preview</button>}
                      <button className="secondary-button" type="button" onClick={() => downloadQuotationFile(file)}>{isPdfFile(file) ? <FileText size={14} /> : <Download size={14} />}{isPdfFile(file) ? ' Open PDF' : ' Download'}</button>
                    </div>
                  </div>)}
                </div>}
              </section>}
              {detailNgId === item.id && <section className="action-process-flow">
                <div className="panel-head compact-head"><div><span className="eyebrow">PROCESS FLOW</span><h2>Action journey</h2></div></div>
                <div className="action-stepper">
                  {['Assigned', 'Planning', 'In Progress', 'Review', 'Closed', 'Reassigned'].map((stage, index) => (
                    <div key={stage} className={`action-step ${processFlowStage === index ? 'active' : processFlowStage > index ? 'done' : ''}`}>
                      <b>{index + 1}</b>
                      <span>{stage}</span>
                    </div>
                  ))}
                </div>
              </section>}
              {detailNgId === item.id && item.monetarySupportRequired && <section className="action-process-flow">
                <div className="panel-head compact-head"><div><span className="eyebrow">FINANCIAL APPROVAL STATUS</span><h2>Approval timeline</h2></div></div>
                <div className="action-stepper financial">
                  {item.approvalTimeline.map((stage, index) => (
                    <div key={`${stage.label}-${index}`} className={`action-step ${stage.active ? 'active' : ''} ${stage.tone}`}>
                      <b>{index + 1}</b>
                      <span>{stage.label}</span>
                    </div>
                  ))}
                </div>
                <div className="approval-history-list">
                  {item.approvalTrail.length ? item.approvalTrail.map(entry => <div key={entry.id} className="approval-history-row">
                    <strong>{entry.level}: {entry.decision}</strong>
                    <span>{entry.at || 'Date unavailable'} | {entry.previousStatus} {'->'} {entry.newStatus}</span>
                    <small>{entry.remarks}</small>
                  </div>) : <div className="action-empty compact">No approval history recorded yet.</div>}
                </div>
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
                    <div className="wide approval-status-line"><span>Expense Approval Status</span><StatusBadge>{item.canResubmitExpense ? item.expenseApprovalStatus : getExpenseDraftStatus(item, actionForm)}</StatusBadge></div>
                    <div className="wide approval-status-line"><span>Current Stage</span><StatusBadge>{item.currentStage}</StatusBadge></div>
                    <div className="wide approval-status-line"><span>Current Approver</span><StatusBadge>{item.currentApprover}</StatusBadge></div>
                    <div className="wide approval-status-line"><span>Group DISHA Review</span><StatusBadge>{item.groupDishaApprovalStatus || 'Pending Group DISHA Review'}</StatusBadge></div>
                    <div className="wide approval-status-line"><span>CEO Approval</span><StatusBadge>{item.ceoApprovalStatus || 'Not Required'}</StatusBadge></div>
                    {item.groupDishaReviewRemarks && <div className="wide"><span className="action-section-label">Group DISHA Remarks</span><p className="quotation-upload-copy">{item.groupDishaReviewRemarks}</p></div>}
                    {item.ceoReviewRemarks && <div className="wide"><span className="action-section-label">CEO Remarks</span><p className="quotation-upload-copy">{item.ceoReviewRemarks}</p></div>}
                    {canUpdate && actionForm.monetarySupportRequired && <div className="wide">
                      <button className="primary-button" type="button" onClick={sendExpenseForApproval} disabled={actionSaving}>{item.canResubmitExpense ? 'Resubmit for Approval' : 'Send for Approval'}</button>
                    </div>}
                    <div className="wide quotation-upload-panel">
                      <div className="panel-head compact-head">
                        <div>
                          <span className="eyebrow">OPTIONAL</span>
                          <h2>Quotation / Supporting Documents</h2>
                        </div>
                        <StatusBadge>{cleanFileList(actionForm.quotationFiles).length || cleanFileList(actionForm.newQuotationFiles).length ? 'Quotation Attached' : 'No Quotation Attached'}</StatusBadge>
                      </div>
                      <p className="quotation-upload-copy">Upload vendor quotations, estimates, images, supporting documents, or cost justifications. Up to 10 files, 10 MB each. JPG, JPEG, PNG, and PDF only.</p>
                      <label className="quotation-upload-dropzone">
                        <Upload size={16} />
                        <span>Add files</span>
                        <input type="file" accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf" multiple onChange={handleQuotationFiles} />
                      </label>
                      {!cleanFileList(actionForm.quotationFiles).length && !cleanFileList(actionForm.newQuotationFiles).length ? <div className="action-empty compact">No quotation attached yet. This section is optional.</div> : <div className="quotation-list">
                        {cleanFileList(actionForm.quotationFiles).map(file => <div key={file.storage_path || file.file_url || file.file_name} className="quotation-file-card">
                          <div className="quotation-file-main">
                            <span className="quotation-file-icon">{isPdfFile(file) ? <FileText size={16} /> : <FileImage size={16} />}</span>
                            <div>
                              <strong>{file.file_name}</strong>
                              <small>{formatFileSize(file.file_size)} | Saved in workflow</small>
                            </div>
                          </div>
                          <div className="quotation-file-actions">
                            {isPreviewableImage(file) && <button className="secondary-button" type="button" onClick={() => previewQuotationFile(file)}><Eye size={14} /> Preview</button>}
                            <button className="secondary-button" type="button" onClick={() => downloadQuotationFile(file)}><Download size={14} /> Download</button>
                            <button className="secondary-button" type="button" onClick={() => removeSavedQuotationFile(file.storage_path)}><X size={14} /> Remove</button>
                          </div>
                        </div>)}
                        {cleanFileList(actionForm.newQuotationFiles).map(file => <div key={file.id} className="quotation-file-card pending">
                          <div className="quotation-file-main">
                            <span className="quotation-file-icon">{isPdfFile(file) ? <FileText size={16} /> : <FileImage size={16} />}</span>
                            <div>
                              <strong>{file.name}</strong>
                              <small>{formatFileSize(file.size)} | Ready to upload on save</small>
                            </div>
                          </div>
                          <div className="quotation-file-actions">
                            {isPreviewableImage(file) && <button className="secondary-button" type="button" onClick={() => previewQuotationFile(file)}><Eye size={14} /> Preview</button>}
                            <button className="secondary-button" type="button" onClick={() => downloadQuotationFile(file)}><Download size={14} /> Download</button>
                            <button className="secondary-button" type="button" onClick={() => removePendingQuotationFile(file.id)}><X size={14} /> Remove</button>
                          </div>
                        </div>)}
                      </div>}
                    </div>
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
                {(canReview || item.reviewReady || (expenseApproverView && ['expense', 'financial-review', 'financial-approval'].includes(activeTab))) && <label className="wide">Review Comments<textarea rows="2" value={actionForm.reviewComments} onChange={event => updateActionForm('reviewComments', event.target.value)} /></label>}
                {actionMessage && <div className="wide audit-checklist-note" role="alert"><span>{actionMessage}</span></div>}
                <div className="wide form-footer">
                  <button className="secondary-button" type="button" onClick={() => setEditingNgId('')} disabled={actionSaving}>Cancel</button>
                  <div>
                    {canUpdate && <button className="secondary-button" type="button" onClick={() => saveAction(actionForm.actionPlanItems.length ? 'In Progress' : 'Planning')} disabled={actionSaving}>Save Progress</button>}
                    {canUpdate && <button className="primary-button" type="button" onClick={() => saveAction('Submitted for Review')} disabled={actionSaving}>Submit for Review</button>}
                    {canReview && item.reviewReady && <button className="primary-button" type="button" onClick={() => reviewAction(item, 'Approve Closure')} disabled={actionSaving}>Approve Closure</button>}
                    {canReview && item.reviewReady && <button className="secondary-button" type="button" onClick={() => reviewAction(item, 'Send Back')} disabled={actionSaving}>Send Back</button>}
                    {expenseApproverView && ['expense', 'financial-review', 'financial-approval'].includes(activeTab) && canActOnExpense(item) && <button className="primary-button" type="button" onClick={() => approveExpense(item, 'Approved')} disabled={actionSaving}>{activeTab === 'financial-review' ? 'Approve & Forward to CEO' : 'Approve'}</button>}
                    {expenseApproverView && ['expense', 'financial-review', 'financial-approval'].includes(activeTab) && canActOnExpense(item) && <button className="secondary-button" type="button" onClick={() => approveExpense(item, 'Rejected')} disabled={actionSaving}>Reject</button>}
                  </div>
                </div>
              </section>}
            </div>
            <div className="action-row-actions">
              <button className="secondary-button" type="button" onClick={() => setDetailNgId(current => current === item.id ? '' : item.id)}>View Details</button>
              {canUpdate ? <button className="primary-button" type="button" onClick={() => openActionForm(item)}>{item.canResubmitExpense ? 'Revise & Resubmit' : 'Update Action'}</button> : <button className="secondary-button" type="button" onClick={() => setDetailNgId(item.id)}>View Progress</button>}
              {canReview && item.reviewQueue && <button className="primary-button" type="button" onClick={() => reviewAction(item, 'Approve Closure')} disabled={actionSaving}>Approve Closure</button>}
              {canReview && item.reviewQueue && <button className="secondary-button" type="button" onClick={() => reviewAction(item, 'Send Back')} disabled={actionSaving}>Send Back</button>}
              {expenseApproverView && ['expense', 'financial-review', 'financial-approval'].includes(activeTab) && canActOnExpense(item) && <button className="primary-button" type="button" onClick={() => openActionForm(item)}>{activeTab === 'financial-review' ? 'Review' : 'Approve'}</button>}
            </div>
          </div>
        })}
      </div>)}
    </section>
  </div>
}
