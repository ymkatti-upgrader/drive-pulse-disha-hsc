import { useEffect, useState } from 'react'
import { requireSupabase } from '../supabaseClient'

function priorityFromRisk(row) {
  if (row.risk_level === 'Critical') return 'Critical'
  return row.evidence_required ? 'Important' : 'Normal'
}

function weightFromPriority(priority) {
  if (priority === 'Critical') return 5
  if (priority === 'Important') return 3
  return 1
}

function scoreGroupFromClassification(value) {
  return String(value || '').toLowerCase().includes('process') ? 'Process' : 'Result'
}

function normalizeSerialValue(row) {
  const direct = Number(row.sub_question_num ?? row.subQuestionNum ?? row.serial_no ?? row.sequence)
  if (Number.isFinite(direct) && direct > 0) return direct

  const versionMatch = String(row.version || '').match(/^v\d+-[A-Z0-9]+-(\d{3})(?:-|$)/i)
  const versionSerial = versionMatch ? Number(versionMatch[1]) : Number.NaN
  if (Number.isFinite(versionSerial) && versionSerial > 0) return versionSerial

  const source = String(row.evaluation_question || row.question || row.evaluation_parameter || row.version || '').trim()
  const match = source.match(/^\s*(\d+(?:\.\d+)?)/)
  const parsed = match ? Number(match[1]) : Number.NaN
  return Number.isFinite(parsed) && parsed > 0 ? parsed : Number.POSITIVE_INFINITY
}

function checklistCodeSortValue(value) {
  const text = String(value || '')
  const match = text.match(/(\d+)/)
  return match ? Number(match[1]) : Number.POSITIVE_INFINITY
}

function subQuestionOrderFromVersion(version) {
  const text = String(version || '')
  const match = text.match(/^v\d+-[A-Z0-9]+-(\d{3})(?:-|$)/i) || text.match(/^v\d+-(\d{3})(?:-|$)/i)
  return match ? Number(match[1]) : Number.POSITIVE_INFINITY
}

function stripLeadingSerial(text) {
  return String(text || '').replace(/^\s*\d+(?:\.\d+)?[.)]?\s*/, '').trim()
}

function mapChecklistRow(row) {
  const priority = priorityFromRisk(row)
  const subQuestionNum = normalizeSerialValue(row)
  const question = stripLeadingSerial(row.evaluation_question || row.question || row.evaluation_parameter || '')
  return {
    id: row.checklist_code,
    dbId: row.id,
    dqQuestionNum: row.checklist_code || '',
    dqSort: checklistCodeSortValue(row.checklist_code),
    subQuestionNum,
    subQuestionOrder: subQuestionOrderFromVersion(row.version),
    createdAt: row.created_at || '',
    version: row.version,
    section: row.section,
    area: row.area,
    chapter: row.chapter,
    classification: row.classification,
    scoreGroup: scoreGroupFromClassification(row.classification),
    priority,
    applicableDepartments: Array.isArray(row.applicable_departments) ? row.applicable_departments : [],
    locationAspect: row.location_aspect || '',
    guestImpact: row.guest_experience_impact === 'Direct' ? 'High' : 'Medium',
    facilityType: row.facility_type || '',
    question,
    questionLabel: subQuestionNum === Number.POSITIVE_INFINITY ? row.checklist_code || '' : String(subQuestionNum),
    evaluationQuestion: row.evaluation_question || '',
    evaluationParameter: row.evaluation_parameter || '',
    weight: weightFromPriority(priority),
    evidenceRequired: Boolean(row.evidence_required),
    result: '',
    remarks: '',
    purpose: row.purpose || '',
    checkingMethod: row.checking_method || '',
    additionalInfo: row.additional_info || '',
    sopReference: row.sop_reference || '',
  }
}

export function useAuditChecklist() {
  const [checklist, setChecklist] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false

    async function loadChecklist() {
      setLoading(true)
      setError('')
      try {
        const client = requireSupabase()
        const result = await client
          .from('audit_checklist_master')
          .select('id, checklist_code, sub_question_num, version, created_at, section, area, chapter, classification, applicable_departments, location_aspect, evaluation_question, evaluation_parameter, guest_experience_impact, facility_type, question, purpose, checking_method, additional_info, sop_reference, evidence_required, status')
          .eq('status', 'active')
        if (result.error) throw result.error
        const allRows = result.data || []
        const workbookOrderedRows = allRows.filter(row => /^v\d+-[A-Z0-9]+-\d{3}(?:-|$)/i.test(String(row.version || '')))
        const rowsToUse = workbookOrderedRows.length ? workbookOrderedRows : allRows
        const nextChecklist = rowsToUse.map(mapChecklistRow).sort((a, b) => {
          if (a.dqSort !== b.dqSort) return a.dqSort - b.dqSort
          if (a.id !== b.id) return String(a.id).localeCompare(String(b.id))
          const aSerial = Number.isFinite(a.subQuestionNum) ? a.subQuestionNum : Number.POSITIVE_INFINITY
          const bSerial = Number.isFinite(b.subQuestionNum) ? b.subQuestionNum : Number.POSITIVE_INFINITY
          if (aSerial !== bSerial) return aSerial - bSerial
          const aOrder = Number.isFinite(a.subQuestionOrder) ? a.subQuestionOrder : Number.POSITIVE_INFINITY
          const bOrder = Number.isFinite(b.subQuestionOrder) ? b.subQuestionOrder : Number.POSITIVE_INFINITY
          if (aOrder !== bOrder) return aOrder - bOrder
          const aCreated = a.createdAt || ''
          const bCreated = b.createdAt || ''
          if (aCreated !== bCreated) return String(aCreated).localeCompare(String(bCreated))
          return String(a.dbId).localeCompare(String(b.dbId))
        }).reduce((acc, item) => {
          acc.push({
            ...item,
            displaySubQuestionNum: Number.isFinite(item.subQuestionNum) ? item.subQuestionNum : null,
          })
          return acc
        }, [])
        if (!cancelled) setChecklist(nextChecklist)
      } catch (err) {
        if (!cancelled) {
          setChecklist([])
          setError(err.message || 'Unable to load audit checklist.')
        }
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    loadChecklist()
    return () => {
      cancelled = true
    }
  }, [])

  return { checklist, loading, error }
}
