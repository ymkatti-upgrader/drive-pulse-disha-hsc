import { useMemo, useRef, useState } from 'react'
import { AlertCircle, CheckCircle2, Download, FileSpreadsheet, FileText, Upload } from 'lucide-react'
import * as XLSX from 'xlsx'
import { PageHeader, Progress, StatusBadge } from '../components/UI'
import { DEFAULT_PASSWORD, isSystemAdmin, mockRoles, useAuth } from '../auth/AuthContext'
import { requireSupabase } from '../supabaseClient'

const checklistTemplateColumns = [
  'DISHA Question No.',
  'Applicable Department - Sales',
  'Applicable Department - Service & Parts',
  'Applicable Department - Used Car',
  'Applicable Department - Accessory',
  'Applicable Department - Value Chain',
  'Applicable Department - Other',
  'Classification',
  'Location / Aspect',
  'Guest Experience Impact',
  'Applicable Facility - 3S',
  'Applicable Facility - 2S',
  'Applicable Facility - 1S',
  'Applicable Facility - TES',
  'Applicable Facility - Satellite',
  'Applicable Facility - Rural',
  'Evaluation Parameter',
  'Evaluation Question',
  'Purpose',
  'Checking Method',
  'Additional Information (Items / Documents / Material)',
  'Requirement',
  'Photo / Document Description\r\n[Evaluator Reference]',
  'Process KPI',
  'Result KPI',
  'SOP / Material Reference',
]

const checklistDepartmentColumns = [
  ['Applicable Department - Sales', 'Sales'],
  ['Applicable Department - Service & Parts', 'Service & Parts'],
  ['Applicable Department - Used Car', 'Used Car'],
  ['Applicable Department - Accessory', 'Accessory'],
  ['Applicable Department - Value Chain', 'Value Chain'],
  ['Applicable Department - Other', 'Other'],
]

const checklistFacilityColumns = [
  ['Applicable Facility - 3S', '3S'],
  ['Applicable Facility - 2S', '2S'],
  ['Applicable Facility - 1S', '1S'],
  ['Applicable Facility - TES', 'TES'],
  ['Applicable Facility - Satellite', 'Satellite'],
  ['Applicable Facility - Rural', 'Rural'],
]

const acceptedFlagValues = new Set(['y', 'yes', 'true', '1'])
const rejectedFlagValues = new Set(['', '-', 'n', 'no', 'false', '0'])
const activeStatusValues = new Set(['', 'yes', 'active', 'y', 'true', '1'])
const inactiveStatusValues = new Set(['no', 'inactive', 'n', 'false', '0'])
const mockUserRoles = new Set(mockRoles)
const IMPORT_DEBUG_PREFIX = '[MasterImport Debug]'
const userRoleLookup = new Map([
  ...mockRoles.map(role => [normalizeRoleKey(role), role]),
  ['locationfunctionalpic', 'Location Functional HOD'],
  ['systenadministrator', 'System Administrator'],
  ['systemadmin', 'System Administrator'],
  ['groupdishahscpic', 'Group DISHA HSC PIC'],
  ['branchdishapic', 'Branch DISHA PIC'],
  ['branchdishahscpic', 'Branch Disha HSC PIC'],
  ['ngpic', 'NG PIC'],
  ['admin', 'Admin'],
  ['superadmin', 'Super Admin'],
])

const importTypes = {
  locations: {
    label: 'Locations',
    description: 'Import dealership and outlet location records.',
    fileName: 'locations-template',
    sheetName: 'Locations',
    columns: ['Location Code', 'Location Name', 'Type', 'Active'],
    columnMap: { Active: 'status' },
    required: ['locationCode', 'locationName', 'type'],
    duplicateKeys: ['locationCode', 'locationName'],
    sampleRows: [
      { locationCode: 'BL06A-SALES', locationName: 'HEBBAL', type: '1S', status: 'YES' },
      { locationCode: 'BL06A-SERVICE', locationName: 'KOGILU', type: '2S', status: 'YES' },
    ],
  },
  departments: {
    label: 'Departments',
    description: 'Import department records.',
    fileName: 'departments-template',
    sheetName: 'Departments',
    columns: ['Department Name', 'Active'],
    columnMap: { Active: 'status' },
    required: ['departmentName'],
    duplicateKeys: ['departmentName'],
    sampleRows: [],
  },
  roles: {
    label: 'Roles',
    description: 'Import role records for workflow control.',
    fileName: 'roles-template',
    sheetName: 'Roles',
    columns: ['Role Name', 'Mapped to', 'Description', 'Active'],
    columnMap: { 'Mapped to': 'mappedTo', Active: 'status' },
    required: ['roleName'],
    duplicateKeys: ['roleName'],
    sampleRows: [
      { roleName: 'CEO', mappedTo: 'CEO', description: 'Full organizational visibility, strategic oversight, final approver for critical findings and high-value actions, Cost approval', status: 'Yes' },
      { roleName: 'Group Functional HOD', mappedTo: 'Group Functional HOD', description: 'Full visibility across locations and functions, reviews performance and compliance.', status: 'Yes' },
    ],
  },
  users: {
    label: 'Users',
    description: 'Import user access and workflow responsibility records.',
    fileName: 'users-template',
    sheetName: 'Users',
    columns: ['Employee Name', 'MobileNo', 'Role', 'Department', 'Location', 'Active', 'User Type'],
    columnMap: {
      'Employee Name': 'full_name',
      MobileNo: 'mobile_number',
      Mobile: 'mobile_number',
      'Mobile Number': 'mobile_number',
      mobile_number: 'mobile_number',
      password: 'password',
      Password: 'password',
      Designation: 'designation',
      Active: 'status',
      'User Type': 'userType',
    },
    ignoredHeaders: ['Email', 'Employee ID'],
    required: ['full_name', 'mobile_number', 'role'],
    duplicateKeys: ['mobile_number'],
    sampleRows: [],
  },
  checklist: {
    label: 'Audit Checklist',
    description: 'Import finalized DISHA HSC checklist evaluation parameters.',
    fileName: 'audit-checklist-template',
    sheetName: 'Audit Checklist',
    columns: checklistTemplateColumns,
    required: ['questionCode', 'evaluationQuestion', 'evaluationParameter'],
    duplicateKeys: ['questionCode', 'evaluationParameter'],
    sampleRows: [],
  },
  rolePermissions: {
    label: 'Role Permissions',
    description: 'Import role permission matrix records.',
    fileName: 'role-permissions-template',
    sheetName: 'Role Permissions',
    columns: ['Role', 'View', 'Add', 'Edit', 'Delete', 'Approve', 'Verify', 'Close', 'Export', 'AI Access'],
    columnMap: { 'AI Access': 'aiAccess' },
    required: ['role'],
    duplicateKeys: ['role'],
    flagFields: ['view', 'add', 'edit', 'delete', 'approve', 'verify', 'close', 'export', 'aiAccess'],
    sampleRows: [
      { role: 'CEO', view: 'Y', add: 'Y', edit: 'Y', delete: 'N', approve: 'Y', verify: 'Y', close: 'Y', export: 'Y', aiAccess: 'Y' },
      { role: 'Group DISHA HSC PIC', view: 'Y', add: 'Y', edit: 'Y', delete: 'Y', approve: 'Y', verify: 'Y', close: 'Y', export: 'Y', aiAccess: 'Y' },
    ],
  },
  approvalMatrix: {
    label: 'Approval Matrix',
    description: 'Import approval type and approver rules.',
    fileName: 'approval-matrix-template',
    sheetName: 'Approval Matrix',
    columns: ['Approval Type', 'Approver'],
    columnMap: { 'Approval Type': 'approvalType' },
    required: ['approvalType', 'approver'],
    duplicateKeys: ['approvalType'],
    sampleRows: [
      { approvalType: 'Cost Approval', approver: 'CEO' },
      { approvalType: 'Yokoten Approval', approver: 'CEO' },
    ],
  },
  escalationMatrix: {
    label: 'Escalation Matrix',
    description: 'Import escalation event and recipient rules.',
    fileName: 'escalation-matrix-template',
    sheetName: 'Escalation Matrix',
    columns: ['Event Type', 'Days', 'Escalate To'],
    columnMap: { 'Event Type': 'eventType', 'Escalate To': 'escalateTo' },
    required: ['eventType', 'escalateTo'],
    duplicateKeys: ['eventType', 'days', 'escalateTo'],
    sampleRows: [
      { eventType: 'Critical Finding', days: '0', escalateTo: 'Group Functional HOD' },
      { eventType: 'Critical Finding', days: '0', escalateTo: 'DISHA HSC PIC' },
    ],
  },
  aiGovernance: {
    label: 'AI Governance',
    description: 'Import AI governance settings.',
    fileName: 'ai-governance-template',
    sheetName: 'AI Governance',
    columns: ['Feature', 'Enabled', 'Approver'],
    required: ['feature', 'enabled'],
    duplicateKeys: ['feature'],
    flagFields: ['enabled'],
    sampleRows: [
      { feature: 'Root Cause Suggestion', enabled: 'Yes', approver: 'Branch DISHA PIC' },
      { feature: '5 Why Suggestion', enabled: 'Yes', approver: 'Branch DISHA PIC' },
    ],
  },
  evidenceGovernance: {
    label: 'Evidence Governance',
    description: 'Import evidence governance records.',
    fileName: 'evidence-governance-template',
    sheetName: 'Evidence Governance',
    columns: ['Evidence Type', 'Upload Allowed', 'Edit Allowed', 'Delete Allowed', 'Retention Period', 'Owner Role', 'Mandatory'],
    columnMap: {
      'Evidence Type': 'evidenceType',
      'Upload Allowed': 'uploadAllowed',
      'Edit Allowed': 'editAllowed',
      'Delete Allowed': 'deleteAllowed',
      'Retention Period': 'retentionPeriod',
      'Owner Role': 'ownerRole',
    },
    required: ['evidenceType'],
    duplicateKeys: ['evidenceType'],
    sampleRows: [
      { evidenceType: 'Audit Photo', uploadAllowed: 'Yes', editAllowed: 'Yes (Before Audit Closure)', deleteAllowed: 'No', retentionPeriod: '5 Years', ownerRole: 'Auditor / Branch DISHA PIC', mandatory: 'Yes' },
      { evidenceType: 'Audit Document', uploadAllowed: 'Yes', editAllowed: 'Yes (Before Audit Closure)', deleteAllowed: 'No', retentionPeriod: '5 Years', ownerRole: 'Auditor / Branch DISHA PIC', mandatory: 'Conditional' },
    ],
  },
  notificationRules: {
    label: 'Notification Rules',
    description: 'Import notification event and recipient rules.',
    fileName: 'notification-rules-template',
    sheetName: 'Notification Rules',
    columns: ['Event', 'Recipient Role', 'Priority', 'Enabled'],
    columnMap: { 'Recipient Role': 'recipientRole' },
    required: ['event', 'recipientRole'],
    duplicateKeys: ['event', 'recipientRole'],
    flagFields: ['enabled'],
    sampleRows: [
      { event: 'Audit Assigned', recipientRole: 'Auditor', priority: 'High', enabled: 'Yes' },
      { event: 'Audit Due Tomorrow', recipientRole: 'Auditor', priority: 'High', enabled: 'Yes' },
    ],
  },
  systemSettings: {
    label: 'System Settings',
    description: 'Import system settings.',
    fileName: 'system-settings-template',
    sheetName: 'System Settings',
    columns: ['Setting Name', 'Value', 'Description'],
    columnMap: { 'Setting Name': 'settingName' },
    required: ['settingName'],
    duplicateKeys: ['settingName'],
    sampleRows: [
      { settingName: 'Application Name', value: 'Drive Pulse - DISHA HSC', description: 'System name displayed across application' },
      { settingName: 'Mobile Login Enabled', value: 'Yes', description: 'Allow login using registered mobile number' },
    ],
  },
}

