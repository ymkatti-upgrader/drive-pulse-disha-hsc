import { ChevronRight, Search, SlidersHorizontal, Trash2 } from 'lucide-react'

export function PageHeader({ eyebrow, title, description, action }) {
  return <div className="page-header">
    <div><span className="eyebrow">{eyebrow}</span><h1>{title}</h1>{description && <p>{description}</p>}</div>
    {action && <div className="page-action">{action}</div>}
  </div>
}

export function StatCard({ label, value, meta, icon: Icon, tone = 'red' }) {
  return <div className="stat-card card">
    <div className={`stat-icon ${tone}`}><Icon size={20} /></div>
    <div><span>{label}</span><strong>{value}</strong><small>{meta}</small></div>
  </div>
}

export function StatusBadge({ children }) {
  const key = String(children).toLowerCase().replaceAll(' ', '-')
  return <span className={`status status-${key}`}>{children}</span>
}

export function Progress({ value, color = 'red' }) {
  return <div className="progress"><span className={color} style={{ width: `${value}%` }} /></div>
}

export function SearchBar({ placeholder = 'Search audits, improvements or people' }) {
  return <div className="search-bar"><Search size={18} /><input placeholder={placeholder} /><button aria-label="Filter"><SlidersHorizontal size={18} /></button></div>
}

export function DataRow({ title, subtitle, meta, status, onClick, onDelete, deleteLabel = 'Delete audit' }) {
  const showDelete = typeof onDelete === 'function'
  return <div className={`data-row ${showDelete ? 'has-delete' : ''}`} role={onClick ? 'button' : undefined} tabIndex={onClick ? 0 : undefined} onClick={onClick} onKeyDown={event => {
    if (!onClick) return
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      onClick(event)
    }
  }}>
    {showDelete && <button type="button" className="data-row-delete" title={deleteLabel} aria-label={deleteLabel} onClick={event => { event.stopPropagation(); onDelete(event) }}><Trash2 size={14} /></button>}
    <div className="data-main"><strong>{title}</strong><span>{subtitle}</span></div>
    <div className="data-meta">{meta && <span>{meta}</span>}{status && <StatusBadge>{status}</StatusBadge>}<ChevronRight size={18} /></div>
  </div>
}

export function EmptyState({ icon: Icon, title, text }) {
  return <div className="empty-state"><Icon size={30} /><strong>{title}</strong><p>{text}</p></div>
}

export function Stepper({ steps, active }) {
  return <div className="stepper">{steps.map((step, index) => <div className={`step ${index <= active ? 'active' : ''}`} key={step}>
    <span>{index + 1}</span><small>{step}</small>
  </div>)}</div>
}
