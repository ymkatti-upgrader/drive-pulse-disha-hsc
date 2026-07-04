import { Award, BookOpenCheck, CheckCircle2, ClipboardCheck, FileBarChart, ShieldAlert, ShieldCheck, Target, TrendingUp, UserCheck, Wallet } from 'lucide-react'
import { useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { isInProgressAuditStatus, useAudits } from '../audits/AuditContext'
import { filterByUserAccess, getRoleProfile, useAuth } from '../auth/AuthContext'
import { PageHeader, Progress, StatusBadge } from '../components/UI'
import { useCapas } from '../capa/CapaContext'
import { useYokoten } from '../yokoten/YokotenContext'

const emptyMessage = 'No data yet'

function averageScore(rows) {
  const scored = rows.filter(item => Number.isFinite(Number(item.score)))
  if (!scored.length) return null
  return Math.round(scored.reduce((sum, item) => sum + Number(item.score), 0) / scored.length)
}

function parseDate(value) {
  if (!value) return null
  const parsed = new Date(value)
  return Number.isNaN(parsed.getTime()) ? null : parsed
}

function isPastDue(value) {
  const parsed = parseDate(value)
  if (!parsed) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  parsed.setHours(0, 0, 0, 0)
  return parsed < today
}

function groupCounts(rows, key) {
  const groups = new Map()
  rows.forEach(row => {
    const name = row[key] || 'Unassigned'
    groups.set(name, (groups.get(name) || 0) + 1)
  })
  return [...groups.entries()].map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count)
}

function groupAverage(rows, key) {
  const groups = new Map()
  rows.forEach(row => {
    const name = row[key] || 'Unassigned'
    const score = Number(row.score)
    if (!Number.isFinite(score)) return
    const current = groups.get(name) || { total: 0, count: 0 }
    groups.set(name, { total: current.total + score, count: current.count + 1 })
  })
  return [...groups.entries()]
    .map(([name, value]) => ({ name, score: Math.round(value.total / value.count), count: value.count }))
    .sort((a, b) => b.score - a.score)
}

function Kpi({ label, value, meta, icon: Icon, tone = 'blue', onClick }) {
  return <button className={`leadership-kpi ${tone}`} onClick={onClick}>
    <span className="leadership-kpi-icon"><Icon /></span>
    <div><span>{label}</span><strong>{value}</strong><small>{meta}</small></div>
  </button>
}

function Panel({ eyebrow, title, action, children }) {
  return <section className="card exec-panel">
    <div className="panel-head">
      <div><span className="eyebrow">{eyebrow}</span><h2>{title}</h2></div>
      {action}
    </div>
    {children}
  </section>
}

function EmptyPanel({ title }) {
  return <Panel eyebrow={title.toUpperCase()} title={title}><div className="role-empty">{emptyMessage}</div></Panel>
}

function ListPanel({ eyebrow, title, rows, getTitle, getSubtitle, getBadge, onClick }) {
  if (!rows.length) return <EmptyPanel title={title} />
  return <Panel eyebrow={eyebrow} title={title}>
    <div className="role-compact-list">
      {rows.map(item => <button key={item.id || item.capaId || item.auditId || item.name} className="role-list-item" onClick={() => onClick?.(item)}>
        <div>
          <strong>{getTitle(item)}</strong>
          <span>{getSubtitle(item)}</span>
        </div>
        {getBadge ? <StatusBadge>{getBadge(item)}</StatusBadge> : null}
      </button>)}
    </div>
  </Panel>
}

function ShortcutCard({ title, description, icon: Icon, onClick }) {
  return <button className="role-shortcut-card" onClick={onClick}>
    <span className="role-shortcut-icon"><Icon size={18} /></span>
    <div><strong>{title}</strong><small>{description}</small></div>
  </button>
}

