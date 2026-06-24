import { useEffect, useMemo, useRef, useState } from 'react'
import { AlertCircle, Check, CheckCircle2, ChevronLeft, Minus, Save, Send, Trash2, Upload, X } from 'lucide-react'
import { useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { isInProgressAuditStatus, useAudits } from '../audits/AuditContext'
import { useAuditChecklist } from '../audits/useAuditChecklist'
import { Progress } from '../components/UI'
import { useCapas } from '../capa/CapaContext'
import { isSystemAdmin, useAuth } from '../auth/AuthContext'
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

function isDeletableAuditStatus(status) {
  const normalized = normalizeText(status)
  return ['draft', 'in progress', 'in_progress', 'pending submission'].includes(normalized)
}

function isSubmittedAuditStatus(status) {
  return ['submitted', 'completed', 'approved', 'closed'].includes(normalizeText(status))
}

function canDeleteAudit(user, audit) {
  if (!audit || !isDeletableAuditStatus(audit.status)) return false
  return isSystemAdmin(user)
}

function getPendingReasons(item) {
  const reasons = []
  if (!item.result) reasons.push('Result not selected')
  if (item.result === 'NG' && !String(item.currentCondition || '').trim()) reasons.push('Current Condition / Gap Observed missing')
  if (item.result === 'NG' && !String(item.picForNg || '').trim()) reasons.push('PIC for NG missing')
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

function checklistDepartmentAliases(value) {
  const normalized = normalizeText(value)
  if (normalized === 'service') return ['service & parts']
  if (normalized === 'u-trust') return ['used car']
  if (normalized === 'vas') return ['value chain']
  if (normalized === 'accessories') return ['accessory']
  return [normalized]
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

function buildDraftPayload(items, auditId, respondedBy) {
  return items.map(item => ({
    audit_id: auditId,
    checklist_id: item.dbId,
    result: item.result || null,
    observation: String(item.currentCondition || '').trim() || null,
    comments: null,
    responded_by: respondedBy,
    pic_for_ng: String(item.picForNg || '').trim() || null,
    tentative_closing_date: getTentativeClosingDate(item) || null,
    evidence_files: Array.isArray(item.evidenceFiles) ? item.evidenceFiles : [],
  }))
}

function mergeDraftRows(items, rows) {
  const rowsByChecklist = new Map((rows || []).map(row => [row.checklist_id, row]))
  return items.map(item => {
    const row = rowsByChecklist.get(item.dbId)
    if (!row) return item
    const combinedCondition = combineCurrentConditionAndGap(row.observation || '', row.comments || '')
    return {
      ...item,
      result: row.result || '',
      currentCondition: combinedCondition,
      gapIdentified: row.comments || '',
      picForNg: row.pic_for_ng || '',
      tentative_closing_date: normalizeDraftDate(row.tentative_closing_date),
      evidenceFiles: Array.isArray(row.evidence_files) ? row.evidence_files : [],
      evidenceUploaded: Array.isArray(row.evidence_files) ? row.evidence_files.length > 0 : Boolean(item.evidenceUploaded),
    }
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

function ReviewSnapshot({ groups, activeGroup, onJumpToDq }) {
  return <section className="audit-review-panel card">
    <div className="audit-review-head">
      <div>
        <span>Review Audit</span>
        <h2>Snapshot of all DQ questions</h2>
      </div>
      <small>{groups.length} DQ groups</small>
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
                <span>{item.picForNg || '-'}</span>
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

function ScoreButtons({ item, onSelect }) {
  return <div className="audit-score-buttons compact">
    <button className={`score-ok ${item.result === 'OK' ? 'selected' : ''}`} onClick={event => { event.stopPropagation(); onSelect('OK') }}><Check /><span>OK</span></button>
    <button className={`score-ng ${item.result === 'NG' ? 'selected' : ''}`} onClick={event => { event.stopPropagation(); onSelect('NG') }}><X /><span>NG</span></button>
    <button className={`score-na ${item.result === 'NA' ? 'selected' : ''}`} onClick={event => { event.stopPropagation(); onSelect('NA') }}><Minus /><span>NA</span></button>
  </div>
}

function EvidenceUploadCard({ item, onUpdate }) {
  const fileCount = item.evidenceFiles?.length || 0

  function handleFiles(event) {
    event.stopPropagation()
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
      <input type="file" multiple accept="image/*,.pdf,.doc,.docx,.xls,.xlsx" onChange={handleFiles} />
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
  const navigate = useNavigate()
  const { user } = useAuth()
  const [resolvedRespondedById, setResolvedRespondedById] = useState('')
  const { audits, submitAudit, deleteAudit } = useAudits()
  const { capas, upsertAutoCapa, cancelAutoCapa, deleteCapasByAudit } = useCapas()
  const { checklist, checklistLoading, checklistError } = useAuditChecklist()
  const draftHydratedRef = useRef(false)
  const lastDraftSignatureRef = useRef('')
  const draftSaveTimerRef = useRef(null)
  const currentAudit = audits.find(item => item.id === id) || audits.find(item => isInProgressAuditStatus(item.status)) || audits[0]
  const auditId = currentAudit?.id || id || ''
  const canDeleteCurrentAudit = useMemo(() => canDeleteAudit(user, currentAudit), [user, currentAudit])
  const selectedAuditDepartments = useMemo(
    () => splitDelimitedValues(currentAudit?.departments || currentAudit?.department)
      .flatMap(part => checklistDepartmentAliases(part))
      .map(part => normalizeText(part))
      .filter(Boolean),
    [currentAudit?.departments, currentAudit?.department],
  )
  const selectedAuditLocation = useMemo(() => normalizeText(currentAudit?.location), [currentAudit?.location])
  const viewMode = searchParams.get('view') || 'audit'
  const isReviewMode = viewMode === 'review'
  const visibleChecklist = useMemo(() => {
    if (!selectedAuditDepartments.length) return checklist
    return checklist.filter(item => {
      const applicableDepartments = Array.isArray(item.applicableDepartments) ? item.applicableDepartments.map(normalizeText) : []
      if (!applicableDepartments.length) return false
      if (applicableDepartments.includes('all')) return true
      return selectedAuditDepartments.some(department => applicableDepartments.includes(department))
    })
  }, [checklist, selectedAuditDepartments])

  useEffect(() => {
    const nextItems = visibleChecklist.map(item => ({
      ...item,
      currentCondition: item.currentCondition || '',
      gapIdentified: item.gapIdentified || '',
      evidenceUploaded: Boolean(item.evidenceUploaded),
      evidenceFiles: item.evidenceFiles || [],
      picForNg: item.picForNg || '',
      tentative_closing_date: getTentativeClosingDate(item),
      remarks: item.remarks || '',
    }))
    draftHydratedRef.current = false
    lastDraftSignatureRef.current = ''
    setItems(nextItems)
    setActiveId(nextItems[0]?.dbId || '')
    setActiveDqCode(nextItems[0]?.id || '')
  }, [visibleChecklist])

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
              value: userRow.employee_name || userRow.mobile_no || userRow.id,
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

  useEffect(() => {
    let cancelled = false

    async function loadDraftResponses() {
      if (!auditId || !items.length || !currentAudit || isSubmittedAuditStatus(currentAudit.status)) return
      try {
        const client = requireSupabase()
        const { data, error: loadError } = await client
          .from('audit_responses')
          .select('id, audit_id, checklist_id, result, observation, comments, pic_for_ng, tentative_closing_date, evidence_files, updated_at')
          .eq('audit_id', auditId)

        if (loadError) throw loadError

        const backupKey = auditDraftStorageKey(auditId)
        const backupRows = (() => {
          try {
            const stored = JSON.parse(localStorage.getItem(backupKey))
            return Array.isArray(stored?.rows) ? stored.rows : []
          } catch {
            return []
          }
        })()

        const rows = (data && data.length) ? data : backupRows
        if (cancelled) return

        setItems(current => {
          const merged = mergeDraftRows(current, rows)
          lastDraftSignatureRef.current = JSON.stringify(buildDraftPayload(merged, auditId, user?.id || currentAudit?.auditor_id || ''))
          return merged
        })
        draftHydratedRef.current = true
      } catch (loadError) {
        if (cancelled) return
        const backupKey = auditDraftStorageKey(auditId)
        try {
          const stored = JSON.parse(localStorage.getItem(backupKey))
          const rows = Array.isArray(stored?.rows) ? stored.rows : []
          if (rows.length) {
            setItems(current => {
              const merged = mergeDraftRows(current, rows)
              lastDraftSignatureRef.current = JSON.stringify(buildDraftPayload(merged, auditId, user?.id || currentAudit?.auditor_id || ''))
              return merged
            })
            draftHydratedRef.current = true
            return
          }
        } catch {
          // fall through
        }
        draftHydratedRef.current = true
      }
    }

    loadDraftResponses()
    return () => { cancelled = true }
  }, [auditId, currentAudit, items.length, user?.id, visibleChecklist])

  useEffect(() => {
    if (!items.length || !auditId) return
    const currentAuditLocation = currentAudit?.location || ''
    const currentAuditDepartments = splitDelimitedValues(currentAudit?.departments || currentAudit?.department)
    items.forEach(item => {
      if (item.result === 'NG') {
        upsertAutoCapa({ auditId, auditLocation: currentAuditLocation, auditDepartments: currentAuditDepartments, question: item, remarks: item.remarks, currentCondition: item.currentCondition, gapIdentified: '', evidenceUploaded: item.evidenceUploaded })
      } else {
        cancelAutoCapa(auditId, item.id)
      }
    })
  }, [items, auditId, currentAudit?.location, currentAudit?.departments, currentAudit?.department, upsertAutoCapa, cancelAutoCapa])

  const dqGroups = useMemo(() => groupChecklistByDq(items), [items])
  const selectedDqFromUrl = searchParams.get('dq') || ''
  const activeGroup = dqGroups.find(group => group.code === activeDqCode || group.code === selectedDqFromUrl) || dqGroups[0] || null
  const groupItems = activeGroup?.items || []
  const dqItems = useMemo(() => [...groupItems].sort((a, b) => {
    const aSerial = Number.isFinite(a.displaySubQuestionNum) ? a.displaySubQuestionNum : Number.isFinite(a.subQuestionNum) ? a.subQuestionNum : Number.POSITIVE_INFINITY
    const bSerial = Number.isFinite(b.displaySubQuestionNum) ? b.displaySubQuestionNum : Number.isFinite(b.subQuestionNum) ? b.subQuestionNum : Number.POSITIVE_INFINITY
    if (aSerial !== bSerial) return aSerial - bSerial
    const aOrder = Number.isFinite(a.subQuestionOrder) ? a.subQuestionOrder : Number.POSITIVE_INFINITY
    const bOrder = Number.isFinite(b.subQuestionOrder) ? b.subQuestionOrder : Number.POSITIVE_INFINITY
    if (aOrder !== bOrder) return aOrder - bOrder
    return String(a.dbId).localeCompare(String(b.dbId))
  }), [groupItems])
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
      ready: pending === 0 && ngMissingCondition === 0 && capaPending === 0,
    }
  }, [items, capas, auditId])

  const progress = completion.total ? Math.round(completion.completed / completion.total * 100) : 0
  const draftRespondedById = resolvedRespondedById || user?.id || currentAudit?.auditor_id || ''
  const draftStorageKey = useMemo(() => auditDraftStorageKey(auditId), [auditId])
  const draftPayload = useMemo(() => buildDraftPayload(items, auditId, draftRespondedById), [items, auditId, draftRespondedById])
  const draftSignature = useMemo(() => JSON.stringify(draftPayload), [draftPayload])
  const currentDqLabel = activeGroup?.code || 'DQ'
  const currentDqTotalLabel = `DQ${String(dqGroups.length || 0).padStart(3, '0')}`
  const currentDqCompletedCount = dqItems.filter(item => item.result).length
  const pendingQuestions = completion.pending
  const totalQuestions = completion.total
  const cumulativeComplianceScore = metrics.overall.percent
  const overallProgress = progress

  async function persistDraftResponses(showToast = false) {
    if (!auditId) {
      setError('No audit selected.')
      return false
    }
    if (!draftHydratedRef.current) {
      setError('Audit draft is still loading. Please try again in a moment.')
      return false
    }
    if (!draftPayload.length) {
      setError('Nothing to save yet.')
      return false
    }
    if (!draftRespondedById) {
      setError('Logged-in user not found in backend. Please re-login.')
      return false
    }
    if (draftSaveTimerRef.current) {
      window.clearTimeout(draftSaveTimerRef.current)
      draftSaveTimerRef.current = null
    }
    setDraftSaving(true)
    try {
      const client = requireSupabase()
      const { error: saveError } = await client.from('audit_responses').upsert(draftPayload, { onConflict: 'audit_id,checklist_id' })
      if (saveError) throw saveError
      lastDraftSignatureRef.current = draftSignature
      if (draftStorageKey) localStorage.removeItem(draftStorageKey)
      if (showToast) {
        setDraftMessage('Draft saved')
        window.setTimeout(() => setDraftMessage(''), 1600)
      }
      return true
    } catch (saveError) {
      if (draftStorageKey) localStorage.setItem(draftStorageKey, JSON.stringify({ rows: draftPayload, updatedAt: new Date().toISOString() }))
      setError(saveError?.message || 'Unable to save draft right now.')
      return false
    } finally {
      setDraftSaving(false)
    }
  }

  useEffect(() => {
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
  }, [draftSignature, auditId, draftStorageKey, draftRespondedById])

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
    setItems(current => current.map(item => (item.dbId === dbId ? { ...item, ...updates } : item)))
    setError('')
  }

  function selectResult(dbId, result) {
    const current = items.find(item => item.dbId === dbId)
    if (!current) return
    updateItem(dbId, {
      result,
      remarks: result === 'NA' ? '' : current.remarks || '',
    })
  }

  function openDqGroup(code) {
    setActiveDqCode(code)
    setSearchParams(code ? { dq: code, view: 'audit' } : { view: 'audit' }, { replace: true })
    const firstItem = dqGroups.find(group => group.code === code)?.items?.[0]
    if (firstItem) setActiveId(firstItem.dbId)
  }

  function proceedToDq(code) {
    if (!code) return
    openDqGroup(code)
    setPendingDialog(null)
  }

  async function handleNextDq() {
    if (currentDqIndex < 0) {
      setError('Unable to determine current DQ.')
      return
    }

    if (currentDqIndex >= dqGroups.length - 1) {
      setError('This is the last DQ.')
      openReview()
      return
    }

    const nextCode = dqGroups[currentDqIndex + 1].code
    const pendingItems = dqItems
      .map((item, index) => ({ item, index, reasons: getPendingReasons(item) }))
      .filter(entry => entry.reasons.length)

    if (pendingItems.length) {
      const pendingMessage = formatPendingListMessage(pendingItems.map(entry => ({
        item: entry.item,
        reasons: entry.reasons,
        subQuestionNum: getQuestionLabel(entry.item, entry.index),
        subQuestionText: cleanQuestion(entry.item.evaluationQuestion || entry.item.question),
      })), activeGroup?.code || selectedDqFromUrl || dqItems[0]?.dqQuestionNum || '')
      setError(pendingMessage)
      setPendingDialog({
        nextCode,
        pendingItems: pendingItems.map(entry => ({
          item: entry.item,
          reasons: entry.reasons,
          subQuestionNum: getQuestionLabel(entry.item, entry.index),
          subQuestionText: cleanQuestion(entry.item.evaluationQuestion || entry.item.question),
        })),
      })
      return
    }

    const saveResult = await persistDraftResponses(false)
    if (!saveResult) {
      if (!error) setError('Unable to save draft before moving to next DQ.')
      return
    }
    openDqGroup(nextCode)
  }

  function openReview() {
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
    const issues = []
    if (!completion.ready) {
      if (completion.pending) issues.push(`${completion.pending} unanswered questions`)
      if (completion.ngMissingCondition) issues.push(`${completion.ngMissingCondition} NG findings without current condition`)
      if (completion.capaPending) issues.push(`${completion.capaPending} improvement actions pending`)
      setError(`Audit cannot be submitted: ${issues.join(', ')}.`)
      return
    }
    setError('')
    submitAudit(auditId, { score: metrics.overall.percent, submittedBy: currentAudit?.owner })
    setSubmitted(true)
    window.setTimeout(() => navigate('/dashboard', { replace: true }), 1400)
  }

  function openDeleteDialog() {
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
    if (!auditId || deleting) return
    setDeleting(true)
    setDeleteMessage('')
    try {
      const client = requireSupabase()
      const { error: responseError } = await client.from('audit_responses').delete().eq('audit_id', auditId)
      if (responseError) throw responseError
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

  const getSelectedPicOption = item => relevantPicOptions.find(option => option.value === item.picForNg || option.id === item.picForNg || option.employee_name === item.picForNg) || null
  const getWhatsAppDetails = item => {
    if (item.result !== 'NG' || !item.picForNg) return null
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
          <span>Current DQ</span>
          <strong>{currentDqLabel} / {currentDqTotalLabel}</strong>
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
        <button className="secondary-button audit-header-action" disabled={draftSaving} onClick={() => persistDraftResponses(true)}><Save size={16} /> Save draft</button>
        <button className="secondary-button audit-header-action" disabled={currentDqIndex <= 0} onClick={() => currentDqIndex > 0 && openDqGroup(dqGroups[currentDqIndex - 1].code)}><ChevronLeft size={16} /> Previous DQ</button>
        {currentDqIndex >= 0 && currentDqIndex < dqGroups.length - 1 ? (
          <button className="primary-button audit-header-action audit-header-next" onClick={handleNextDq}>Next DQ</button>
        ) : (
          <button className="primary-button audit-header-action audit-header-next" onClick={openReview}>Review Audit</button>
        )}
      </div>
    </header>

    {draftMessage && <div className="audit-success-message" role="status"><CheckCircle2 /><div><strong>{draftMessage}</strong><span>Continue from the saved draft anytime.</span></div></div>}

    <section className="audit-focus-panel card">
      <div className="audit-focus-head">
        <div>
          <span>DQ Page</span>
          <h2>{activeGroup?.code || 'DQ'} {activeGroup ? `- ${activeGroup.title}` : ''}</h2>
        </div>
        <small>{currentDqIndex >= 0 ? `Page ${currentDqIndex + 1} of ${dqGroups.length}` : `Page 1 of ${dqGroups.length || 1}`}</small>
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
        const whatsappDetails = item.result === 'NG' && item.picForNg ? getWhatsAppDetails(item) : null
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
                <ScoreButtons item={item} onSelect={result => selectResult(item.dbId, result)} />
              </div>
            </div>

            <div className="audit-question-card-right">
              <textarea className="audit-inline-textarea audit-condition-textarea" rows="3" value={item.currentCondition || ''} placeholder="Current Condition / Gap Observed" onClick={event => event.stopPropagation()} onChange={event => updateItem(item.dbId, { currentCondition: event.target.value, gapIdentified: '' })} />
              <div className="audit-question-ng-fields">
                <EvidenceUploadCard item={item} onUpdate={updates => updateItem(item.dbId, updates)} />
                <select className="audit-inline-select" value={item.picForNg || ''} onClick={event => event.stopPropagation()} onChange={event => updateItem(item.dbId, { picForNg: event.target.value })}>
                  <option value="">Select PIC</option>
                  {relevantPicOptions.map(option => <option key={option.id} value={option.value}>{option.label || option.value}</option>)}
                </select>
                {item.result === 'NG' && <label className="audit-date-field" onClick={event => event.stopPropagation()}>
                  <span>Tentative Closing Date</span>
                  <input className="audit-inline-date" type="date" value={getTentativeClosingDate(item)} onChange={event => updateItem(item.dbId, { tentative_closing_date: event.target.value, tentativeClosingDate: event.target.value })} />
                </label>}
                {whatsappDetails && item.result === 'NG' && item.picForNg && (() => {
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
            </div>
          </div>
        </article>
      })}
    </section>

    {isReviewMode && <ReviewSnapshot groups={dqGroups} activeGroup={activeGroup} onJumpToDq={code => backToAudit(code)} />}

    <section className="audit-footer card">
      <div className="audit-footer-status">
        <div><span>AUDIT COMPLETION STATUS</span><strong className={completion.ready ? 'ready' : 'not-ready'}>{completion.ready ? 'Ready: Yes' : 'Ready: No'}</strong></div>
        <p>{completion.pending} pending, {completion.ngMissingCondition} NG missing condition.</p>
      </div>
      {error && <div className="audit-submission-error" role="alert"><AlertCircle size={20} /><span>{error}</span></div>}
      <div className="audit-footer-actions">
        <button className="secondary-button" disabled={draftSaving} onClick={() => persistDraftResponses(true)}><Save size={18} /> Save draft</button>
        {!isReviewMode ? (
          <>
            <button className="secondary-button" disabled={currentDqIndex <= 0} onClick={() => currentDqIndex > 0 && openDqGroup(dqGroups[currentDqIndex - 1].code)}><ChevronLeft size={18} /> Previous DQ</button>
            {currentDqIndex >= 0 && currentDqIndex < dqGroups.length - 1 ? (
              <button className="primary-button" onClick={handleNextDq}>Next DQ</button>
            ) : (
              <button className="primary-button" onClick={openReview}>Review Audit</button>
            )}
          </>
        ) : (
          <>
            <button className="secondary-button" onClick={() => backToAudit(dqGroups[dqGroups.length - 1]?.code)}><ChevronLeft size={18} /> Back to Audit</button>
            <button className="primary-button" disabled={!completion.ready} onClick={handleSubmit}><Send size={18} /> Submit Audit</button>
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
          <button className="secondary-button" onClick={() => setPendingDialog(null)}>Stay here</button>
          <button className="primary-button" onClick={() => proceedToDq(pendingDialog.nextCode)}>Continue</button>
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
