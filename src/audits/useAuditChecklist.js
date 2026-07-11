import { useEffect, useState } from 'react'
import { requireSupabase } from '../supabaseClient'
import { checklistRowOrderValue, checklistRowSerialValue } from './checklistSort'

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
  const rowOrder = checklistRowOrderValue(row)
  const subQuestionNum = checklistRowSerialValue(row)
  const question = stripLeadingSerial(row.evaluation_question || row.question || row.evaluation_parameter || '')
  return {
    id: row.checklist_code,
    dbId: row.id,
    dqQuestionNum: row.checklist_code || '',
    dqSort: checklistCodeSortValue(row.checklist_code),
    rowOrder,
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
          .select('*')
          .eq('status', 'active')
        if (result.error) throw result.error
        const allRows = result.data || []
        const workbookOrderedRows = allRows.filter(row => /^v\d+-[A-Z0-9]+-\d{3}(?:-|$)/i.test(String(row.version || '')))
        const rowsToUse = workbookOrderedRows.length ? workbookOrderedRows : allRows
        const nextChecklist = rowsToUse.map(mapChecklistRow).sort((a, b) => {
          if (a.dqSort !== b.dqSort) return a.dqSort - b.dqSort
          const aRowOrder = Number.isFinite(a.rowOrder) ? a.rowOrder : Number.POSITIVE_INFINITY
          const bRowOrder = Number.isFinite(b.rowOrder) ? b.rowOrder : Number.POSITIVE_INFINITY
          if (aRowOrder !== bRowOrder) return aRowOrder - bRowOrder
          const aSerial = Number.isFinite(a.subQuestionNum) ? a.subQuestionNum : Number.POSITIVE_INFINITY
          const bSerial = Number.isFinite(b.subQuestionNum) ? b.subQuestionNum : Number.POSITIVE_INFINITY
          if (aSerial !== bSerial) return aSerial - bSerial
          const aOrder = Number.isFinite(a.subQuestionOrder) ? a.subQuestionOrder : Number.POSITIVE_INFINITY
          const bOrder = Number.isFinite(b.subQuestionOrder) ? b.subQuestionOrder : Number.POSITIVE_INFINITY
          if (aOrder !== bOrder) return aOrder - bOrder
          const aCreated = a.createdAt || ''
          const bCreated = b.createdAt || ''
          if (aCreated !== bCreated) return String(aCreated).localeCompare(String(bCreated))
          if (a.id !== b.id) return String(a.id).localeCompare(String(b.id))
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
