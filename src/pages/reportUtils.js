const DAY_MS = 24 * 60 * 60 * 1000

function normalizedText(value) {
  return String(value ?? '').trim().toLowerCase()
}

function toDate(value) {
  if (!value) return null
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? null : date
}

export function formatDate(value, fallback = '-') {
  const date = toDate(value)
  if (!date) return fallback
  return new Intl.DateTimeFormat('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }).format(date)
}

export function formatDateTime(value, fallback = '-') {
  const date = toDate(value)
  if (!date) return fallback
  return new Intl.DateTimeFormat('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(date)
}

export function formatCurrency(value, fallback = '-') {
  const amount = Number(value)
  if (!Number.isFinite(amount)) return fallback
  return `INR ${amount.toLocaleString('en-IN')}`
}

export function formatPercent(value, fallback = '-') {
  const amount = Number(value)
  if (!Number.isFinite(amount)) return fallback
  return `${Math.round(amount)}%`
}

export function toNumber(value) {
  const amount = Number(String(value ?? '').replace(/,/g, ''))
  return Number.isFinite(amount) ? amount : 0
}

export function daysBetween(startValue, endValue = new Date()) {
  const start = toDate(startValue)
  const end = toDate(endValue)
  if (!start || !end) return null
  const startDate = new Date(start)
  const endDate = new Date(end)
  startDate.setHours(0, 0, 0, 0)
  endDate.setHours(0, 0, 0, 0)
  return Math.max(0, Math.round((endDate.getTime() - startDate.getTime()) / DAY_MS))
}

export function deriveStatus(row = {}) {
  const actionStatus = normalizedText(row.action_status)
  const closureStatus = normalizedText(row.closure_status)
  const verificationStatus = normalizedText(row.verification_status)
  const expenseStatus = normalizedText(row.expense_approval_status)

  if (row.is_void) return 'Voided'
  if (normalizedText(row.result) !== 'ng') return 'OK'
  if (['closed', 'approved'].includes(closureStatus) || row.actual_closure_date) return 'Closed'
  if (verificationStatus.includes('pending')) return 'Pending Verification'
  if (expenseStatus === 'pending ceo approval') return 'Pending CEO Approval'
  if (expenseStatus.includes('pending')) return 'In Progress'
  if (actionStatus.includes('in progress') || actionStatus.includes('open')) return 'In Progress'
  return 'Open'
}

export function deriveSeverity(row = {}, finding = {}) {
  const raw = finding.risk_level || row.severity || row.risk_level || row.priority || ''
  const text = String(raw || '').trim()
  if (text) return text
  if (normalizedText(row.result) === 'ng') return 'Major'
  return 'Minor'
}

export function deriveAuditType(audit = {}, row = {}) {
  return audit.title || row.audit_type || row.audit_title || 'General Audit'
}

export function normalizeLookupMap(rows, key = 'id') {
  const map = new Map()
  ;(rows || []).forEach(row => {
    map.set(row[key], row)
  })
  return map
}

export function normalizeUserMap(users = [], mappings = []) {
  const mappingByUser = new Map()
  ;(mappings || []).forEach(mapping => {
    if (!mappingByUser.has(mapping.user_id)) mappingByUser.set(mapping.user_id, [])
    mappingByUser.get(mapping.user_id).push(mapping)
  })

  const map = new Map()
  ;(users || []).forEach(user => {
    const access = mappingByUser.get(user.id) || []
    const department = [...new Set(access.map(item => item.department).filter(Boolean))].join(', ')
    const location = [...new Set(access.map(item => item.location).filter(Boolean))].join(', ')
    const role = [...new Set(access.map(item => item.role).filter(Boolean))].join(', ')
    map.set(user.id, {
      id: user.id,
      employee_name: user.employee_name || '',
      mobile_no: user.mobile_no || '',
      department,
      location,
      role,
      access,
    })
  })
  return map
}

export function buildReportRows({ audits = [], responses = [], findings = [], users = [], locations = [], departments = [], evidence = [] }) {
  const auditMap = normalizeLookupMap(audits)
  const locationMap = normalizeLookupMap(locations)
  const departmentMap = normalizeLookupMap(departments)
  const userMap = normalizeUserMap(users.users || users, users.mappings || [])
  const evidenceByFinding = new Map()
  ;(evidence || []).forEach(item => {
    if (!item.finding_id) return
    if (!evidenceByFinding.has(item.finding_id)) evidenceByFinding.set(item.finding_id, [])
    evidenceByFinding.get(item.finding_id).push(item)
  })
  const findingByResponse = new Map()
  ;(findings || []).forEach(finding => {
    if (finding.audit_response_id) findingByResponse.set(finding.audit_response_id, finding)
  })

  return (responses || [])
    .filter(row => row && row.is_void !== true)
    .map(row => {
      const audit = auditMap.get(row.audit_id) || {}
      const finding = findingByResponse.get(row.id) || {}
      const auditLocation = row.audit_location || locationMap.get(audit.location_id)?.name || locationMap.get(audit.location_id)?.code || ''
      const auditDepartment = row.audit_department || departmentMap.get(audit.department_id)?.name || ''
      const auditor = userMap.get(audit.auditor_id)?.employee_name || audit.auditor_name || ''
      const pic = row.pic_for_ng_name
        || userMap.get(row.assigned_pic_user_id)?.employee_name
        || userMap.get(row.pic_for_ng_user_id)?.employee_name
        || ''
      const picMobile = row.pic_for_ng_mobile || userMap.get(row.assigned_pic_user_id)?.mobile_no || userMap.get(row.pic_for_ng_user_id)?.mobile_no || ''
      const rootCause = row.root_cause || finding.root_cause || ''
      const causeCategory = row.cause_category || 'Unclassified'
      const status = deriveStatus(row)
      const severity = deriveSeverity(row, finding)
      const targetDate = finding.target_date || row.target_date || row.expected_closure_date || ''
      const actualClosureDate = finding.closed_at || row.actual_closure_date || ''
      const createdAt = row.created_at || finding.created_at || audit.created_at
      const closedAt = actualClosureDate || finding.closed_at || row.actual_closure_date
      const ageDays = daysBetween(targetDate || createdAt, closedAt || new Date())
      const overdue = Boolean(targetDate && !closedAt && daysBetween(targetDate, new Date()) > 0)
      const evidenceCount = evidenceByFinding.get(finding.id)?.length || 0
      const monetarySupportRequired = Boolean(row.monetary_support_required)
      const expectedExpenseAmount = toNumber(row.expected_expense_amount)
      const expenseApprovalStatus = row.expense_approval_status || 'Not Required'
      const summary = row.observation || row.comments || row.root_cause || finding.auditor_comments || finding.gap_identified || ''

      return {
        id: row.id,
        auditId: audit.audit_no || row.audit_id,
        auditNo: audit.audit_no || '',
        auditTitle: audit.title || '',
        auditType: deriveAuditType(audit, row),
        auditStatus: audit.status || '',
        auditScore: Number(audit.score),
        submittedAt: audit.submitted_at || '',
        completedAt: audit.completed_at || '',
        locationId: audit.location_id || '',
        departmentId: audit.department_id || '',
        location: auditLocation || '',
        department: auditDepartment || '',
        auditor,
        auditorId: audit.auditor_id || '',
        question: row.sub_question_text || '',
        checklistId: row.checklist_id || '',
        dqQuestion: row.dq_question_num || row.sub_question_num || '',
        pic,
        picMobile,
        picUserId: row.assigned_pic_user_id || row.pic_for_ng_user_id || '',
        result: row.result || '',
        status,
        severity,
        rootCauseCategory: causeCategory,
        rootCause,
        monetarySupportRequired,
        expectedExpenseAmount,
        expenseCategory: row.expense_category || 'Unspecified',
        expensePurpose: row.expense_purpose || '',
        expenseApprovalStatus,
        expenseApproverRole: row.expense_approver_role || '',
        targetDate,
        actualClosureDate,
        createdAt,
        updatedAt: row.updated_at || finding.updated_at || audit.updated_at,
        ageingDays: ageDays,
        overdue,
        remarks: summary,
        closureStatus: row.closure_status || finding.status || '',
        verificationStatus: row.verification_status || '',
        evidenceCount,
        quotationCount: Array.isArray(row.quotation_files) ? row.quotation_files.length : 0,
        findingId: finding.id || '',
        findingStatus: finding.status || '',
        findingRisk: finding.risk_level || '',
        findingTargetDate: finding.target_date || '',
      }
    })
    .filter(row => row.auditId)
}

export function filterRows(rows, filters = {}) {
  const startDate = filters.startDate ? toDate(filters.startDate) : null
  const endDate = filters.endDate ? toDate(filters.endDate) : null
  const location = normalizedText(filters.location)
  const department = normalizedText(filters.department)
  const auditType = normalizedText(filters.auditType)
  const auditor = normalizedText(filters.auditor)
  const pic = normalizedText(filters.pic)
  const status = normalizedText(filters.status)
  const severity = normalizedText(filters.severity)
  const rootCauseCategory = normalizedText(filters.rootCauseCategory)
  const monetarySupport = normalizedText(filters.monetarySupportRequired)
  const search = normalizedText(filters.search)

  return (rows || []).filter(row => {
    const createdAt = toDate(row.createdAt) || toDate(row.updatedAt) || toDate(row.targetDate)
    if (startDate && createdAt && createdAt < startDate) return false
    if (endDate && createdAt && createdAt > endDate) return false
    if (location && normalizedText(row.location) !== location) return false
    if (department && normalizedText(row.department) !== department) return false
    if (auditType && normalizedText(row.auditType) !== auditType) return false
    if (auditor && normalizedText(row.auditor) !== auditor) return false
    if (pic && normalizedText(row.pic) !== pic) return false
    if (status && normalizedText(row.status) !== status) return false
    if (severity && normalizedText(row.severity) !== severity) return false
    if (rootCauseCategory && normalizedText(row.rootCauseCategory) !== rootCauseCategory) return false
    if (monetarySupport === 'yes' && !row.monetarySupportRequired) return false
    if (monetarySupport === 'no' && row.monetarySupportRequired) return false
    if (search) {
      const haystack = [
        row.auditId,
        row.auditTitle,
        row.auditType,
        row.location,
        row.department,
        row.auditor,
        row.pic,
        row.question,
        row.remarks,
        row.rootCause,
        row.rootCauseCategory,
        row.status,
        row.severity,
      ].map(value => normalizedText(value)).join(' | ')
      if (!haystack.includes(search)) return false
    }
    return true
  })
}

export function sortRows(rows, sortKey, sortDirection = 'desc') {
  const direction = sortDirection === 'asc' ? 1 : -1
  const getValue = row => {
    switch (sortKey) {
      case 'auditId': return row.auditId
      case 'location': return row.location
      case 'department': return row.department
      case 'question': return row.question
      case 'pic': return row.pic
      case 'status': return row.status
      case 'dueDate': return row.targetDate
      case 'ageing': return row.ageingDays
      case 'remarks': return row.remarks
      default: return row.createdAt
    }
  }
  return [...(rows || [])].sort((a, b) => {
    const left = getValue(a)
    const right = getValue(b)
    const leftNumber = Number(left)
    const rightNumber = Number(right)
    if (Number.isFinite(leftNumber) && Number.isFinite(rightNumber)) return (leftNumber - rightNumber) * direction
    return String(left ?? '').localeCompare(String(right ?? ''), 'en-IN', { numeric: true, sensitivity: 'base' }) * direction
  })
}

export function paginateRows(rows, page = 1, pageSize = 10) {
  const safePage = Math.max(1, Number(page) || 1)
  const safeSize = Math.max(1, Number(pageSize) || 10)
  const start = (safePage - 1) * safeSize
  return {
    page: safePage,
    pageSize: safeSize,
    totalPages: Math.max(1, Math.ceil((rows || []).length / safeSize)),
    rows: (rows || []).slice(start, start + safeSize),
  }
}

export function buildSummary(rows = []) {
  const nonVoid = rows.filter(row => row)
  const ngRows = nonVoid.filter(row => normalizedText(row.result) === 'ng')
  const openCapas = ngRows.filter(row => !['closed', 'approved'].includes(normalizedText(row.closureStatus)) && !row.actualClosureDate)
  const closedCapas = ngRows.filter(row => ['closed', 'approved'].includes(normalizedText(row.closureStatus)) || row.actualClosureDate)
  const overdueCapas = openCapas.filter(row => row.overdue)
  const pendingVerification = ngRows.filter(row => normalizedText(row.verificationStatus).includes('pending'))
  const pendingCeoApproval = nonVoid.filter(row => row.monetarySupportRequired && normalizedText(row.expenseApprovalStatus) === 'pending ceo approval')
  const monetaryRequested = nonVoid.filter(row => row.monetarySupportRequired)
  const totalRequested = monetaryRequested.reduce((sum, row) => sum + toNumber(row.expectedExpenseAmount), 0)
  const totalApproved = monetaryRequested
    .filter(row => normalizedText(row.expenseApprovalStatus) === 'approved')
    .reduce((sum, row) => sum + toNumber(row.expectedExpenseAmount), 0)
  const averageClosureDays = closedCapas.length
    ? Math.round(closedCapas.reduce((sum, row) => sum + Math.max(0, Number(row.ageingDays) || 0), 0) / closedCapas.length)
    : 0
  const repeatMap = new Map()
  nonVoid.forEach(row => {
    const findingKey = row.checklistId || row.dqQuestion || row.question
    const key = [normalizedText(row.location), normalizedText(row.department), normalizedText(findingKey)].join('|')
    repeatMap.set(key, (repeatMap.get(key) || 0) + 1)
  })
  const repeatFindings = [...repeatMap.values()].filter(count => count > 1).length
  const overallCompliance = nonVoid.length ? Math.round((nonVoid.filter(row => normalizedText(row.result) !== 'ng').length / nonVoid.length) * 100) : 0

  return {
    totalAudits: new Set(nonVoid.map(row => row.auditId)).size,
    overallCompliance,
    totalNgFindings: ngRows.length,
    openCapas: openCapas.length,
    closedCapas: closedCapas.length,
    overdueCapas: overdueCapas.length,
    averageClosureDays,
    repeatFindings,
    pendingVerification: pendingVerification.length,
    pendingCeoApproval: pendingCeoApproval.length,
    totalMonetaryValueRequested: totalRequested,
    totalMonetaryValueApproved: totalApproved,
  }
}

export function groupBy(rows, getKey, getLabel = getKey) {
  const groups = new Map()
  ;(rows || []).forEach(row => {
    const key = getKey(row) || 'Unassigned'
    if (!groups.has(key)) groups.set(key, { key, label: getLabel(row) || key, rows: [] })
    groups.get(key).rows.push(row)
  })
  return [...groups.values()]
}

export function buildComplianceSeries(audits = []) {
  const groups = new Map()
  ;(audits || []).forEach(audit => {
    const date = toDate(audit.submittedAt || audit.submitted_at || audit.createdAt || audit.created_at)
    if (!date) return
    const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
    if (!groups.has(key)) groups.set(key, { key, label: date.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' }), values: [] })
    groups.get(key).values.push(Number(audit.score))
  })
  return [...groups.values()]
    .sort((a, b) => a.key.localeCompare(b.key))
    .map(group => ({
      label: group.label,
      value: group.values.length ? Math.round(group.values.filter(Number.isFinite).reduce((sum, value) => sum + value, 0) / group.values.length) : 0,
      count: group.values.length,
    }))
}

export function buildCountSeries(rows = [], getKey) {
  const groups = new Map()
  rows.forEach(row => {
    const key = getKey(row) || 'Unassigned'
    groups.set(key, (groups.get(key) || 0) + 1)
  })
  return [...groups.entries()].map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value)
}

export function buildParetoSeries(rows = [], getKey) {
  const grouped = buildCountSeries(rows, getKey)
  const total = grouped.reduce((sum, item) => sum + item.value, 0)
  let cumulative = 0
  return grouped.map(item => {
    cumulative += item.value
    return {
      ...item,
      cumulative,
      cumulativePercent: total ? Math.round((cumulative / total) * 100) : 0,
      percent: total ? Math.round((item.value / total) * 100) : 0,
    }
  })
}

export function buildOverdueAgeSeries(rows = []) {
  const buckets = [
    { label: '0-7 Days', min: 0, max: 7 },
    { label: '8-15 Days', min: 8, max: 15 },
    { label: '16-30 Days', min: 16, max: 30 },
    { label: '31+ Days', min: 31, max: Infinity },
  ]
  return buckets.map(bucket => ({
    label: bucket.label,
    value: rows.filter(row => row.overdue && Number(row.ageingDays) >= bucket.min && Number(row.ageingDays) <= bucket.max).length,
  }))
}

export function buildTrendByMonth(rows = [], dateField = 'createdAt') {
  const groups = new Map()
  rows.forEach(row => {
    const date = toDate(row[dateField])
    if (!date) return
    const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
    if (!groups.has(key)) groups.set(key, { key, label: date.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' }), total: 0, completed: 0 })
    const group = groups.get(key)
    group.total += 1
    if (normalizedText(row.status) === 'closed' || normalizedText(row.result) !== 'ng') group.completed += 1
  })
  return [...groups.values()].sort((a, b) => a.key.localeCompare(b.key)).map(group => ({
    label: group.label,
    total: group.total,
    completed: group.completed,
    value: group.total ? Math.round((group.completed / group.total) * 100) : 0,
  }))
}

export function buildCompletionTrend(audits = []) {
  return buildTrendByMonth(audits.map(audit => ({
    createdAt: audit.createdAt || audit.created_at,
    status: audit.status,
    result: audit.status === 'submitted' ? 'ok' : 'ng',
  })))
}

export function buildStatusSeries(rows = []) {
  const labels = ['Open', 'In Progress', 'Pending Verification', 'Pending CEO Approval', 'Closed', 'OK', 'Voided']
  const counts = labels.map(label => ({
    label,
    value: rows.filter(row => normalizedText(row.status) === normalizedText(label)).length,
  }))
  return counts.filter(item => item.value > 0)
}

export function buildCompletionQuality(audits = []) {
  const total = audits.length
  const submitted = audits.filter(item => ['submitted', 'completed', 'closed'].includes(normalizedText(item.status))).length
  return total ? Math.round((submitted / total) * 100) : 0
}

export function buildDashboardSnapshot({ audits = [], rows = [] }) {
  const complianceTrend = buildComplianceSeries(audits)
  const locationComparison = buildCountSeries(audits, item => item.location || 'Unassigned')
  const departmentNg = buildCountSeries(rows.filter(row => normalizedText(row.result) === 'ng'), row => row.department || 'Unassigned')
  const capaStatus = buildStatusSeries(rows.filter(row => normalizedText(row.result) === 'ng'))
  const rootCausePareto = buildParetoSeries(rows.filter(row => normalizedText(row.result) === 'ng'), row => row.rootCauseCategory || 'Unclassified')
  const overdueAgeing = buildOverdueAgeSeries(rows.filter(row => normalizedText(row.result) === 'ng'))
  const repeatFindings = buildCountSeries(
    rows.filter(row => normalizedText(row.result) === 'ng'),
    row => `${row.dqQuestion || row.question || 'Question'}`
  )
  const monetaryByCategory = buildCountSeries(rows.filter(row => row.monetarySupportRequired), row => row.expenseCategory || 'Unspecified')
  const auditCompletion = buildTrendByMonth(audits, 'submittedAt')
  const picPendingActions = buildCountSeries(
    rows.filter(row => normalizedText(row.result) === 'ng' && !['closed', 'approved'].includes(normalizedText(row.closureStatus)) && !row.actualClosureDate),
    row => row.pic || 'Unassigned'
  )

  return {
    complianceTrend,
    locationComparison,
    departmentNg,
    capaStatus,
    rootCausePareto,
    overdueAgeing,
    repeatFindings,
    monetaryByCategory,
    auditCompletion,
    picPendingActions,
  }
}
