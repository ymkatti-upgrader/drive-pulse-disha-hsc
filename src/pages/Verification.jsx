import { CheckCircle2, ChevronRight, ClipboardCheck, FileCheck2, History, ShieldCheck } from 'lucide-react'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useCapas } from '../capa/CapaContext'
import { PageHeader, StatusBadge } from '../components/UI'

export default function Verification() {
  const navigate = useNavigate()
  const { capas } = useCapas()
  const queue = capas.filter(item => ['Evidence Uploaded', 'Verification Pending'].includes(item.status))
  const [selectedId, setSelectedId] = useState(queue[0]?.capaId || '')
  const selected = queue.find(item => item.capaId === selectedId) || queue[0]

  return <>
    <PageHeader eyebrow="AUDITOR WORKBENCH" title="Implementation Verification" description="Review evidence, assess effectiveness, and confirm sustainable closure." />
    {queue.length === 0 ? <section className="card verification-queue-empty"><CheckCircle2 /><h2>No actions awaiting verification</h2><p>Improvement Actions will appear here after implementation evidence is uploaded.</p></section> : <div className="verification-layout">
      <section className="card verification-list"><div className="panel-head"><div><span className="eyebrow">QUEUE</span><h2>Awaiting review</h2></div><span className="count-badge">{queue.length}</span></div>{queue.map(item => <button className={selected?.capaId === item.capaId ? 'active' : ''} onClick={() => setSelectedId(item.capaId)} key={item.capaId}><span className="verify-icon"><ShieldCheck /></span><div><strong>{item.capaId}</strong><b>{item.finding}</b><small>{item.departmentOwner} | {item.riskLevel} Risk</small></div><ChevronRight size={17} /></button>)}</section>
      <section className="card verification-queue-detail">
        <div className="review-head"><div><div className="id-line"><span className="eyebrow">{selected.capaId}</span><StatusBadge>{selected.status}</StatusBadge></div><h2>{selected.finding}</h2><p>{selected.auditId} | {selected.dishaQuestionNo} | {selected.departmentOwner}</p></div><span className={`severity ${String(selected.riskLevel).toLowerCase()}`}>{selected.riskLevel}</span></div>
        <div className="verification-readiness"><div><FileCheck2 /><span><small>Implementation</small><strong>{selected.countermeasurePlan?.implementationStatus || 'Pending'}</strong></span></div><div><ClipboardCheck /><span><small>Evidence Review</small><strong>{selected.evidenceUploaded ? 'Evidence uploaded' : 'Evidence pending'}</strong></span></div><div><History /><span><small>Previous Verifications</small><strong>{selected.verificationHistory?.length || 0}</strong></span></div></div>
        <div className="verification-queue-summary"><div><span>Permanent Countermeasure</span><p>{selected.countermeasurePlan?.permanent || 'Permanent countermeasure has not been recorded.'}</p></div><div><span>Expected Result</span><p>{selected.countermeasurePlan?.expectedResult || 'Expected result has not been recorded.'}</p></div><div><span>Target Completion</span><p>{selected.countermeasurePlan?.targetCompletionDate || selected.targetDate || 'Not set'}</p></div></div>
        <button className="primary-button verification-open-button" onClick={() => navigate(`/improvements/${selected.capaId}`)}><ShieldCheck size={18} /> Open Verification</button>
      </section>
    </div>}
  </>
}
