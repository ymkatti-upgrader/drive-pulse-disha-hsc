import { Download, FileDown, RefreshCcw, ShieldAlert } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { canAccessScope, canManageDishaWorkflow, canViewReports, getAccessScopeValues, getPrimaryRole, getRoleProfile, useAuth } from '../auth/AuthContext'
import { PageHeader, StatusBadge } from '../components/UI'
import { requireSupabase } from '../supabaseClient'
import KpiCards from './KpiCards'
import ReportCharts from './ReportCharts'
import ReportFilters from './ReportFilters'
import ReportTables from './ReportTables'
import { buildDashboardSnapshot, buildReportRows, buildSummary, filterRows, formatDate, formatDateTime, sortRows } from './reportUtils'
import { exportDashboardSummaryPdf, exportRowsToCsv, exportRowsToExcel } from './exportUtils'

const emptyFilters = {
  startDate: '',
  endDate: '',
  location: '',
  department: '',
  auditType: '',
  auditor: '',
  pic: '',
  status: '',
  severity: '',
  rootCauseCategory: '',
  monetarySupportRequired: '',
  search: '',
}

const tabConfig = [
  { key: 'executive', title: 'Executive Summary', dataset: 'all' },
  { key: 'audit', title: 'Audit Summary', dataset: 'audits' },
  { key: 'ng', title: 'NG Findings', dataset: 'ng' },
  { key: 'capa', title: 'CAPA Tracker', dataset: 'ng' },
  { key: 'root-cause', title: 'Root Cause Analysis', dataset: 'ng' },
  { key: 'location', title: 'Location Performance', dataset: 'audits' },
  { key: 'department', title: 'Department Performance', dataset: 'audits' },
  { key: 'pic', title: 'PIC Performance', dataset: 'ng' },
  { key: 'repeat', title: 'Repeat Findings', dataset: 'ng' },
  { key: 'monetary', title: 'Monetary Support', dataset: 'all' },
  { key: 'overdue', title: 'Overdue & Ageing', dataset: 'ng' },
  { key: 'evidence', title: 'Evidence Status', dataset: 'ng' },
]

const roleTabConfig = {
  'group-functional-hod': ['executive', 'ng', 'capa', 'location', 'repeat', 'overdue'],
  'location-functional-hod': ['executive', 'ng', 'capa', 'overdue', 'repeat'],
  viewer: ['executive', 'audit', 'ng', 'repeat'],
}

const roleKpiConfig = {
  'group-functional-hod': ['totalNgFindings', 'openCapas', 'overdueCapas', 'closedCapas', 'repeatFindings', 'averageClosureDays'],
}

const roleChartConfig = {
  'group-functional-hod': ['complianceTrend', 'locationComparison', 'capaStatus', 'rootCausePareto', 'overdueAgeing', 'repeatFindings', 'picPendingActions'],
}

function periodLabel(value) {
  return value ? formatDate(value) : 'All time'
}

function defaultDate(daysAgo = 180) {
  const date = new Date()
  date.setDate(date.getDate() - daysAgo)
  return date.toISOString().slice(0, 10)
}

function accessibleRow(user, row) {
  if (!row) return false
  const scope = { department: row.department, location: row.location }
  if (canManageDishaWorkflow(user) || canViewReports(user)) return canAccessScope(user, scope)
  return canAccessScope(user, scope)
}

function getVisibleTabs(roleProfileId) {
  const allowed = roleTabConfig[roleProfileId]
  if (!allowed) return tabConfig
  return tabConfig.filter(item => allowed.includes(item.key))
}

function getScopedDepartments(user, roleProfileId) {
  const departments = getAccessScopeValues(user, 'department')
  if (!departments.length) return []
  if (roleProfileId === 'group-functional-hod') return departments.filter(value => String(value || '').trim().toLowerCase() !== 'all')
  return departments
}

function getScopedLocations(user) {
  return getAccessScopeValues(user, 'location').filter(value => String(value || '').trim().toLowerCase() !== 'all')
}

