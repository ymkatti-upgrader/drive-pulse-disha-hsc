import { ArrowLeft, Bot, CalendarDays, CheckCircle2, CircleDollarSign, ClipboardCheck, FileText, History, MapPin, Paperclip, RotateCcw, Save, Share2, ShieldAlert, Sparkles, UserRound, Users, X } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { StatusBadge } from '../components/UI'
import { useCapas } from '../capa/CapaContext'
import { useYokoten } from '../yokoten/YokotenContext'

const improvementStages = ['Observation', 'Gap Identified', 'Root Cause', 'Countermeasure', 'Verification', 'Yokoten']
const statusStage = {
  Open: 1,
  'Root Cause Analysis': 2,
  'Countermeasure Planned': 3,
  'Approval Pending': 3,
  'Implementation In Progress': 3,
  'Evidence Uploaded': 4,
  'Verification Pending': 4,
  Closed: 4,
  'Yokoten Shared': 5,
  Cancelled: 1,
}

function createMockAiSenseiDraft(capa = {}) {
  const currentCondition = capa.currentCondition || capa.auditorRemarks || capa.finding || ''
  const gapIdentified = capa.gapIdentified || capa.auditorRemarks || 'Operational gap requires clearer control and standard adherence.'
  const auditorRemarks = capa.auditorRemarks || currentCondition || gapIdentified
  const department = capa.departmentOwner || capa.area || ''
  const riskLevel = capa.riskLevel || 'Medium'
  const guestImpact = capa.guestExperienceImpact || 'Medium'
  const previousWhys = Array.isArray(capa.fiveWhys) ? capa.fiveWhys.filter(why => why && why.trim()) : []
  const previousWhySummary = previousWhys.length
    ? previousWhys.map((why, index) => `Why ${index + 1}: ${why}`).join('\n')
    : 'No previous 5 Why inputs available.'

  const suggestedFiveWhys = [
    previousWhys[0] || `Why did the gap appear in ${capa.area || 'this process'}? Because the standard was not followed consistently.`,
    previousWhys[1] || 'Why was the standard not followed consistently? Because the control point is not visible or reinforced in daily work.',
    previousWhys[2] || 'Why is the control point not visible? Because the process reminder and ownership are not clearly assigned.',
    previousWhys[3] || 'Why is ownership unclear? Because the routine check and escalation mechanism are not embedded in the workflow.',
    previousWhys[4] || 'Why is escalation not embedded? Because the standard action review cadence is not yet sustained.',
  ]

  const gapSentence = gapIdentified.replace(/\.$/, '')
  const rootCause = `The issue appears to stem from ${gapSentence.toLowerCase()} with inconsistent execution in ${capa.area || 'the current process'}.`
  const temporaryCountermeasure = `Contain the gap immediately in ${capa.area || 'the affected area'} by reinforcing the current standard, confirming daily checks, and adding supervisor review until closure.`
  const permanentCountermeasure = `Update the standard operating method for ${capa.area || 'the process'}, assign a clear owner in ${department || 'the department'}, and add a routine control to prevent recurrence.`
  const riskGuestImpactNote = `Risk level is ${riskLevel}. Guest impact is ${guestImpact}. Immediate attention is required if service quality, safety, or complaint exposure can increase.`
  const yokotenOpportunity = `If this control is effective in ${capa.area || 'this area'}, the same standard can be shared with similar locations through Yokoten coaching and a short best-practice note.`
  const managementSummary = `Improvement action ${capa.capaId} requires HOD/PIC review. The likely root cause is linked to the observed gap in ${capa.area || 'the operation'}, and the proposed countermeasure should be validated before implementation.`

  return {
    possibleRootCause: rootCause,
    suggestedFiveWhys,
    temporaryCountermeasure,
    permanentCountermeasure,
    riskGuestImpactNote,
    yokotenOpportunity,
    managementSummary,
    context: {
      evaluationItem: capa.finding || '',
      currentCondition,
      gapIdentified,
      auditorRemarks,
      area: capa.area || '',
      department,
      riskLevel,
      guestImpact,
      previousWhySummary,
    },
  }
}

