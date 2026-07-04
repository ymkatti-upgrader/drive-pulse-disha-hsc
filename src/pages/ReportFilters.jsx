import { CalendarDays, ChevronDown, RefreshCcw, Search } from 'lucide-react'

function SelectField({ label, value, onChange, options }) {
  return <label className="report-filter-field">
    <span>{label}</span>
    <div className="report-select">
      <select value={value} onChange={onChange}>
        {options.map(option => <option key={option.value} value={option.value}>{option.label}</option>)}
      </select>
      <ChevronDown size={16} />
    </div>
  </label>
}

export default function ReportFilters({ value, options, onChange, onRefresh, loading, lastRefreshed }) {
  const handleChange = key => event => onChange(current => ({ ...current, [key]: event.target.value }))

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
      <label className="report-filter-field">
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
      </label>
      <SelectField label="Location" value={value.location} onChange={handleChange('location')} options={options.locations} />
      <SelectField label="Department" value={value.department} onChange={handleChange('department')} options={options.departments} />
      <SelectField label="Audit type" value={value.auditType} onChange={handleChange('auditType')} options={options.auditTypes} />
      <SelectField label="Auditor" value={value.auditor} onChange={handleChange('auditor')} options={options.auditors} />
      <SelectField label="PIC" value={value.pic} onChange={handleChange('pic')} options={options.pics} />
      <SelectField label="Status" value={value.status} onChange={handleChange('status')} options={options.statuses} />
      <SelectField label="Severity" value={value.severity} onChange={handleChange('severity')} options={options.severities} />
      <SelectField label="Root cause category" value={value.rootCauseCategory} onChange={handleChange('rootCauseCategory')} options={options.rootCauseCategories} />
      <SelectField label="Monetary support required" value={value.monetarySupportRequired} onChange={handleChange('monetarySupportRequired')} options={options.yesNo} />
      <label className="report-filter-field report-search-field">
        <span>Quick search</span>
        <div className="report-search">
          <Search size={16} />
          <input value={value.search} onChange={handleChange('search')} placeholder="Search audit, question, PIC, remarks" />
        </div>
      </label>
    </div>
  </section>
}
