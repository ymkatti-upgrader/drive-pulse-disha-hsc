import { Download, Eye, FileSpreadsheet, FileText, Search } from 'lucide-react'
import { useMemo, useState } from 'react'
import { StatusBadge } from '../components/UI'
import { buildTableExportRows, exportRowsToCsv, exportRowsToExcel } from './exportUtils'
import { formatDate, formatDurationDays, paginateRows, sortRows } from './reportUtils'

function statusTone(status) {
  const key = String(status || '').toLowerCase()
  if (['closed', 'approved', 'ok'].includes(key)) return 'green'
  if (['overdue', 'rejected', 'ng'].includes(key)) return 'red'
  if (['pending', 'in progress', 'pending verification', 'pending ceo approval'].includes(key)) return 'amber'
  if (['submitted', 'review'].includes(key)) return 'blue'
  return 'neutral'
}

function AgeingBadge({ days }) {
  const tone = days > 30 ? 'red' : days > 14 ? 'amber' : 'green'
  return <span className={`report-ageing ${tone}`}>{Number.isFinite(Number(days)) ? `${days} day(s)` : '-'}</span>
}

export default function ReportTables({
  title,
  rows,
  tabKey,
  onViewDetails,
  onExportExcel,
  onExportCsv,
  search,
  onSearch,
  sortKey,
  sortDirection,
  onSortChange,
  page,
  pageSize,
  onPageChange,
}) {
  const [internalSearch, setInternalSearch] = useState('')
  const effectiveSearch = search ?? internalSearch
  const setSearch = onSearch || setInternalSearch

  const filtered = useMemo(() => {
    const query = String(effectiveSearch || '').trim().toLowerCase()
    const sorted = sortRows(rows, sortKey, sortDirection)
    return query ? sorted.filter(row => Object.values(row).some(value => String(value ?? '').toLowerCase().includes(query))) : sorted
  }, [effectiveSearch, rows, sortKey, sortDirection])

  const paging = paginateRows(filtered, page, pageSize)

  function handleSort(key) {
    if (!onSortChange) return
    onSortChange(key)
  }

  const isLifecycleTab = tabKey === 'lifecycle'

  return <section className="card report-table-card">
    <div className="report-table-head">
      <div>
        <span className="eyebrow">{tabKey}</span>
        <h2>{title}</h2>
        <p>{filtered.length} record(s) matched</p>
      </div>
      <div className="report-table-actions">
        <button className="secondary-button" type="button" onClick={() => onExportExcel(buildTableExportRows(filtered), `${tabKey}.xlsx`, title)}><FileSpreadsheet size={16} /> Export Excel</button>
        <button className="secondary-button" type="button" onClick={() => onExportCsv(buildTableExportRows(filtered), `${tabKey}.csv`, title)}><Download size={16} /> Export CSV</button>
      </div>
    </div>

    <div className="report-table-search">
      <Search size={16} />
      <input value={effectiveSearch} onChange={event => setSearch(event.target.value)} placeholder="Search current table" />
    </div>

    {paging.rows.length ? <div className="report-table-wrap">
      <table className="report-table">
        <thead>
          {isLifecycleTab
            ? <tr>
              <th onClick={() => handleSort('auditId')}>Audit Number</th>
              <th>Audit Name</th>
              <th onClick={() => handleSort('location')}>Location</th>
              <th onClick={() => handleSort('department')}>Department</th>
              <th onClick={() => handleSort('question')}>Question</th>
              <th onClick={() => handleSort('pic')}>PIC</th>
              <th>Assigned Date</th>
              <th>Financial Approval</th>
              <th>Implementation</th>
              <th>Closure Date</th>
              <th>Closure Time</th>
              <th>Financial Approval Time</th>
              <th>Implementation Time</th>
              <th>Verification Time</th>
              <th onClick={() => handleSort('status')}>Current Status</th>
              <th>Action</th>
            </tr>
            : <tr>
              <th onClick={() => handleSort('auditId')}>Audit Number</th>
              <th onClick={() => handleSort('location')}>Location</th>
              <th onClick={() => handleSort('department')}>Department</th>
              <th onClick={() => handleSort('question')}>Question</th>
              <th onClick={() => handleSort('pic')}>PIC</th>
              <th onClick={() => handleSort('status')}>Status</th>
              <th onClick={() => handleSort('dueDate')}>Due Date</th>
              <th onClick={() => handleSort('ageing')}>Ageing</th>
              <th>Remarks</th>
              <th>Action</th>
            </tr>}
        </thead>
        <tbody>
          {paging.rows.map(row => isLifecycleTab
            ? <tr key={row.id}>
              <td><strong>{row.auditId}</strong></td>
              <td>{row.auditTitle || '-'}</td>
              <td>{row.location || '-'}</td>
              <td>{row.department || '-'}</td>
              <td>
                <strong>{row.question || '-'}</strong>
                <small>{row.result || '-'}</small>
              </td>
              <td>
                <strong>{row.pic || '-'}</strong>
                <small>{row.picMobile || ''}</small>
              </td>
              <td>{formatDate(row.assignedAt)}</td>
              <td>{row.monetarySupportRequired ? formatDate(row.ceoApprovedAt) : 'Not Applicable'}</td>
              <td>{formatDate(row.implementationCompletedAt)}</td>
              <td>{formatDate(row.closureCompletedAt)}</td>
              <td>{formatDurationDays(row.closureTimeDays)}</td>
              <td>{row.monetarySupportRequired ? formatDurationDays(row.financialApprovalTimeDays, 'Not Applicable') : 'Not Applicable'}</td>
              <td>{row.monetarySupportRequired ? formatDurationDays(row.implementationTimeDays, 'Not Applicable') : 'Not Applicable'}</td>
              <td>{formatDurationDays(row.verificationTimeDays)}</td>
              <td><StatusBadge>{row.currentStage || row.status || '-'}</StatusBadge></td>
              <td>
                <button className="secondary-button" type="button" onClick={() => onViewDetails(row)}><Eye size={14} /> View Details</button>
              </td>
            </tr>
            : <tr key={row.id}>
              <td>
                <strong>{row.auditId}</strong>
                <small>{row.auditType}</small>
              </td>
              <td>{row.location || '-'}</td>
              <td>{row.department || '-'}</td>
              <td>
                <strong>{row.question || '-'}</strong>
                <small>{row.result || '-'}</small>
              </td>
              <td>
                <strong>{row.pic || '-'}</strong>
                <small>{row.picMobile || ''}</small>
              </td>
              <td><StatusBadge>{row.status || '-'}</StatusBadge></td>
              <td>{row.targetDate || '-'}</td>
              <td><AgeingBadge days={row.ageingDays} /></td>
              <td>{row.remarks || '-'}</td>
              <td>
                <button className="secondary-button" type="button" onClick={() => onViewDetails(row)}><Eye size={14} /> View Details</button>
              </td>
            </tr>)}
        </tbody>
      </table>
    </div> : <div className="report-empty-inline">No matching rows for the selected filters.</div>}

    <div className="report-pagination">
      <span>Page {paging.page} of {paging.totalPages}</span>
      <div>
        <button className="secondary-button" type="button" disabled={paging.page <= 1} onClick={() => onPageChange(Math.max(1, paging.page - 1))}>Previous</button>
        <button className="secondary-button" type="button" disabled={paging.page >= paging.totalPages} onClick={() => onPageChange(Math.min(paging.totalPages, paging.page + 1))}>Next</button>
      </div>
    </div>
  </section>
}