export default function Dashboard() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const roleProfile = getRoleProfile(user)
  const roleLabel = roleProfile.label
  const { audits } = useAudits()
  const { capas } = useCapas()
  const { stories } = useYokoten()

  const scopedAudits = useMemo(() => {
    if (['system-admin', 'ceo', 'group-disha'].includes(roleProfile.id)) return audits
    return filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  }, [audits, roleProfile.id, user])

  const scopedCapas = useMemo(() => {
    if (['system-admin', 'ceo', 'group-disha'].includes(roleProfile.id)) return capas
    return filterByUserAccess(user, capas, item => ({ department: item.departmentOwner || item.department || item.area, location: item.location || item.locationAspect }))
  }, [capas, roleProfile.id, user])

  const derived = useMemo(() => {
    const submittedAudits = scopedAudits.filter(item => item.status === 'Submitted')
    const inProgressAudits = scopedAudits.filter(item => isInProgressAuditStatus(item.status))
    const activeActions = scopedCapas.filter(item => !['Closed', 'Yokoten Shared', 'Cancelled'].includes(item.status))
    const verificationPending = scopedCapas.filter(item => ['Evidence Uploaded', 'Verification Pending'].includes(item.status))
    const approvalPending = activeActions.filter(item => item.status === 'Approval Pending' || item.countermeasurePlan?.approvalRequired === 'Yes')
    const overdueActions = activeActions.filter(item => isPastDue(item.targetDate || item.due || item.countermeasurePlan?.targetCompletionDate))
    const repeatFindings = activeActions.filter(item => item.repeatFinding)
    const closedThisMonth = scopedCapas.filter(item => {
      if (item.status !== 'Closed') return false
      const closedDate = parseDate(item.closedAt || item.closed_at || item.actualClosureDate || item.updatedAt || item.updated_at)
      if (!closedDate) return false
      const now = new Date()
      return closedDate.getMonth() === now.getMonth() && closedDate.getFullYear() === now.getFullYear()
    })
    const closedWithDates = scopedCapas.filter(item => parseDate(item.createdDate || item.created_at) && parseDate(item.closedAt || item.closed_at || item.actualClosureDate || item.updatedAt || item.updated_at))
    const averageClosureDays = closedWithDates.length
      ? Math.round(closedWithDates.reduce((sum, item) => {
        const createdAt = parseDate(item.createdDate || item.created_at)
        const closedAt = parseDate(item.closedAt || item.closed_at || item.actualClosureDate || item.updatedAt || item.updated_at)
        return sum + Math.max(0, Math.round((closedAt - createdAt) / (1000 * 60 * 60 * 24)))
      }, 0) / closedWithDates.length)
      : null
    const totalNg = scopedCapas.length
    const locationRanking = groupAverage(submittedAudits, 'location')
    const departmentRanking = groupAverage(submittedAudits, 'department')
    const actionByDepartment = groupCounts(activeActions, 'departmentOwner')
    const actionByLocation = groupCounts(activeActions, 'location')
    return {
      submittedAudits,
      inProgressAudits,
      activeActions,
      verificationPending,
      approvalPending,
      overdueActions,
      repeatFindings,
      closedThisMonth,
      averageClosureDays,
      totalNg,
      complianceScore: averageScore(submittedAudits),
      locationRanking,
      departmentRanking,
      actionByDepartment,
      actionByLocation,
    }
  }, [scopedAudits, scopedCapas])

  const shortcuts = roleProfile.navigation
    .filter(item => item.feature !== 'dashboard')
    .slice(0, 4)
    .map(item => ({
      ...item,
      icon: item.feature.includes('report') ? FileBarChart
        : item.feature.includes('verification') ? ShieldCheck
          : item.feature.includes('audit') || item.feature.includes('conduct') ? ClipboardCheck
            : item.feature.includes('financial') ? Wallet
              : Target,
      path: item.feature === 'reports' ? '/reports'
        : item.feature === 'management-review' ? '/management-review'
          : item.feature === 'verification' ? '/verification'
            : item.feature === 'audit-workbench' || item.feature === 'conduct-audit' ? '/audits/new'
              : item.feature === 'masters' ? '/masters'
                : '/action-center',
    }))

  const hasAnyData = scopedAudits.length || scopedCapas.length || stories.length

  const roleKpis = {
    'system-admin': [
      { label: 'Total Audits', value: String(scopedAudits.length), meta: 'Across all locations', icon: ClipboardCheck, tone: 'blue', path: '/audits/new' },
      { label: 'Submitted Audits', value: String(derived.submittedAudits.length), meta: 'Audit completion visibility', icon: CheckCircle2, tone: 'green', path: '/audits/new' },
      { label: 'Open Actions', value: String(derived.activeActions.length), meta: 'Workflow exposure in reports', icon: Target, tone: 'amber', path: '/reports' },
      { label: 'Overall Compliance', value: derived.complianceScore === null ? emptyMessage : `${derived.complianceScore}%`, meta: 'Submitted audits only', icon: Award, tone: 'green', path: '/reports' },
    ],
    ceo: [
      { label: 'Overall Compliance', value: derived.complianceScore === null ? emptyMessage : `${derived.complianceScore}%`, meta: 'Submitted audits only', icon: Award, tone: 'green', path: '/reports' },
      { label: 'Pending Financial Approvals', value: String(derived.approvalPending.length), meta: 'Requires executive attention', icon: Wallet, tone: 'amber', path: '/action-center' },
      { label: 'Overdue CAPA', value: String(derived.overdueActions.length), meta: 'Past target date', icon: ShieldAlert, tone: 'red', path: '/action-center' },
      { label: 'Repeat Findings', value: String(derived.repeatFindings.length), meta: 'Reoccurring issues', icon: TrendingUp, tone: 'blue', path: '/reports' },
    ],
    'group-disha': [
      { label: 'Audits Monitored', value: String(scopedAudits.length), meta: 'All visible audits', icon: ClipboardCheck, tone: 'blue', path: '/management-review' },
      { label: 'Review Queue', value: String(derived.activeActions.length), meta: 'Open governance actions', icon: Target, tone: 'amber', path: '/action-center' },
      { label: 'Financial Review Queue', value: String(derived.approvalPending.length), meta: 'Technical scrutiny needed', icon: Wallet, tone: 'amber', path: '/action-center' },
      { label: 'Verification Queue', value: String(derived.verificationPending.length), meta: 'Awaiting evidence review', icon: UserCheck, tone: 'blue', path: '/verification' },
    ],
    'group-functional-hod': [
      { label: 'Total NG', value: String(derived.totalNg), meta: 'In your department scope', icon: ShieldAlert, tone: 'blue', path: '/reports' },
      { label: 'Open CAPA', value: String(derived.activeActions.length), meta: 'Department CAPA under review', icon: Target, tone: 'amber', path: '/action-center' },
      { label: 'Overdue Actions', value: String(derived.overdueActions.length), meta: 'Escalation needed', icon: ShieldAlert, tone: 'red', path: '/action-center' },
      { label: 'Pending Review', value: String(derived.approvalPending.length), meta: 'Awaiting review or approval', icon: UserCheck, tone: 'amber', path: '/action-center' },
      { label: 'Closed This Month', value: String(derived.closedThisMonth.length), meta: 'Department closures this month', icon: CheckCircle2, tone: 'green', path: '/reports' },
      { label: 'Repeat Findings', value: String(derived.repeatFindings.length), meta: 'Department recurrence', icon: TrendingUp, tone: 'blue', path: '/reports' },
      { label: 'Avg Closure Days', value: derived.averageClosureDays === null ? emptyMessage : `${derived.averageClosureDays}d`, meta: 'Average time to close', icon: Award, tone: 'green', path: '/reports' },
    ],
    'branch-auditor': [
      { label: 'My Audits', value: String(scopedAudits.length), meta: 'Assigned audit scope', icon: ClipboardCheck, tone: 'blue', path: '/audits/new' },
      { label: 'In Progress', value: String(derived.inProgressAudits.length), meta: 'Current execution', icon: Target, tone: 'amber', path: '/audits/new' },
      { label: 'Verification Queue', value: String(derived.verificationPending.length), meta: 'Awaiting your check', icon: UserCheck, tone: 'blue', path: '/verification' },
      { label: 'Open Findings', value: String(derived.activeActions.length), meta: 'Tracked through CAPA', icon: ShieldAlert, tone: 'red', path: '/reports' },
    ],
    'location-functional-hod': [
      { label: 'Assigned Actions', value: String(derived.activeActions.length), meta: 'Open CAPA items', icon: Target, tone: 'amber', path: '/action-center' },
      { label: 'Overdue Actions', value: String(derived.overdueActions.length), meta: 'Immediate attention required', icon: ShieldAlert, tone: 'red', path: '/action-center' },
      { label: 'Financial Requests', value: String(derived.approvalPending.length), meta: 'Support requests in flow', icon: Wallet, tone: 'blue', path: '/action-center' },
      { label: 'Verification Pending', value: String(derived.verificationPending.length), meta: 'Action evidence waiting', icon: UserCheck, tone: 'green', path: '/reports' },
    ],
    viewer: [
      { label: 'Visible Audits', value: String(scopedAudits.length), meta: 'Read-only scope', icon: ClipboardCheck, tone: 'blue', path: '/reports' },
      { label: 'Compliance Snapshot', value: derived.complianceScore === null ? emptyMessage : `${derived.complianceScore}%`, meta: 'Submitted audits only', icon: Award, tone: 'green', path: '/reports' },
      { label: 'Open Findings', value: String(derived.activeActions.length), meta: 'Read-only improvement view', icon: ShieldAlert, tone: 'amber', path: '/reports' },
      { label: 'Repeat Findings', value: String(derived.repeatFindings.length), meta: 'Trend visibility', icon: TrendingUp, tone: 'blue', path: '/reports' },
    ],
  }[roleProfile.id] || []

  return <div className={`leadership-dashboard role-dashboard exec-shell role-home role-${roleProfile.dashboardTone}`}>
    <PageHeader
      eyebrow={roleProfile.dashboardEyebrow}
      title={roleProfile.dashboardName}
      description={roleProfile.description}
      action={<button className="secondary-button" onClick={() => navigate(shortcuts[0]?.path || '/reports')}>{shortcuts[0]?.label || 'Open Reports'}</button>}
    />

    <section className="card role-hero-card">
      <div className="role-hero-copy">
        <span className="eyebrow">ROLE FOCUS</span>
        <h2>{roleLabel}</h2>
        <p>{user?.employee_name ? `${user.employee_name} is signed in. ` : ''}{roleProfile.description}</p>
      </div>
      <div className="role-shortcut-grid">
        {shortcuts.map(item => <ShortcutCard key={`${item.path}-${item.label}`} title={item.label} description={item.description} icon={item.icon} onClick={() => navigate(item.path)} />)}
      </div>
    </section>

    {!hasAnyData && <section className="card exec-panel"><div className="panel-head"><div><span className="eyebrow">DASHBOARD</span><h2>{emptyMessage}</h2><p>Data will appear here as audits and actions are created.</p></div></div></section>}

    {hasAnyData && <section className="leadership-kpi-grid">
      {roleKpis.map(item => <Kpi key={item.label} label={item.label} value={item.value} meta={item.meta} icon={item.icon} tone={item.tone} onClick={() => navigate(item.path)} />)}
    </section>}

    {roleProfile.id === 'ceo' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="LOCATION RANKING" title="Top locations" rows={derived.locationRanking.slice(0, 6)} getTitle={item => item.name} getSubtitle={item => `${item.count} submitted audit(s)`} getBadge={item => `${item.score}%`} onClick={() => navigate('/reports')} />
      <ListPanel eyebrow="DEPARTMENT RANKING" title="Top departments" rows={derived.departmentRanking.slice(0, 6)} getTitle={item => item.name} getSubtitle={item => `${item.count} submitted audit(s)`} getBadge={item => `${item.score}%`} onClick={() => navigate('/reports')} />
    </section>}

    {roleProfile.id === 'group-disha' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="REVIEW QUEUE" title="Open governance actions" rows={derived.activeActions.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.departmentOwner || item.department || 'No department'} | ${item.status || 'Open'}`} getBadge={item => item.riskLevel || item.severity || 'Open'} onClick={() => navigate('/action-center')} />
      <ListPanel eyebrow="VERIFICATION" title="Awaiting verification" rows={derived.verificationPending.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.auditId || item.capaId} | ${item.departmentOwner || item.department || 'No department'}`} getBadge={item => item.status} onClick={() => navigate('/verification')} />
    </section>}

    {roleProfile.id === 'group-functional-hod' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="LOCATION-WISE COMPLIANCE" title="Department compliance by location" rows={derived.locationRanking.slice(0, 8)} getTitle={item => item.name} getSubtitle={item => `${item.count} submitted audit(s)`} getBadge={item => `${item.score}%`} onClick={() => navigate('/reports')} />
      <ListPanel eyebrow="ESCALATION" title="Overdue action list" rows={derived.overdueActions.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.departmentOwner || item.department || 'No department'} | Due ${item.targetDate || item.due || 'Not set'}`} getBadge={item => item.riskLevel || item.severity || 'Open'} onClick={() => navigate('/action-center')} />
    </section>}

    {roleProfile.id === 'branch-auditor' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="MY AUDITS" title="Assigned audits" rows={scopedAudits.slice(0, 8)} getTitle={item => item.title || item.id} getSubtitle={item => `${item.department || 'No department'} | ${item.status || 'Draft'}`} getBadge={item => Number.isFinite(Number(item.score)) ? `${item.score}%` : item.status || 'Draft'} onClick={() => navigate('/audits/new')} />
      <ListPanel eyebrow="FINDINGS" title="Recent findings requiring follow-up" rows={derived.activeActions.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.auditId || item.capaId} | ${item.departmentOwner || item.department || 'No department'}`} getBadge={item => item.status || 'Open'} onClick={() => navigate('/verification')} />
    </section>}

    {roleProfile.id === 'location-functional-hod' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="ASSIGNED ACTIONS" title="My CAPA workload" rows={derived.activeActions.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.departmentOwner || item.department || 'No department'} | ${item.status || 'Open'}`} getBadge={item => item.riskLevel || item.severity || 'Open'} onClick={() => navigate('/action-center')} />
      <ListPanel eyebrow="SUPPORT FLOW" title="Requests in collaboration or approval" rows={derived.approvalPending.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.countermeasurePlan?.approver || 'Approver pending'} | ${item.status || 'Open'}`} getBadge={item => item.status || 'Open'} onClick={() => navigate('/action-center')} />
    </section>}

    {roleProfile.id === 'system-admin' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="AUDIT CONTROL" title="Recent audits" rows={scopedAudits.slice(0, 8)} getTitle={item => item.title || item.id} getSubtitle={item => `${item.location || 'No location'} | ${item.department || 'No department'}`} getBadge={item => item.status || 'Draft'} onClick={() => navigate('/audits/new')} />
      <ListPanel eyebrow="REPORTING" title="Action exposure by location" rows={derived.actionByLocation.slice(0, 8)} getTitle={item => item.name} getSubtitle={item => `${item.count} open action(s)`} getBadge={item => item.count} onClick={() => navigate('/reports')} />
    </section>}

    {roleProfile.id === 'viewer' && <section className="exec-row exec-focus-grid role-home-grid">
      <ListPanel eyebrow="AUDIT HISTORY" title="Recent audits" rows={scopedAudits.slice(0, 8)} getTitle={item => item.title || item.id} getSubtitle={item => `${item.location || 'No location'} | ${item.status || 'Draft'}`} getBadge={item => Number.isFinite(Number(item.score)) ? `${item.score}%` : item.status || 'Draft'} onClick={() => navigate('/reports')} />
      <ListPanel eyebrow="REPORTING" title="Read-only findings view" rows={derived.activeActions.slice(0, 8)} getTitle={item => item.finding || item.issue || item.capaId} getSubtitle={item => `${item.departmentOwner || item.department || 'No department'} | ${item.status || 'Open'}`} getBadge={item => item.riskLevel || item.severity || 'Open'} onClick={() => navigate('/reports')} />
    </section>}

    {stories.length > 0 && ['group-disha', 'branch-auditor'].includes(roleProfile.id) && <Panel eyebrow="YOKOTEN" title="Shared learnings" action={<BookOpenCheck />}>
      <div className="role-compact-list">
        {stories.slice(0, 6).map(story => <button key={story.id} className="role-list-item" onClick={() => navigate('/yokoten')}>
          <div><strong>{story.improvementTitle}</strong><span>{story.approvalStatus}</span></div>
          <StatusBadge>{story.status || 'Shared'}</StatusBadge>
        </button>)}
      </div>
    </Panel>}

    {derived.complianceScore !== null && <section className="card exec-panel">
      <div className="panel-head"><div><span className="eyebrow">COMPLIANCE</span><h2>Submitted audit score</h2></div></div>
      <Progress value={derived.complianceScore} color={derived.complianceScore >= 85 ? 'green' : derived.complianceScore >= 70 ? 'amber' : 'red'} />
    </section>}
  </div>
}
