function positiveNumber(value) {
  const num = Number(value)
  return Number.isFinite(num) && num > 0 ? num : Number.NaN
}

export function checklistRowOrderValue(row) {
  return positiveNumber(
    row.sequence ??
      row.order ??
      row.sl_no ??
      row.serial_no ??
      row.sub_question_num ??
      row.subQuestionNum,
  )
}

export function checklistRowSerialValue(row) {
  const direct = positiveNumber(row.sub_question_num ?? row.subQuestionNum ?? row.serial_no ?? row.sequence ?? row.order ?? row.sl_no)
  if (Number.isFinite(direct)) return direct

  const versionMatch = String(row.version || '').match(/^v\d+-[A-Z0-9]+-(\d{3})(?:-|$)/i)
  const versionSerial = versionMatch ? Number(versionMatch[1]) : Number.NaN
  if (Number.isFinite(versionSerial) && versionSerial > 0) return versionSerial

  const source = String(row.evaluation_question || row.question || row.evaluation_parameter || row.version || '').trim()
  const match = source.match(/^\s*(\d+(?:\.\d+)?)/)
  const parsed = match ? Number(match[1]) : Number.NaN
  return Number.isFinite(parsed) && parsed > 0 ? parsed : Number.POSITIVE_INFINITY
}

