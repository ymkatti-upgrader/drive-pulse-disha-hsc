import { ArrowRight, Banknote, BadgeCheck, CalendarClock, CheckCircle2, ClipboardList, FileWarning, ShieldAlert, TimerReset, UserRoundSearch } from 'lucide-react'
import { formatCurrency, formatDurationDays } from './reportUtils'

const kpis = [
  { key: 'totalAudits', label: 'Total Audits', icon: ClipboardList, tone: 'blue' },
  { key: 'overallCompliance', label: 'Overall Compliance %', icon: BadgeCheck, tone: 'green' },
  { key: 'totalNgFindings', label: 'Total NG Findings', icon: FileWarning, tone: 'red' },
  { key: 'openCapas', label: 'Open CAPAs', icon: ShieldAlert, tone: 'amber' },
  { key: 'closedCapas', label: 'Closed CAPAs', icon: CheckCircle2, tone: 'green' },
  { key: 'overdueCapas', label: 'Overdue CAPAs', icon: CalendarClock, tone: 'red' },
  { key: 'averageClosureDays', label: 'Average Closure Days', icon: TimerReset, tone: 'blue' },
  { key: 'repeatFindings', label: 'Repeat Findings', icon: ArrowRight, tone: 'amber' },
  { key: 'pendingVerification', label: 'Pending Verification', icon: UserRoundSearch, tone: 'blue' },
  { key: 'pendingCeoApproval', label: 'Pending CEO Expense Approvals', icon: Banknote, tone: 'amber' },
  { key: 'totalMonetaryValueRequested', label: 'Total Monetary Value Requested', icon: Banknote, tone: 'red', currency: true },
  { key: 'totalMonetaryValueApproved', label: 'Total Monetary Value Approved', icon: Banknote, tone: 'green', currency: true },
]

export default function KpiCards({ summary, onSelectKpi, visibleKeys, cards = kpis, activeKey = '' }) {
  const visibleCards = visibleKeys?.length ? cards.filter(card => visibleKeys.includes(card.key)) : cards
  return <section className="report-kpi-grid">
    {visibleCards.map(card => {
      const Icon = card.icon
      const value = card.currency
        ? formatCurrency(summary[card.key])
        : card.duration
          ? formatDurationDays(summary[card.key], card.naLabel || '-')
          : summary[card.key]
      const active = activeKey === card.key
      return <button key={card.key} type="button" className={`card report-kpi ${card.tone}${active ? ' active' : ''}`} aria-pressed={active} onClick={() => onSelectKpi(card)}>
        <div className="report-kpi-icon"><Icon size={18} /></div>
        <div className="report-kpi-copy">
          <span>{card.label}</span>
          <strong>{value}</strong>
          <small>{active ? 'Click again to clear' : 'Click to drill down'}</small>
        </div>
      </button>
    })}
  </section>
}
