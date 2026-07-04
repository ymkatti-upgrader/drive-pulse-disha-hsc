import { CalendarDays, ChevronDown, RefreshCcw, Search } from 'lucide-react'

function SelectField({ label, value, onChange, options, disabled = false }) {
  return <label className="report-filter-field">
    <span>{label}</span>
    <div className="report-select">
      <select value={value} onChange={onChange} disabled={disabled}>
        {options.map(option => <option key={option.value} value={option.value}>{option.label}</option>)}
      </select>
      <ChevronDown size={16} />
    </div>
  </label>
}

export default function ReportFilters({ value, options, onChange, onRefresh, loading, lastRefreshed, visibleFields, lockedFields = [] }) {
  const handleChange = key => event => onChange(current => ({ ...current, [key]: event.target.value }))
  const show = key => !visibleFields || visibleFields.includes(key)
  const isLocked = key => lockedFields.includes(key)

  return <section className="card report-filters">
    <div className="report-filters-head">
      <div>
        <span className="eyebrow">FILTERS</span>
        <h2>Interactive report filters</h2>
        <p>Slice the dashboard by date, ownership, status and approval state.</p>
      </div>
      <div className="report-filters-meta">
        <span>{loading ? 'Refreshing...' : `Last refreshed ${lastRefreshed || 'just now'}`}</span>
        <button className="secondary-button" type="button" onClick={onRefresh} disabled={loading}><RefreshCcw size={16} /> Refresh</button>
      </div>
    </div>

    <div className="report-filter-grid">
      {show('startDate') && show('endDate') && <label className="report-filter-field">
        <span>Date range</span>
        <div className="report-date-grid">
          <div className="report-date-input">
            <CalendarDays size={16} />
            <input type="date" value={value.startDate} onChange={handleChange('startDate')} />
          </div>
          <div className="report-date-input">
            <CalendarDays size={16} />
            <input type="date" value={value.endDate} onChange={handleChange('endDate')} />
          </div>
        </div>
      </label>}
      {show('location') && <SelectField label="Location" value={value.location} onChange={handleChange('location')} options={options.locations} disabled={isLocked('location')} />}
      {show('department') && <SelectField label="Department" value={value.department} onChange={handleChange('department')} options={options.departments} disabled={isLocked('department')} />}
      {show('auditType') && <SelectField label="Audit type" value={value.auditType} onChange={handleChange('auditType')} options={options.auditTypes} disabled={isLocked('auditType')} />}
      {show('auditor') && <SelectField label="Auditor" value={value.auditor} onChange={handleChange('auditor')} options={options.auditors} disabled={isLocked('auditor')} />}
      {show('pic') && <SelectField label="PIC" value={value.pic} onChange={handleChange('pic')} options={options.pics} disabled={isLocked('pic')} />}
      {show('status') && <SelectField label="Status" value={value.status} onChange={handleChange('status')} options={options.statuses} disabled={isLocked('status')} />}
      {show('severity') && <SelectField label="Severity" value={value.severity} onChange={handleChange('severity')} options={options.severities} disabled={isLocked('severity')} />}
      {show('rootCauseCategory') && <SelectField label="Root cause category" value={value.rootCauseCategory} onChange={handleChange('rootCauseCategory')} options={options.rootCauseCategories} disabled={isLocked('rootCauseCategory')} />}
      {show('monetarySupportRequired') && <SelectField label="Monetary support required" value={value.monetarySupportRequired} onChange={handleChange('monetarySupportRequired')} options={options.yesNo} disabled={isLocked('monetarySupportRequired')} />}
      {show('search') && <label className="report-filter-field report-search-field">
        <span>Quick search</span>
        <div className="report-search">
          <Search size={16} />
          <input value={value.search} onChange={handleChange('search')} placeholder="Search audit, question, PIC, remarks" />
        </div>
      </label>}
    </div>
  </section>
}