function formatAiSenseiSavedAt(timestamp) {
  if (!timestamp) return 'Not saved'
  return new Intl.DateTimeFormat('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(timestamp))
}

function createAiSenseiHistoryRecord(capa = {}, draft = {}) {
  const savedAt = new Date().toISOString()
  return {
    id: `AI-${Date.now()}`,
    savedAt,
    savedLabel: formatAiSenseiSavedAt(savedAt),
    generatedBy: 'Mock Auditor',
    savedStatus: 'Saved',
    reviewStatus: 'Draft',
    reviewedBy: '',
    reviewDate: '',
    finalDecision: 'Pending',
    editedAfterSave: false,
    aiSuggestionUseful: '',
    aiUsefulnessRating: '',
    aiRatingReason: '',
    aiSuggestionImplemented: '',
    finalActionChangedByHuman: '',
    findingGapSummary: [draft.context?.evaluationItem || capa.finding || '', draft.context?.gapIdentified || capa.gapIdentified || ''].filter(Boolean).join(' | '),
    possibleRootCause: draft.possibleRootCause || '',
    suggestedFiveWhys: Array.isArray(draft.suggestedFiveWhys) ? draft.suggestedFiveWhys : ['', '', '', '', ''],
    temporaryCountermeasure: draft.temporaryCountermeasure || '',
    permanentCountermeasure: draft.permanentCountermeasure || '',
    riskGuestImpactNote: draft.riskGuestImpactNote || '',
    yokotenOpportunity: draft.yokotenOpportunity || '',
    managementSummary: draft.managementSummary || '',
    context: draft.context || {},
  }
}

export default function CapaDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { capas, statusOptions, updateCapaStatus, updateImprovementAnalysis, submitVerification } = useCapas()
  const { stories, upsertStory } = useYokoten()
  const capa = capas.find(item => item.capaId === id)
  const existingYokoten = stories.find(item => item.sourceImprovementId === id)
  const [analysisSaved, setAnalysisSaved] = useState(false)
  const [analysisError, setAnalysisError] = useState('')
  const [verificationError, setVerificationError] = useState('')
  const [verificationSaved, setVerificationSaved] = useState('')
  const [yokotenError, setYokotenError] = useState('')
  const [yokotenSaved, setYokotenSaved] = useState(false)
  const [aiSenseiOpen, setAiSenseiOpen] = useState(false)
  const [aiSenseiSaved, setAiSenseiSaved] = useState(false)
  const [aiSenseiError, setAiSenseiError] = useState('')
  const [aiSenseiDraft, setAiSenseiDraft] = useState(() => createMockAiSenseiDraft(capa))
  const [aiSenseiSelected, setAiSenseiSelected] = useState(null)
  const [aiSenseiEditingEntryId, setAiSenseiEditingEntryId] = useState(null)
  const [yokoten, setYokoten] = useState(() => existingYokoten || {
    sourceImprovementId: id,
    improvementTitle: capa?.finding || '',
    originalFinding: capa?.finding || '',
    countermeasureImplemented: capa?.countermeasurePlan?.permanent || '',
    benefitsAchieved: capa?.countermeasurePlan?.expectedResult || '',
    appliedTo: [],
    attachments: [],
    approvalStatus: 'Draft',
    department: capa?.departmentOwner || capa?.area || '',
    location: capa?.locationAspect || 'Dealership',
    category: capa?.classification || 'Process',
  })

  useEffect(() => {
    setAiSenseiDraft(createMockAiSenseiDraft(capa))
    setAiSenseiOpen(false)
    setAiSenseiSaved(false)
    setAiSenseiError('')
    setAiSenseiSelected(null)
    setAiSenseiEditingEntryId(null)
  }, [capa?.capaId])

  useEffect(() => {
    function handleKeyDown(event) {
      if (event.key === 'Escape') setAiSenseiOpen(false)
    }
    if (aiSenseiOpen) window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [aiSenseiOpen])

  if (!capa) return <div className="card capa-not-found"><ShieldAlert /><h1>Improvement action not found</h1><button className="primary-button" onClick={() => navigate('/improvements')}>Back to Improvement Tracker</button></div>

  const fiveWhys = Array.isArray(capa.fiveWhys) ? capa.fiveWhys : ['', '', '', '', '']
  const answeredWhys = fiveWhys.filter(value => value.trim()).length
  const whyCompletion = answeredWhys * 20
  const whyRule = 'Optional: 5 Why analysis'
  const plan = capa.countermeasurePlan || { temporary: '', permanent: '', responsiblePerson: '', supportingDepartment: '', targetCompletionDate: '', estimatedCost: '', approvalRequired: 'No', approver: '', expectedResult: '', implementationStatus: 'Planned' }
  const implementationStages = ['Planned', 'In Progress', 'Completed']
  const implementationIndex = implementationStages.indexOf(plan.implementationStatus)
  const verification = capa.verification || { implementationVerified: false, effectivenessRating: '', comments: '', evidenceReview: '' }
  const verificationHistory = capa.verificationHistory || []
  const effectivenessOptions = ['Effective', 'Partially Effective', 'Not Effective']
  const yokotenApplications = ['Sales', 'Service', 'Parts', 'HR', 'CRM', 'Body & Paint', 'U-Trust', 'All Locations']
  const aiSenseiHistory = Array.isArray(capa.aiSenseiHistory) ? capa.aiSenseiHistory : []
  const aiSummary = aiSenseiHistory.reduce((acc, entry) => {
    acc.total += 1
    if (['Accepted', 'Edited & Accepted'].includes(entry.reviewStatus)) acc.accepted += 1
    if (entry.reviewStatus === 'Rejected') acc.rejected += 1
    const rating = Number(entry.aiUsefulnessRating)
    if (Number.isFinite(rating) && rating > 0) {
      acc.ratingTotal += rating
      acc.ratingCount += 1
    }
    if (String(entry.aiSuggestionUseful).toLowerCase() === 'yes' && String(entry.aiSuggestionImplemented).toLowerCase() === 'yes') acc.assisted += 1
    return acc
  }, { total: 0, accepted: 0, rejected: 0, ratingTotal: 0, ratingCount: 0, assisted: 0 })
  const aiAverageRating = aiSummary.ratingCount ? (aiSummary.ratingTotal / aiSummary.ratingCount).toFixed(1) : '0.0'

  function updateWhy(index, value) {
    const next = fiveWhys.map((why, whyIndex) => whyIndex === index ? value : why)
    updateImprovementAnalysis(capa.capaId, { fiveWhys: next })
    setAnalysisSaved(false)
    setAnalysisError('')
  }

  function saveAnalysis() {
    updateImprovementAnalysis(capa.capaId, { rootCause: capa.rootCauseSummary || capa.rootCause || '' })
    setAnalysisError('')
    setAnalysisSaved(true)
    window.setTimeout(() => setAnalysisSaved(false), 1800)
  }

  function updatePlan(field, value) {
    updateImprovementAnalysis(capa.capaId, { countermeasurePlan: { ...plan, [field]: value, ...(field === 'approvalRequired' && value === 'No' ? { approver: '' } : {}) } })
  }

  function updateVerification(field, value) {
    updateImprovementAnalysis(capa.capaId, { verification: { ...verification, [field]: value } })
    setVerificationError('')
    setVerificationSaved('')
  }

  function verifyImplementation() {
    if (!verification.implementationVerified || !verification.effectivenessRating || !verification.comments.trim() || !verification.evidenceReview.trim()) {
      setVerificationError('Confirm implementation and complete the rating, comments, and evidence review before submitting verification.')
      setVerificationSaved('')
      return
    }

    submitVerification(capa.capaId, verification)
    setVerificationError('')
    setVerificationSaved(verification.effectivenessRating === 'Not Effective'
      ? 'Verification recorded. The Improvement Action has been reopened at Countermeasure Planned.'
      : `Verification recorded. Status updated to ${verification.effectivenessRating === 'Effective' ? 'Closed' : 'Verification Pending'}.`)
  }

  function updateYokoten(field, value) {
    setYokoten(current => ({ ...current, [field]: value }))
    setYokotenError('')
    setYokotenSaved(false)
  }

  function toggleYokotenApplication(option) {
    setYokoten(current => ({ ...current, appliedTo: current.appliedTo.includes(option) ? current.appliedTo.filter(item => item !== option) : [...current.appliedTo, option] }))
    setYokotenError('')
    setYokotenSaved(false)
  }

  function saveYokoten() {
    if (!yokoten.improvementTitle.trim() || !yokoten.originalFinding.trim() || !yokoten.countermeasureImplemented.trim() || !yokoten.benefitsAchieved.trim() || yokoten.appliedTo.length === 0) {
      setYokotenError('Complete the title, finding, countermeasure, benefits, and at least one applicable area.')
      setYokotenSaved(false)
      return
    }
    upsertStory(yokoten)
    updateImprovementAnalysis(capa.capaId, { yokotenNote: yokoten.benefitsAchieved })
    if (yokoten.approvalStatus === 'Approved') updateCapaStatus(capa.capaId, 'Yokoten Shared')
    setYokotenError('')
    setYokotenSaved(true)
  }

  function generateAiSensei() {
    setAiSenseiDraft(createMockAiSenseiDraft(capa))
    setAiSenseiOpen(true)
    setAiSenseiError('')
    setAiSenseiSaved(false)
  }

  function updateAiSenseiField(field, value) {
    setAiSenseiDraft(current => ({ ...current, [field]: value }))
    setAiSenseiSaved(false)
    setAiSenseiError('')
  }

  function updateAiSenseiWhy(index, value) {
    setAiSenseiDraft(current => ({
      ...current,
      suggestedFiveWhys: current.suggestedFiveWhys.map((why, whyIndex) => whyIndex === index ? value : why),
    }))
    setAiSenseiSaved(false)
    setAiSenseiError('')
  }

  function saveAiSensei() {
    const draft = aiSenseiDraft
    if (!draft.possibleRootCause.trim() || !draft.temporaryCountermeasure.trim() || !draft.permanentCountermeasure.trim() || !draft.managementSummary.trim()) {
      setAiSenseiError('Complete the AI Sensei suggestions before saving them to the Improvement Action.')
      setAiSenseiSaved(false)
      return
    }

    const existingEntry = aiSenseiEditingEntryId ? aiSenseiHistory.find(entry => entry.id === aiSenseiEditingEntryId) : null
    const historyRecord = existingEntry
      ? {
          ...existingEntry,
          ...draft,
          savedStatus: 'Saved',
          editedAfterSave: true,
          reviewStatus: existingEntry.reviewStatus || 'Draft',
          reviewedBy: existingEntry.reviewedBy || '',
          reviewDate: existingEntry.reviewDate || '',
          finalDecision: existingEntry.finalDecision || 'Pending',
          savedLabel: existingEntry.savedLabel || formatAiSenseiSavedAt(existingEntry.savedAt || new Date().toISOString()),
        }
      : createAiSenseiHistoryRecord(capa, draft)

    const nextHistory = existingEntry
      ? aiSenseiHistory.map(entry => entry.id === existingEntry.id ? historyRecord : entry)
      : [historyRecord, ...aiSenseiHistory]
    updateImprovementAnalysis(capa.capaId, {
      rootCause: draft.possibleRootCause,
      rootCauseSummary: draft.possibleRootCause,
      fiveWhys: draft.suggestedFiveWhys,
      countermeasure: draft.permanentCountermeasure,
      countermeasurePlan: { ...plan, temporary: draft.temporaryCountermeasure, permanent: draft.permanentCountermeasure },
      yokotenNote: draft.yokotenOpportunity,
      aiSenseiSummary: draft.managementSummary,
      aiSenseiContext: draft.context,
      aiSenseiUpdatedAt: new Date().toISOString(),
      aiSenseiHistory: nextHistory,
    })
    setAiSenseiError('')
    setAiSenseiSaved(true)
    setAiSenseiSelected(historyRecord)
    setAiSenseiEditingEntryId(null)
    window.setTimeout(() => setAiSenseiSaved(false), 1800)
  }

  function openAiSenseiFromHistory(entry) {
    setAiSenseiDraft({
      possibleRootCause: entry.possibleRootCause || '',
      suggestedFiveWhys: Array.isArray(entry.suggestedFiveWhys) ? entry.suggestedFiveWhys : ['', '', '', '', ''],
      temporaryCountermeasure: entry.temporaryCountermeasure || '',
      permanentCountermeasure: entry.permanentCountermeasure || '',
      riskGuestImpactNote: entry.riskGuestImpactNote || '',
      yokotenOpportunity: entry.yokotenOpportunity || '',
      managementSummary: entry.managementSummary || '',
      context: entry.context || createMockAiSenseiDraft(capa).context,
    })
    setAiSenseiOpen(true)
    setAiSenseiError('')
    setAiSenseiSaved(false)
    setAiSenseiEditingEntryId(entry.id)
  }

  function updateAiSenseiHistory(entryId, updater) {
    const nextHistory = aiSenseiHistory.map(entry => (entry.id === entryId ? updater(entry) : entry))
    updateImprovementAnalysis(capa.capaId, { aiSenseiHistory: nextHistory })
    setAiSenseiSelected(current => (current?.id === entryId ? nextHistory.find(entry => entry.id === entryId) || null : current))
    return nextHistory.find(entry => entry.id === entryId)
  }

  function sendAiSenseiForReview(entryId) {
    const updated = updateAiSenseiHistory(entryId, entry => ({
      ...entry,
      reviewStatus: 'Under PIC Review',
      reviewedBy: 'PIC',
      reviewDate: formatAiSenseiSavedAt(new Date()),
      finalDecision: 'Pending',
    }))
    if (updated) setAiSenseiSelected(updated)
  }

  function acceptAiSenseiSuggestion(entryId) {
    const entry = aiSenseiHistory.find(item => item.id === entryId)
    if (!entry) return
    const finalStatus = entry.editedAfterSave ? 'Edited & Accepted' : 'Accepted'
    updateImprovementAnalysis(capa.capaId, {
      rootCause: entry.possibleRootCause,
      rootCauseSummary: entry.possibleRootCause,
      fiveWhys: entry.suggestedFiveWhys,
      countermeasure: entry.permanentCountermeasure,
      countermeasurePlan: { ...plan, temporary: entry.temporaryCountermeasure, permanent: entry.permanentCountermeasure },
      yokotenNote: entry.yokotenOpportunity,
      aiSenseiSummary: entry.managementSummary,
      aiSenseiAcceptedAt: new Date().toISOString(),
    })
    const updated = updateAiSenseiHistory(entryId, current => ({
      ...current,
      reviewStatus: finalStatus,
      reviewedBy: 'PIC / HOD',
      reviewDate: formatAiSenseiSavedAt(new Date()),
      finalDecision: 'Accepted',
      acceptedIntoAction: true,
    }))
    if (updated) setAiSenseiSelected(updated)
  }

  function rejectAiSenseiSuggestion(entryId) {
    const updated = updateAiSenseiHistory(entryId, entry => ({
      ...entry,
      reviewStatus: 'Rejected',
      reviewedBy: 'PIC / HOD',
      reviewDate: formatAiSenseiSavedAt(new Date()),
      finalDecision: 'Rejected',
      acceptedIntoAction: false,
    }))
    if (updated) setAiSenseiSelected(updated)
  }

  function updateAiSenseiReviewFeedback(entryId, field, value) {
    const updated = updateAiSenseiHistory(entryId, entry => ({
      ...entry,
      [field]: value,
    }))
    if (updated) setAiSenseiSelected(updated)
  }

  function saveAiSenseiReviewFeedback(entryId) {
    const entry = aiSenseiHistory.find(item => item.id === entryId)
    if (!entry) return
    const updated = updateAiSenseiHistory(entryId, current => ({
      ...current,
      aiSuggestionUseful: current.aiSuggestionUseful || 'No',
      aiUsefulnessRating: current.aiUsefulnessRating || '',
      aiRatingReason: current.aiRatingReason || '',
      aiSuggestionImplemented: current.aiSuggestionImplemented || 'No',
      finalActionChangedByHuman: current.finalActionChangedByHuman || 'No',
      reviewDate: current.reviewDate || formatAiSenseiSavedAt(new Date()),
      reviewedBy: current.reviewedBy || 'PIC / HOD',
    }))
    if (updated) setAiSenseiSelected(updated)
  }

  function deleteAiSensei(entryId) {
    updateImprovementAnalysis(capa.capaId, {
      aiSenseiHistory: aiSenseiHistory.filter(entry => entry.id !== entryId),
    })
    setAiSenseiSelected(current => (current?.id === entryId ? null : current))
    setAiSenseiEditingEntryId(current => (current === entryId ? null : current))
  }

  const details = [
    ['Improvement ID', capa.capaId], ['Audit ID', capa.auditId], ['DISHA Question No', capa.dishaQuestionNo],
    ['Area', capa.area], ['Chapter', capa.chapter], ['Classification', capa.classification],
    ['Location / Aspect', capa.locationAspect], ['Guest Experience Impact', capa.guestExperienceImpact], ['Facility Type', capa.facilityType],
    ['Department Owner', capa.departmentOwner], ['Risk Level', capa.riskLevel], ['Evidence Required', capa.evidenceRequired ? 'Yes' : 'No'],
    ['Evidence Uploaded', capa.evidenceUploaded ? 'Yes' : 'No'], ['Created Date', capa.createdDate], ['Target Date', capa.targetDate],
  ]

  return <>
    <button className="back-button" onClick={() => navigate('/improvements')}><ArrowLeft size={18} /> Back to Improvement Tracker</button>
    <div className="detail-header auto-capa-detail-head"><div><span className="eyebrow">IMPROVEMENT DETAIL</span><div className="id-line"><strong>{capa.capaId}</strong><span className={`severity ${String(capa.riskLevel).toLowerCase()}`}>{capa.riskLevel}</span><StatusBadge>{capa.status}</StatusBadge></div><h1>{capa.finding}</h1><p>{capa.auditId} · {capa.dishaQuestionNo}</p></div><label>Status<select value={capa.status} onChange={event => updateCapaStatus(capa.capaId, event.target.value)}>{statusOptions.map(status => <option key={status}>{status}</option>)}</select></label></div>

    <section className="card improvement-workflow"><span className="eyebrow">IMPROVEMENT FLOW</span><div>{improvementStages.map((stage, index) => <div className={index <= statusStage[capa.status] ? 'active' : ''} key={stage}><span>{index + 1}</span><strong>{stage}</strong></div>)}</div></section>

    <div className="auto-capa-detail-grid">
      <section className="card panel auto-capa-finding"><div className="panel-head"><div><span className="eyebrow">OBSERVATION & GAP</span><h2>Standard versus current condition</h2></div></div><div className="finding-callout"><FileText /><p>{capa.finding}</p></div><div className="auditor-remarks"><strong>Current Condition Observed</strong><p>{capa.currentCondition || capa.auditorRemarks || 'No current condition recorded.'}</p></div><div className="auditor-remarks"><strong>Gap Identified</strong><p>{capa.gapIdentified || capa.auditorRemarks || 'No gap recorded.'}</p></div></section>
      <section className="card panel five-why-card">
        <div className="five-why-head"><div><span className="eyebrow">TOYOTA PROBLEM SOLVING</span><h2>5 Why Analysis</h2><p>{whyRule}</p><label className="repeat-finding"><input type="checkbox" checked={capa.repeatFinding} onChange={event => { updateImprovementAnalysis(capa.capaId, { repeatFinding: event.target.checked }); setAnalysisError(''); setAnalysisSaved(false) }} /> Repeat Finding</label></div><div className="five-why-score"><strong>{whyCompletion}%</strong><span>5 Why Completion</span></div></div>
        <div className="five-why-progress"><div className="progress"><span style={{ width: `${whyCompletion}%` }} /></div><div>{[0, 20, 40, 60, 80, 100].map(step => <span className={whyCompletion >= step ? 'active' : ''} key={step}>{step}%</span>)}</div></div>
        <div className="five-why-list">{fiveWhys.map((why, index) => <label key={index}><span><b>{index + 1}</b><strong>Why {index + 1}</strong></span><textarea rows="2" value={why} onChange={event => updateWhy(index, event.target.value)} placeholder={index === 0 ? 'Why did the gap occur?' : 'Why did the previous cause occur?'} /></label>)}</div>
        <label className="root-cause-summary"><span>Root Cause Summary</span><textarea rows="4" value={capa.rootCauseSummary || ''} onChange={event => { updateImprovementAnalysis(capa.capaId, { rootCauseSummary: event.target.value }); setAnalysisSaved(false); setAnalysisError('') }} placeholder="Summarize the confirmed root cause based on the 5 Why analysis..." /></label>
        <div className={`five-why-actions ${analysisError ? 'has-error' : ''}`}><span>{analysisError || (analysisSaved ? 'Analysis saved successfully' : 'Analysis is ready to save.')}</span><button className="primary-button" onClick={saveAnalysis}><Save size={18} /> Save Analysis</button></div>
      </section>
      <section className="card panel ai-sensei-card">
        <div className="panel-head ai-sensei-head">
          <div>
            <span className="eyebrow">AI SENSEI</span>
            <h2>Draft root cause, countermeasure, and Yokoten options</h2>
            <p>Mock guidance only. Open the assistant to review a suggested analysis before saving it into the Improvement Action.</p>
          </div>
          <button className="secondary-button ai-sensei-trigger" onClick={generateAiSensei}><Sparkles size={18} /> Ask AI Sensei</button>
        </div>
        <div className="ai-sensei-cta">
          <Bot size={18} />
          <span>Use AI Sensei for mock root cause ideas, countermeasures, and Yokoten opportunities.</span>
        </div>
      </section>
      <section className="card panel ai-sensei-history-card">
        <div className="panel-head">
          <div>
            <span className="eyebrow">AI SENSEI HISTORY</span>
            <h2>Saved suggestions and reusable drafts</h2>
          </div>
          <History size={24} />
        </div>
        <div className="ai-sensei-summary-grid">
          <div><span>Total AI Suggestions</span><strong>{aiSummary.total}</strong></div>
          <div><span>Accepted Suggestions</span><strong>{aiSummary.accepted}</strong></div>
          <div><span>Rejected Suggestions</span><strong>{aiSummary.rejected}</strong></div>
          <div><span>Average AI Usefulness Rating</span><strong>{aiAverageRating}</strong></div>
          <div className="wide"><span>AI Assisted Improvements</span><strong>{aiSummary.assisted}</strong></div>
        </div>
        {aiSenseiHistory.length === 0 ? (
          <div className="ai-sensei-empty">
            <History />
            <strong>No AI Sensei history yet</strong>
            <p>Save a suggestion from the AI Sensei panel and it will appear here for later reuse.</p>
          </div>
        ) : (
          <div className="ai-sensei-history-list">
            {aiSenseiHistory.map(entry => (
              <article key={entry.id} className="ai-sensei-history-item">
                <div className="ai-sensei-history-head">
                  <div>
                    <strong>{entry.savedLabel}</strong>
                    <small>Suggested by AI • Generated by {entry.generatedBy}</small>
                  </div>
                  <div className="ai-sensei-history-badges">
                    <StatusBadge>{entry.savedStatus}</StatusBadge>
                    <StatusBadge>{entry.reviewStatus || 'Draft'}</StatusBadge>
                  </div>
                </div>
                <p className="ai-sensei-history-summary">{entry.findingGapSummary || 'No summary available.'}</p>
                <dl className="ai-sensei-history-snippets">
                  <div><dt>Suggested Root Cause</dt><dd>{entry.possibleRootCause || 'Not available'}</dd></div>
                  <div><dt>Suggested Countermeasure</dt><dd>{entry.permanentCountermeasure || 'Not available'}</dd></div>
                </dl>
                <div className="ai-sensei-history-trail">
                  <div><span>Reviewed by</span><strong>{entry.reviewedBy || 'Not yet reviewed'}</strong></div>
                  <div><span>Review date</span><strong>{entry.reviewDate || 'Pending'}</strong></div>
                  <div><span>Final decision</span><strong>{entry.finalDecision || 'Pending'}</strong></div>
                </div>
                {(entry.aiUsefulnessRating || entry.aiSuggestionUseful || entry.aiRatingReason || entry.aiSuggestionImplemented || entry.finalActionChangedByHuman) && (
                  <div className="ai-sensei-quick-feedback">
                    <div><span>Useful</span><strong>{entry.aiSuggestionUseful || 'Pending'}</strong></div>
                    <div><span>Rating</span><strong>{entry.aiUsefulnessRating || 'Pending'}</strong></div>
                    <div><span>Implemented</span><strong>{entry.aiSuggestionImplemented || 'Pending'}</strong></div>
                    <div><span>Changed by Human</span><strong>{entry.finalActionChangedByHuman || 'Pending'}</strong></div>
                  </div>
                )}
                <div className="ai-sensei-history-actions">
                  <button className="secondary-button" onClick={() => setAiSenseiSelected(entry)}>View Details</button>
                  <button className="secondary-button" onClick={() => openAiSenseiFromHistory(entry)}>Edit Before Accepting</button>
                  <button className="secondary-button" onClick={() => sendAiSenseiForReview(entry.id)} disabled={(entry.reviewStatus || 'Draft') === 'Under PIC Review' || (entry.reviewStatus || 'Draft') === 'Accepted' || (entry.reviewStatus || 'Draft') === 'Edited & Accepted'}>Send for PIC Review</button>
                  <button className="secondary-button" onClick={() => acceptAiSenseiSuggestion(entry.id)} disabled={(entry.reviewStatus || 'Draft') !== 'Under PIC Review'}>Accept Suggestion</button>
                  <button className="secondary-button danger" onClick={() => rejectAiSenseiSuggestion(entry.id)} disabled={(entry.reviewStatus || 'Draft') === 'Rejected' || (entry.reviewStatus || 'Draft') === 'Accepted' || (entry.reviewStatus || 'Draft') === 'Edited & Accepted'}>Reject Suggestion</button>
                  <button className="secondary-button danger" onClick={() => deleteAiSensei(entry.id)}>Delete Suggestion</button>
                </div>
              </article>
            ))}
          </div>
        )}
        {aiSenseiSelected && <div className="ai-sensei-history-detail">
          <div className="panel-head">
            <div>
              <span className="eyebrow">HISTORY DETAIL</span>
              <h2>{aiSenseiSelected.savedLabel}</h2>
            </div>
            <button className="text-button" onClick={() => setAiSenseiSelected(null)}>Close</button>
          </div>
          <div className="ai-sensei-history-detail-grid">
            <div><span>Date &amp; Time</span><strong>{aiSenseiSelected.savedLabel}</strong></div>
            <div><span>Generated By</span><strong>{aiSenseiSelected.generatedBy}</strong></div>
            <div className="wide"><span>Finding / Gap Summary</span><p>{aiSenseiSelected.findingGapSummary}</p></div>
            <div className="wide"><span>Suggested Root Cause</span><p>{aiSenseiSelected.possibleRootCause}</p></div>
            <div className="wide"><span>Suggested Countermeasure</span><p>{aiSenseiSelected.permanentCountermeasure}</p></div>
            <div className="wide"><span>Management Summary</span><p>{aiSenseiSelected.managementSummary}</p></div>
            <div><span>Reviewed By</span><strong>{aiSenseiSelected.reviewedBy || 'Not yet reviewed'}</strong></div>
            <div><span>Review Date</span><strong>{aiSenseiSelected.reviewDate || 'Pending'}</strong></div>
            <div className="wide"><span>Final Decision</span><strong>{aiSenseiSelected.finalDecision || 'Pending'}</strong></div>
            <div className="wide ai-sensei-feedback-form">
              <span>AI Suggestion Useful?</span>
              <div className="toggle-row">
                <button type="button" className={aiSenseiSelected.aiSuggestionUseful === 'Yes' ? 'selected' : ''} onClick={() => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'aiSuggestionUseful', 'Yes')}>Yes</button>
                <button type="button" className={aiSenseiSelected.aiSuggestionUseful === 'No' ? 'selected' : ''} onClick={() => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'aiSuggestionUseful', 'No')}>No</button>
              </div>
            </div>
            <label className="wide ai-sensei-feedback-form"><span>Rating: 1 to 5</span><select value={aiSenseiSelected.aiUsefulnessRating || ''} onChange={event => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'aiUsefulnessRating', event.target.value)}><option value="">Select rating</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></label>
            <label className="wide ai-sensei-feedback-form"><span>Reason for Rating</span><textarea rows="3" value={aiSenseiSelected.aiRatingReason || ''} onChange={event => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'aiRatingReason', event.target.value)} /></label>
            <div className="wide ai-sensei-feedback-form">
              <span>Was AI suggestion implemented?</span>
              <div className="toggle-row">
                <button type="button" className={aiSenseiSelected.aiSuggestionImplemented === 'Yes' ? 'selected' : ''} onClick={() => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'aiSuggestionImplemented', 'Yes')}>Yes</button>
                <button type="button" className={aiSenseiSelected.aiSuggestionImplemented === 'No' ? 'selected' : ''} onClick={() => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'aiSuggestionImplemented', 'No')}>No</button>
              </div>
            </div>
            <div className="wide ai-sensei-feedback-form">
              <span>Final action changed by human?</span>
              <div className="toggle-row">
                <button type="button" className={aiSenseiSelected.finalActionChangedByHuman === 'Yes' ? 'selected' : ''} onClick={() => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'finalActionChangedByHuman', 'Yes')}>Yes</button>
                <button type="button" className={aiSenseiSelected.finalActionChangedByHuman === 'No' ? 'selected' : ''} onClick={() => updateAiSenseiReviewFeedback(aiSenseiSelected.id, 'finalActionChangedByHuman', 'No')}>No</button>
              </div>
            </div>
            <div className="wide ai-sensei-feedback-actions">
              <button className="secondary-button" onClick={() => saveAiSenseiReviewFeedback(aiSenseiSelected.id)}>Save Review Feedback</button>
            </div>
          </div>
        </div>}
      </section>
      <section className="card panel countermeasure-card">
        <div className="panel-head"><div><span className="eyebrow">COUNTERMEASURE PLANNING</span><h2>Plan and assign implementation</h2></div><StatusBadge>{plan.implementationStatus}</StatusBadge></div>
        <div className="countermeasure-form">
          <label className="wide">Temporary Countermeasure<textarea rows="3" value={plan.temporary} onChange={event => updatePlan('temporary', event.target.value)} placeholder="Immediate containment to control the gap..." /></label>
          <label className="wide">Permanent Countermeasure<textarea rows="3" value={plan.permanent} onChange={event => updatePlan('permanent', event.target.value)} placeholder="Permanent action addressing the confirmed root cause..." /></label>
          <label>Responsible Person<input value={plan.responsiblePerson} onChange={event => updatePlan('responsiblePerson', event.target.value)} placeholder="Name of action owner" /></label>
          <label>Supporting Department<input value={plan.supportingDepartment} onChange={event => updatePlan('supportingDepartment', event.target.value)} placeholder="Department or team" /></label>
          <label>Target Completion Date<input type="date" value={plan.targetCompletionDate} onChange={event => updatePlan('targetCompletionDate', event.target.value)} /></label>
          <label>Estimated Cost<input type="number" min="0" value={plan.estimatedCost} onChange={event => updatePlan('estimatedCost', event.target.value)} placeholder="INR" /></label>
          <label>Approval Required<select value={plan.approvalRequired} onChange={event => updatePlan('approvalRequired', event.target.value)}><option>No</option><option>Yes</option></select></label>
          {plan.approvalRequired === 'Yes' && <label>Approver<input value={plan.approver} onChange={event => updatePlan('approver', event.target.value)} placeholder="Approval authority" /></label>}
          <label className="wide">Expected Result<textarea rows="3" value={plan.expectedResult} onChange={event => updatePlan('expectedResult', event.target.value)} placeholder="Describe the measurable result expected after implementation..." /></label>
          <label>Implementation Status<select value={plan.implementationStatus} onChange={event => updatePlan('implementationStatus', event.target.value)}>{implementationStages.map(status => <option key={status}>{status}</option>)}</select></label>
        </div>
        <div className="countermeasure-save"><span>Changes are saved automatically.</span><button className="secondary-button" onClick={() => updateCapaStatus(capa.capaId, plan.implementationStatus === 'Completed' ? 'Evidence Uploaded' : plan.implementationStatus === 'In Progress' ? 'Implementation In Progress' : 'Countermeasure Planned')}><Save size={18} /> Update Improvement Status</button></div>
      </section>
      <section className="card implementation-timeline">
        <div className="panel-head"><div><span className="eyebrow">IMPLEMENTATION TIMELINE</span><h2>Countermeasure progress</h2></div></div>
        <div className="implementation-steps">{implementationStages.map((stage, index) => <div className={index <= implementationIndex ? 'active' : ''} key={stage}><span>{index === 0 ? <CalendarDays /> : index === 1 ? <Users /> : <CheckCircle2 />}</span><div><strong>{stage}</strong><small>{index === 0 ? (plan.targetCompletionDate ? `Target: ${plan.targetCompletionDate}` : 'Target date pending') : index === 1 ? (plan.responsiblePerson || 'Owner pending') : (plan.expectedResult || 'Expected result pending')}</small></div></div>)}</div>
        <div className="implementation-summary"><div><UserRound /><span><small>Responsible Person</small><strong>{plan.responsiblePerson || 'Not assigned'}</strong></span></div><div><CircleDollarSign /><span><small>Estimated Cost</small><strong>{plan.estimatedCost ? `INR ${Number(plan.estimatedCost).toLocaleString('en-IN')}` : 'Not assessed'}</strong></span></div><div><CheckCircle2 /><span><small>Approval</small><strong>{plan.approvalRequired === 'Yes' ? plan.approver || 'Approver pending' : 'Not required'}</strong></span></div></div>
      </section>
      <section className="card panel verification-module">
        <div className="panel-head"><div><span className="eyebrow">AUDITOR VERIFICATION</span><h2>Verify implementation effectiveness</h2></div><ClipboardCheck size={26} /></div>
        <label className="implementation-verified"><input type="checkbox" checked={verification.implementationVerified} onChange={event => updateVerification('implementationVerified', event.target.checked)} /><span><strong>Implementation Verified</strong><small>I have reviewed the implemented countermeasure against the agreed action plan.</small></span></label>
        <fieldset className="effectiveness-field"><legend>Effectiveness Rating</legend><div className="effectiveness-options">{effectivenessOptions.map(option => <button type="button" className={`effectiveness-option ${verification.effectivenessRating === option ? 'selected' : ''} ${option.toLowerCase().replaceAll(' ', '-')}`} onClick={() => updateVerification('effectivenessRating', option)} key={option}>{option}</button>)}</div></fieldset>
        {verification.effectivenessRating === 'Not Effective' && <div className="verification-reopen"><RotateCcw size={20} /><span><strong>This action will be reopened.</strong> Its status will return to Countermeasure Planned when verification is submitted.</span></div>}
        <div className="verification-form"><label>Verification Comments<textarea rows="4" value={verification.comments} onChange={event => updateVerification('comments', event.target.value)} placeholder="Record the verification result and observed effectiveness..." /></label><label>Evidence Review<textarea rows="4" value={verification.evidenceReview} onChange={event => updateVerification('evidenceReview', event.target.value)} placeholder="List the photos, documents, or records reviewed..." /></label></div>
        <div className={`verification-actions ${verificationError ? 'has-error' : ''}`}><span>{verificationError || verificationSaved || 'All verification decisions are stored in the history below.'}</span><button className="primary-button" onClick={verifyImplementation}><ClipboardCheck size={18} /> Submit Verification</button></div>
      </section>
      <section className="card panel verification-history">
        <div className="panel-head"><div><span className="eyebrow">AUDIT TRAIL</span><h2>Verification history</h2></div><History size={25} /></div>
        {verificationHistory.length === 0 ? <div className="verification-empty"><History /><strong>No verification recorded</strong><p>The first submitted auditor decision will appear here.</p></div> : <div className="verification-history-list">{verificationHistory.map(entry => <article key={entry.id}><div className="verification-history-head"><div><strong>{entry.effectivenessRating}</strong><span>{entry.verifiedAt} by {entry.auditor}</span></div><StatusBadge>{entry.resultingStatus}</StatusBadge></div><dl><div><dt>Implementation Verified</dt><dd>{entry.implementationVerified ? 'Yes' : 'No'}</dd></div><div><dt>Verification Comments</dt><dd>{entry.comments}</dd></div><div><dt>Evidence Review</dt><dd>{entry.evidenceReview}</dd></div></dl></article>)}</div>}
      </section>
      <section className="card panel yokoten-module">
        <div className="panel-head"><div><span className="eyebrow">YOKOTEN</span><h2>Share this successful improvement</h2></div><Share2 size={26} /></div>
        <div className="yokoten-form">
          <label className="wide">Improvement Title<input value={yokoten.improvementTitle} onChange={event => updateYokoten('improvementTitle', event.target.value)} placeholder="Clear title for the shared improvement" /></label>
          <label className="wide">Original Finding<textarea rows="3" value={yokoten.originalFinding} onChange={event => updateYokoten('originalFinding', event.target.value)} placeholder="Describe the original condition or gap..." /></label>
          <label className="wide">Countermeasure Implemented<textarea rows="4" value={yokoten.countermeasureImplemented} onChange={event => updateYokoten('countermeasureImplemented', event.target.value)} placeholder="Explain the proven countermeasure and how it was implemented..." /></label>
          <label className="wide">Benefits Achieved<textarea rows="3" value={yokoten.benefitsAchieved} onChange={event => updateYokoten('benefitsAchieved', event.target.value)} placeholder="Record measurable quality, safety, cost, delivery, or guest benefits..." /></label>
          <label>Department<input value={yokoten.department} onChange={event => updateYokoten('department', event.target.value)} /></label>
          <label>Location<input value={yokoten.location} onChange={event => updateYokoten('location', event.target.value)} /></label>
          <label>Category<input value={yokoten.category} onChange={event => updateYokoten('category', event.target.value)} /></label>
          <label>Approval Status<select value={yokoten.approvalStatus} onChange={event => updateYokoten('approvalStatus', event.target.value)}><option>Draft</option><option>Pending Approval</option><option>Approved</option><option>Rejected</option></select></label>
        </div>
        <fieldset className="yokoten-application-field"><legend>Can Be Applied To</legend><div>{yokotenApplications.map(option => <label className={yokoten.appliedTo.includes(option) ? 'selected' : ''} key={option}><input type="checkbox" checked={yokoten.appliedTo.includes(option)} onChange={() => toggleYokotenApplication(option)} /><span>{option}</span></label>)}</div></fieldset>
        <label className="yokoten-upload"><Paperclip /><span><strong>Attachments</strong><small>{yokoten.attachments.length ? yokoten.attachments.join(', ') : 'Add supporting photos or documents'}</small></span><input type="file" multiple onChange={event => updateYokoten('attachments', Array.from(event.target.files).map(file => file.name))} /></label>
        <div className={`yokoten-actions ${yokotenError ? 'has-error' : ''}`}><span>{yokotenError || (yokotenSaved ? 'Yokoten story saved successfully.' : 'Approved stories become available in the Yokoten Library.')}</span><div><button className="secondary-button" onClick={() => navigate('/yokoten')}>View Library</button><button className="primary-button" onClick={saveYokoten}><Share2 size={18} /> Save Yokoten</button></div></div>
      </section>
      <section className="card panel improvement-thinking"><div className="panel-head"><div><span className="eyebrow">PROBLEM SOLVING</span><h2>Root cause and countermeasure</h2></div></div><div><span>Root Cause</span><p>{capa.rootCause || 'Root cause analysis is pending.'}</p></div><div><span>Countermeasure</span><p>{capa.countermeasure || 'Countermeasure planning is pending.'}</p></div><div><span>Verification</span><p>{capa.verificationNote || 'Verification will be recorded after implementation.'}</p></div><div><span>Yokoten</span><p>{capa.yokotenNote || 'Learning has not yet been shared across locations.'}</p></div></section>
      <section className="card panel"><div className="panel-head"><div><span className="eyebrow">IMPROVEMENT INFORMATION</span><h2>Linked audit data</h2></div></div><div className="capa-detail-fields">{details.map(([label, value]) => <div key={label}><span>{label}</span><strong>{value}</strong></div>)}</div></section>
      <aside className="card side-card auto-capa-side"><span className="eyebrow">ACTION TIMELINE</span><div><CalendarDays /><span><strong>Created</strong><small>{capa.createdDate}</small></span></div><div><MapPin /><span><strong>Target closure</strong><small>{capa.targetDate}</small></span></div><div><CheckCircle2 /><span><strong>Current status</strong><small>{capa.status}</small></span></div></aside>
    </div>

    {aiSenseiOpen && <div className="ai-sensei-overlay" role="presentation" onClick={() => setAiSenseiOpen(false)}>
        <div className="ai-sensei-modal card" role="dialog" aria-modal="true" aria-labelledby="ai-sensei-title" onClick={event => event.stopPropagation()}>
        <div className="ai-sensei-modal-head">
          <div>
            <span className="eyebrow">AI SENSEI</span>
            <h2 id="ai-sensei-title">{aiSenseiEditingEntryId ? 'Edit saved suggestion' : 'Mock AI suggestion panel'}</h2>
            <p>Review, edit, and save before applying to the Improvement Action.</p>
          </div>
          <button className="icon-button ai-sensei-close" onClick={() => setAiSenseiOpen(false)} aria-label="Close AI Sensei panel"><X size={18} /></button>
        </div>

        <div className="ai-sensei-disclaimer">
          <Bot size={18} />
          <span>AI suggestions are for support only. Final decision must be reviewed by PIC / HOD.</span>
        </div>

        <div className="ai-sensei-body">
          <div className="ai-sensei-context">
            <span className="eyebrow">COLLECTED CONTEXT</span>
            <div className="ai-sensei-context-grid">
              <div><strong>Evaluation Item</strong><p>{aiSenseiDraft.context.evaluationItem || 'Not available'}</p></div>
              <div><strong>Current Condition Observed</strong><p>{aiSenseiDraft.context.currentCondition || 'Not available'}</p></div>
              <div><strong>Gap Identified</strong><p>{aiSenseiDraft.context.gapIdentified || 'Not available'}</p></div>
              <div><strong>Auditor Remarks</strong><p>{aiSenseiDraft.context.auditorRemarks || 'Not available'}</p></div>
              <div><strong>Area</strong><p>{aiSenseiDraft.context.area || 'Not available'}</p></div>
              <div><strong>Department</strong><p>{aiSenseiDraft.context.department || 'Not available'}</p></div>
              <div><strong>Risk Level</strong><p>{aiSenseiDraft.context.riskLevel || 'Not available'}</p></div>
              <div><strong>Guest Impact</strong><p>{aiSenseiDraft.context.guestImpact || 'Not available'}</p></div>
              <div className="wide"><strong>Existing 5 Why Inputs</strong><p>{aiSenseiDraft.context.previousWhySummary}</p></div>
            </div>
          </div>

          <div className="ai-sensei-grid">
            <label className="wide"><span>Possible Root Cause</span><textarea rows="3" value={aiSenseiDraft.possibleRootCause} onChange={event => updateAiSenseiField('possibleRootCause', event.target.value)} /></label>
            <div className="ai-sensei-why-list">
              <span>Suggested 5 Why Analysis</span>
              {aiSenseiDraft.suggestedFiveWhys.map((why, index) => <label key={index}><strong>Why {index + 1}</strong><textarea rows="2" value={why} onChange={event => updateAiSenseiWhy(index, event.target.value)} /></label>)}
            </div>
            <label><span>Temporary Countermeasure</span><textarea rows="3" value={aiSenseiDraft.temporaryCountermeasure} onChange={event => updateAiSenseiField('temporaryCountermeasure', event.target.value)} /></label>
            <label><span>Permanent Countermeasure</span><textarea rows="3" value={aiSenseiDraft.permanentCountermeasure} onChange={event => updateAiSenseiField('permanentCountermeasure', event.target.value)} /></label>
            <label><span>Risk / Guest Impact Note</span><textarea rows="3" value={aiSenseiDraft.riskGuestImpactNote} onChange={event => updateAiSenseiField('riskGuestImpactNote', event.target.value)} /></label>
            <label><span>Yokoten Opportunity</span><textarea rows="3" value={aiSenseiDraft.yokotenOpportunity} onChange={event => updateAiSenseiField('yokotenOpportunity', event.target.value)} /></label>
            <label className="wide"><span>Management Summary</span><textarea rows="3" value={aiSenseiDraft.managementSummary} onChange={event => updateAiSenseiField('managementSummary', event.target.value)} /></label>
          </div>

          <div className={`ai-sensei-actions ${aiSenseiError ? 'has-error' : ''}`}>
            <span>{aiSenseiError || (aiSenseiSaved ? 'AI Sensei suggestions saved to the Improvement Action.' : 'Edit the suggestions before saving them to the record.')}</span>
            <button className="primary-button" onClick={saveAiSensei}><Save size={18} /> Save to Improvement Action</button>
          </div>
        </div>
      </div>
    </div>}
  </>
}
