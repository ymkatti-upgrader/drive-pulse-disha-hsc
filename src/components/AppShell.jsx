import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { ArrowRight, BarChart3, Bell, BookOpenCheck, ClipboardCheck, FileBarChart, LayoutDashboard, LogOut, Menu, MoreHorizontal, Settings2, ShieldCheck, Target, X } from 'lucide-react'
import { useState } from 'react'
import { canAccessFeature, getPrimaryRole, getRoleProfile, useAuth } from '../auth/AuthContext'
import { useNotifications } from '../notifications/NotificationContext'

const roleLabels = {
  CEO: 'CEO',
  'Group Functional PIC': 'Group Functional PIC',
  'Group Functional HOD': 'Group Functional HOD',
  'Group DISHA HSC PIC': 'Group DISHA HSC PIC',
  'Branch DISHA PIC': 'Branch DISHA PIC',
  'Branch Disha HSC PIC': 'Branch Disha HSC PIC',
  'NG PIC': 'NG PIC',
  'Location Functional HOD': 'Location Functional HOD',
  Viewer: 'Viewer',
  'System Administrator': 'System Administrator',
  Admin: 'Admin',
  'Super Admin': 'Super Admin',
}

const navCatalog = {
  dashboard: { to: '/dashboard', icon: LayoutDashboard },
  reports: { to: '/reports', icon: BarChart3 },
  'management-review': { to: '/management-review', icon: FileBarChart },
  'audit-workbench': { to: '/audits/new', icon: ClipboardCheck },
  'conduct-audit': { to: '/audits/new', icon: ClipboardCheck },
  'action-center': { to: '/action-center', icon: Target },
  'review-queue': { to: '/action-center', icon: Target },
  'financial-review': { to: '/action-center', icon: ShieldCheck },
  'financial-approvals': { to: '/action-center', icon: ShieldCheck },
  verification: { to: '/verification', icon: ShieldCheck },
  yokoten: { to: '/yokoten', icon: BookOpenCheck },
  masters: { to: '/masters', icon: Settings2 },
}

function dedupeNavigation(items) {
  const seen = new Set()
  return items.filter(item => {
    const key = `${item.to}|${item.label}`
    if (seen.has(key)) return false
    seen.add(key)
    return true
  })
}

