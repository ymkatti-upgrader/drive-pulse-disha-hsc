import { useEffect, useMemo, useRef, useState } from 'react'
import { AlertCircle, Check, CheckCircle2, ChevronLeft, Minus, Save, Send, Trash2, Upload, X } from 'lucide-react'
import { useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { isInProgressAuditStatus, useAudits } from '../audits/AuditContext'
import { useAuditChecklist } from '../audits/useAuditChecklist'
import { checklistRowOrderValue } from '../audits/checklistSort'
import { Progress } from '../components/UI'
import { useCapas } from '../capa/CapaContext'
import { canAccessAuditModule, canManageDishaWorkflow, filterByUserAccess, getPrimaryRole, isSystemAdmin, useAuth } from '../auth/AuthContext'
import { requireSupabase } from '../supabaseClient'

function weightedScore(items) {
  const applicable = items.filter(item => item.result && item.result !== 'NA')
  const achieved = applicable.reduce((total, item) => total + (item.result === 'OK' ? item.weight : 0), 0)
  const available = applicable.reduce((total, item) => total + item.weight, 0)
  return { achieved, available, percent: available ? Math.round((achieved / available) * 100) : 0, questions: applicable.length }
}

function groupedScores(items, key) {
  return [...new Set(items.map(item => item[key]).filter(Boolean))].map(name => ({ name, ...weightedScore(items.filter(item => item[key] === name)) }))
}

function cleanQuestion(value) {
  return String(value || '').replace(/^\s*\d+(?:\.\d+)?[.)]?\s*/, '').trim()
}

function normalizeText(value) {
  return String(value || '').trim().toLowerCase()
}

function joinParts(parts) {
  return parts.filter(Boolean).join(' · ')
}

function buildPicLabel(user) {
  return joinParts([
    user.employee_name || user.name || user.full_name,
    user.role,
    user.department,
    user.location,
  ])
}

function normalizeWhatsAppMobile(value) {
  const digits = String(value || '').replace(/\D/g, '')
  if (!digits) return ''
  if (digits.startsWith('91') && digits.length >= 12) return digits.slice(0, 12)
  if (digits.length === 10) return `91${digits}`
  if (digits.length > 10) return `91${digits.slice(-10)}`
  return digits
}

function buildWhatsAppMessage({ picName, auditLocation, department, dqQuestionNum, subQuestion, currentCondition, tentativeClosingDate, auditorName }) {
  return [
    `Dear ${picName},`,
    '',
    'NG observed in Disha HanSaChu Audit.',
    '',
    `Location: ${auditLocation || '-'}`,
    `Department: ${department || '-'}`,
    `DQ: ${dqQuestionNum || '-'}`,
    `Sub-question: ${subQuestion || '-'}`,
    `Current Condition / Gap Observed: ${currentCondition || '-'}`,
    `Tentative closing date: ${tentativeClosingDate || '-'}`,
    '',
    'Please review and take corrective action.',
    '',
    'Regards,',
    auditorName || '-',
  ].join('\n')
}

function buildWhatsAppUrl(number, message) {
  const normalizedNumber = normalizeWhatsAppMobile(number)
  if (!normalizedNumber) return ''
  return `https://wa.me/${normalizedNumber}?text=${encodeURIComponent(message)}`
}

function combineCurrentConditionAndGap(currentCondition, gapObserved) {
  const condition = String(currentCondition || '').trim()
  const gap = String(gapObserved || '').trim()
  if (!gap) return condition
  if (/\bGap\s*:/i.test(condition) && condition.toLowerCase().includes(gap.toLowerCase())) return condition
  return [condition, `Gap: ${gap}`].filter(Boolean).join('\n')
}

function normalizeRequirementFlag(value) {
  return normalizeText(value) === 'yes'
}

function describeSupabaseError(error) {
  if (!error) return 'Unknown Supabase error'
  const parts = [error.message || 'Unknown Supabase error']
  if (error.code) parts.push(`code=${error.code}`)
  if (error.details) parts.push(`details=${error.details}`)
  if (error.hint) parts.push(`hint=${error.hint}`)
  return parts.join(' | ')
}

function isUuid(value) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(String(value || '').trim())
}

function logAuditSaveContext({ operation, table, user, auditId, auditLocation, auditDepartments, payload, error }) {
  const payloadKeys = Array.isArray(payload) ? Object.keys(payload[0] || {}) : Object.keys(payload || {})
  console.info('[Audit save context]', {
    operation,
    table,
    role: getPrimaryRole(user),
    userId: user?.id || '',
    userEmail: user?.email || user?.mobile_no || '',
    auditId,
    location: auditLocation || '',
    departments: Array.isArray(auditDepartments) ? auditDepartments : [],
    payloadKeys,
    errorCode: error?.code || '',
    errorMessage: error?.message || '',
    errorDetails: error?.details || '',
    errorHint: error?.hint || '',
  })
}

function isDeletableAuditStatus(status) {
  const normalized = normalizeText(status)
  return ['draft', 'in progress', 'in_progress', 'pending submission'].includes(normalized)
}

function isSubmittedAuditStatus(status) {
  return ['submitted', 'completed', 'approved', 'closed'].includes(normalizeText(status))
}

function humanizeConductAuditStatus(status) {
  const value = normalizeText(status)
  if (value === 'scheduled') return 'Scheduled'
  if (value === 'in_progress' || value === 'in progress') return 'In Progress'
  if (value === 'submitted') return 'Submitted'
  if (value === 'completed') return 'Completed'
  return status || 'Draft'
}

function mapRouteAuditRow(audit = {}, lookups = {}) {
  return {
    id: audit.id,
    auditId: audit.audit_number || audit.audit_no || audit.id,
    auditNumber: audit.audit_number || audit.audit_no || '',
    audit_no: audit.audit_no || audit.audit_number || '',
    audit_number: audit.audit_number || audit.audit_no || '',
    audit_type: audit.title || '',
    title: audit.title || '',
    locationId: audit.location_id || '',
    location: lookups.location?.name || lookups.location?.code || '',
    departmentId: audit.department_id || '',
    department: lookups.department?.name || '',
    departments: lookups.department?.name ? [lookups.department.name] : [],
    auditFunctionId: audit.audit_function_id || '',
    auditFunction: lookups.auditFunction?.name || 'Not Assigned',
    auditor_id: audit.auditor_id || '',
    auditor_name: lookups.auditor?.employee_name || '',
    start_date: audit.scheduled_date || '',
    date: audit.scheduled_date || '',
    scheduled_date: audit.scheduled_date || '',
    startedAt: audit.started_at || '',
    submittedAt: audit.submitted_at || '',
    completedAt: audit.completed_at || '',
    created_at: audit.created_at || '',
    updated_at: audit.updated_at || '',
    status: humanizeConductAuditStatus(audit.status),
    score: audit.score ?? null,
    created_by: audit.created_by || '',
  }
}

function canDeleteAudit(user, audit) {
  if (!audit || !isDeletableAuditStatus(audit.status)) return false
  return isSystemAdmin(user)
}

function getPendingReasons(item) {
  const reasons = []
  if (!item.result) reasons.push('Result not selected')
  if (item.result === 'NG' && !String(item.currentCondition || '').trim()) reasons.push('Current Condition / Gap Observed missing')
  if (item.result === 'NG' && !String(item.picForNgUserId || item.picForNg || '').trim()) reasons.push('PIC for NG missing')
  if (item.result === 'NG' && !String(item.tentative_closing_date || item.tentativeClosingDate || '').trim()) reasons.push('Tentative Closing Date missing')
  return reasons
}

function formatPendingListMessage(pendingItems, dqCode) {
  if (!pendingItems.length) return ''
  const lines = pendingItems.map(({ item, reasons, subQuestionNum, subQuestionText }) => {
    const code = dqCode || item.dqQuestionNum || item.id || 'DQ'
    const questionNum = subQuestionNum || getQuestionLabel(item, 0)
    const missing = reasons.join(', ')
    return `${code} - Q${questionNum} - ${subQuestionText}: ${missing}`
  })
  return `Please complete the following before moving to next DQ:\n${lines.join('\n')}`
}

function groupChecklistByDq(items) {
  const grouped = new Map()
  items.forEach(item => {
    const code = item.id || 'DQ'
    if (!grouped.has(code)) grouped.set(code, [])
    grouped.get(code).push(item)
  })
  return [...grouped.entries()].map(([code, groupItems], index) => ({
    code,
    index,
    items: [...groupItems].sort((a, b) => {
      const aRowOrder = Number.isFinite(a.rowOrder) ? a.rowOrder : checklistRowOrderValue(a)
      const bRowOrder = Number.isFinite(b.rowOrder) ? b.rowOrder : checklistRowOrderValue(b)
      if (aRowOrder !== bRowOrder) return aRowOrder - bRowOrder
      const aSerial = Number.isFinite(a.displaySubQuestionNum) ? a.displaySubQuestionNum : Number.isFinite(a.subQuestionNum) ? a.subQuestionNum : Number.POSITIVE_INFINITY
      const bSerial = Number.isFinite(b.displaySubQuestionNum) ? b.displaySubQuestionNum : Number.isFinite(b.subQuestionNum) ? b.subQuestionNum : Number.POSITIVE_INFINITY
      if (aSerial !== bSerial) return aSerial - bSerial
      return String(a.dbId).localeCompare(String(b.dbId))
    }),
    label: groupItems[0]?.id || code,
    title: groupItems[0]?.evaluationParameter || groupItems[0]?.question || groupItems[0]?.chapter || 'Main Question',
  }))
}

