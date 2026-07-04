import { BarChart3, ChevronRight, PieChart, TrendingUp } from 'lucide-react'

function ChartCard({ title, subtitle, icon: Icon, children }) {
  return <section className="card report-chart">
    <div className="panel-head">
      <div>
        <span className="eyebrow">{title}</span>
        <h2>{subtitle}</h2>
      </div>
      <Icon size={18} />
    </div>
    {children}
  </section>
}

function BarList({ data, onSelect, valueFormatter = value => value, barClass = '' }) {
  const max = Math.max(...data.map(item => Number(item.value) || 0), 1)
  return <div className="report-bar-list">
    {data.length ? data.map(item => <button key={item.label} type="button" className={`report-bar-row ${barClass}`} onClick={() => onSelect(item)}>
      <div className="report-bar-label">
        <strong>{item.label}</strong>
        <span>{valueFormatter(item.value, item)}</span>
      </div>
      <div className="report-bar-track">
        <i style={{ width: `${Math.max(6, ((Number(item.value) || 0) / max) * 100)}%` }} />
      </div>
      <ChevronRight size={16} />
    </button>) : <div className="report-empty-inline">No data for the current filter set.</div>}
  </div>
}

function DonutList({ data, onSelect }) {
  const total = data.reduce((sum, item) => sum + (Number(item.value) || 0), 0)
  return <div className="report-donut-layout">
    <div className="report-donut">
      <div>
        <strong>{total}</strong>
        <span>Total</span>
      </div>
    </div>
    <div className="report-donut-legend">
      {data.map(item => <button key={item.label} type="button" onClick={() => onSelect(item)}>
        <i />
        <span>{item.label}</span>
        <strong>{item.value}</strong>
      </button>)}
    </div>
  </div>
}

export default function ReportCharts({ snapshot, onSelectGroup }) {
  return <section className="report-chart-grid">
    <ChartCard title="TREND" subtitle="Compliance trend by month" icon={TrendingUp}>
      <BarList data={snapshot.complianceTrend} onSelect={item => onSelectGroup('Compliance trend', item.label)} valueFormatter={value => `${value}%`} />
    </ChartCard>

    <ChartCard title="LOCATION" subtitle="Location-wise compliance comparison" icon={BarChart3}>
      <BarList data={snapshot.locationComparison} onSelect={item => onSelectGroup('Location comparison', item.label)} valueFormatter={value => `${value} audit(s)`} />
    </ChartCard>

    <ChartCard title="DEPARTMENT" subtitle="Department-wise NG count" icon={BarChart3}>
      <BarList data={snapshot.departmentNg} onSelect={item => onSelectGroup('Department NG count', item.label)} valueFormatter={value => `${value} NG`} />
    </ChartCard>

    <ChartCard title="CAPA STATUS" subtitle="CAPA status donut chart" icon={PieChart}>
      <DonutList data={snapshot.capaStatus} onSelect={item => onSelectGroup('CAPA status', item.label)} />
    </ChartCard>

    <ChartCard title="ROOT CAUSE" subtitle="Root cause Pareto chart" icon={BarChart3}>
      <BarList data={snapshot.rootCausePareto} onSelect={item => onSelectGroup('Root cause', item.label)} valueFormatter={(value, item) => `${value} NG | ${item.cumulativePercent}% cum.`} />
    </ChartCard>

    <ChartCard title="AGEING" subtitle="Overdue CAPA ageing chart" icon={BarChart3}>
      <BarList data={snapshot.overdueAgeing} onSelect={item => onSelectGroup('Overdue ageing', item.label)} valueFormatter={value => `${value} overdue`} />
    </ChartCard>

    <ChartCard title="REPEAT FINDINGS" subtitle="Repeat findings by DQ / question" icon={BarChart3}>
      <BarList data={snapshot.repeatFindings} onSelect={item => onSelectGroup('Repeat findings', item.label)} valueFormatter={value => `${value} repeat(s)`} />
    </ChartCard>

    <ChartCard title="MONETARY" subtitle="Monetary requests by category" icon={BarChart3}>
      <BarList data={snapshot.monetaryByCategory} onSelect={item => onSelectGroup('Monetary category', item.label)} valueFormatter={value => `${value} request(s)`} />
    </ChartCard>

    <ChartCard title="AUDIT COMPLETION" subtitle="Audit completion trend" icon={TrendingUp}>
      <BarList data={snapshot.auditCompletion} onSelect={item => onSelectGroup('Audit completion trend', item.label)} valueFormatter={value => `${value}%`} />
    </ChartCard>

    <ChartCard title="PIC ACTIONS" subtitle="PIC-wise pending actions" icon={BarChart3}>
      <BarList data={snapshot.picPendingActions} onSelect={item => onSelectGroup('PIC pending actions', item.label)} valueFormatter={value => `${value} pending`} />
    </ChartCard>
  </section>
}