const initialData = Object.fromEntries(Object.entries(importTypes).map(([key, config]) => [key, config.sampleRows.map((row, index) => ({ id: `${key}-${index + 1}`, ...row }))]))

function camelCase(label) {
  return label
    .replace(/[^a-zA-Z0-9]+(.)/g, (_, char) => char.toUpperCase())
    .replace(/^[A-Z]/, char => char.toLowerCase())
    .replace(/[^a-zA-Z0-9]/g, '')
}

function normalizeValue(value) {
  return String(value ?? '').trim()
}

function normalizeMobile(value) {
  if (value === null || value === undefined) return ''

  return String(value)
    .replace(/\.0$/, '')
    .replace(/\D/g, '')
    .slice(-10)
}

function normalizeHeader(value) {
  return normalizeValue(value)
    .replace(/\r\n|\n|\r/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
}

function logImportDebug(stage, details) {
  void stage
  void details
}

function normalizeFlag(value) {
  return normalizeValue(value).toLowerCase()
}

function normalizeRoleKey(value) {
  return normalizeValue(value).replace(/\s+/g, '').toLowerCase()
}

function normalizeUserRole(value) {
  return userRoleLookup.get(normalizeRoleKey(value)) || ''
}

function normalizeUserLocation(value) {
  const location = normalizeValue(value)
  if (!location) return { location: '', locationScope: 'group', locationNote: 'Group-level user' }
  if (location.toLowerCase() === 'group') return { location: '', locationScope: 'group', locationNote: 'Group-level user' }
  if (location.toLowerCase() === 'rural') return { location: 'RURAL', locationScope: 'rural', locationNote: 'RURAL location text retained; mapping can be handled later' }
  if (location.includes(',')) {
    return {
      location: '',
      locationScope: 'multi-location',
      locationNote: `Multiple locations supplied (${location}); marked as multi-location user`,
      sourceLocations: location.split(',').map(item => normalizeValue(item)).filter(Boolean),
    }
  }
  return { location, locationScope: 'location', locationNote: '' }
}

function locationIsValidForRole(role, normalizedLocation) {
  if (role !== 'Location Functional HOD') return true
  return normalizedLocation.locationScope === 'location'
    && Boolean(normalizedLocation.location)
    && !normalizedLocation.location.includes(',')
}

function flagSelected(value) {
  return acceptedFlagValues.has(normalizeFlag(value))
}

function flagIsValid(value) {
  return acceptedFlagValues.has(normalizeFlag(value)) || rejectedFlagValues.has(normalizeFlag(value))
}

function fieldFlagIsValid(value) {
  return acceptedFlagValues.has(normalizeFlag(value)) || inactiveStatusValues.has(normalizeFlag(value)) || rejectedFlagValues.has(normalizeFlag(value))
}

function normalizeImportStatus(value) {
  const status = normalizeFlag(value)
  if (activeStatusValues.has(status)) return 'active'
  if (inactiveStatusValues.has(status)) return 'inactive'
  return ''
}

function normalizeColumnKey(label, config) {
  const header = normalizeHeader(label)
  const mappedKey = Object.entries(config?.columnMap || {})
    .find(([sourceHeader]) => normalizeHeader(sourceHeader) === header)?.[1]
  if (mappedKey) return mappedKey
  const key = camelCase(normalizeHeader(label))
  return key
}

function normalizeRowHeaders(row) {
  return Object.fromEntries(Object.entries(row).map(([key, value]) => [normalizeHeader(key), value]))
}

function csvEscape(value) {
  return `"${String(value ?? '').replaceAll('"', '""')}"`
}

function rowsToSheetRows(config, rows) {
  if (config === importTypes.checklist) return rows.map(row => checklistTemplateColumns.reduce((acc, column) => {
    const departmentMatch = checklistDepartmentColumns.find(([header]) => header === column)
    const facilityMatch = checklistFacilityColumns.find(([header]) => header === column)
    if (column === 'DISHA Question No.') acc[column] = row.questionCode ?? ''
    else if (departmentMatch) acc[column] = row.applicableDepartments?.includes(departmentMatch[1]) ? 'Y' : ''
    else if (facilityMatch) acc[column] = row.applicableFacilityTypes?.includes(facilityMatch[1]) ? 'Y' : ''
    else if (column === 'Classification') acc[column] = row.classification ?? ''
    else if (column === 'Location / Aspect') acc[column] = row.locationAspect ?? ''
    else if (column === 'Guest Experience Impact') acc[column] = row.guestImpact ?? ''
    else if (column === 'Evaluation Parameter') acc[column] = row.evaluationParameter ?? ''
    else if (column === 'Evaluation Question') acc[column] = row.evaluationQuestion ?? ''
    else if (column === 'Purpose') acc[column] = row.purpose ?? ''
    else if (column === 'Checking Method') acc[column] = row.checkingMethod ?? ''
    else if (column === 'Additional Information (Items / Documents / Material)') acc[column] = row.additionalInformation ?? ''
    else if (column === 'Requirement') acc[column] = row.requirement ?? ''
    else if (column === 'Photo / Document Description\r\n[Evaluator Reference]') acc[column] = row.evidenceDescription ?? ''
    else if (column === 'Process KPI') acc[column] = row.processKpi ?? ''
    else if (column === 'Result KPI') acc[column] = row.resultKpi ?? ''
    else if (column === 'SOP / Material Reference') acc[column] = row.sopReference ?? ''
    return acc
  }, {}))

  return rows.map(row => config.columns.reduce((acc, column) => ({
    ...acc,
    [column]: row[normalizeColumnKey(column, config)] ?? '',
  }), {}))
}

function downloadBlob(filename, mimeType, content) {
  const blob = content instanceof Blob ? content : new Blob([content], { type: mimeType })
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = filename
  anchor.click()
  URL.revokeObjectURL(url)
}

function downloadTemplate(config, format) {
  const workbook = XLSX.utils.book_new()
  const sheet = XLSX.utils.json_to_sheet(rowsToSheetRows(config, config.sampleRows), { header: config.columns })
  XLSX.utils.book_append_sheet(workbook, sheet, config.label.slice(0, 31))
  if (format === 'xlsx') {
    const xlsxArray = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
    downloadBlob(`${config.fileName}.xlsx`, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', new Blob([xlsxArray]))
    return
  }

  const csv = XLSX.utils.sheet_to_csv(sheet)
  downloadBlob(`${config.fileName}.csv`, 'text/csv;charset=utf-8', csv)
}

function rowDisplayValue(row, column, config) {
  if (column === 'Location' && row.locationScope === 'group') return row.locationNote || 'Group'
  if (column === 'Location' && row.locationScope === 'multi-location') return row.locationNote || row.sourceLocations?.join(', ') || 'Multi-location'
  if (column === 'Location' && row.locationScope === 'rural') return row.locationNote || 'RURAL'
  return row[normalizeColumnKey(column, config)] || row[column] || '-'
}

function workbookColumnDisplayValue(row, column, config) {
  if (config === importTypes.checklist) return rowsToSheetRows(config, [row])[0][column] || '-'
  return rowDisplayValue(row, column, config)
}

function getHeaderIssues(headers, config, strict = true) {
  const normalizedActual = headers.map(normalizeHeader).filter(Boolean)
  if (!strict) {
    const actualKeys = new Set(normalizedActual.map(header => normalizeColumnKey(header, config)))
    const missing = config.required.filter(field => !actualKeys.has(field))
    return { missing, unexpected: [] }
  }

  const expectedHeaders = config.columns.map(normalizeHeader)
  const ignoredHeaders = new Set((config.ignoredHeaders || []).map(normalizeHeader))
  const actualForValidation = normalizedActual.filter(header => !ignoredHeaders.has(header))
  const actualSet = new Set(actualForValidation)
  const expectedSet = new Set(expectedHeaders)
  const missing = expectedHeaders.filter(header => !actualSet.has(header))
  const unexpected = actualForValidation.filter(header => !expectedSet.has(header))
  return { missing, unexpected }
}

function fieldLabel(field, config) {
  return config.columns.find(column => normalizeColumnKey(column, config) === field) || field
}

function missingFieldLabels(fields, config) {
  return fields.map(field => fieldLabel(field, config)).join(', ')
}

function normalizeDbText(value) {
  return normalizeValue(value).toLowerCase()
}

function findByName(items, value, key = 'name') {
  const wanted = normalizeDbText(value)
  return items.find(item => normalizeDbText(item[key]) === wanted)
}

function firstValidFacilityType(facilityTypes) {
  return (facilityTypes || []).find(item => ['3S', '2S', '1S', 'TES', 'Satellite', 'Rural'].includes(item)) || null
}

function collectApplicableDepartments(rawRow) {
  return checklistDepartmentColumns
    .filter(([header]) => flagSelected(rawRow[normalizeHeader(header)] ?? rawRow[header]))
    .map(([, department]) => department)
}

function normalizeChecklistKeyPart(value) {
  return normalizeValue(value).replace(/\s+/g, ' ').toLowerCase()
}

function normalizeChecklistKeyArray(values) {
  return [...(values || [])].map(normalizeChecklistKeyPart).filter(Boolean).sort().join(',')
}

function checklistDuplicateKey(row) {
  return [
    normalizeChecklistKeyPart(row.questionCode),
    normalizeChecklistKeyPart(row.evaluationQuestion),
    normalizeChecklistKeyPart(row.evaluationParameter),
    normalizeChecklistKeyPart(row.classification),
    normalizeChecklistKeyPart(row.locationAspect),
    normalizeChecklistKeyPart(row.guestImpact),
    normalizeChecklistKeyArray(row.applicableDepartments),
    normalizeChecklistKeyArray(row.applicableFacilityTypes),
  ].join('||')
}

function checklistGeneratedUniqueKey(row) {
  return [
    normalizeChecklistKeyPart(row.questionCode),
    normalizeChecklistKeyPart(row.evaluationQuestion),
    normalizeChecklistKeyPart(row.evaluationParameter),
    normalizeChecklistKeyArray(row.applicableDepartments),
    normalizeChecklistKeyArray(row.applicableFacilityTypes),
  ].join('||')
}

function getChecklistField(row, aliases, fallback = '') {
  for (const alias of aliases) {
    const normalizedAlias = normalizeHeader(alias)
    const value = normalizeValue(row[normalizedAlias] ?? row[alias])
    if (value) return value
  }
  return fallback
}

function normalizeChecklistActive(value, fallback = true) {
  const flag = normalizeFlag(value)
  if (!flag) return fallback
  if (['no', 'n', 'false', '0', 'inactive'].includes(flag)) return false
  if (['yes', 'y', 'true', '1', 'active'].includes(flag)) return true
  return fallback
}

function buildChecklistMasterRow(rawRow, previousRow, index) {
  const workbookRow = mapChecklistRow(rawRow)
  const questionCode = workbookRow.questionCode || previousRow?.questionCode || ''
  const subQuestionIndex = previousRow?.questionCode === questionCode ? (previousRow?.subQuestionIndex || 0) + 1 : 1
  const guestImpact = workbookRow.guestImpact === 'Indirect' ? 'Indirect' : 'Direct'
  const uniqueKey = checklistGeneratedUniqueKey({ ...workbookRow, questionCode })

  return {
    ...workbookRow,
    questionCode,
    subQuestionIndex,
    checklistPoint: workbookRow.evaluationQuestion,
    standardRequirement: workbookRow.requirement,
    maxScore: 1,
    auditType: 'DISHA HSC',
    department: workbookRow.applicableDepartments.join(', '),
    location: workbookRow.locationAspect,
    category: workbookRow.classification,
    subCategory: workbookRow.evaluationParameter,
    active: true,
    checklist_code: questionCode,
    version: `v1-${questionCode}-${String(subQuestionIndex).padStart(3, '0')}-${stableHash(uniqueKey).slice(0, 6)}`,
    section: workbookRow.classification || 'DISHA HSC',
    area: workbookRow.applicableDepartments.join(', ') || 'DISHA HSC',
    chapter: workbookRow.evaluationParameter || questionCode || 'DISHA HSC',
    classification: workbookRow.classification || 'General',
    location_aspect: workbookRow.locationAspect || null,
    evaluation_question: workbookRow.evaluationQuestion,
    evaluation_parameter: workbookRow.evaluationParameter,
    guest_experience_impact: guestImpact,
    facility_type: firstValidFacilityType(workbookRow.applicableFacilityTypes),
    question: workbookRow.requirement || workbookRow.evaluationQuestion || workbookRow.evaluationParameter,
    purpose: workbookRow.purpose,
    checking_method: workbookRow.checkingMethod,
    additional_info: workbookRow.additionalInformation,
    sop_reference: workbookRow.sopReference,
    evidence_required: normalizeValue(workbookRow.requirement).toLowerCase() === 'yes',
    applicable_departments: workbookRow.applicableDepartments,
    department_owner_id: null,
    status: 'active',
  }
}

function stableHash(value) {
  let hash = 5381
  for (let index = 0; index < value.length; index += 1) {
    hash = ((hash << 5) + hash) + value.charCodeAt(index)
    hash |= 0
  }
  return Math.abs(hash).toString(36)
}

function supabaseChecklistToImportRow(row) {
  return {
    id: row.id,
    questionCode: row.checklist_code,
    subQuestionNum: row.sub_question_num,
    applicableDepartments: Array.isArray(row.applicable_departments) ? row.applicable_departments : [],
    applicableFacilityTypes: row.facility_type ? [row.facility_type] : [],
    classification: row.classification,
    locationAspect: row.location_aspect,
    guestImpact: row.guest_experience_impact,
    riskLevel: row.guest_experience_impact === 'Direct' ? 'Critical' : 'Medium',
    evaluationParameter: row.evaluation_parameter,
    evaluationQuestion: row.evaluation_question,
    purpose: row.purpose,
    checkingMethod: row.checking_method,
    additionalInformation: row.additional_info,
    requirement: row.question,
    evidenceDescription: '',
    processKpi: '',
    resultKpi: '',
    sopReference: row.sop_reference,
    evidenceRequired: row.evidence_required,
    active: row.status === 'active',
    status: row.status,
  }
}

async function loadSupabaseLookups(client) {
  const [rolesResult, departmentsResult, locationsResult] = await Promise.all([
    client.from('roles').select('id,name'),
    client.from('departments').select('id,name'),
    client.from('locations').select('id,code,name,type'),
  ])
  logImportDebug('Supabase lookup response', {
    roles: { count: rolesResult.data?.length || 0, error: rolesResult.error },
    departments: { count: departmentsResult.data?.length || 0, error: departmentsResult.error },
    locations: { count: locationsResult.data?.length || 0, error: locationsResult.error },
  })
  const error = rolesResult.error || departmentsResult.error || locationsResult.error
  if (error) throw error
  return {
    roles: rolesResult.data || [],
    departments: departmentsResult.data || [],
    locations: locationsResult.data || [],
    rolesById: new Map((rolesResult.data || []).map(row => [row.id, row])),
    departmentsById: new Map((departmentsResult.data || []).map(row => [row.id, row])),
    locationsById: new Map((locationsResult.data || []).map(row => [row.id, row])),
  }
}

function buildChecklistPayload(rows, lookups = null, includeV1ImportHelpers = false) {
  return rows.map((row, index) => {
    const ownerDepartmentName = row.applicableDepartments?.[0]
    const department = lookups && ownerDepartmentName ? findByName(lookups.departments, ownerDepartmentName) : null
    const guestImpact = row.guestImpact === 'Indirect' ? 'Indirect' : 'Direct'
    const importIdentityKey = checklistDuplicateKey(row)
    return {
      checklist_code: row.questionCode || `DQ-${index + 1}`,
      sub_question_num: Number.isFinite(Number(row.subQuestionIndex)) ? Number(row.subQuestionIndex) : null,
      version: `v1-${stableHash(importIdentityKey)}`,
      section: row.classification || 'DISHA HSC',
      area: row.locationAspect || row.classification || 'DISHA HSC',
      chapter: row.evaluationParameter || row.questionCode || 'DISHA HSC',
      classification: row.classification || 'General',
      location_aspect: row.locationAspect || null,
      evaluation_question: row.evaluationQuestion || '',
      evaluation_parameter: row.evaluationParameter || '',
      guest_experience_impact: guestImpact,
      facility_type: firstValidFacilityType(row.applicableFacilityTypes),
      question: row.requirement || row.evaluationQuestion || row.evaluationParameter || row.questionCode || 'Checklist question',
      purpose: row.purpose || null,
      checking_method: row.checkingMethod || null,
      additional_info: row.additionalInformation || null,
      sop_reference: row.sopReference || null,
      evidence_required: normalizeValue(row.requirement).toLowerCase() === 'yes',
      applicable_departments: row.applicableDepartments || [],
      department_owner_id: department?.id || null,
      ...(includeV1ImportHelpers ? { department_owner_name: ownerDepartmentName || null } : {}),
      import_unique_key: checklistGeneratedUniqueKey(row),
      status: 'active',
    }
  })
}

async function writeChecklistToSupabase(rows) {
  const client = requireSupabase()
  const payload = rows.map((row, index) => ({
    checklist_code: row.checklist_code || `CHK-${String(index + 1).padStart(4, '0')}`,
    sub_question_num: Number.isFinite(Number(row.subQuestionIndex)) ? Number(row.subQuestionIndex) : null,
    version: row.version || 'v1',
    section: row.section || row.auditType || 'Checklist Master',
    area: row.area || row.location || row.department || row.auditType || 'Checklist Master',
    chapter: row.chapter || row.subCategory || row.category || row.department || row.auditType || 'Checklist Master',
    classification: row.classification || row.category || 'General',
    location_aspect: row.location_aspect || row.location || null,
    evaluation_question: row.evaluation_question || row.checklistPoint || '',
    evaluation_parameter: row.evaluation_parameter || row.standardRequirement || '',
    guest_experience_impact: row.guest_experience_impact || 'Direct',
    facility_type: row.facility_type || null,
    question: row.question || row.checklistPoint || 'Checklist point',
    purpose: row.purpose || null,
    checking_method: row.checking_method || null,
    additional_info: row.additional_info || null,
    sop_reference: row.sop_reference || null,
    evidence_required: normalizeValue(row.requirement || row.question || '').toLowerCase() === 'yes' ? true : Boolean(row.evidence_required),
    applicable_departments: row.applicable_departments || [],
    department_owner_id: row.department_owner_id || null,
    status: row.status || (row.active ? 'active' : 'inactive'),
  }))

  const deleteResult = await client
    .from('audit_checklist_master')
    .delete()
    .neq('checklist_code', '__disha_hsc_never_matches__')
  if (deleteResult.error) {
    throw new Error(`Unable to delete old audit checksheet before upload: ${deleteResult.error.message}`)
  }

  logImportDebug('Checklist Supabase payload', {
    rpcCalled: false,
    rpcName: 'direct-upsert-audit_checklist_master',
    totalRows: rows.length,
    payloadLength: payload.length,
    firstPayloadRow: payload[0] || null,
    firstPayloadFieldNames: payload[0] ? Object.keys(payload[0]) : [],
    payloadSample: payload.slice(0, 3),
    importMethod: 'direct_table_upsert',
    viteEnvBlockingRpcPath: false,
  })
  const writeResult = await client
    .from('audit_checklist_master')
    .upsert(payload, { onConflict: 'checklist_code,version' })
    .select('id, checklist_code, status')
  logImportDebug('Checklist Supabase write response', {
    rpcCalled: false,
    rpcName: 'direct-upsert-audit_checklist_master',
    payloadLength: payload.length,
    firstPayloadRow: payload[0] || null,
    firstPayloadFieldNames: payload[0] ? Object.keys(payload[0]) : [],
    response: writeResult,
    dataCount: writeResult.data?.length || 0,
    dataSample: writeResult.data?.slice(0, 3),
    supabaseRpcError: writeResult.error,
  })
  if (writeResult.error) throw writeResult.error
  if (payload.length > 0 && (writeResult.data?.length || 0) === 0) {
    throw new Error('Checklist import returned 0 rows for a non-empty payload.')
  }
  const refreshResult = await client
    .from('audit_checklist_master')
    .select('id, checklist_code, version, section, area, chapter, classification, applicable_departments, location_aspect, evaluation_question, evaluation_parameter, guest_experience_impact, facility_type, question, purpose, checking_method, additional_info, sop_reference, evidence_required, status')
    .eq('status', 'active')
    .order('checklist_code', { ascending: true })
  if (refreshResult.error) throw refreshResult.error
  const backendCount = refreshResult.data?.length || 0
  return {
    inserted: writeResult.data?.length || 0,
    updated: 0,
    skipped: 0,
    rows: (refreshResult.data || []).map(supabaseChecklistToImportRow),
    backendCount,
  }
}

function mapChecklistRow(rawRow) {
  const value = header => normalizeValue(rawRow[normalizeHeader(header)] ?? rawRow[header])
  const guestImpact = value('Guest Experience Impact')
  const evidenceDescription = value('Photo / Document Description [Evaluator Reference]')
  return {
    questionCode: value('DISHA Question No.'),
    evaluationQuestion: value('Evaluation Question'),
    evaluationParameter: value('Evaluation Parameter'),
    classification: value('Classification'),
    locationAspect: value('Location / Aspect'),
    guestImpact,
    riskLevel: guestImpact === 'Direct' ? 'Critical' : guestImpact === 'Indirect' ? 'Medium' : '',
    purpose: value('Purpose'),
    checkingMethod: value('Checking Method'),
    additionalInformation: value('Additional Information (Items / Documents / Material)'),
    requirement: value('Requirement'),
    evidenceDescription,
    processKpi: value('Process KPI'),
    resultKpi: value('Result KPI'),
    sopReference: value('SOP / Material Reference'),
    applicableDepartments: collectApplicableDepartments(rawRow),
    applicableFacilityTypes: checklistFacilityColumns.filter(([header]) => flagSelected(rawRow[normalizeHeader(header)] ?? rawRow[header])).map(([, facility]) => facility),
    active: true,
    evidenceRequired: normalizeValue(value('Requirement')).toLowerCase() === 'yes',
    status: 'Active',
  }
}

function validateChecklistRows(parsedRows, selectedType) {
  const accepted = []
  const failures = []
  let mandatoryMissing = 0
  let previousRow = null

  parsedRows.forEach((rawRow, index) => {
    const lineNo = index + 2
    const row = buildChecklistMasterRow(rawRow, previousRow, index)
    const rowIssues = []
    if (!row.questionCode) {
      mandatoryMissing += 1
      rowIssues.push('Missing DISHA Question No.')
    }
    if (!row.evaluationParameter) rowIssues.push('Missing Evaluation Parameter')
    if (!row.evaluationQuestion) {
      mandatoryMissing += 1
      rowIssues.push('Missing Evaluation Question')
    }

    if (rowIssues.length) {
      failures.push({ row: lineNo, issue: rowIssues.join(' | '), ...row })
      return
    }

    previousRow = {
      questionCode: row.questionCode,
      subQuestionIndex: row.subQuestionIndex,
    }
    accepted.push({ id: `${selectedType}-${Date.now()}-${index}`, ...row })
  })

  return { accepted, failures, duplicateCount: 0, mandatoryMissing }
}

export default function MasterImport() {
  const [selectedType, setSelectedType] = useState('users')
  const [records, setRecords] = useState(initialData)
  const [fileName, setFileName] = useState('')
  const [importState, setImportState] = useState(null)
  const [dragActive, setDragActive] = useState(false)
  const [duplicateMode, setDuplicateMode] = useState('skip')
  const [supabaseStatus, setSupabaseStatus] = useState(null)
  const [isImporting, setIsImporting] = useState(false)
  const fileInputRef = useRef(null)
  const auth = useAuth()
  const { importUsers } = auth
  const canAdminister = isSystemAdmin(auth.user)
  const config = importTypes[selectedType]
  const rows = records[selectedType]
  const hasActiveColumn = config.columns.includes('Active')

  const summary = useMemo(() => {
    if (!importState) return { total: 0, valid: 0, errors: 0, duplicates: 0, updated: 0, skipped: 0, mandatoryMissing: 0 }
    return importState.summary
  }, [importState])

  function mapRow(row) {
    const ignoredHeaders = new Set((config.ignoredHeaders || []).map(normalizeHeader))
    const mapped = Object.fromEntries(Object.entries(row)
      .filter(([key]) => !ignoredHeaders.has(normalizeHeader(key)))
      .map(([key, value]) => [normalizeColumnKey(key, config), normalizeValue(value)]))
    if (selectedType === 'users') {
      mapped.mobile_number = normalizeMobile(mapped.mobile_number || row.mobile || row.Mobile || row['Mobile Number'] || row.mobile_number)
      mapped.password = String(mapped.password || row.password || row.Password || row['Password'] || '').trim()
    }
    if (selectedType !== 'checklist' && hasActiveColumn) {
      const hasStatusColumn = Object.prototype.hasOwnProperty.call(mapped, 'status')
      if (hasStatusColumn) {
        const normalizedStatus = normalizeImportStatus(mapped.status)
        mapped.statusInvalid = !normalizedStatus
        mapped.status = normalizedStatus || ''
      } else {
        mapped.status = 'active'
      }
    }
    return mapped
  }

  function validateGenericRows(parsedRows) {
    const existingKeys = new Set(rows.map(row => config.duplicateKeys.map(key => normalizeValue(row[key]).toLowerCase()).join('||')))
    const seenKeys = new Set()
    const accepted = []
    const failures = []
    let duplicateCount = 0
    let mandatoryMissing = 0

    parsedRows.forEach((row, index) => {
      const lineNo = index + 2
      const missingFields = config.required.filter(field => !normalizeValue(row[field]))
      const duplicateKey = config.duplicateKeys.map(key => normalizeValue(row[key]).toLowerCase()).join('||')
      const rowIssues = []

      if (missingFields.length) {
        mandatoryMissing += 1
        rowIssues.push(`Missing mandatory fields: ${missingFieldLabels(missingFields, config)}`)
      }

      if (row.statusInvalid) {
        rowIssues.push('Invalid status. Use Active, Yes, Y, TRUE, 1, Inactive, No, N, FALSE, 0, or leave blank.')
      }

      const invalidFlagFields = (config.flagFields || []).filter(field => !fieldFlagIsValid(row[field]))
      if (invalidFlagFields.length) {
        rowIssues.push(`Invalid flag values: ${missingFieldLabels(invalidFlagFields, config)}. Use Yes, Y, TRUE, 1, No, N, FALSE, 0, -, or leave blank.`)
      }

      if (duplicateKey && (existingKeys.has(duplicateKey) || seenKeys.has(duplicateKey))) {
        duplicateCount += 1
        rowIssues.push('Duplicate record already exists')
      }

      if (rowIssues.length) {
        failures.push({ row: lineNo, issue: rowIssues.join(' | '), ...row })
        return
      }

      seenKeys.add(duplicateKey)
      const { statusInvalid, ...cleanRow } = row
      accepted.push({
        id: `${selectedType}-${Date.now()}-${index}`,
        ...cleanRow,
        ...(hasActiveColumn ? { status: cleanRow.status || 'active' } : {}),
      })
    })

    return { accepted, failures, duplicateCount, mandatoryMissing }
  }

  function validateUserRows(parsedRows) {
    const accepted = []
    const updates = []
    const skipped = []
    const failures = []
    let mandatoryMissing = 0

    parsedRows.forEach((row, index) => {
      const lineNo = index + 2
      const mobileKey = normalizeMobile(row.mobile_number || row.mobile || row.Mobile || row['Mobile Number'] || row.mobile_number)
      const missingFields = config.required.filter(field => !normalizeValue(row[field]))
      const rowIssues = []
      const normalizedRole = normalizeUserRole(row.role)
      const normalizedLocation = normalizeUserLocation(row.location)

      if (missingFields.length) {
        mandatoryMissing += 1
        rowIssues.push(`Missing mandatory fields: ${missingFieldLabels(missingFields, config)}`)
      }
      if (mobileKey.length !== 10) rowIssues.push('Invalid mobile number')
      if (row.role && (!normalizedRole || !mockUserRoles.has(normalizedRole))) rowIssues.push('Role not found')
      if (normalizedRole && !locationIsValidForRole(normalizedRole, normalizedLocation)) rowIssues.push('Location Functional HOD requires one specific location')
      if (row.statusInvalid) rowIssues.push('Invalid status. Use Active, Yes, Y, TRUE, 1, Inactive, No, N, FALSE, 0, or leave blank.')

      if (rowIssues.length) {
        failures.push({ row: lineNo, issue: rowIssues.join(' | '), ...row })
        return
      }

      const { statusInvalid, ...cleanRow } = row
      const profileRow = {
        id: `${selectedType}-${Date.now()}-${index}`,
        ...cleanRow,
        mobile: mobileKey,
        mobile_number: mobileKey,
        password: DEFAULT_PASSWORD,
        role: normalizedRole,
        ...normalizedLocation,
        designation: cleanRow.designation || '',
        is_active: (cleanRow.status || 'active') === 'active',
        status: cleanRow.status || 'active',
      }
      accepted.push({
        ...profileRow,
        password: profileRow.password,
        must_reset_password: true,
        must_change_password: true,
      })
    })

    return {
      accepted,
      updates,
      skipped,
      failures,
      duplicateCount: 0,
      mandatoryMissing,
    }
  }

  function validateAndPreview(file) {
    const extension = file.name.split('.').pop().toLowerCase()
    const reader = new FileReader()

    reader.onload = event => {
      try {
        const workbook = extension === 'csv'
          ? XLSX.read(event.target.result, { type: 'string' })
          : XLSX.read(event.target.result, { type: 'array' })
        const matchingSheetName = workbook.SheetNames.find(name => normalizeHeader(name).toLowerCase() === normalizeHeader(config.sheetName || config.label).toLowerCase())
        const sheet = workbook.Sheets[matchingSheetName || workbook.SheetNames[0]]
        const sheetRows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' })
        const headers = (sheetRows[0] || []).map(normalizeHeader)
        const parsedRows = XLSX.utils.sheet_to_json(sheet, { defval: '', raw: false }).map(normalizeRowHeaders)
        const headerIssues = getHeaderIssues(headers, config, selectedType !== 'users')
        logImportDebug('Workbook parsed', {
          file: file.name,
          importType: selectedType,
          workbookSheets: workbook.SheetNames,
          selectedSheetName: matchingSheetName || workbook.SheetNames[0],
          expectedSheetName: config.sheetName || config.label,
          detectedHeaders: headers,
          expectedHeaders: config.columns,
          missingHeaders: headerIssues.missing,
          unexpectedHeaders: headerIssues.unexpected,
          totalRowsParsed: parsedRows.length,
          rawSheetRowCount: Math.max(sheetRows.length - 1, 0),
          payloadSampleBeforeValidation: parsedRows.slice(0, 3),
        })

        if (headerIssues.missing.length || headerIssues.unexpected.length) {
          const failures = [{
            row: 1,
            issue: [
              headerIssues.missing.length ? `Missing headers: ${headerIssues.missing.join(', ')}` : '',
              headerIssues.unexpected.length ? `Unexpected headers: ${headerIssues.unexpected.join(', ')}` : '',
            ].filter(Boolean).join(' | '),
          }]
          setImportState({
            file: file.name,
            type: selectedType,
            accepted: [],
            failures,
            confirmed: false,
          summary: { total: Math.max(sheetRows.length - 1, 0), valid: 0, errors: failures.length, duplicates: 0, updated: 0, skipped: 0, mandatoryMissing: 0 },
            errors: failures,
          })
          logImportDebug('Validation result', {
            importType: selectedType,
            totalRowsParsed: Math.max(sheetRows.length - 1, 0),
            validRows: 0,
            errorRows: failures.length,
            failuresSample: failures.slice(0, 5),
            payloadSampleBeforeImport: [],
          })
          setFileName(file.name)
          return
        }

        const validation = selectedType === 'checklist'
          ? validateChecklistRows(parsedRows, selectedType)
          : selectedType === 'users'
            ? validateUserRows(parsedRows.map(mapRow))
            : validateGenericRows(parsedRows.map(mapRow))
        logImportDebug('Validation result', {
          importType: selectedType,
          rowsMarkedValidBeforeConfirm: validation.accepted.length,
          confirmImportEnabledAfterValidation: Boolean(validation.accepted.length),
          totalRowsParsed: parsedRows.length,
          validRows: validation.accepted.length,
          updatedRows: validation.updates?.length || 0,
          skippedRows: validation.skipped?.length || 0,
          errorRows: validation.failures.length,
          duplicateRows: validation.duplicateCount,
          mandatoryMissingRows: validation.mandatoryMissing,
          failuresSample: validation.failures.slice(0, 5),
          payloadSampleBeforeImport: [
            ...(validation.accepted || []),
            ...(validation.updates || []),
            ...(validation.skipped || []),
          ].slice(0, 3),
        })

        setImportState({
          file: file.name,
          type: selectedType,
          accepted: validation.accepted,
          updates: validation.updates || [],
          skipped: validation.skipped || [],
          failures: validation.failures,
          confirmed: false,
          summary: {
            total: parsedRows.length,
            valid: validation.accepted.length,
            errors: validation.failures.length,
            duplicates: validation.duplicateCount,
            updated: validation.updates?.length || 0,
            skipped: validation.skipped?.length || 0,
            mandatoryMissing: validation.mandatoryMissing,
          },
          errors: validation.failures,
        })
        setFileName(file.name)
      } catch (error) {
        logImportDebug('Workbook parse failed', {
          file: file.name,
          importType: selectedType,
          error,
        })
        setImportState({
          file: file.name,
          type: selectedType,
          accepted: [],
          failures: [{ row: 1, issue: 'Unable to read the uploaded file. Please use the provided template format.' }],
          confirmed: false,
          summary: { total: 0, valid: 0, errors: 1, duplicates: 0, updated: 0, skipped: 0, mandatoryMissing: 0 },
          errors: [{ row: 1, issue: 'Unable to read the uploaded file. Please use the provided template format.' }],
        })
        setFileName(file.name)
      }
    }

    if (extension === 'csv') reader.readAsText(file)
    else reader.readAsArrayBuffer(file)
  }

  async function confirmImport() {
    if (!canAdminister || !hasImportableRows || importState.confirmed || isImporting) return
    setSupabaseStatus(null)
    setIsImporting(true)
    if (selectedType === 'users') {
      const rowsToWrite = [...(importState.accepted || []), ...(importState.updates || [])]
      logImportDebug('Users import payload', {
        acceptedRows: importState.accepted?.length || 0,
        updatedRows: importState.updates?.length || 0,
        skippedRowsExcludedFromPayload: importState.skipped?.length || 0,
        totalRowsToWrite: rowsToWrite.length,
        payloadSampleBeforeImport: rowsToWrite.slice(0, 3),
        backendTable: 'app_users',
      })
      try {
        const authImport = await importUsers(rowsToWrite)
        logImportDebug('Users import Supabase response', {
          authImport,
          backendUsersTable: 'app_users',
          backendMappingsTable: 'user_access_mappings',
          uniqueUsersWritten: (authImport.created || 0) + (authImport.updated || 0),
          mappingsWritten: authImport.mappings || 0,
        })
        setRecords(current => ({ ...current, users: [...(importState.accepted || [])] }))
        setSupabaseStatus({
          inserted: authImport.created || 0,
          updated: authImport.updated || 0,
          skipped: importState.skipped?.length || 0,
          mappings: authImport.mappings || 0,
          local: false,
        })
        setImportState(current => ({
          ...current,
          confirmed: true,
          summary: {
            ...current.summary,
            valid: authImport.created || 0,
            updated: authImport.updated || 0,
            skipped: importState.skipped?.length || 0,
          },
        }))
      } catch (error) {
        logImportDebug('Users import failed', {
          error,
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        })
        setSupabaseStatus({ error: error.message || 'Users Master import failed.' })
        setImportState(current => ({
          ...current,
          errors: [...(current?.errors || []), { row: 0, issue: error.message || 'Users Master import failed.' }],
          summary: { ...(current?.summary || {}), errors: (current?.summary?.errors || 0) + 1 },
        }))
      }
      setIsImporting(false)
      return
    }

    if (selectedType === 'checklist') {
      try {
        const rowsToWrite = importState.accepted || []
        logImportDebug('Checklist confirm payload', {
          rpcWillBeCalled: false,
          validRows: rowsToWrite.length,
          rowsMarkedValidBeforeConfirm: importState.accepted?.length || 0,
          errorRows: importState.failures?.length || 0,
          payloadLengthBeforeBuild: rowsToWrite.length,
          payloadSampleBeforeImport: rowsToWrite.slice(0, 3),
        })
        const result = await writeChecklistToSupabase(rowsToWrite)
        setRecords(current => ({ ...current, [selectedType]: result.rows }))
        setSupabaseStatus(result)
        logImportDebug('Checklist import summary', {
          parsedRows: rowsToWrite.length,
          savedRows: result.inserted || 0,
          backendCount: result.backendCount || 0,
        })
        setImportState(current => ({
          ...current,
          confirmed: true,
          summary: {
            ...current.summary,
            valid: result.inserted,
            updated: result.updated,
            skipped: result.skipped,
            backendCount: result.backendCount || 0,
          },
        }))
        setIsImporting(false)
        return
      } catch (error) {
        logImportDebug('Checklist import failed', {
          error,
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        })
        setSupabaseStatus({ error: error.message || 'Supabase import failed.' })
        setImportState(current => ({
          ...current,
          errors: [...(current?.errors || []), { row: 0, issue: error.message || 'Supabase import failed.' }],
          summary: { ...(current?.summary || {}), errors: (current?.summary?.errors || 0) + 1 },
        }))
        setIsImporting(false)
        return
      }
    }
    setRecords(current => {
      if (selectedType !== 'users') return { ...current, [selectedType]: [...current[selectedType], ...importState.accepted] }
      const updatesByMobile = new Map((importState.updates || []).map(row => [normalizeValue(row.mobile_number).toLowerCase(), row]))
      const updatedExisting = current.users.map(row => updatesByMobile.get(normalizeValue(row.mobile_number).toLowerCase()) || row)
      return { ...current, users: [...updatedExisting, ...(importState.accepted || [])] }
    })
    setImportState(current => ({ ...current, confirmed: true }))
    setIsImporting(false)
  }

  function resetImport(type = selectedType) {
    setSelectedType(type)
    setImportState(null)
    setFileName('')
    setSupabaseStatus(null)
    setIsImporting(false)
    setDuplicateMode('skip')
  }

  function changeDuplicateMode(mode) {
    setDuplicateMode(mode)
    setImportState(null)
    setFileName('')
    setSupabaseStatus(null)
    setIsImporting(false)
  }

  function onFileChange(event) {
    const file = event.target.files?.[0]
    if (file) validateAndPreview(file)
    event.target.value = ''
  }

  function handleDrop(event) {
    event.preventDefault()
    setDragActive(false)
    const file = event.dataTransfer.files?.[0]
    if (file) validateAndPreview(file)
  }

  function downloadErrorReport() {
    const errors = importState?.errors || []
    const csv = ['Row,Issue,Question Code,Evaluation Parameter,Evaluation Question'].concat(errors.map(error => [
      error.row,
      error.issue,
      error.questionCode,
      error.evaluationParameter,
      error.evaluationQuestion,
    ].map(csvEscape).join(','))).join('\n')
    downloadBlob(`${config.fileName}-error-report.csv`, 'text/csv;charset=utf-8', csv)
  }

  const previewRows = selectedType === 'users' && importState
    ? [...(importState.accepted || []).map(row => ({ ...row, importOutcome: 'New User' })), ...(importState.updates || []).map(row => ({ ...row, importOutcome: 'Existing User Updated' })), ...(importState.skipped || [])]
    : importState?.accepted || []
  const hasImportableRows = selectedType === 'users'
    ? Boolean(importState?.accepted?.length || importState?.updates?.length || importState?.skipped?.length)
    : Boolean(importState?.accepted?.length)
  const visibleRows = previewRows.length ? previewRows : rows
  const tableTitle = previewRows.length && !importState?.confirmed ? 'Import Preview' : 'Imported and existing records'
  const processedRows = selectedType === 'users' ? summary.valid + summary.updated + summary.skipped : summary.valid
  const progressValue = summary.total ? Math.round((processedRows / summary.total) * 100) : 0

  return <div className="master-import-page">
    <PageHeader
      eyebrow="DATA OPERATIONS"
      title="Master Data Import"
      description="Upload Excel or CSV files, validate them locally, preview valid rows, then confirm import."
      action={<div className="import-header-actions"><button className="secondary-button" disabled={!canAdminister} onClick={() => canAdminister && downloadTemplate(config, 'xlsx')}><Download size={17} /> XLSX Template</button><button className="secondary-button" disabled={!canAdminister} onClick={() => canAdminister && downloadTemplate(config, 'csv')}><Download size={17} /> CSV Template</button></div>}
    />

    <section className="card import-banner">
      <div>
        <span className="eyebrow">IMPORT TARGET</span>
        <h2>{config.label}</h2>
        <p>{config.description}</p>
      </div>
      <div className="import-type-switch">
          {Object.entries(importTypes).map(([key, item]) => <button key={key} className={selectedType === key ? 'active' : ''} disabled={!canAdminister} onClick={() => canAdminister && resetImport(key)}>{item.label}</button>)}
      </div>
    </section>

    <div className="master-import-grid">
      <section className="card import-card">
        <div className="panel-head">
          <div><span className="eyebrow">UPLOAD FILE</span><h2>Excel or CSV import</h2></div>
          <StatusBadge>{fileName ? 'File selected' : 'No file selected'}</StatusBadge>
        </div>
        <div
          className={`import-dropzone ${dragActive ? 'active' : ''}`}
          onDragOver={event => { event.preventDefault(); setDragActive(true) }}
          onDragLeave={() => setDragActive(false)}
          onDrop={handleDrop}
        >
          <FileSpreadsheet size={34} />
          <strong>Drop a file here or browse from your device</strong>
          <span>Supported formats: `.xlsx`, `.xls`, `.csv`</span>
          <input ref={fileInputRef} type="file" accept=".xlsx,.xls,.csv" onChange={onFileChange} disabled={!canAdminister} />
          <button className="primary-button" type="button" disabled={!canAdminister} onClick={() => canAdminister && fileInputRef.current?.click()}><Upload size={17} /> Choose File</button>
        </div>

        <div className="import-summary-grid">
          <div><span>Total Rows</span><strong>{summary.total}</strong></div>
          {selectedType === 'users' ? <>
            <div><span>New Users Imported</span><strong>{summary.valid}</strong></div>
            <div><span>Duplicate Users Skipped</span><strong>{summary.skipped}</strong></div>
            <div><span>Existing Users Updated</span><strong>{summary.updated}</strong></div>
            <div><span>Error Rows</span><strong>{summary.errors}</strong></div>
          </> : <>
            <div><span>Valid Rows</span><strong>{summary.valid}</strong></div>
            <div><span>Error Rows</span><strong>{summary.errors}</strong></div>
            <div><span>Duplicate Rows</span><strong>{summary.duplicates}</strong></div>
            <div><span>Mandatory Missing</span><strong>{summary.mandatoryMissing}</strong></div>
          </>}
        </div>

        <div className="import-actions">
          {selectedType === 'users' && <>
            <button className={`secondary-button ${duplicateMode === 'skip' ? 'active' : ''}`} type="button" onClick={() => changeDuplicateMode('skip')}>Skip duplicates</button>
            <button className={`secondary-button ${duplicateMode === 'update' ? 'active' : ''}`} type="button" onClick={() => changeDuplicateMode('update')}>Update existing users</button>
          </>}
          <button className="secondary-button" onClick={() => downloadTemplate(config, 'xlsx')}><FileText size={17} /> Download XLSX Template</button>
          <button className="secondary-button" onClick={() => downloadTemplate(config, 'csv')}><Download size={17} /> Download CSV Template</button>
          <button className="secondary-button" onClick={downloadErrorReport} disabled={!importState?.errors?.length}><AlertCircle size={17} /> Download Error Report</button>
          <button className="primary-button" onClick={confirmImport} disabled={!canAdminister || !hasImportableRows || importState?.confirmed || isImporting}><Upload size={17} /> {isImporting ? 'Importing' : importState?.confirmed ? 'Imported' : 'Confirm Import'}</button>
        </div>
      </section>

      <section className="card import-card">
        <div className="panel-head">
          <div><span className="eyebrow">IMPORT STATUS</span><h2>Summary and validation</h2></div>
          <StatusBadge>{importState?.confirmed ? 'Uploaded' : importState ? 'Preview Ready' : 'Awaiting upload'}</StatusBadge>
        </div>
        <div className="import-status-lines">
          <div><span>File</span><strong>{fileName || 'No file uploaded'}</strong></div>
          <div><span>Master</span><strong>{config.label}</strong></div>
          <div><span>{selectedType === 'users' ? 'New users' : 'Valid rows'}</span><strong>{summary.valid}</strong></div>
          <div><span>Error rows</span><strong>{summary.errors}</strong></div>
          {supabaseStatus && <div><span>{supabaseStatus.local ? 'Auth Store' : 'Supabase'}</span><strong>{supabaseStatus.error ? supabaseStatus.error : `Inserted ${supabaseStatus.inserted || 0}, Updated ${supabaseStatus.updated || 0}, Skipped ${supabaseStatus.skipped || 0}`}</strong></div>}
        </div>
        <div className="import-progress-block">
          <div><span>Validation progress</span><strong>{progressValue}%</strong></div>
          <Progress value={progressValue} />
        </div>
        <div className="import-tips">
          <h3>{selectedType === 'checklist' ? 'Checklist validation rules' : 'Validation rules'}</h3>
          <ul>
            {selectedType === 'checklist' ? <>
              <li>Header validation uses the finalized DISHA HSC checklist template.</li>
              <li>Question Code, Evaluation Question, and Evaluation Parameter are mandatory.</li>
              <li>Direct guest impact maps to Critical; Indirect maps to Medium.</li>
              <li>Departments and facilities are converted from accepted flags: Y, Yes, TRUE, 1.</li>
            </> : <>
              <li>Mandatory fields are checked before rows are accepted.</li>
              <li>{selectedType === 'users' ? 'Duplicate mobile numbers are skipped by default, or updated when selected.' : 'Duplicates are checked against existing data and within the uploaded file.'}</li>
              <li>Failed rows can be downloaded as an error report for correction.</li>
            </>}
          </ul>
        </div>
      </section>
    </div>

    <section className="card import-table-card">
      <div className="panel-head">
        <div><span className="eyebrow">{importState?.accepted?.length && !importState.confirmed ? 'IMPORT PREVIEW' : 'LOCAL MOCK DATA'}</span><h2>{tableTitle}</h2></div>
        <StatusBadge>{visibleRows.length} records</StatusBadge>
      </div>
      <div className="import-table-scroll">
        <table className="import-table">
          <thead>
            <tr>
              {config.columns.map(column => <th key={column}>{column}</th>)}
              {selectedType === 'users' && previewRows.length > 0 && <th>Import Result</th>}
            </tr>
          </thead>
          <tbody>
            {visibleRows.slice(0, 20).map(row => <tr key={row.id}>{config.columns.map(column => <td key={column}>{workbookColumnDisplayValue(row, column, config)}</td>)}{selectedType === 'users' && previewRows.length > 0 && <td>{row.importOutcome || '-'}</td>}</tr>)}
          </tbody>
        </table>
      </div>
    </section>

    <section className="card import-errors-card">
      <div className="panel-head">
        <div><span className="eyebrow">ERROR REPORT</span><h2>Validation failures</h2></div>
        <StatusBadge>{importState?.errors?.length || 0} issues</StatusBadge>
      </div>
      {importState?.errors?.length ? <div className="import-error-list">{importState.errors.map(error => <article key={`${error.row}-${error.issue}`}><strong>Row {error.row}</strong><p>{error.issue}</p></article>)}</div> : <div className="import-empty"><CheckCircle2 size={30} /><strong>No validation failures yet</strong><p>Upload a file to generate a local validation report.</p></div>}
    </section>
  </div>
}