function splitDelimitedValues(value) {
  if (Array.isArray(value)) return value.map(item => String(item || '').trim()).filter(Boolean)
  return String(value || '').split(',').map(item => item.trim()).filter(Boolean)
}

function rowSerial(item, index) {
  if (Number.isFinite(item.displaySubQuestionNum)) return String(item.displaySubQuestionNum)
  if (Number.isFinite(item.subQuestionNum)) return String(item.subQuestionNum)
  if (item.questionLabel) return String(item.questionLabel)
  if (item.dqQuestionNum) return String(item.dqQuestionNum)
  return String(index + 1)
}

function getQuestionLabel(item, index) {
  const serial = rowSerial(item, index)
  return serial === item.id ? item.id : serial
}

function getSubQuestionTooltip(item) {
  const main = cleanQuestion(item.evaluationQuestion || item.question)
  const detail = cleanQuestion(item.question || item.evaluationParameter || item.chapter || item.area || '')
  return detail && detail !== main ? detail : ''
}

function auditDraftStorageKey(auditId) {
  return auditId ? `disha-hsc-audit-draft:${auditId}` : ''
}

function normalizeDraftDate(value) {
  return String(value || '').slice(0, 10)
}

function getTentativeClosingDate(item) {
  return normalizeDraftDate(item?.tentative_closing_date || item?.tentativeClosingDate || '')
}

function normalizeDraftValue(value) {
  return value === undefined ? null : value
}

function hasMeaningfulQuestionData(item) {
  return Boolean(
    cleanQuestion(item?.evaluationQuestion || item?.question || '')
    || String(item?.dqQuestionNum || item?.id || '').trim()
    || String(item?.dbId || '').trim()
  )
}

function shouldPersistAuditResponse(item, auditId) {
  if (!auditId || !item?.dbId || !hasMeaningfulQuestionData(item)) return false
  const hasAnyActionableInput = Boolean(
    String(item.result || '').trim()
    || String(item.currentCondition || '').trim()
    || String(item.gapIdentified || '').trim()
    || String(item.picForNgUserId || item.picForNg || '').trim()
    || String(item.tentative_closing_date || item.tentativeClosingDate || '').trim()
    || (Array.isArray(item.evidenceFiles) && item.evidenceFiles.length)
  )
  if (!hasAnyActionableInput) return false
  if (item.result === 'NG' && !hasMeaningfulQuestionData(item)) return false
  return true
}

function getNgActionWorkflowStatus(item) {
  if (item?.result !== 'NG') return null
  return String(item?.picForNgUserId || item?.picForNgMobile || item?.picForNg || '').trim() ? 'Assigned' : 'Open'
}

function buildDraftPayload(items, auditId, auditReference, respondedBy) {
  return items
    .filter(item => shouldPersistAuditResponse(item, auditId))
    .map(item => {
      const actionStatus = getNgActionWorkflowStatus(item)
      return {
        audit_id: auditReference || auditId,
        audit_uuid: isUuid(auditId) ? auditId : null,
        checklist_id: normalizeDraftValue(item.dbId),
        dq_question_num: normalizeDraftValue(item.dqQuestionNum || item.id || null),
        sub_question_num: normalizeDraftValue(Number.isFinite(item.displaySubQuestionNum) ? String(item.displaySubQuestionNum) : Number.isFinite(item.subQuestionNum) ? String(item.subQuestionNum) : null),
        sub_question_text: normalizeDraftValue(cleanQuestion(item.evaluationQuestion || item.question || '')) || null,
        result: normalizeDraftValue(item.result || null),
        current_condition_observed: String(item.currentCondition || '').trim() || null,
        observation: String(item.currentCondition || '').trim() || null,
        comments: String(item.gapIdentified || '').trim() || null,
        audit_location: normalizeDraftValue(item.auditLocation || null),
        audit_department: normalizeDraftValue(item.auditDepartment || null),
        responded_by: normalizeDraftValue(respondedBy),
        pic_for_ng_user_id: normalizeDraftValue(item.picForNgUserId || null),
        assigned_pic_user_id: normalizeDraftValue(item.picForNgUserId || null),
        pic_for_ng_name: normalizeDraftValue(item.picForNgName || item.picForNg || null),
        pic_for_ng_mobile: normalizeDraftValue(item.picForNgMobile || null),
        pic_for_ng: normalizeDraftValue(item.picForNgName || item.picForNg || null),
        status: actionStatus,
        action_status: actionStatus,
        closure_status: item.result === 'NG' ? 'Open' : null,
        verification_status: item.result === 'NG' ? 'Not Started' : null,
        is_void: false,
        tentative_closing_date: getTentativeClosingDate(item) || null,
        evidence_files: Array.isArray(item.evidenceFiles) ? item.evidenceFiles : [],
      }
    })
    .map(record => Object.fromEntries(Object.entries(record).map(([key, value]) => [key, value === undefined ? null : value])))
}

function mergeDraftRows(items, rows) {
  const rowsByChecklist = new Map((rows || []).map(row => [String(row.checklist_id || '').trim(), row]))
  return items.map(item => {
    const row = rowsByChecklist.get(String(item.dbId || '').trim())
    if (!row) return item
    const combinedCondition = combineCurrentConditionAndGap(row.current_condition_observed || row.observation || '', row.comments || '')
    return {
      ...item,
      result: row.result || '',
      currentCondition: combinedCondition,
      gapIdentified: row.comments || '',
      auditLocation: row.audit_location || item.auditLocation || '',
      auditDepartment: row.audit_department || item.auditDepartment || '',
      picForNg: row.assigned_pic_user_id || row.pic_for_ng_user_id || row.pic_for_ng || '',
      picForNgUserId: row.assigned_pic_user_id || row.pic_for_ng_user_id || '',
      picForNgName: row.pic_for_ng_name || row.pic_for_ng || '',
      picForNgMobile: row.pic_for_ng_mobile || '',
      status: row.action_status || row.status || '',
      tentative_closing_date: normalizeDraftDate(row.tentative_closing_date),
      tentativeClosingDate: normalizeDraftDate(row.tentative_closing_date),
      evidenceFiles: Array.isArray(row.evidence_files) ? row.evidence_files : [],
      evidenceUploaded: Array.isArray(row.evidence_files) ? row.evidence_files.length > 0 : Boolean(item.evidenceUploaded),
      rootCause: row.root_cause || '',
      correctiveActionPlan: row.corrective_action_plan || '',
      preventiveActionPlan: row.preventive_action_plan || '',
      actionTaken: row.action_taken || '',
      closureRemarks: row.closure_remarks || '',
      actualClosureDate: normalizeDraftDate(row.actual_closure_date),
      closureEvidenceFiles: Array.isArray(row.closure_evidence_files) ? row.closure_evidence_files : [],
    }
  })
}

function summarizeDraftRows(rows = []) {
  return (rows || []).slice(0, 5).map(row => ({
    id: row.id,
    audit_id: row.audit_id,
    audit_uuid: row.audit_uuid,
    checklist_id: row.checklist_id,
    result: row.result,
  }))
}

function summarizeChecklistItems(items = []) {
  return (items || []).slice(0, 5).map(item => ({
    checklist_id: item.dbId,
    dbId: item.dbId,
    id: item.id,
    dqQuestionNum: item.dqQuestionNum,
    title: item.evaluationQuestion || item.question || item.evaluationParameter || item.chapter || '',
    result: item.result || '',
  }))
}

function countMatchedDraftRows(items = [], rows = []) {
  const itemIds = new Set((items || []).map(item => String(item.dbId || '').trim()).filter(Boolean))
  return (rows || []).filter(row => itemIds.has(String(row.checklist_id || '').trim())).length
}

function mergeChecklistState(nextItems, existingItems) {
  const existingById = new Map((existingItems || []).map(item => [item.dbId, item]))
  return nextItems.map(item => {
    const existing = existingById.get(item.dbId)
    if (!existing) return item
    return {
      ...item,
      ...existing,
      auditLocation: item.auditLocation,
      auditDepartment: item.auditDepartment,
      tentative_closing_date: getTentativeClosingDate(existing),
      tentativeClosingDate: getTentativeClosingDate(existing),
    }
  })
}

function countAnsweredItems(items = []) {
  return (items || []).filter(item => String(item?.result || '').trim()).length
}

function getItemDqCode(item) {
  return String(item?.id || item?.dqQuestionNum || '').trim()
}

