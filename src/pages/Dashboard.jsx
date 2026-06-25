import { Award, BookOpenCheck, CheckCircle2, ClipboardCheck, ShieldAlert, Target, UserCheck } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { isInProgressAuditStatus, useAudits } from '../audits/AuditContext'
import { canManageDishaWorkflow, filterByUserAccess, getPrimaryRole, useAuth } from '../auth/AuthContext'
import { PageHeader, Progress } from '../components/UI'
import { useCapas } from '../capa/CapaContext'
import { useYokoten } from '../yokoten/YokotenContext'

const emptyMessage = 'No data yet'

function averageScore(rows) {
  const scored = rows.filter(item => Number.isFinite(Number(item.score)))
  if (!scored.length) return null
  return Math.round(scored.reduce((sum, item) => sum + Number(item.score), 0) / scored.length)
}

function Kpi({ label, value, meta, icon: Icon, tone, onClick }) {
  return <button className={`leadership-kpi ${tone || ''}`} onClick={onClick}>
    <span className="leadership-kpi-icon"><Icon /></span>
    <div><span>{label}</span><strong>{value}</strong><small>{meta}</small></div>
  </button>
}

function EmptyPanel({ title }) {
  return <section className="card exec-panel">
    <div className="panel-head"><div><span className="eyebrow">{title}</span><h2>{emptyMessage}</h2><p>Submitted audits only</p></div></div>
  </section>
}

function ListPanel({ title, rows, getTitle, getSubtitle, onClick }) {
  if (!rows.length) return <EmptyPanel title={title} />
  return <section className="card exec-panel">
    <div className="panel-head"><div><span className="eyebrow">{title}</span><h2>{title}</h2></div></div>
    <div className="role-compact-list">
      {rows.map(item => <button key={item.id || item.capaId || item.auditId} className="role-list-item" onClick={() => onClick(item)}>
        <div><strong>{getTitle(item)}</strong><span>{getSubtitle(item)}</span></div>
      </button>)}
    </div>
  </section>
}

export default function Dashboard() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits } = useAudits()
  const { capas } = useCapas()
  const { stories } = useYokoten()

  const canSeeAllWorkflowData = canManageDishaWorkflow(user)
  const scopedAudits = canSeeAllWorkflowData ? audits : filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  const scopedCapas = canSeeAllWorkflowData ? capas : filterByUserAccess(user, capas, item => ({ department: item.departmentOwner || item.department || item.area, location: item.location || item.locationAspect }))
  const activeActions = scopedCapas.filter(item => !['Closed', 'Yokoten Shared', 'Cancelled'].includes(item.status))
  const submittedAudits = scopedAudits.filter(item => item.status === 'Submitted')
  const inProgressAudits = scopedAudits.filter(item => isInProgressAuditStatus(item.status))
  const verificationPending = scopedCapas.filter(item => item.status === 'Verification Pending')
  const criticalActions = activeActions.filter(item => item.riskLevel === 'Critical')
  const repeatFindings = activeActions.filter(item => item.repeatFinding)
  const complianceScore = averageScore(submittedAudits)
  const hasAnyData = scopedAudits.length || scopedCapas.length || stories.length

  return <div className="leadership-dashboard role-dashboard exec-shell">
    <PageHeader
      eyebrow="ROLE-BASED HOME"
      title={`${getPrimaryRole(user) || 'User'} Dashboard`}
      description={user?.employee_name || user?.name || user?.full_name || user?.mobile_no || user?.mobile ? `Signed in as ${user?.employee_name || user?.name || user?.full_name || user?.mobile_no || user?.mobile}` : emptyMessage}
      action={<button className="secondary-button" onClick={() => navigate('/reports')}>View Reports</button>}
    />

    {!hasAnyData && <section className="card exec-panel"><div className="panel-head"><div><span className="eyebrow">DASHBOARD</span><h2>{emptyMessage}</h2><p>Submitted audits only</p></div></div></section>}

    {hasAnyData && <section className="leadership-kpi-grid">
      <Kpi label="Compliance Score" value={complianceScore === null ? emptyMessage : `${complianceScore}%`} meta="Submitted audits only" icon={Award} tone="green" onClick={() => navigate('/reports')} />
      <Kpi label="Total Audits" value={String(scopedAudits.length)} meta="Created audits" icon={ClipboardCheck} tone="blue" onClick={() => navigate('/audits/new')} />
      <Kpi label="Submitted Audits" value={String(submittedAudits.length)} meta="Completed submissions" icon={CheckCircle2} tone="green" onClick={() => navigate('/audits/new')} />
      <Kpi label="In-progress Audits" value={String(inProgressAudits.length)} meta="Currently open" icon={Target} tone="amber" onClick={() => navigate('/audits/new')} />
      <Kpi label="Critical Findings" value={String(criticalActions.length)} meta="From real improvement actions" icon={ShieldAlert} tone="red" onClick={() => navigate('/improvements')} />
      <Kpi label="Verification Pending" value={String(verificationPending.length)} meta="Awaiting review" icon={UserCheck} tone="blue" onClick={() => navigate('/verification')} />
    </section>}

    {hasAnyData && <section className="exec-row exec-focus-grid">
      <ListPanel
        title="Recent Audits"
        rows={scopedAudits.slice(0, 8)}
        getTitle={item => item.title || item.id}
        getSubtitle={item => `${item.id} | ${item.status || 'Draft'}${Number.isFinite(Number(item.score)) ? ` | ${item.score}%` : ''}`}
        onClick={item => isInProgressAuditStatus(item.status) ? navigate(`/audits/${item.id}/conduct`) : navigate('/audits/new')}
      />
      <ListPanel
        title="Open Improvement Actions"
        rows={activeActions.slice(0, 8)}
        getTitle={item => item.finding || item.issue || item.capaId}
        getSubtitle={item => `${item.capaId || item.id} | ${item.status || 'Open'} | ${item.riskLevel || item.severity || 'Unrated'}`}
        onClick={item => navigate(`/improvements/${item.capaId || item.id}`)}
      />
    </section>}

    {hasAnyData && <section className="exec-row exec-focus-grid">
      <ListPanel
        title="Repeat Findings"
        rows={repeatFindings.slice(0, 8)}
        getTitle={item => item.finding || item.issue || item.capaId}
        getSubtitle={item => `${item.capaId || item.id} | ${item.departmentOwner || item.department || 'No department'}`}
        onClick={item => navigate(`/improvements/${item.capaId || item.id}`)}
      />
      <section className="card exec-panel">
        <div className="panel-head"><div><span className="eyebrow">YOKOTEN</span><h2>Shared learnings</h2></div><BookOpenCheck /></div>
        {stories.length ? <div className="role-compact-list">{stories.slice(0, 8).map(story => <button key={story.id} className="role-list-item" onClick={() => navigate('/yokoten')}><div><strong>{story.improvementTitle}</strong><span>{story.approvalStatus}</span></div></button>)}</div> : <div className="role-empty">{emptyMessage}</div>}
      </section>
    </section>}

    {complianceScore !== null && <section className="card exec-panel">
      <div className="panel-head"><div><span className="eyebrow">COMPLIANCE</span><h2>Submitted audit score</h2></div></div>
      <Progress value={complianceScore} color={complianceScore >= 85 ? 'green' : complianceScore >= 70 ? 'amber' : 'red'} />
    </section>}
  </div>
}
