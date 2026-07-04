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

const chartConfig = [
  { key: 'complianceTrend', title: 'TREND', subtitle: 'Compliance trend by month', icon: TrendingUp, dataKey: 'complianceTrend', formatter: value => `${value}%`, focus: 'Compliance trend' },
  { key: 'locationComparison', title: 'LOCATION', subtitle: 'Location-wise compliance comparison', icon: BarChart3, dataKey: 'locationComparison', formatter: value => `${value} audit(s)`, focus: 'Location comparison' },
  { key: 'departmentNg', title: 'DEPARTMENT', subtitle: 'Department-wise NG count', icon: BarChart3, dataKey: 'departmentNg', formatter: value => `${value} NG`, focus: 'Department NG count' },
  { key: 'capaStatus', title: 'CAPA STATUS', subtitle: 'CAPA status donut chart', icon: PieChart, dataKey: 'capaStatus', donut: true, focus: 'CAPA status' },
  { key: 'rootCausePareto', title: 'ROOT CAUSE', subtitle: 'Root cause Pareto chart', icon: BarChart3, dataKey: 'rootCausePareto', formatter: (value, item) => `${value} NG | ${item.cumulativePercent}% cum.`, focus: 'Root cause' },
  { key: 'overdueAgeing', title: 'AGEING', subtitle: 'Overdue CAPA ageing chart', icon: BarChart3, dataKey: 'overdueAgeing', formatter: value => `${value} overdue`, focus: 'Overdue ageing' },
  { key: 'repeatFindings', title: 'REPEAT FINDINGS', subtitle: 'Repeat findings by DQ / question', icon: BarChart3, dataKey: 'repeatFindings', formatter: value => `${value} repeat(s)`, focus: 'Repeat findings' },
  { key: 'monetaryByCategory', title: 'MONETARY', subtitle: 'Monetary requests by category', icon: BarChart3, dataKey: 'monetaryByCategory', formatter: value => `${value} request(s)`, focus: 'Monetary category' },
  { key: 'auditCompletion', title: 'AUDIT COMPLETION', subtitle: 'Audit completion trend', icon: TrendingUp, dataKey: 'auditCompletion', formatter: value => `${value}%`, focus: 'Audit completion trend' },
  { key: 'picPendingActions', title: 'PIC ACTIONS', subtitle: 'PIC-wise pending actions', icon: BarChart3, dataKey: 'picPendingActions', formatter: value => `${value} pending`, focus: 'PIC pending actions' },
]

export default function ReportCharts({ snapshot, onSelectGroup, visibleKeys, charts = chartConfig }) {
  const visibleCharts = visibleKeys?.length ? charts.filter(item => visibleKeys.includes(item.key)) : charts
  return <section className="report-chart-grid">
    {visibleCharts.map(item => <ChartCard key={item.key} title={item.title} subtitle={item.subtitle} icon={item.icon}>
      {item.donut
        ? <DonutList data={snapshot[item.dataKey]} onSelect={entry => onSelectGroup(item.focus, entry.label)} />
        : <BarList data={snapshot[item.dataKey]} onSelect={entry => onSelectGroup(item.focus, entry.label)} valueFormatter={item.formatter} />}
    </ChartCard>)}
  </section>
}
