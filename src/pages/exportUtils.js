import * as XLSX from 'xlsx'
import { formatCurrency, formatDate, formatDurationDays, formatPercent } from './reportUtils'

function createWorkbook(rows, sheetName = 'Report') {
  const workbook = XLSX.utils.book_new()
  const worksheet = XLSX.utils.json_to_sheet(rows)
  XLSX.utils.book_append_sheet(workbook, worksheet, sheetName)
  return workbook
}

function downloadBlob(blob, fileName) {
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = fileName
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}

export function exportRowsToCsv(rows, fileName = 'report.csv') {
  const worksheet = XLSX.utils.json_to_sheet(rows)
  const csv = XLSX.utils.sheet_to_csv(worksheet)
  downloadBlob(new Blob([csv], { type: 'text/csv;charset=utf-8;' }), fileName)
}

export function exportRowsToExcel(rows, fileName = 'report.xlsx', sheetName = 'Report') {
  const workbook = createWorkbook(rows, sheetName)
  const buffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
  downloadBlob(new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }), fileName)
}

export function exportDashboardSummaryPdf({ title, generatedAt, metrics = [], notes = [] }) {
  const win = window.open('', '_blank', 'noopener,noreferrer,width=1200,height=900')
  if (!win) return

  const cards = metrics.map(metric => `
    <div class="print-metric">
      <span>${metric.label}</span>
      <strong>${metric.value}</strong>
      <small>${metric.meta || ''}</small>
    </div>
  `).join('')

  const list = notes.map(note => `<li>${note}</li>`).join('')
  win.document.write(`
    <html>
      <head>
        <title>${title}</title>
        <style>
          body{font-family:Arial,sans-serif;padding:24px;color:#1f2937}
          h1{margin:0 0 8px;font-size:28px}
          p{color:#6b7280}
          .grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin:20px 0}
          .print-metric{border:1px solid #e5e7eb;border-radius:12px;padding:14px}
          .print-metric span{display:block;font-size:12px;color:#6b7280;text-transform:uppercase;letter-spacing:.08em}
          .print-metric strong{display:block;font-size:26px;margin-top:8px}
          .print-metric small{display:block;font-size:12px;color:#6b7280;margin-top:4px}
          ul{padding-left:18px}
        </style>
      </head>
      <body>
        <h1>${title}</h1>
        <p>Generated ${generatedAt}</p>
        <div class="grid">${cards}</div>
        <h2>Notes</h2>
        <ul>${list}</ul>
      </body>
    </html>
  `)
  win.document.close()
  win.focus()
  setTimeout(() => win.print(), 250)
}

export function buildTableExportRows(rows) {
  return rows.map(row => ({
    AuditNumber: row.auditId,
    AuditName: row.auditTitle,
    Location: row.location,
    Department: row.department,
    Question: row.question,
    PIC: row.pic,
    AssignedDate: formatDate(row.assignedAt),
    FinancialApprovalDate: formatDate(row.ceoApprovedAt),
    ImplementationDate: formatDate(row.implementationCompletedAt),
    VerificationDate: formatDate(row.verificationCompletedAt),
    ClosureDate: formatDate(row.closureCompletedAt),
    ClosureTime: formatDurationDays(row.closureTimeDays, row.monetarySupportRequired ? '-' : '-'),
    FinancialApprovalTime: row.monetarySupportRequired ? formatDurationDays(row.financialApprovalTimeDays, 'Not Applicable') : 'Not Applicable',
    ImplementationTime: row.monetarySupportRequired ? formatDurationDays(row.implementationTimeDays, 'Not Applicable') : 'Not Applicable',
    VerificationTime: formatDurationDays(row.verificationTimeDays),
    CurrentStage: row.currentStage || row.status,
    Status: row.status,
    Severity: row.severity,
    DueDate: formatDate(row.targetDate),
    AgeingDays: row.ageingDays,
    Remarks: row.remarks,
    MonetarySupport: row.monetarySupportRequired ? 'Yes' : 'No',
    RequestedAmount: formatCurrency(row.expectedExpenseAmount),
    Compliance: formatPercent(row.auditScore),
  }))
}