function buildOptions(rows, selector, includeAllLabel = 'All') {
  const values = [...new Set(rows.map(selector).filter(Boolean))].sort((a, b) => String(a).localeCompare(String(b), 'en-IN', { numeric: true, sensitivity: 'base' }))
  return [{ value: '', label: includeAllLabel }, ...values.map(value => ({ value, label: value }))]
}

function groupSummaryRows(audits = []) {
  const groups = new Map()
  audits.forEach(audit => {
    const key = audit.auditId || audit.id
    if (!groups.has(key)) groups.set(key, audit)
  })
  return [...groups.values()].map(item => ({
    id: item.id || item.auditId,
    auditId: item.auditId,
    auditType: item.auditType,
    auditScore: item.auditScore,
    location: item.location,
    department: item.department,
    auditor: item.auditor,
    status: item.auditStatus || item.status,
    targetDate: item.targetDate,
    ageingDays: item.ageingDays,
    remarks: item.remarks,
    result: item.result,
    question: item.question,
    pic: item.pic,
    picMobile: item.picMobile,
    submittedAt: item.submittedAt,
    completedAt: item.completedAt,
    updatedAt: item.updatedAt,
    createdAt: item.createdAt,
  }))
}

function buildDedupedRepeatRows(rows = []) {
  const counts = new Map()
  rows.forEach(row => {
    const key = [row.location, row.department, row.checklistId || row.dqQuestion || row.question].map(value => String(value || '').trim().toLowerCase()).join('|')
    counts.set(key, (counts.get(key) || 0) + 1)
  })
  return rows.filter(row => {
    const key = [row.location, row.department, row.checklistId || row.dqQuestion || row.question].map(value => String(value || '').trim().toLowerCase()).join('|')
    return (counts.get(key) || 0) > 1
  })
}

function buildTableData(tabKey, rows, summaryRows) {
  if (tabKey === 'executive') return summaryRows
  if (tabKey === 'audit') return summaryRows
  if (tabKey === 'location' || tabKey === 'department') return summaryRows
  if (tabKey === 'repeat') return buildDedupedRepeatRows(rows)
  if (tabKey === 'monetary') return rows.filter(row => row.monetarySupportRequired)
  if (tabKey === 'evidence') return rows.filter(row => row.evidenceCount > 0 || row.quotationCount > 0)
  if (tabKey === 'overdue') return rows.filter(row => row.overdue)
  if (tabKey === 'ng' || tabKey === 'capa' || tabKey === 'root-cause' || tabKey === 'pic') return rows.filter(row => String(row.result).toUpperCase() === 'NG')
  return rows
}

function buildFilterOptions(rows, audits) {
  return {
    locations: buildOptions(rows, row => row.location || ''),
    departments: buildOptions(rows, row => row.department || ''),
    auditTypes: buildOptions(audits, row => row.auditType || ''),
    auditors: buildOptions(audits, row => row.auditor || ''),
    pics: buildOptions(rows, row => row.pic || ''),
    statuses: buildOptions(rows, row => row.status || ''),
    severities: buildOptions(rows, row => row.severity || ''),
    rootCauseCategories: buildOptions(rows, row => row.rootCauseCategory || ''),
    yesNo: [
      { value: '', label: 'All' },
      { value: 'Yes', label: 'Yes' },
      { value: 'No', label: 'No' },
    ],
  }
}

function buildSelectedRows(rows, filters, focus) {
  const filtered = filterRows(rows, filters)
  if (focus?.rows) return filterRows(focus.rows, filters)
  if (!focus) return filtered
  const needle = String(focus.value || '').toLowerCase()
  return filtered.filter(row => [row.location, row.department, row.auditType, row.auditor, row.pic, row.status, row.severity, row.rootCauseCategory, row.question].some(value => String(value || '').toLowerCase().includes(needle)))
}

function ErrorFallback({ error }) {
  return <section className="card report-error">
    <ShieldAlert size={28} />
    <strong>Reports dashboard could not load</strong>
    <p>{String(error?.message || error || 'Unknown error')}</p>
  </section>
}

