import { BarChart3, CalendarDays, FileDown, Sparkles, Target, TriangleAlert, UserCheck } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuditChecklist } from '../audits/useAuditChecklist'
import { useAudits } from '../audits/AuditContext'
import { getPrimaryRole, useAuth } from '../auth/AuthContext'
import { useCapas } from '../capa/CapaContext'
import { PageHeader, Progress, StatusBadge } from '../components/UI'
import { useYokoten } from '../yokoten/YokotenContext'

const emptyMessage = 'No data available yet.'

function averageScore(rows) {
  const scored = rows.filter(item => Number.isFinite(Number(item.score)))
  if (!scored.length) return null
  return Math.round(scored.reduce((sum, item) => sum + Number(item.score), 0) / scored.length)
}

function toneClass(value) {
  if (value === null || value === undefined) return 'blue'
  if (value >= 90) return 'green'
  if (value >= 80) return 'blue'
  if (value >= 70) return 'amber'
  return 'red'
}

function MetricTile({ label, value, helper, tone = 'blue', icon: Icon }) {
  return <div className={`card mgmt-metric ${tone}`}>
    <div className="mgmt-metric-head"><span>{label}</span>{Icon && <Icon size={18} />}</div>
    <strong>{value}</strong>
    {helper && <small>{helper}</small>}
  </div>
}

function groupCounts(rows, key) {
  const groups = new Map()
  rows.forEach(row => {
    const name = row[key] || 'Unassigned'
    groups.set(name, (groups.get(name) || 0) + 1)
  })
  return [...groups.entries()].map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count)
}

export default function ManagementReviewCenter() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { audits } = useAudits()
  const { capas } = useCapas()
  const { stories } = useYokoten()
  const { checklist, loading: checklistLoading, error: checklistError } = useAuditChecklist()
  const [printFriendly, setPrintFriendly] = useState(false)

  const review = useMemo(() => {
    const submittedAudits = audits.filter(item => item.status === 'Submitted')
    const activeCapas = capas.filter(item => item.status !== 'Closed' && item.status !== 'Cancelled' && item.status !== 'Yokoten Shared')
    const verificationPending = capas.filter(item => ['Evidence Uploaded', 'Verification Pending'].includes(item.status))
    const criticalFindings = activeCapas.filter(item => item.riskLevel === 'Critical' || item.severity === 'Critical')
    const repeatFindings = activeCapas.filter(item => item.repeatFinding)
    return {
      submittedAudits,
      activeCapas,
      verificationPending,
      criticalFindings,
      repeatFindings,
      overallCompliance: averageScore(submittedAudits),
      checklistCount: checklist.length,
      departmentFindings: groupCounts(activeCapas, 'departmentOwner'),
    }
  }, [audits, capas, checklist.length])

  const hasData = audits.length || capas.length || checklist.length || stories.length

  if (checklistLoading) {
    return <div className="mgmt-review-page"><section className="card mgmt-panel"><strong>Loading audit checklist...</strong></section></div>
  }

  return <div className={`mgmt-review-page ${printFriendly ? 'print-friendly' : ''}`}>
    <PageHeader
      eyebrow="MANAGEMENT REVIEW CENTER"
      title="Management Review Center"
      description={user ? `Viewing as ${getPrimaryRole(user)}.` : 'Executive review based on available real data.'}
      action={<div className="mgmt-toolbar">
        <button className={`secondary-button ${printFriendly ? 'active' : ''}`} onClick={() => setPrintFriendly(current => !current)}>Print Friendly View</button>
        <button className="secondary-button" onClick={() => window.print()}><FileDown size={16} /> Export PDF</button>
      </div>}
    />

    {!hasData ? <section className="card mgmt-panel"><strong>{emptyMessage}</strong>{checklistError && <p>{checklistError}</p>}</section> : <>
      <section className="mgmt-summary-grid">
        <MetricTile label="Overall Compliance %" value={review.overallCompliance === null ? emptyMessage : `${review.overallCompliance}%`} helper="Submitted audits only" tone={toneClass(review.overallCompliance)} icon={BarChart3} />
        <MetricTile label="Imported Checklist Rows" value={review.checklistCount} helper={review.checklistCount ? 'From audit_checklist_master' : 'No audit checklist imported.'} tone="blue" icon={CalendarDays} />
        <MetricTile label="Critical Findings" value={review.criticalFindings.length} helper="Open improvement actions" tone="red" icon={TriangleAlert} />
        <MetricTile label="Open Improvement Actions" value={review.activeCapas.length} helper="Not closed or cancelled" tone="amber" icon={Target} />
        <MetricTile label="Verification Pending" value={review.verificationPending.length} helper="Evidence uploaded or verification pending" tone="blue" icon={UserCheck} />
        <MetricTile label="Yokoten Stories" value={stories.length} helper="Current library records" tone="green" icon={Sparkles} />
      </section>

      <div className="mgmt-grid">
        <section className="card mgmt-panel">
          <div className="mgmt-section-head"><div><span className="eyebrow">AUDIT SUMMARY</span><h2>Submitted audits</h2></div></div>
          {review.submittedAudits.length ? <div className="mgmt-rank-list">{review.submittedAudits.map(item => <button key={item.id} className="mgmt-rank-row" onClick={() => navigate('/reports')}>
            <div className="mgmt-rank-main"><div><strong>{item.title || item.id}</strong><small>{item.department || 'No department'} | {item.status}</small></div>{Number.isFinite(Number(item.score)) && <Progress value={Number(item.score)} color={toneClass(Number(item.score))} />}</div>
            <div className="mgmt-rank-meta"><strong>{Number.isFinite(Number(item.score)) ? `${item.score}%` : '-'}</strong></div>
          </button>)}</div> : <p>{emptyMessage}</p>}
        </section>

        <section className="card mgmt-panel">
          <div className="mgmt-section-head"><div><span className="eyebrow">FINDINGS</span><h2>Open actions by department</h2></div></div>
          {review.departmentFindings.length ? <div className="mgmt-rank-list">{review.departmentFindings.map(item => <button key={item.name} className="mgmt-rank-row" onClick={() => navigate('/improvements')}>
            <div className="mgmt-rank-main"><div><strong>{item.name}</strong><small>{item.count} open action(s)</small></div></div>
            <div className="mgmt-rank-meta"><strong>{item.count}</strong></div>
          </button>)}</div> : <p>{emptyMessage}</p>}
        </section>

        <section className="card mgmt-panel">
          <div className="mgmt-section-head"><div><span className="eyebrow">REPEAT FINDINGS</span><h2>Repeat finding analysis</h2></div></div>
          {review.repeatFindings.length ? <div className="mgmt-analysis-list">{review.repeatFindings.map(item => <button key={item.capaId || item.id} className="mgmt-analysis-row" onClick={() => navigate(`/improvements/${item.capaId || item.id}`)}>
            <div><strong>{item.finding || item.issue}</strong><p>{item.departmentOwner || item.department || 'No department'}</p></div>
            <StatusBadge>{item.riskLevel || item.severity || 'Unrated'}</StatusBadge>
          </button>)}</div> : <p>{emptyMessage}</p>}
        </section>
      </div>
    </>}
  </div>
}
