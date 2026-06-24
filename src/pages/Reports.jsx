import { Download } from 'lucide-react'
import { useAudits } from '../audits/AuditContext'
import { filterByUserAccess, useAuth } from '../auth/AuthContext'
import { useCapas } from '../capa/CapaContext'
import { PageHeader, Progress, StatusBadge } from '../components/UI'

const emptyMessage = 'No data available yet.'

function averageScore(rows) {
  const scored = rows.filter(item => Number.isFinite(Number(item.score)))
  if (!scored.length) return null
  return Math.round(scored.reduce((sum, item) => sum + Number(item.score), 0) / scored.length)
}

function groupAuditScores(audits, key) {
  const groups = new Map()
  audits.forEach(audit => {
    const name = audit[key] || 'Unassigned'
    if (!groups.has(name)) groups.set(name, [])
    groups.get(name).push(audit)
  })
  return [...groups.entries()].map(([name, rows]) => ({ name, count: rows.length, score: averageScore(rows) }))
}

export default function Reports() {
  const { user } = useAuth()
  const { audits } = useAudits()
  const { capas } = useCapas()
  const scopedAudits = filterByUserAccess(user, audits, item => ({ department: item.department, location: item.location }))
  const scopedCapas = filterByUserAccess(user, capas, item => ({ department: item.departmentOwner || item.department || item.area, location: item.location || item.locationAspect }))
  const submittedAudits = scopedAudits.filter(item => item.status === 'Submitted')
  const compliance = averageScore(submittedAudits)
  const departmentScores = groupAuditScores(submittedAudits, 'department')
  const openActions = scopedCapas.filter(item => !['Closed', 'Yokoten Shared', 'Cancelled'].includes(item.status))
  const hasData = scopedAudits.length || scopedCapas.length

  return <>
    <PageHeader eyebrow="ANALYTICS" title="Reports & insights" description="Measure compliance, improvement performance and recurring risk." action={<button className="secondary-button"><Download size={17} /> Export report</button>} />

    {!hasData ? <section className="card panel"><h2>{emptyMessage}</h2></section> : <div className="reports-grid">
      <section className="card panel">
        <div className="panel-head"><div><span className="eyebrow">OVERALL COMPLIANCE</span><h2>{compliance === null ? emptyMessage : `${compliance}%`}</h2></div></div>
        {compliance !== null && <Progress value={compliance} color={compliance >= 85 ? 'green' : compliance >= 70 ? 'amber' : 'red'} />}
      </section>

      <section className="card panel">
        <div className="panel-head"><div><span className="eyebrow">BY DEPARTMENT</span><h2>Compliance score</h2></div></div>
        {departmentScores.length ? <div className="report-depts">{departmentScores.map(item => <div key={item.name}><div><strong>{item.name}</strong><span>{item.score === null ? emptyMessage : `${item.score}%`}</span></div>{item.score !== null && <Progress value={item.score} color={item.score >= 85 ? 'green' : item.score >= 70 ? 'amber' : 'red'} />}</div>)}</div> : <p>{emptyMessage}</p>}
      </section>

      <section className="card panel">
        <div className="panel-head"><div><span className="eyebrow">IMPROVEMENT PERFORMANCE</span><h2>Open actions</h2></div></div>
        <div className="donut-wrap"><div><strong>{openActions.length}</strong><span>Open</span></div></div>
      </section>

      <section className="card panel span-2">
        <div className="panel-head"><div><span className="eyebrow">FINDINGS</span><h2>Current improvement actions</h2></div></div>
        {openActions.length ? <div className="risk-table">
          <div className="risk-head"><span>Finding</span><span>Department</span><span>Status</span><span>Risk</span><span>Audit</span></div>
          {openActions.slice(0, 10).map(item => <div key={item.capaId || item.id}><strong>{item.finding || item.issue}</strong><span>{item.departmentOwner || item.department || '-'}</span><b>{item.status}</b><StatusBadge>{item.riskLevel || item.severity || 'Unrated'}</StatusBadge><span>{item.auditId || item.audit || '-'}</span></div>)}
        </div> : <p>{emptyMessage}</p>}
      </section>
    </div>}
  </>
}