export default function AppShell() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [moreOpen, setMoreOpen] = useState(false)
  const [notificationOpen, setNotificationOpen] = useState(false)
  const { user, logout } = useAuth()
  const { notifications, unreadCount, markRead, markAllRead } = useNotifications()
  const navigate = useNavigate()
  const location = useLocation()
  const roleProfile = getRoleProfile(user)
  const roleLabel = roleLabels[getPrimaryRole(user)] || getPrimaryRole(user)
  const mobileNo = user?.mobile_no || user?.mobile || ''
  const sidebarNav = dedupeNavigation(
    roleProfile.navigation
      .map(item => ({ ...item, ...navCatalog[item.feature] }))
      .filter(item => item.to),
  )
  const primaryNav = sidebarNav.slice(0, 3)
  const secondaryNav = sidebarNav.slice(3)
  const isMoreRoute = secondaryNav.some(item => location.pathname.startsWith(item.to))

  async function handleLogout() {
    await logout()
    setSidebarOpen(false)
    setMoreOpen(false)
    setNotificationOpen(false)
    navigate('/login', { replace: true })
  }

  function openMoreRoute(path) {
    setMoreOpen(false)
    navigate(path)
  }

  function openNotification(link, id) {
    markRead(id)
    setNotificationOpen(false)
    navigate(link)
  }

  return <div className="app-shell">
    <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
      <div className="brand"><span className="brand-mark">DP</span><div><strong>Drive Pulse</strong><small>DISHA HSC</small></div></div>
      <button className="close-menu" aria-label="Close menu" onClick={() => setSidebarOpen(false)}><X /></button>
      <div className="workspace-label">{roleProfile.dashboardName}</div>
      <nav>{sidebarNav.map(({ to, label, icon: Icon }) => <NavLink to={to} key={`${to}-${label}`} onClick={() => setSidebarOpen(false)}><Icon size={19} /><span>{label}</span></NavLink>)}</nav>

      <div className="sidebar-account">
        <div className="user-card"><span>{roleLabel.slice(0, 2).toUpperCase()}</span><div><strong>{roleLabel}</strong><small>+91 {mobileNo}</small></div></div>
        <button className="logout-button" onClick={handleLogout}><LogOut size={18} /><span>Logout</span></button>
      </div>
    </aside>

    {sidebarOpen && <button className="scrim" aria-label="Close navigation" onClick={() => setSidebarOpen(false)} />}

    <main>
      <header className="topbar">
        <button className="menu-button" aria-label="Open menu" onClick={() => setSidebarOpen(true)}><Menu /></button>
        <div className="mobile-brand"><span className="brand-mark">DP</span><strong>{roleProfile.dashboardName}</strong></div>
        <div className="topbar-actions">
          <div className="header-identity"><strong>{roleLabel}</strong><span>+91 {mobileNo}</span></div>
          <button className="icon-button notification-trigger" aria-label="Notifications" onClick={() => setNotificationOpen(current => !current)}><Bell size={20} />{unreadCount > 0 && <i />}{unreadCount > 0 && <span>{unreadCount > 9 ? '9+' : unreadCount}</span>}</button>
          <div className="top-avatar">{roleLabel.slice(0, 2).toUpperCase()}</div>
        </div>
      </header>
      {notificationOpen && <>
        <button className="more-scrim" aria-label="Close notifications" onClick={() => setNotificationOpen(false)} />
        <section className="notification-popover card" aria-label="Notifications">
          <div className="notification-popover-head">
            <div><span className="eyebrow">NOTIFICATIONS</span><strong>Action alerts</strong><p>{unreadCount} unread</p></div>
            <div className="notification-popover-actions">
              <button className="text-button" onClick={() => { markAllRead(); setNotificationOpen(false) }}>Mark all read</button>
              <button className="icon-button" aria-label="Close notifications" onClick={() => setNotificationOpen(false)}><X size={18} /></button>
            </div>
          </div>
          <div className="notification-popover-list">
            {notifications.slice(0, 8).map(item => <button key={item.id} className={`notification-item ${item.read ? 'read' : ''}`} onClick={() => openNotification(item.actionLink, item.id)}>
              <div className={`notification-priority ${item.priority.toLowerCase()}`}>{item.priority}</div>
              <div className="notification-main">
                <div><strong>{item.title}</strong><span>{item.category}</span></div>
                <p>{item.detail}</p>
                <small>{item.dateTime} | {item.status}</small>
              </div>
              <ArrowRight size={16} />
            </button>)}
          </div>
          <div className="notification-popover-footer">
            <button className="secondary-button full" onClick={() => {
              setNotificationOpen(false)
              navigate(canAccessFeature(user, 'action-center') ? '/action-center' : '/reports')
            }}>Open {canAccessFeature(user, 'action-center') ? 'Action Workspace' : 'Reports'}</button>
          </div>
        </section>
      </>}
      <div className="content"><Outlet /></div>
    </main>

    {moreOpen && <>
      <button className="more-scrim" aria-label="Close More menu" onClick={() => setMoreOpen(false)} />
      <section className="more-sheet" aria-label="More menu">
        <div className="more-sheet-head"><div><strong>{roleLabel}</strong><span>+91 {mobileNo}</span></div><button aria-label="Close More menu" onClick={() => setMoreOpen(false)}><X size={20} /></button></div>
        {secondaryNav.map(({ to, label, description, icon: Icon }) => <button key={`${to}-${label}`} onClick={() => openMoreRoute(to)}><Icon size={20} /><span><strong>{label}</strong><small>{description}</small></span></button>)}
        <button className="mobile-logout" onClick={handleLogout}><LogOut size={20} /><span><strong>Logout</strong><small>Sign out of Drive Pulse | DISHA HSC</small></span></button>
      </section>
    </>}

    <nav className="bottom-nav">
      {primaryNav.map(({ to, label, icon: Icon }) => <NavLink to={to} key={`${to}-${label}`}><Icon size={20} /><span>{label}</span></NavLink>)}
      <button className={moreOpen || isMoreRoute ? 'active' : ''} onClick={() => setMoreOpen(true)}><MoreHorizontal size={20} /><span>More</span></button>
    </nav>
  </div>
}