function sortDqItems(items = []) {
  return [...items].sort((a, b) => {
    const aRowOrder = Number.isFinite(a.rowOrder) ? a.rowOrder : checklistRowOrderValue(a)
    const bRowOrder = Number.isFinite(b.rowOrder) ? b.rowOrder : checklistRowOrderValue(b)
    if (aRowOrder !== bRowOrder) return aRowOrder - bRowOrder
    const aSerial = Number.isFinite(a.displaySubQuestionNum) ? a.displaySubQuestionNum : Number.isFinite(a.subQuestionNum) ? a.subQuestionNum : Number.POSITIVE_INFINITY
    const bSerial = Number.isFinite(b.displaySubQuestionNum) ? b.displaySubQuestionNum : Number.isFinite(b.subQuestionNum) ? b.subQuestionNum : Number.POSITIVE_INFINITY
    if (aSerial !== bSerial) return aSerial - bSerial
    const aOrder = Number.isFinite(a.subQuestionOrder) ? a.subQuestionOrder : Number.POSITIVE_INFINITY
    const bOrder = Number.isFinite(b.subQuestionOrder) ? b.subQuestionOrder : Number.POSITIVE_INFINITY
    if (aOrder !== bOrder) return aOrder - bOrder
    return String(a.dbId).localeCompare(String(b.dbId))
  })
}

function Gauge({ value }) {
  const bounded = Math.max(0, Math.min(100, Number(value) || 0))
  const angle = 180 - bounded * 1.8
  const radians = (angle * Math.PI) / 180
  const centerX = 120
  const centerY = 110
  const radius = 88
  const needleX = centerX + Math.cos(radians) * radius
  const needleY = centerY - Math.sin(radians) * radius
  return <div className="audit-gauge">
    <div className="audit-gauge-arc">
      <svg viewBox="0 0 240 130" className="audit-gauge-svg" role="img" aria-label={`Compliance score ${bounded}%`}>
        <path className="audit-gauge-track" pathLength="100" d="M 22 110 A 98 98 0 0 1 218 110" />
        <path className="audit-gauge-fill" pathLength="100" d="M 22 110 A 98 98 0 0 1 218 110" style={{ strokeDasharray: `${bounded} 100` }} />
        <line className="audit-gauge-needle" x1={centerX} y1={centerY} x2={needleX} y2={needleY} />
        <circle className="audit-gauge-hub" cx={centerX} cy={centerY} r="6" />
      </svg>
      <div className="audit-gauge-center">
        <strong>{bounded}%</strong>
        <span>Compliance Score</span>
      </div>
    </div>
  </div>
}

function ReviewSnapshot({ groups, activeGroup, onJumpToDq, auditFunction }) {
  return <section className="audit-review-panel card">
    <div className="audit-review-head">
      <div>
        <span>Review Audit</span>
        <h2>Snapshot of all DQ questions</h2>
      </div>
      <small>Audit Function: {auditFunction || 'Not Assigned'} | {groups.length} DQ groups</small>
    </div>
    <div className="audit-review-list">
      {groups.map(group => (
        <article key={group.code} className={`audit-review-group ${activeGroup?.code === group.code ? 'active' : ''}`}>
          <div className="audit-review-group-head">
            <div>
              <strong>{group.code}</strong>
              <span>{group.title}</span>
            </div>
            <button className="text-button" onClick={() => onJumpToDq(group.code)}>Open</button>
          </div>
          <div className="audit-review-table">
            <div className="audit-review-row head">
              <span>Sub</span>
              <span>Question</span>
              <span>Score</span>
              <span>Current Condition / Gap</span>
              <span>PIC</span>
            </div>
            {group.items.map((item, index) => (
              <div key={item.dbId} className="audit-review-row">
                <span>{getQuestionLabel(item, index)}</span>
                <span>{cleanQuestion(item.evaluationQuestion || item.question)}</span>
                <span>{item.result || '-'}</span>
                <span>{item.currentCondition || '-'}</span>
                <span>{item.picForNgName || item.picForNg || '-'}</span>
              </div>
            ))}
          </div>
        </article>
      ))}
    </div>
  </section>
}

function SummaryChip({ label, value, tone }) {
  return <div className={`audit-summary-chip ${tone || ''}`}>
    <span>{label}</span>
    <strong>{value}</strong>
  </div>
}

function DetailAccordion({ title, value, open = false }) {
  return <details className="audit-detail-accordion" open={open}>
    <summary>{title}</summary>
    <div>{value || '-'}</div>
  </details>
}

function ScoreButtons({ item, onSelect, disabled = false }) {
  return <div className="audit-score-buttons compact">
    <button disabled={disabled} className={`score-ok ${item.result === 'OK' ? 'selected' : ''}`} onClick={event => { event.stopPropagation(); if (!disabled) onSelect('OK') }}><Check /><span>OK</span></button>
    <button disabled={disabled} className={`score-ng ${item.result === 'NG' ? 'selected' : ''}`} onClick={event => { event.stopPropagation(); if (!disabled) onSelect('NG') }}><X /><span>NG</span></button>
    <button disabled={disabled} className={`score-na ${item.result === 'NA' ? 'selected' : ''}`} onClick={event => { event.stopPropagation(); if (!disabled) onSelect('NA') }}><Minus /><span>NA</span></button>
  </div>
}

function EvidenceUploadCard({ item, onUpdate, disabled = false }) {
  const fileCount = item.evidenceFiles?.length || 0

  function handleFiles(event) {
    event.stopPropagation()
    if (disabled) return
    const nextFiles = Array.from(event.target.files || []).map(file => file.name)
    if (!nextFiles.length) return
    onUpdate({
      evidenceUploaded: true,
      evidenceFiles: [...(item.evidenceFiles || []), ...nextFiles],
    })
    event.target.value = ''
  }

  return <div className="audit-evidence-actions" onClick={event => event.stopPropagation()}>
    <label className={`audit-evidence-card ${fileCount ? 'uploaded' : ''}`}>
      <input type="file" multiple accept="image/*,.pdf,.doc,.docx,.xls,.xlsx" disabled={disabled} onChange={handleFiles} />
      <Upload size={16} />
      <span>{fileCount ? `${fileCount} file${fileCount > 1 ? 's' : ''}` : 'Upload'}</span>
    </label>
  </div>
}