export default function ReportsDashboard() {
  const { user } = useAuth()
  const roleProfile = getRoleProfile(user)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [lastRefreshed, setLastRefreshed] = useState('')
  const [filters, setFilters] = useState({ ...emptyFilters, startDate: defaultDate(180), endDate: new Date().toISOString().slice(0, 10) })
  const [tab, setTab] = useState('executive')
  const [detailRow, setDetailRow] = useState(null)
  const [focus, setFocus] = useState(null)
  const [sortState, setSortState] = useState({ key: 'createdAt', direction: 'desc' })
  const [pageByTab, setPageByTab] = useState({})
  const [searchByTab, setSearchByTab] = useState({})
  const [data, setData] = useState({ audits: [], rows: [], summaryRows: [], snapshot: null, options: null, summary: null })

  const roleName = getPrimaryRole(user)
  const scopedDepartments = useMemo(() => getScopedDepartments(user, roleProfile.id), [roleProfile.id, user])
  const scopedLocations = useMemo(() => getScopedLocations(user), [user])
  const departmentLocked = roleProfile.id === 'group-functional-hod' && scopedDepartments.length <= 1

  useEffect(() => {
    if (roleProfile.id !== 'group-functional-hod') return
    if (!scopedDepartments.length) return
    setFilters(current => {
      const validCurrent = current.department && scopedDepartments.some(item => String(item).toLowerCase() === String(current.department).toLowerCase())
      if (validCurrent) return current
      return { ...current, department: scopedDepartments[0] }
    })
  }, [roleProfile.id, scopedDepartments])

  async function loadData() {
    setLoading(true)
    setError('')
    try {
      const client = requireSupabase()
      const departmentFilters = scopedDepartments
      const locationFilters = scopedLocations
      const [departmentsLookupResult, locationsLookupResult] = await Promise.all([
        client.from('departments').select('id, name, status'),
        client.from('locations').select('id, code, name, type, visibility'),
      ])
      if (departmentsLookupResult.error) throw departmentsLookupResult.error
      if (locationsLookupResult.error) throw locationsLookupResult.error

      const allowedDepartmentIds = departmentFilters.length
        ? (departmentsLookupResult.data || [])
          .filter(item => departmentFilters.some(value => String(value).trim().toLowerCase() === String(item.name || '').trim().toLowerCase()))
          .map(item => item.id)
        : []
      const allowedLocationIds = locationFilters.length
        ? (locationsLookupResult.data || [])
          .filter(item => locationFilters.some(value => {
            const needle = String(value).trim().toLowerCase()
            return needle === String(item.name || '').trim().toLowerCase() || needle === String(item.code || '').trim().toLowerCase()
          }))
          .map(item => item.id)
        : []

      let responseQuery = client.from('audit_responses').select('id, audit_id, checklist_id, result, sub_question_text, audit_location, audit_department, assigned_pic_user_id, pic_for_ng_user_id, pic_for_ng_name, pic_for_ng_mobile, action_status, closure_status, verification_status, cause_category, monetary_support_required, expected_expense_amount, expense_category, expense_purpose, expense_approval_status, expense_approver_role, quotation_files, is_void, tentative_closing_date, actual_closure_date, updated_at, created_at, observation, comments, root_cause').order('created_at', { ascending: false })
      let auditQuery = client.from('audits').select('id, audit_no, title, location_id, department_id, auditor_id, status, score, scheduled_date, started_at, submitted_at, completed_at, created_at, updated_at')
      let findingQuery = client.from('audit_findings').select('id, audit_response_id, audit_id, checklist_id, location_id, owner_department_id, location_functional_hod_id, current_condition, gap_identified, auditor_comments, risk_level, status, target_date, closed_at, created_at, updated_at')
      let evidenceQuery = client.from('finding_evidence').select('id, finding_id, file_name, mime_type, file_size_bytes, storage_path, uploaded_at, evidence_stage, is_deleted').eq('is_deleted', false)

      if (departmentFilters.length) {
        responseQuery = responseQuery.in('audit_department', departmentFilters)
      }

      if (locationFilters.length) {
        responseQuery = responseQuery.in('audit_location', locationFilters)
      }

      if (allowedDepartmentIds.length) {
        auditQuery = auditQuery.in('department_id', allowedDepartmentIds)
        findingQuery = findingQuery.in('owner_department_id', allowedDepartmentIds)
      }

      if (allowedLocationIds.length) {
        auditQuery = auditQuery.in('location_id', allowedLocationIds)
        findingQuery = findingQuery.in('location_id', allowedLocationIds)
      }

      if (filters.startDate) {
        responseQuery = responseQuery.gte('created_at', filters.startDate)
        auditQuery = auditQuery.gte('created_at', filters.startDate)
        findingQuery = findingQuery.gte('created_at', filters.startDate)
        evidenceQuery = evidenceQuery.gte('uploaded_at', filters.startDate)
      }

      if (filters.endDate) {
        responseQuery = responseQuery.lte('created_at', `${filters.endDate}T23:59:59`)
        auditQuery = auditQuery.lte('created_at', `${filters.endDate}T23:59:59`)
        findingQuery = findingQuery.lte('created_at', `${filters.endDate}T23:59:59`)
        evidenceQuery = evidenceQuery.lte('uploaded_at', `${filters.endDate}T23:59:59`)
      }

      const [auditsResult, responsesResult, findingsResult, usersResult, mappingsResult, departmentsResult, locationsResult, evidenceResult] = await Promise.all([
        auditQuery,
        responseQuery,
        findingQuery,
        client.from('app_users').select('id, employee_name, mobile_no, active'),
        client.from('user_access_mappings').select('user_id, role, department, location, user_type, active').eq('active', true),
        Promise.resolve({ data: departmentsLookupResult.data, error: null }),
        Promise.resolve({ data: locationsLookupResult.data, error: null }),
        evidenceQuery,
      ])

      const anyError = [auditsResult, responsesResult, findingsResult, usersResult, mappingsResult, departmentsResult, locationsResult, evidenceResult].find(result => result.error)
      if (anyError?.error) throw anyError.error

      const rawAudits = (auditsResult.data || []).map(row => ({
        ...row,
        auditId: row.audit_no,
        auditType: row.title,
        createdAt: row.created_at,
        updatedAt: row.updated_at,
        submittedAt: row.submitted_at,
        completedAt: row.completed_at,
      }))

      const joinedRows = buildReportRows({
        audits: rawAudits.map(row => ({
          ...row,
          audit_no: row.audit_no,
          title: row.title,
          location_id: row.location_id,
          department_id: row.department_id,
          auditor_id: row.auditor_id,
        })),
        responses: responsesResult.data || [],
        findings: findingsResult.data || [],
        users: { users: usersResult.data || [], mappings: mappingsResult.data || [] },
        departments: departmentsResult.data || [],
        locations: locationsResult.data || [],
        evidence: evidenceResult.data || [],
      }).filter(row => accessibleRow(user, row))

      const summaryRows = groupSummaryRows(joinedRows)
      const filteredRows = filterRows(joinedRows, filters)
      const snapshot = buildDashboardSnapshot({ audits: summaryRows, rows: filteredRows })
      const summary = buildSummary(filteredRows)

      setData({
        audits: summaryRows,
        rows: joinedRows,
        summaryRows,
        snapshot,
        options: buildFilterOptions(joinedRows, summaryRows),
        summary,
      })
      setLastRefreshed(formatDateTime(new Date()))
    } catch (loadError) {
      console.error('Reports dashboard load failed', loadError)
      setError(loadError?.message || 'Unable to load report data.')
      setData(current => ({ ...current, audits: [], rows: [], summaryRows: [], snapshot: null, options: null, summary: null }))
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [filters.startDate, filters.endDate, roleProfile.id, scopedDepartments.join('|'), scopedLocations.join('|')])

  const options = data.options || buildFilterOptions([], [])
  const filteredRows = useMemo(() => buildSelectedRows(data.rows, filters, focus), [data.rows, filters, focus])
  const filteredAudits = useMemo(() => filterRows(data.audits, filters), [data.audits, filters])
  const summary = useMemo(() => buildSummary(filteredRows), [filteredRows])
  const snapshot = useMemo(() => buildDashboardSnapshot({ audits: filteredAudits, rows: filteredRows }), [filteredAudits, filteredRows])

  const summaryRows = useMemo(() => {
    const source = tab === 'executive' ? filteredRows : buildTableData(tab, filteredRows, data.summaryRows)
    return source.map(row => ({
      ...row,
      status: row.status || row.auditStatus || '',
    }))
  }, [data.summaryRows, filteredRows, tab])

  const activeSearch = searchByTab[tab] || ''
  const activeSort = sortState
  const exportTitle = tabConfig.find(item => item.key === tab)?.title || 'Report'

  function setTabSearch(value) {
    setSearchByTab(current => ({ ...current, [tab]: value }))
    setPageByTab(current => ({ ...current, [tab]: 1 }))
  }

  function setSort(key) {
    setSortState(current => ({
      key,
      direction: current.key === key && current.direction === 'asc' ? 'desc' : 'asc',
    }))
  }

  function exportCurrentExcel(rows, fileName) {
    exportRowsToExcel(rows, fileName, exportTitle)
  }

  function exportCurrentCsv(rows, fileName) {
    exportRowsToCsv(rows, fileName)
  }

  function exportSummaryPdf() {
    exportDashboardSummaryPdf({
      title: 'DISHA HSC Reports & Analytics',
      generatedAt: lastRefreshed || formatDateTime(new Date()),
      metrics: [
        { label: 'Total Audits', value: summary.totalAudits, meta: periodLabel(filters.startDate) },
        { label: 'Overall Compliance %', value: `${summary.overallCompliance}%`, meta: 'Filtered view' },
        { label: 'Open CAPAs', value: summary.openCapas, meta: 'NG rows not closed' },
        { label: 'Pending CEO Approvals', value: summary.pendingCeoApproval, meta: 'Monetary support' },
        { label: 'Monetary Value Requested', value: `INR ${summary.totalMonetaryValueRequested.toLocaleString('en-IN')}`, meta: 'Filtered view' },
        { label: 'Monetary Value Approved', value: `INR ${summary.totalMonetaryValueApproved.toLocaleString('en-IN')}`, meta: 'Approved only' },
      ],
      notes: [
        `Role: ${roleName}`,
        `Filters applied: ${JSON.stringify(filters)}`,
        `Drill-down focus: ${focus ? `${focus.label} - ${focus.value}` : 'None'}`,
      ],
    })
  }

  function exportNgFindings() {
    exportRowsToExcel(buildTableData('ng', filteredRows, data.summaryRows), 'NG Findings Register.xlsx', 'NG Findings Register')
  }

  function exportCapaTracker() {
    exportRowsToExcel(buildTableData('capa', filteredRows, data.summaryRows), 'CAPA Tracker.xlsx', 'CAPA Tracker')
  }

  function exportMonetaryReport() {
    exportRowsToExcel(buildTableData('monetary', filteredRows, data.summaryRows), 'Monetary Approval Report.xlsx', 'Monetary Approval Report')
  }

  const activeTabRows = useMemo(() => {
    const base = tab === 'executive' ? filteredRows : buildTableData(tab, filteredRows, data.summaryRows)
    return sortRows(base, activeSort.key, activeSort.direction)
  }, [activeSort.direction, activeSort.key, data.summaryRows, filteredRows, tab])

  const currentPage = pageByTab[tab] || 1
  const pageSize = 8

  function handleSelectGroup(label, value) {
    setFocus({ label, value })
    setTab('executive')
  }

  function handleSelectKpi(card) {
    const base = filterRows(data.rows, filters)
    let rows = base
    switch (card.key) {
      case 'totalAudits':
      case 'overallCompliance':
        rows = base
        break
      case 'totalNgFindings':
        rows = base.filter(row => String(row.result).toUpperCase() === 'NG')
        break
      case 'openCapas':
        rows = base.filter(row => String(row.result).toUpperCase() === 'NG' && !['closed', 'approved'].includes(String(row.closureStatus || '').toLowerCase()) && !row.actualClosureDate)
        break
      case 'closedCapas':
        rows = base.filter(row => String(row.result).toUpperCase() === 'NG' && (['closed', 'approved'].includes(String(row.closureStatus || '').toLowerCase()) || row.actualClosureDate))
        break
      case 'overdueCapas':
        rows = base.filter(row => row.overdue)
        break
      case 'averageClosureDays':
        rows = base.filter(row => String(row.result).toUpperCase() === 'NG' && row.actualClosureDate)
        break
      case 'repeatFindings':
        rows = buildDedupedRepeatRows(base)
        break
      case 'pendingVerification':
        rows = base.filter(row => String(row.verificationStatus || '').toLowerCase().includes('pending'))
        break
      case 'pendingCeoApproval':
        rows = base.filter(row => row.monetarySupportRequired && String(row.expenseApprovalStatus || '').toLowerCase() === 'pending ceo approval')
        break
      case 'totalMonetaryValueRequested':
      case 'totalMonetaryValueApproved':
        rows = base.filter(row => row.monetarySupportRequired)
        break
      default:
        rows = base
    }
    setFocus({ label: card.label, value: card.key, rows })
    setTab('executive')
  }

  function handleViewDetails(row) {
    setDetailRow(row)
  }

  const tabs = useMemo(() => getVisibleTabs(roleProfile.id), [roleProfile.id])
  const currentTabConfig = tabs.find(item => item.key === tab) || tabs[0] || tabConfig[0]

  const selectedExportRows = buildTableData(tab, filteredRows, data.summaryRows)
  const visibleKpis = roleKpiConfig[roleProfile.id]
  const visibleCharts = roleChartConfig[roleProfile.id]

  useEffect(() => {
    if (tabs.some(item => item.key === tab)) return
    setTab(tabs[0]?.key || 'executive')
  }, [tab, tabs])

  if (error) {
    return <ErrorFallback error={new Error(error)} />
  }

  return <div className="reports-dashboard-page">
    <PageHeader
      eyebrow="REPORTS / ANALYTICS"
      title="DISHA HSC Reports & Analytics"
      description={`Role-based reporting for ${roleName}. ${roleProfile.id === 'group-functional-hod' ? 'Department scope is locked to your access mapping.' : focus ? `Drill-down: ${focus.label} - ${focus.value}` : 'Click any KPI or chart segment to inspect details.'}`}
      action={<div className="report-page-actions">
        <button className="secondary-button" type="button" onClick={loadData} disabled={loading}><RefreshCcw size={16} /> Refresh</button>
        <button className="secondary-button" type="button" onClick={exportSummaryPdf}><FileDown size={16} /> Export Summary PDF</button>
      </div>}
    />

    <ReportFilters
      value={filters}
      options={options}
      onChange={setFilters}
      onRefresh={loadData}
      loading={loading}
      lastRefreshed={lastRefreshed}
      visibleFields={roleProfile.id === 'group-functional-hod'
        ? ['startDate', 'endDate', 'location', 'department', 'pic', 'status', 'severity', 'rootCauseCategory', 'search']
        : undefined}
      lockedFields={departmentLocked ? ['department'] : []}
    />

    {loading && <section className="card report-skeleton">
      <div className="report-skeleton-line wide" />
      <div className="report-skeleton-grid">
        {Array.from({ length: 12 }).map((_, index) => <div key={index} className="report-skeleton-card" />)}
      </div>
    </section>}

    {!loading && <>
      <KpiCards summary={summary} onSelectKpi={handleSelectKpi} visibleKeys={visibleKpis} />
      <ReportCharts snapshot={snapshot} onSelectGroup={handleSelectGroup} visibleKeys={visibleCharts} />

      <section className="card report-drilldown">
        <div className="report-drilldown-head">
          <div>
            <span className="eyebrow">DRILL-DOWN</span>
            <h2>{focus ? `${focus.label} - ${focus.value}` : 'Filtered report rows'}</h2>
            <p>{filteredRows.length} row(s) match the current filter set.</p>
          </div>
          <div className="report-drilldown-actions">
            <button className="secondary-button" type="button" onClick={() => exportCurrentExcel(buildTableData(tab, filteredRows, data.summaryRows), `${exportTitle}.xlsx`)}><Download size={16} /> Export filtered Excel</button>
            <button className="secondary-button" type="button" onClick={() => exportCurrentCsv(buildTableData(tab, filteredRows, data.summaryRows), `${exportTitle}.csv`)}><Download size={16} /> Export filtered CSV</button>
          </div>
        </div>
        <div className="report-export-strip">
          <button className="secondary-button" type="button" onClick={exportNgFindings}><Download size={16} /> Export NG Findings Register</button>
          <button className="secondary-button" type="button" onClick={exportCapaTracker}><Download size={16} /> Export CAPA Tracker</button>
          {roleProfile.id !== 'group-functional-hod' && roleProfile.id !== 'viewer' && <button className="secondary-button" type="button" onClick={exportMonetaryReport}><Download size={16} /> Export Monetary Approval Report</button>}
        </div>
      </section>

      <section className="report-tabs">
        {tabs.map(item => <button key={item.key} className={tab === item.key ? 'active' : ''} onClick={() => { setTab(item.key); setFocus(null); setPageByTab(current => ({ ...current, [item.key]: 1 })) }}>{item.title}</button>)}
      </section>

      <ReportTables
        title={currentTabConfig.title}
        tabKey={currentTabConfig.key}
        rows={selectedExportRows}
        onViewDetails={handleViewDetails}
        onExportExcel={exportRowsToExcel}
        onExportCsv={exportRowsToCsv}
        search={activeSearch}
        onSearch={setTabSearch}
        sortKey={activeSort.key}
        sortDirection={activeSort.direction}
        onSortChange={setSort}
        page={currentPage}
        pageSize={pageSize}
        onPageChange={nextPage => setPageByTab(current => ({ ...current, [tab]: nextPage }))}
      />
    </>}

    {detailRow && <div className="modal-layer">
      <button className="modal-backdrop" aria-label="Close details" onClick={() => setDetailRow(null)} />
      <section className="card report-detail-modal">
        <div className="modal-head">
          <div>
            <span className="eyebrow">DETAIL VIEW</span>
            <h2>{detailRow.auditId}</h2>
            <p>{detailRow.location} | {detailRow.department}</p>
          </div>
          <button type="button" onClick={() => setDetailRow(null)}>x</button>
        </div>
        <div className="report-detail-grid">
          <div><span>Question</span><strong>{detailRow.question || '-'}</strong></div>
          <div><span>PIC</span><strong>{detailRow.pic || '-'}</strong></div>
          <div><span>Status</span><StatusBadge>{detailRow.status || '-'}</StatusBadge></div>
          <div><span>Due Date</span><strong>{formatDate(detailRow.targetDate)}</strong></div>
          <div><span>Ageing</span><strong>{detailRow.ageingDays} day(s)</strong></div>
          <div><span>Remarks</span><strong>{detailRow.remarks || '-'}</strong></div>
          <div><span>Severity</span><strong>{detailRow.severity || '-'}</strong></div>
          <div><span>Root Cause</span><strong>{detailRow.rootCause || '-'}</strong></div>
          <div><span>Monetary Support</span><strong>{detailRow.monetarySupportRequired ? 'Yes' : 'No'}</strong></div>
          <div><span>Expected Expense</span><strong>{detailRow.expectedExpenseAmount ? `INR ${Number(detailRow.expectedExpenseAmount).toLocaleString('en-IN')}` : '-'}</strong></div>
        </div>
      </section>
    </div>}
  </div>
}