export default function ConductAudit() {
  const { id } = useParams()
  const [searchParams, setSearchParams] = useSearchParams()
  const [activeDqCode, setActiveDqCode] = useState(searchParams.get('dq') || '')
  const [activeId, setActiveId] = useState('')
  const [items, setItems] = useState([])
  const [error, setError] = useState('')
  const [submitted, setSubmitted] = useState(false)
  const [deleted, setDeleted] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [deleteMessage, setDeleteMessage] = useState('')
  const [picOptions, setPicOptions] = useState([])
  const [pendingDialog, setPendingDialog] = useState(null)
  const [draftSaving, setDraftSaving] = useState(false)
  const [draftMessage, setDraftMessage] = useState('')
  const [routeAudit, setRouteAudit] = useState(null)
  const [routeAuditError, setRouteAuditError] = useState('')
  const navigate = useNavigate()
  const { user } = useAuth()
  const [resolvedRespondedById, setResolvedRespondedById] = useState('')
  const { audits, submitAudit, deleteAudit } = useAudits()
  const { capas, upsertAutoCapa, cancelAutoCapa, deleteCapasByAudit } = useCapas()
  const { checklist, loading: checklistLoading, error: checklistError } = useAuditChecklist()
  const draftHydratedRef = useRef(false)
  const lastDraftSignatureRef = useRef('')
  const lastDraftErrorRef = useRef('')
  const draftSaveTimerRef = useRef(null)
  const initializedChecklistKeyRef = useRef('')
  const hydratedDraftKeyRef = useRef('')
  const validationBlockedRef = useRef(false)
  const latestItemsRef = useRef([])
  const canSeeAllWorkflowData = canManageDishaWorkflow(user)
  const visibleAudits = canSeeAllWorkflowData ? audits : filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  const currentAudit = useMemo(
    () => routeAudit || visibleAudits.find(item => item.id === id) || visibleAudits.find(item => isInProgressAuditStatus(item.status)) || visibleAudits[0],
    [routeAudit, visibleAudits, id],
  )
  const auditId = currentAudit?.id || id || ''
  const canEditAudit = canAccessAuditModule(user) || isSystemAdmin(user)
  const isReadOnly = !canEditAudit
  const canDeleteCurrentAudit = useMemo(() => canEditAudit && canDeleteAudit(user, currentAudit), [canEditAudit, user, currentAudit])
  const currentAuditDepartments = useMemo(
    () => splitDelimitedValues(currentAudit?.departments || currentAudit?.department),
    [currentAudit?.departments, currentAudit?.department],
  )
  const currentAuditLocation = currentAudit?.location || ''
  const selectedAuditLocation = useMemo(() => normalizeText(currentAudit?.location), [currentAudit?.location])
  const viewMode = searchParams.get('view') || 'audit'
  const isReviewMode = viewMode === 'review'
  const selectedDqFromUrl = searchParams.get('dq') || ''

  useEffect(() => {
    latestItemsRef.current = items
  }, [items])

  function safeSetItems(reason, updater) {
    setItems(current => {
      const next = typeof updater === 'function' ? updater(current) : updater
      const previousAnsweredCount = countAnsweredItems(current)
      const nextAnsweredCount = countAnsweredItems(next)
      const blockedReasons = new Set(['checklist-init', 'draft-hydrate-db', 'draft-hydrate-local-fallback'])
      if (validationBlockedRef.current && blockedReasons.has(reason)) {
        console.info('[ConductAudit] safeSetItems skipped because validationBlockedRef is active', {
          reason,
          previousAnsweredCount,
          nextAnsweredCount,
          activeDqCode,
        })
        return current
      }
      latestItemsRef.current = next
      console.info('[ConductAudit] safeSetItems', {
        reason,
        previousAnsweredCount,
        nextAnsweredCount,
        activeDqCode,
      })
      return next
    })
  }

  useEffect(() => {
    let cancelled = false

    async function loadRouteAudit() {
      const routeAuditId = String(id || '').trim()
      setRouteAudit(null)
      setRouteAuditError('')
      console.info('[ConductAudit] route audit UUID', routeAuditId)
      if (!routeAuditId) return

      try {
        const client = requireSupabase()
        let auditResult = await client
          .from('audits')
          .select('id, audit_no, audit_number, title, location_id, department_id, audit_function_id, auditor_id, scheduled_date, started_at, submitted_at, completed_at, status, score, created_by, created_at, updated_at')
          .eq('id', routeAuditId)
          .maybeSingle()

        if (auditResult.error && /column .* does not exist/i.test(auditResult.error.message || '')) {
          auditResult = await client
            .from('audits')
            .select('id, audit_no, audit_number, title, location_id, department_id, auditor_id, scheduled_date, started_at, submitted_at, completed_at, status, score, created_by, created_at, updated_at')
            .eq('id', routeAuditId)
            .maybeSingle()
        }

        const { data: auditRow, error: auditError } = auditResult

        if (auditError) throw auditError

        console.info('[ConductAudit] fetched audit row', {
          id: auditRow?.id || '',
          audit_no: auditRow?.audit_no || auditRow?.audit_number || '',
          department_id: auditRow?.department_id || '',
          location_id: auditRow?.location_id || '',
          audit_type: auditRow?.title || '',
          status: auditRow?.status || '',
        })
        console.info('[ConductAudit] department_id used', auditRow?.department_id || '')

        if (!auditRow) {
          if (!cancelled) setRouteAuditError(`Audit not found for UUID ${routeAuditId}.`)
          return
        }

        const [departmentResult, auditFunctionResult, locationResult, auditorResult] = await Promise.all([
          auditRow.department_id
            ? client.from('departments').select('id, name').eq('id', auditRow.department_id).maybeSingle()
            : Promise.resolve({ data: null, error: null }),
          auditRow.audit_function_id
            ? client.from('departments').select('id, name').eq('id', auditRow.audit_function_id).maybeSingle()
            : Promise.resolve({ data: null, error: null }),
          auditRow.location_id
            ? client.from('locations').select('id, code, name').eq('id', auditRow.location_id).maybeSingle()
            : Promise.resolve({ data: null, error: null }),
          auditRow.auditor_id
            ? client.from('app_users').select('id, employee_name').eq('id', auditRow.auditor_id).maybeSingle()
            : Promise.resolve({ data: null, error: null }),
        ])

        if (departmentResult.error) console.warn('[ConductAudit] department lookup failed', departmentResult.error)
        if (auditFunctionResult.error) console.warn('[ConductAudit] audit function lookup failed', auditFunctionResult.error)
        if (locationResult.error) console.warn('[ConductAudit] location lookup failed', locationResult.error)
        if (auditorResult.error) console.warn('[ConductAudit] auditor lookup failed', auditorResult.error)

        if (!cancelled) {
          setRouteAudit(mapRouteAuditRow(auditRow, {
            department: departmentResult.data,
            auditFunction: auditFunctionResult.data,
            location: locationResult.data,
            auditor: auditorResult.data,
          }))
        }
      } catch (loadError) {
        console.error('[ConductAudit] unable to fetch route audit by UUID', loadError)
        if (!cancelled) setRouteAuditError(loadError?.message || 'Unable to load audit details.')
      }
    }

    loadRouteAudit()
    return () => { cancelled = true }
  }, [id])

  const visibleChecklist = useMemo(() => {
    console.info('[ConductAudit] checklist table', 'audit_checklist_master')
    console.info('[ConductAudit] checklist rows loaded', {
      routeAuditId: id || '',
      departmentId: currentAudit?.departmentId || '',
      totalActiveRows: checklist.length,
      loadedRows: checklist.length,
    })
    return checklist
  }, [checklist, currentAudit?.departmentId, id])
  const checklistStateKey = useMemo(
    () => `${auditId || id || ''}::${visibleChecklist.map(item => item.dbId).join('|')}`,
    [auditId, id, visibleChecklist],
  )

  useEffect(() => {
    if (validationBlockedRef.current) {
      console.info('[ConductAudit] checklist init skipped because validationBlockedRef is active', {
        auditId: auditId || '',
        checklistStateKey,
        activeDqCode,
      })
      return
    }
    const nextItems = visibleChecklist.map(item => ({
      ...item,
      currentCondition: item.currentCondition || '',
      gapIdentified: item.gapIdentified || '',
      evidenceUploaded: Boolean(item.evidenceUploaded),
      evidenceFiles: item.evidenceFiles || [],
      picForNg: item.picForNg || '',
      picForNgUserId: item.picForNgUserId || '',
      picForNgName: item.picForNgName || '',
      picForNgMobile: item.picForNgMobile || '',
      auditLocation: currentAudit?.location || '',
      auditDepartment: splitDelimitedValues(currentAudit?.departments || currentAudit?.department).join(', '),
      tentative_closing_date: getTentativeClosingDate(item),
      remarks: item.remarks || '',
    }))
    const existingItems = latestItemsRef.current
    const preserveCurrentAnswers = initializedChecklistKeyRef.current === checklistStateKey && existingItems.length > 0
    const mergedItems = preserveCurrentAnswers ? mergeChecklistState(nextItems, existingItems) : nextItems

    if (!preserveCurrentAnswers) {
      draftHydratedRef.current = false
      lastDraftSignatureRef.current = ''
    }

    initializedChecklistKeyRef.current = checklistStateKey
    const selectedDqItems = selectedDqFromUrl
      ? mergedItems.filter(item => getItemDqCode(item) === selectedDqFromUrl)
      : []
    const fallbackDqCode = selectedDqItems[0]?.id || mergedItems[0]?.id || ''
    safeSetItems('checklist-init', mergedItems)
    setActiveId(current => preserveCurrentAnswers && mergedItems.some(item => item.dbId === current) ? current : selectedDqItems[0]?.dbId || mergedItems[0]?.dbId || '')
    setActiveDqCode(current => preserveCurrentAnswers && mergedItems.some(item => item.id === current) ? current : fallbackDqCode)
  }, [visibleChecklist, checklistStateKey, currentAudit?.location, currentAudit?.departments, currentAudit?.department, selectedDqFromUrl])

  useEffect(() => {
    let cancelled = false

    async function loadPicOptions() {
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

        const nextOptions = (usersResult.data || [])
          .filter(userRow => String(userRow.active ?? '').toLowerCase() !== 'false')
          .map(userRow => {
            const mappings = mappingsByUser.get(userRow.id) || []
            const primaryMapping = mappings[0] || {}
            const departments = [...new Set(mappings.map(item => item.department).filter(Boolean))]
            const locations = [...new Set(mappings.map(item => item.location).filter(Boolean))]
            return {
              id: userRow.id,
              value: userRow.id,
              label: buildPicLabel({
                employee_name: userRow.employee_name,
                role: primaryMapping.role || userRow.user_type || 'PIC',
                department: departments.join(', '),
                location: locations.join(', '),
              }),
              employee_name: userRow.employee_name || '',
              mobile_no: userRow.mobile_no || '',
              role: primaryMapping.role || '',
              department: departments.join(', '),
              location: locations.join(', '),
              active: true,
            }
          })
          .filter(Boolean)

        if (!cancelled) setPicOptions(nextOptions)
      } catch (loadError) {
        if (!cancelled) setPicOptions([])
        console.error('Unable to load PIC options', loadError)
      }
    }

    loadPicOptions()
    return () => { cancelled = true }
  }, [])

  useEffect(() => {
    let cancelled = false

    async function resolveRespondedById() {
      const directId = String(user?.id || '').trim()
      if (directId) {
        setResolvedRespondedById(directId)
        return
      }

      const mobileNo = normalizeWhatsAppMobile(user?.mobile_no || user?.mobile || '')
      if (!mobileNo) {
        setResolvedRespondedById('')
        return
      }

      try {
        const client = requireSupabase()
        const { data, error } = await client
          .from('app_users')
          .select('id')
          .eq('mobile_no', mobileNo.slice(-10))
          .maybeSingle()
        if (error) throw error
        if (!cancelled) setResolvedRespondedById(data?.id || '')
      } catch (resolveError) {
        if (!cancelled) setResolvedRespondedById('')
        console.error('Unable to resolve backend user id for audit draft', resolveError)
      }
    }

    resolveRespondedById()
    return () => { cancelled = true }
  }, [user?.id, user?.mobile_no, user?.mobile])

  const responseAuditId = currentAudit?.auditNumber || currentAudit?.audit_no || currentAudit?.audit_number || currentAudit?.auditId || auditId
  const draftHydrationKey = `${checklistStateKey}::${responseAuditId || ''}`

  useEffect(() => {
    let cancelled = false

    async function loadDraftResponses() {
      if (!auditId || !items.length || !currentAudit || !responseAuditId) return
      console.info('[ConductAudit][draft restore start]', {
        routeAuditId: id || '',
        auditId,
        responseAuditId,
        currentAudit: currentAudit ? {
          id: currentAudit.id,
          auditId: currentAudit.auditId,
          auditNumber: currentAudit.auditNumber,
          audit_no: currentAudit.audit_no,
          audit_number: currentAudit.audit_number,
          status: currentAudit.status,
        } : null,
        firstChecklistItems: summarizeChecklistItems(items),
        mergeKey: 'response.checklist_id -> item.dbId',
        hydratedDraftKey: hydratedDraftKeyRef.current,
        draftHydrationKey,
      })
      if (validationBlockedRef.current) {
        console.info('[ConductAudit] draft hydration skipped because validationBlockedRef is active', {
          auditId,
          checklistStateKey,
          activeDqCode,
        })
        return
      }
      if (hydratedDraftKeyRef.current === draftHydrationKey) {
        draftHydratedRef.current = true
        return
      }
      try {
        const client = requireSupabase()
        console.info('[ConductAudit][draft restore query]', {
          operation: 'rpc',
          function: 'get_audit_responses',
          filters: {
            p_audit_id: responseAuditId,
          },
        })
        const draftResult = await client
          .rpc('get_audit_responses', { p_audit_id: responseAuditId })

        if (draftResult.error) throw draftResult.error

        const backupKey = auditDraftStorageKey(auditId)
        const backupRows = (() => {
          try {
            const stored = JSON.parse(localStorage.getItem(backupKey))
            return Array.isArray(stored?.rows) ? stored.rows : []
          } catch {
            return []
          }
        })()

        const rows = (draftResult.data && draftResult.data.length) ? draftResult.data : backupRows
        const matchedItemsCount = countMatchedDraftRows(items, rows)
        console.info('[ConductAudit][draft restore result]', {
          responseAuditId,
          rowsReturnedCount: draftResult.data?.length || 0,
          backupRowsCount: backupRows.length,
          usedSource: draftResult.data && draftResult.data.length ? 'supabase' : 'localStorage',
          firstRows: summarizeDraftRows(rows),
          firstChecklistItems: summarizeChecklistItems(items),
          mergeKey: 'response.checklist_id -> item.dbId',
          matchedItemsCount,
        })
        if (cancelled) return

        safeSetItems('draft-hydrate-db', current => {
          const merged = mergeDraftRows(current, rows)
          lastDraftSignatureRef.current = JSON.stringify(buildDraftPayload(
            merged,
            auditId,
            responseAuditId,
            user?.id || currentAudit?.auditor_id || '',
          ))
          return merged
        })
        hydratedDraftKeyRef.current = draftHydrationKey
        draftHydratedRef.current = true
      } catch (loadError) {
        if (cancelled) return
        const backupKey = auditDraftStorageKey(auditId)
        try {
          const stored = JSON.parse(localStorage.getItem(backupKey))
          const rows = Array.isArray(stored?.rows) ? stored.rows : []
          if (rows.length) {
            const matchedItemsCount = countMatchedDraftRows(items, rows)
            console.info('[ConductAudit][draft restore fallback]', {
              responseAuditId,
              rowsReturnedCount: rows.length,
              firstRows: summarizeDraftRows(rows),
              firstChecklistItems: summarizeChecklistItems(items),
              mergeKey: 'response.checklist_id -> item.dbId',
              matchedItemsCount,
            })
            safeSetItems('draft-hydrate-local-fallback', current => {
              const merged = mergeDraftRows(current, rows)
              lastDraftSignatureRef.current = JSON.stringify(buildDraftPayload(
                merged,
                auditId,
                responseAuditId,
                user?.id || currentAudit?.auditor_id || '',
              ))
              return merged
            })
            hydratedDraftKeyRef.current = draftHydrationKey
            draftHydratedRef.current = true
            return
          }
        } catch {
          // fall through
        }
        hydratedDraftKeyRef.current = draftHydrationKey
        draftHydratedRef.current = true
      }
    }

    loadDraftResponses()
    return () => { cancelled = true }
  }, [auditId, checklistStateKey, draftHydrationKey, currentAudit, responseAuditId, items.length, user?.id, visibleChecklist, id])

  useEffect(() => {
    if (isReadOnly) return
    if (!items.length || !auditId) return
    items.forEach(item => {
      if (item.result === 'NG') {
        upsertAutoCapa({ auditId, auditLocation: currentAuditLocation, auditDepartments: currentAuditDepartments, question: item, remarks: item.remarks, currentCondition: item.currentCondition, gapIdentified: '', evidenceUploaded: item.evidenceUploaded })
      } else {
        cancelAutoCapa(auditId, item.id)
      }
    })
  }, [isReadOnly, items, auditId, currentAudit?.location, currentAudit?.departments, currentAudit?.department, upsertAutoCapa, cancelAutoCapa])

  const dqGroups = useMemo(() => groupChecklistByDq(items), [items])
  const activeGroup = dqGroups.find(group => group.code === selectedDqFromUrl) || dqGroups.find(group => group.code === activeDqCode) || dqGroups[0] || null
  const currentDqCode = activeGroup?.code || activeDqCode || selectedDqFromUrl || ''
  const dqItemsFromState = useMemo(
    () => sortDqItems(items.filter(item => getItemDqCode(item) === currentDqCode)),
    [items, currentDqCode],
  )
  const dqItems = dqItemsFromState.length ? dqItemsFromState : (activeGroup?.items || [])
  const dqHeaderItem = dqItems[0] || null
  const activeItem = dqItems.find(item => item.dbId === activeId) || dqHeaderItem || items[0] || null

  const metrics = useMemo(() => {
    const evaluated = items.filter(item => item.result && item.result !== 'NA')
    const ok = items.filter(item => item.result === 'OK').length
    const ng = items.filter(item => item.result === 'NG').length
    const overall = weightedScore(items)
    const process = weightedScore(items.filter(item => item.scoreGroup === 'Process'))
    const result = weightedScore(items.filter(item => item.scoreGroup === 'Result'))
    const guest = weightedScore(items.filter(item => item.guestImpact === 'High'))
    const critical = weightedScore(items.filter(item => item.priority === 'Critical'))
    return { evaluated: evaluated.length, ok, ng, pending: items.filter(item => !item.result).length, overall, process, result, guest, critical, departments: groupedScores(items, 'area'), locations: groupedScores(items, 'locationAspect') }
  }, [items])

  const completion = useMemo(() => {
    const pending = items.filter(item => !item.result).length
    const ngMissingCondition = items.filter(item => item.result === 'NG' && !item.currentCondition.trim()).length
    const capaPending = items.filter(item => item.result === 'NG' && !capas.some(capa => capa.auditId === auditId && capa.dishaQuestionNo === item.id && capa.autoGenerated && capa.status !== 'Cancelled')).length
    const completed = items.length - pending
    return {
      total: items.length,
      completed,
      pending,
      ngMissingCondition,
      capaPending,
      ready: pending === 0 && ngMissingCondition === 0,
    }
  }, [items, capas, auditId])

  const progress = completion.total ? Math.round(completion.completed / completion.total * 100) : 0
  const draftRespondedById = resolvedRespondedById || user?.id || currentAudit?.auditor_id || ''
  const draftStorageKey = useMemo(() => auditDraftStorageKey(auditId), [auditId])
  const draftPayload = useMemo(() => buildDraftPayload(items, auditId, responseAuditId, draftRespondedById), [items, auditId, responseAuditId, draftRespondedById])
  const draftSignature = useMemo(() => JSON.stringify(draftPayload), [draftPayload])
  const currentDqLabel = activeGroup?.code || 'DQ'
  const currentDqTotalLabel = `DQ${String(dqGroups.length || 0).padStart(3, '0')}`
  const currentDqCompletedCount = dqItems.filter(item => item.result).length
  const pendingQuestions = completion.pending
  const totalQuestions = completion.total
  const cumulativeComplianceScore = metrics.overall.percent
  const overallProgress = progress

  async function persistDraftResponses(showToast = false) {
    const latestItems = latestItemsRef.current.length ? latestItemsRef.current : items
    const latestDraftPayload = buildDraftPayload(latestItems, auditId, responseAuditId, draftRespondedById)
    const latestDraftSignature = JSON.stringify(latestDraftPayload)
    if (isReadOnly) {
      setError('Read-only users cannot save audit drafts.')
      return false
    }
    if (!auditId) {
      setError('No audit selected.')
      return false
    }
    if (!draftHydratedRef.current) {
      setError('Audit draft is still loading. Please try again in a moment.')
      return false
    }
    if (!latestDraftPayload.length) {
      setError('Nothing to save yet.')
      return false
    }
    if (!draftRespondedById) {
      setError('Logged-in user not found in backend. Please re-login.')
      lastDraftErrorRef.current = 'Logged-in user not found in backend. Please re-login.'
      return false
    }
    if (draftSaveTimerRef.current) {
      window.clearTimeout(draftSaveTimerRef.current)
      draftSaveTimerRef.current = null
    }
    setDraftSaving(true)
    try {
      const client = requireSupabase()
      console.log('Save Draft payload', latestDraftPayload)
      logAuditSaveContext({
        operation: 'rpc',
        table: 'audit_responses',
        user,
        auditId,
        auditLocation: currentAuditLocation,
        auditDepartments: currentAuditDepartments || [],
        payload: latestDraftPayload,
      })
      const { data: savedRows, error: saveError } = await client
        .rpc('upsert_audit_responses', { p_rows: latestDraftPayload })
      if (saveError) throw saveError
      ;(savedRows || [])
        .filter(row => row.assigned_pic_user_id || row.pic_for_ng_user_id || row.pic_for_ng_mobile)
        .forEach(row => {
          console.info('ASSIGNMENT SAVED', {
            response_id: row.id,
            assigned_pic_user_id: row.assigned_pic_user_id || '',
            pic_for_ng_user_id: row.pic_for_ng_user_id || '',
            pic_for_ng_mobile: row.pic_for_ng_mobile || '',
            action_status: row.action_status || '',
          })
        })
      lastDraftSignatureRef.current = latestDraftSignature
      if (draftStorageKey) localStorage.removeItem(draftStorageKey)
      if (showToast) {
        setDraftMessage('Draft saved')
        window.setTimeout(() => setDraftMessage(''), 1600)
      }
      if (showToast && validationBlockedRef.current) {
        validationBlockedRef.current = false
        console.info('[ConductAudit] validationBlockedRef cleared by manual save success', {
          auditId,
          activeDqCode,
        })
      }
      lastDraftErrorRef.current = ''
      return true
    } catch (saveError) {
      console.log('Save Draft error', saveError)
      logAuditSaveContext({
        operation: 'rpc',
        table: 'audit_responses',
        user,
        auditId,
        auditLocation: currentAuditLocation,
        auditDepartments: currentAuditDepartments || [],
        payload: latestDraftPayload,
        error: saveError,
      })
      if (draftStorageKey) localStorage.setItem(draftStorageKey, JSON.stringify({ rows: latestDraftPayload, updatedAt: new Date().toISOString() }))
      lastDraftErrorRef.current = describeSupabaseError(saveError)
      setError(lastDraftErrorRef.current)
      return false
    } finally {
      setDraftSaving(false)
    }
  }

  useEffect(() => {
    if (isReadOnly) return
    if (!draftHydratedRef.current || !auditId || !draftPayload.length || !draftRespondedById) return
    if (draftStorageKey) localStorage.setItem(draftStorageKey, JSON.stringify({ rows: draftPayload, updatedAt: new Date().toISOString() }))
    if (draftSignature === lastDraftSignatureRef.current) return
    if (draftSaveTimerRef.current) window.clearTimeout(draftSaveTimerRef.current)
    draftSaveTimerRef.current = window.setTimeout(() => {
      persistDraftResponses(false)
    }, 900)
    return () => {
      if (draftSaveTimerRef.current) window.clearTimeout(draftSaveTimerRef.current)
    }
  }, [isReadOnly, draftSignature, auditId, draftStorageKey, draftRespondedById])

  useEffect(() => () => {
    if (draftSaveTimerRef.current) window.clearTimeout(draftSaveTimerRef.current)
  }, [])

  useEffect(() => {
    if (!dqGroups.length) return
    if (activeDqCode) return
    const validDq = dqGroups.some(group => group.code === selectedDqFromUrl)
    const nextDq = validDq ? selectedDqFromUrl : dqGroups[0].code
    if (nextDq) {
      setActiveDqCode(nextDq)
      if (selectedDqFromUrl !== nextDq) setSearchParams(nextDq ? { dq: nextDq } : {}, { replace: true })
    }
  }, [dqGroups, selectedDqFromUrl, activeDqCode, setSearchParams])

  useEffect(() => {
    if (!activeGroup) return
    const nextActive = dqItems.find(item => item.dbId === activeId) || dqItems[0]
    if (nextActive && nextActive.dbId !== activeId) setActiveId(nextActive.dbId)
  }, [activeGroup, activeId, dqItems])

  function updateItem(dbId, updates) {
    if (isReadOnly) return
    safeSetItems(`update-item:${dbId}`, current => current.map(item => (item.dbId === dbId ? { ...item, ...updates } : item)))
    setError('')
  }

  function selectResult(dbId, result) {
    if (isReadOnly) return
    const current = items.find(item => item.dbId === dbId)
    if (!current) return
    if (validationBlockedRef.current) {
      validationBlockedRef.current = false
      console.info('[ConductAudit] validationBlockedRef cleared by answer click', {
        dbId,
        dqCode: current.id || current.dqQuestionNum || activeDqCode,
        nextResult: result,
      })
    }
    updateItem(dbId, {
      result,
      remarks: result === 'NA' ? '' : current.remarks || '',
      status: result === 'NG'
        ? (String(current.picForNgUserId || current.picForNgMobile || current.picForNg || '').trim() ? 'Assigned' : 'Open')
        : '',
    })
  }

  function openDqGroup(code) {
    setActiveDqCode(code)
    setSearchParams(code ? { dq: code, view: 'audit' } : { view: 'audit' }, { replace: true })
    const firstItem = dqGroups.find(group => group.code === code)?.items?.[0]
    if (firstItem) setActiveId(firstItem.dbId)
  }

  async function handleNextDq() {
    if (isReadOnly) {
      setError('Read-only users cannot move audit workflow to the next DQ.')
      return false
    }
    console.log('Next DQ clicked')
    if (currentDqIndex < 0) {
      setError('Unable to determine current DQ.')
      return false
    }

    if (currentDqIndex >= dqGroups.length - 1) {
      setError('This is the last DQ.')
      openReview()
      return true
    }

    const currentDqItems = sortDqItems(items.filter(item => getItemDqCode(item) === currentDqCode))
    if (!currentDqItems.length) {
      validationBlockedRef.current = true
      setError(`Unable to validate ${currentDqCode || 'current DQ'} because no checklist rows were found.`)
      setPendingDialog({
        nextCode: dqGroups[currentDqIndex + 1].code,
        pendingItems: [],
      })
      return false
    }

    const nextCode = dqGroups[currentDqIndex + 1].code
    const pendingItems = currentDqItems
      .map((item, index) => ({ item, index, reasons: getPendingReasons(item) }))
      .filter(entry => entry.reasons.length)
    const pendingList = pendingItems.map(entry => ({
      item: entry.item,
      reasons: entry.reasons,
      subQuestionNum: getQuestionLabel(entry.item, entry.index),
      subQuestionText: cleanQuestion(entry.item.evaluationQuestion || entry.item.question),
    }))

    if (pendingItems.length) {
      validationBlockedRef.current = true
      console.info('[ConductAudit] validation failed, blocking checklist rebuild and draft hydration', {
        activeDqCode: currentDqCode,
        nextCode,
        totalCurrentDqItems: currentDqItems.length,
        pendingCount: pendingItems.length,
        pendingItems: pendingList.map(entry => ({
          dbId: entry.item.dbId,
          dqCode: getItemDqCode(entry.item),
          result: entry.item.result || '',
          reasons: entry.reasons,
        })),
      })
      console.log('Validation pending', pendingList)
      const pendingMessage = formatPendingListMessage(pendingList, currentDqCode || currentDqItems[0]?.dqQuestionNum || '')
      setError(pendingMessage)
      setPendingDialog({
        nextCode,
        pendingItems: pendingList,
      })
      return false
    }

    console.log('Next DQ target', nextCode)
    const saveResult = await persistDraftResponses(false)
    if (!saveResult) {
      setError(lastDraftErrorRef.current || 'Unable to save draft before moving to next DQ.')
      return false
    }
    openDqGroup(nextCode)
    return true
  }

  function openReview() {
    if (isReadOnly) return
    const next = new URLSearchParams(searchParams)
    next.set('view', 'review')
    setSearchParams(next, { replace: true })
  }

  function backToAudit(code) {
    const next = new URLSearchParams(searchParams)
    next.set('view', 'audit')
    if (code) next.set('dq', code)
    else next.delete('dq')
    setSearchParams(next, { replace: true })
    if (code) setActiveDqCode(code)
  }

  async function handleSubmit() {
    if (isReadOnly) {
      setError('Read-only users cannot submit audits.')
      return
    }
    const issues = []
    if (!completion.ready) {
      if (completion.pending) issues.push(`${completion.pending} unanswered questions`)
      if (completion.ngMissingCondition) issues.push(`${completion.ngMissingCondition} NG findings without current condition`)
      setError(`Audit cannot be submitted: ${issues.join(', ')}.`)
      return
    }
    const saved = await persistDraftResponses(false)
    if (!saved) {
      setError(`Audit cannot be submitted because draft save failed: ${lastDraftErrorRef.current || 'Unable to save draft right now.'}`)
      return
    }
    setError('')
    submitAudit(auditId, { score: metrics.overall.percent, submittedBy: currentAudit?.owner })
    setSubmitted(true)
    window.setTimeout(() => navigate('/dashboard', { replace: true }), 1400)
  }

  function openDeleteDialog() {
    if (isReadOnly) return
    if (!canDeleteCurrentAudit || deleting) return
    setDeleteMessage('')
    setDeleteDialogOpen(true)
  }

  function closeDeleteDialog() {
    if (deleting) return
    setDeleteDialogOpen(false)
    setDeleteMessage('')
  }

  async function confirmDeleteAudit() {
    if (isReadOnly) return
    if (!auditId || deleting) return
    setDeleting(true)
    setDeleteMessage('')
    try {
      const client = requireSupabase()
      let responseDelete = await client.from('audit_responses').delete().eq('audit_id', responseAuditId)
      if (responseDelete.error) throw responseDelete.error
      const { error: capaError } = await deleteCapasByAudit(auditId)
      if (capaError) throw capaError
      const { error: auditError } = await deleteAudit(auditId)
      if (auditError) throw auditError
      setDeleted(true)
      setDeleteMessage('Audit deleted successfully. Returning to Audit list...')
      window.setTimeout(() => navigate('/audits/new', { replace: true }), 1200)
    } catch (deleteError) {
      setDeleteMessage(deleteError?.message || 'Unable to delete audit.')
    } finally {
      setDeleting(false)
      setDeleteDialogOpen(false)
    }
  }

  const guidance = [
    ['purpose', 'Purpose', activeItem?.purpose],
    ['standard', 'Standard', activeItem?.checkingMethod],
    ['additional', 'Additional Information', activeItem?.additionalInfo],
    ['sop', 'SOP / Material Reference', activeItem?.sopReference],
  ]

  const selectedIndex = activeItem ? items.findIndex(item => item.dbId === activeItem.dbId) : -1
  const selectedLabel = activeItem ? getQuestionLabel(activeItem, selectedIndex >= 0 ? selectedIndex : 0) : '-'
  const currentDqIndex = activeGroup ? dqGroups.findIndex(group => group.code === activeGroup.code) : -1
  const auditDisplayDepartments = useMemo(() => splitDelimitedValues(currentAudit?.departments || currentAudit?.department), [currentAudit?.departments, currentAudit?.department])
  const auditDisplayLocation = currentAudit?.location || '-'
  const relevantPicOptions = useMemo(() => {
    if (!activeItem) return picOptions
    const matches = picOptions.filter(option => {
      const optionLocations = String(option.location || '').split(',').map(part => normalizeText(part)).filter(Boolean)
      const locationMatch = !selectedAuditLocation || optionLocations.some(loc => loc && (loc === 'all' || loc === selectedAuditLocation || selectedAuditLocation.includes(loc) || loc.includes(selectedAuditLocation)))
      const roleMatch = normalizeText(option.role).includes('pic') || normalizeText(option.role).includes('hod')
      return locationMatch && roleMatch
    })
    return matches.length ? matches : picOptions
  }, [picOptions, activeItem, selectedAuditLocation])

  const getSelectedPicOption = item => relevantPicOptions.find(option => option.id === item.picForNgUserId || option.value === item.picForNgUserId || option.id === item.picForNg || option.value === item.picForNg || option.mobile_no === item.picForNgMobile || option.employee_name === item.picForNgName || option.employee_name === item.picForNg) || null
  const getWhatsAppDetails = item => {
    if (item.result !== 'NG' || !(item.picForNgUserId || item.picForNgMobile || item.picForNg)) return null
    const selectedPic = getSelectedPicOption(item)
    if (!selectedPic?.mobile_no) return { missingMobile: true, selectedPic }
    const message = buildWhatsAppMessage({
      picName: selectedPic.employee_name || selectedPic.label || selectedPic.value || 'PIC',
      auditLocation: auditDisplayLocation,
      department: auditDisplayDepartments.join(', '),
      dqQuestionNum: item.id || '',
      subQuestion: cleanQuestion(item.evaluationQuestion || item.question),
      currentCondition: String(item.currentCondition || '').trim(),
      tentativeClosingDate: getTentativeClosingDate(item),
      auditorName: user?.employee_name || user?.name || user?.full_name || 'Auditor',
    })
    const href = buildWhatsAppUrl(selectedPic.mobile_no, message)
    return href ? { href, selectedPic } : { missingMobile: true, selectedPic }
  }

  if (checklistLoading) {
    return <div className="audit-execution-page audit-evaluation-page"><section className="card audit-loading-card"><strong>Loading audit...</strong></section></div>
  }

  if (!items.length) {
    return <div className="audit-execution-page audit-evaluation-page">
      <section className="card audit-empty-card">
        <strong>No checklist items found for this audit.</strong>
        {routeAuditError && <span>{routeAuditError}</span>}
        {checklistError && <span>{checklistError}</span>}
      </section>
    </div>
  }

  if (deleted) {
    return <div className="audit-execution-page audit-evaluation-page">
      <div className="audit-success-message" role="status"><CheckCircle2 /><div><strong>Audit deleted successfully</strong><span>{deleteMessage || 'Returning to Audit list...'}</span></div></div>
    </div>
  }

  return <div className="audit-execution-page audit-evaluation-page">
    {submitted && <div className="audit-success-message" role="status"><CheckCircle2 /><div><strong>Audit submitted successfully</strong><span>Status updated to Submitted. Redirecting to Dashboard...</span></div></div>}
    <header className="audit-progress-header card">
      {canDeleteCurrentAudit && <button className="icon-button audit-delete-icon-button" title="Delete audit" aria-label="Delete audit" disabled={deleting} onClick={openDeleteDialog}><Trash2 size={15} /></button>}
      <div className="audit-progress-header-main">
        <button className="back-button" onClick={() => navigate('/audits/new')}><ChevronLeft size={18} /> Exit audit</button>
        <div className="audit-progress-header-copy audit-progress-header-copy--featured">
          <small>{currentAudit?.auditNumber || currentAudit?.auditId || currentAudit?.id || 'Audit reference pending'}</small>
          <small>Audit Function: {currentAudit?.auditFunction || 'Not Assigned'}</small>
          <span>Current DQ</span>
          <strong>{currentDqLabel} / {currentDqTotalLabel}</strong>
          {isReadOnly && <small>Read-only View</small>}
          <small>{currentDqCompletedCount}/{dqItems.length} current DQ questions</small>
          <small>Sub Q Completed {completion.completed}/{totalQuestions} | Pending {pendingQuestions}</small>
        </div>
      </div>
      <div className="audit-progress-header-center">
        <div className="audit-progress-header-center-top">
          <div className="audit-progress-header-gauge-wrap">
            <Gauge value={cumulativeComplianceScore} />
          </div>
          <div className="audit-progress-header-battery">
            <div className="audit-battery-horizontal" aria-hidden="true">
              <i className="audit-battery-terminal" />
              <div className="audit-battery-track horizontal">
                <i className="audit-battery-fill horizontal" style={{ width: `${overallProgress}%` }} />
              </div>
            </div>
            <div className="audit-battery-meta">
              <span>Progress</span>
              <strong>{overallProgress}%</strong>
              <small>{completion.completed}/{totalQuestions} completed</small>
            </div>
          </div>
        </div>
      </div>
      <div className="audit-progress-header-actions">
        {!isReadOnly && <button type="button" className="secondary-button audit-header-action" disabled={draftSaving} onClick={() => persistDraftResponses(true)}><Save size={16} /> Save draft</button>}
        <button type="button" className="secondary-button audit-header-action" disabled={currentDqIndex <= 0} onClick={() => currentDqIndex > 0 && openDqGroup(dqGroups[currentDqIndex - 1].code)}><ChevronLeft size={16} /> Previous DQ</button>
        {!isReadOnly && (currentDqIndex >= 0 && currentDqIndex < dqGroups.length - 1 ? (
          <button type="button" className="primary-button audit-header-action audit-header-next" onClick={event => { event.preventDefault(); void handleNextDq() }}>Next DQ</button>
        ) : (
          <button type="button" className="primary-button audit-header-action audit-header-next" onClick={openReview}>Review Audit</button>
        ))}
      </div>
    </header>

    {draftMessage && <div className="audit-success-message" role="status"><CheckCircle2 /><div><strong>{draftMessage}</strong><span>Continue from the saved draft anytime.</span></div></div>}

    <section className="audit-focus-panel card">
      <div className="audit-focus-head">
        <div>
          <span>DQ Page</span>
          <h2>{activeGroup?.code || 'DQ'} {activeGroup ? `- ${activeGroup.title}` : ''}</h2>
        </div>
        <small>Audit Function: {currentAudit?.auditFunction || 'Not Assigned'} | {currentDqIndex >= 0 ? `Page ${currentDqIndex + 1} of ${dqGroups.length}` : `Page 1 of ${dqGroups.length || 1}`}</small>
      </div>

      <div className="audit-question-grid">
        <div><span>DQ Question Num</span><strong>{activeItem?.id || '-'}</strong></div>
        <div><span>Applicable dept</span><strong>{(activeItem?.applicableDepartments || []).join(', ') || '-'}</strong></div>
        <div><span>Classification</span><strong>{activeItem?.classification || '-'}</strong></div>
        <div><span>Location / Aspect</span><strong>{activeItem?.locationAspect || '-'}</strong></div>
        <div><span>Guest Experience Impact</span><strong>{activeItem?.guestImpact || '-'}</strong></div>
        <div><span>Process KPI</span><strong>{activeItem?.scoreGroup || '-'}</strong></div>
        <div><span>Result KPI</span><strong>{activeItem?.priority || '-'}</strong></div>
      </div>

      <div className="audit-detail-grid">
        <DetailAccordion title="Purpose" value={activeItem?.purpose} open />
        <DetailAccordion title="Standard" value={activeItem?.checkingMethod} />
        <DetailAccordion title="Additional Information" value={activeItem?.additionalInfo} />
        <DetailAccordion title="SOP / Material Reference" value={activeItem?.sopReference} />
      </div>
    </section>

    <section className="audit-questions-panel">
      {dqItems.map((item, index) => {
        const pending = getPendingReasons(item)
        const whatsappDetails = item.result === 'NG' && (item.picForNgUserId || item.picForNg) ? getWhatsAppDetails(item) : null
        const statusLabel = item.result || 'Pending'
        return <article data-audit-row={item.dbId} data-result={statusLabel} key={`${item.dqQuestionNum || item.id || 'DQ'}-${Number.isFinite(item.displaySubQuestionNum) ? item.displaySubQuestionNum : Number.isFinite(item.subQuestionNum) ? item.subQuestionNum : 'NA'}-${item.dbId}`} className={`audit-question-card card ${activeItem?.dbId === item.dbId ? 'active' : ''} ${pending.length ? 'pending' : ''} result-${normalizeText(statusLabel)}`} onClick={() => setActiveId(item.dbId)}>
          <div className="audit-question-card-grid">
            <div className="audit-question-card-left">
              <div className="audit-question-card-head">
                <div className="audit-question-card-head-row">
                  <span className="audit-question-number">Q{getQuestionLabel(item, index)}</span>
                  <span className={`audit-question-status ${normalizeText(statusLabel)}`}>{statusLabel}</span>
                </div>
                <strong title={getSubQuestionTooltip(item)}>{cleanQuestion(item.evaluationQuestion || item.question)}</strong>
                <small>{item.id}</small>
              </div>
              <div className="audit-question-score">
                <ScoreButtons item={item} disabled={isReadOnly} onSelect={result => selectResult(item.dbId, result)} />
              </div>
            </div>

            <div className="audit-question-card-right">
              <textarea className="audit-inline-textarea audit-condition-textarea" rows="3" value={item.currentCondition || ''} placeholder="Current Condition / Gap Observed" readOnly={isReadOnly} onClick={event => event.stopPropagation()} onChange={event => updateItem(item.dbId, { currentCondition: event.target.value, gapIdentified: '' })} />
              <div className="audit-question-ng-fields">
                <EvidenceUploadCard item={item} disabled={isReadOnly} onUpdate={updates => updateItem(item.dbId, updates)} />
                <select className="audit-inline-select" value={item.picForNgUserId || ''} disabled={isReadOnly} onClick={event => event.stopPropagation()} onChange={event => {
                  const selectedPic = relevantPicOptions.find(option => option.id === event.target.value) || null
                  const nextActionStatus = event.target.value ? 'Assigned' : (item.result === 'NG' ? 'Open' : '')
                  updateItem(item.dbId, {
                    picForNg: selectedPic?.id || event.target.value,
                    picForNgUserId: selectedPic?.id || event.target.value,
                    picForNgName: selectedPic?.label || selectedPic?.employee_name || selectedPic?.value || '',
                    picForNgMobile: selectedPic?.mobile_no || '',
                    status: nextActionStatus,
                  })
                }}>
                  <option value="">Select PIC</option>
                  {relevantPicOptions.map(option => <option key={option.id} value={option.value}>{option.label || option.value}</option>)}
                </select>
                {item.result === 'NG' && <label className="audit-date-field" onClick={event => event.stopPropagation()}>
                  <span>Tentative Closing Date</span>
                  <input className="audit-inline-date" type="date" value={getTentativeClosingDate(item)} disabled={isReadOnly} onChange={event => updateItem(item.dbId, { tentative_closing_date: event.target.value, tentativeClosingDate: event.target.value })} />
                </label>}
                {whatsappDetails && item.result === 'NG' && (item.picForNgUserId || item.picForNgMobile || item.picForNg) && (() => {
                  if (whatsappDetails.missingMobile) return <small className="audit-pic-help">PIC mobile number not available</small>
                  return <a
                    className="secondary-button audit-whatsapp-link"
                    href={whatsappDetails.href}
                    target="_blank"
                    rel="noreferrer"
                    onClick={event => event.stopPropagation()}
                  >
                    <Send size={14} />
                    Send WhatsApp
                  </a>
                })()}
              </div>
              {item.result === 'NG' && <div className="capa-detail-fields">
                <div><span>Action Status</span><strong>{item.status || 'Open'}</strong></div>
                <div><span>Root Cause</span><strong>{item.rootCause || '-'}</strong></div>
                <div><span>Corrective Action Plan</span><strong>{item.correctiveActionPlan || '-'}</strong></div>
                <div><span>Preventive Action Plan</span><strong>{item.preventiveActionPlan || '-'}</strong></div>
                <div><span>Action Taken / Closure Remarks</span><strong>{item.actionTaken || item.closureRemarks || '-'}</strong></div>
                <div><span>Actual Closure Date</span><strong>{item.actualClosureDate || '-'}</strong></div>
                <div><span>Evidence Links</span><strong>{(item.closureEvidenceFiles?.length ? item.closureEvidenceFiles : item.evidenceFiles || []).map(file => file.name || file).join(', ') || '-'}</strong></div>
              </div>}
            </div>
          </div>
        </article>
      })}
    </section>

    {isReviewMode && <ReviewSnapshot groups={dqGroups} activeGroup={activeGroup} onJumpToDq={code => backToAudit(code)} auditFunction={currentAudit?.auditFunction} />}

    <section className="audit-footer card">
      <div className="audit-footer-status">
        <div><span>AUDIT COMPLETION STATUS</span><strong className={completion.ready ? 'ready' : 'not-ready'}>{completion.ready ? 'Ready: Yes' : 'Ready: No'}</strong></div>
        <p>{completion.pending} pending, {completion.ngMissingCondition} NG missing condition.</p>
      </div>
      {error && <div className="audit-submission-error" role="alert"><AlertCircle size={20} /><span>{error}</span></div>}
      <div className="audit-footer-actions">
        {!isReadOnly && <button type="button" className="secondary-button" disabled={draftSaving} onClick={() => persistDraftResponses(true)}><Save size={18} /> Save draft</button>}
        {!isReviewMode ? (
          <>
            <button type="button" className="secondary-button" disabled={currentDqIndex <= 0} onClick={() => currentDqIndex > 0 && openDqGroup(dqGroups[currentDqIndex - 1].code)}><ChevronLeft size={18} /> Previous DQ</button>
            {!isReadOnly && (currentDqIndex >= 0 && currentDqIndex < dqGroups.length - 1 ? (
              <button type="button" className="primary-button" onClick={event => { event.preventDefault(); void handleNextDq() }}>Next DQ</button>
            ) : (
              <button type="button" className="primary-button" onClick={openReview}>Review Audit</button>
            ))}
          </>
        ) : (
          <>
            <button type="button" className="secondary-button" onClick={() => backToAudit(dqGroups[dqGroups.length - 1]?.code)}><ChevronLeft size={18} /> Back to Audit</button>
            {!isReadOnly && <button type="button" className="primary-button" disabled={!completion.ready} onClick={handleSubmit}><Send size={18} /> Submit Audit</button>}
          </>
        )}
      </div>
    </section>

    {pendingDialog && <div className="audit-dialog-backdrop" role="presentation" onClick={() => setPendingDialog(null)}>
      <div className="audit-dialog card" role="dialog" aria-modal="true" aria-label="Pending tasks" onClick={event => event.stopPropagation()}>
        <div className="audit-dialog-head">
          <div>
            <span>Pending tasks</span>
            <strong>Please complete the following before moving to next DQ:</strong>
          </div>
          <button className="icon-button" aria-label="Close dialog" onClick={() => setPendingDialog(null)}><X size={16} /></button>
        </div>
        <div className="audit-dialog-list">
          {pendingDialog.pendingItems.map(({ item, reasons, subQuestionNum, subQuestionText }) => (
            <div key={`${item.dqQuestionNum || item.id || 'DQ'}-${Number.isFinite(item.displaySubQuestionNum) ? item.displaySubQuestionNum : Number.isFinite(item.subQuestionNum) ? item.subQuestionNum : 'NA'}-${item.dbId}`} className="audit-dialog-item pending">
              <strong>{(activeGroup?.code || item.dqQuestionNum || item.id || 'DQ')} - Q{subQuestionNum} - {subQuestionText}</strong>
              <small>{reasons.join(', ')}</small>
            </div>
          ))}
        </div>
        <div className="audit-dialog-actions">
          <button type="button" className="primary-button" onClick={() => setPendingDialog(null)}>OK</button>
        </div>
      </div>
    </div>}

    {deleteDialogOpen && <div className="audit-dialog-backdrop" role="presentation" onClick={closeDeleteDialog}>
      <div className="audit-dialog card delete-dialog" role="dialog" aria-modal="true" aria-label="Delete audit confirmation" onClick={event => event.stopPropagation()}>
        <div className="delete-icon"><Trash2 size={22} /></div>
        <h2>Delete audit</h2>
        <p>Are you sure you want to delete this audit? This cannot be undone.</p>
        {deleteMessage && <div className="audit-submission-error" role="alert"><AlertCircle size={20} /><span>{deleteMessage}</span></div>}
        <div className="modal-actions">
          <button className="secondary-button" onClick={closeDeleteDialog} disabled={deleting}>Cancel</button>
          <button className="danger-button" onClick={confirmDeleteAudit} disabled={deleting}>Delete</button>
        </div>
      </div>
    </div>}

    {checklistError && <div className="audit-checklist-note"><AlertCircle size={18} /><span>{checklistError}</span></div>}
  </div>
}
