import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { ArrowRight, Bell, BookOpenCheck, ClipboardCheck, FileBarChart, LayoutDashboard, LogOut, Menu, MoreHorizontal, Settings2, ShieldCheck, Target, X } from 'lucide-react'
import { useState } from 'react'
import { getPrimaryRole, hasFullAccess, useAuth } from '../auth/AuthContext'
import { useNotifications } from '../notifications/NotificationContext'

const roleLabels = {
  CEO: 'CEO',
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

const leadershipRoles = ['CEO', 'Group Functional HOD', 'Group DISHA HSC PIC', 'Branch DISHA PIC', 'Location Functional HOD']
const desktopNav = [
  { to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/management-review', label: 'Review Center', icon: FileBarChart },
  { to: '/audits/new', label: 'Audit', icon: ClipboardCheck },
  { to: '/action-center', label: 'Disha Action Hub', icon: Target },
  { to: '/yokoten', label: 'Yokoten Library', icon: BookOpenCheck },
  { to: '/masters', label: 'Masters', icon: Settings2 },
]

const mobileNav = desktopNav.filter(item => ['/dashboard', '/audits/new', '/action-center'].includes(item.to))

export default function AppShell() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [moreOpen, setMoreOpen] = useState(false)
  const [notificationOpen, setNotificationOpen] = useState(false)
  const { user, logout } = useAuth()
  const { notifications, unreadCount, markRead, markAllRead } = useNotifications()
  const navigate = useNavigate()
  const location = useLocation()
  const roleLabel = roleLabels[getPrimaryRole(user)] || getPrimaryRole(user)
  const mobileNo = user?.mobile_no || user?.mobile || ''
  const showLeadershipReview = hasFullAccess(user) || leadershipRoles.includes(getPrimaryRole(user))
  const showMasters = (user?.access || []).some(item => {
    const role = String(item.role || '').trim().toLowerCase()
    const userType = String(item.user_type || '').trim().toLowerCase()
    return role === 'super admin' || userType === 'system admin'
  })
  const sidebarNav = desktopNav.filter(item => {
    if (item.to === '/management-review') return showLeadershipReview
    if (item.to === '/masters') return showMasters
    return true
  })
  const isMoreRoute = ['/verification', '/yokoten', '/masters', '/action-center', '/management-review', '/audits'].some(path => location.pathname.startsWith(path))

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
      <div className="workspace-label">HANSAChu AUDIT SYSTEM</div>
      <nav>{sidebarNav.map(({ to, label, icon: Icon }) => <NavLink to={to} key={to} onClick={() => setSidebarOpen(false)}><Icon size={19} /><span>{label}</span></NavLink>)}</nav>

      <div className="sidebar-account">
        <div className="user-card"><span>{roleLabel.slice(0, 2).toUpperCase()}</span><div><strong>{roleLabel}</strong><small>+91 {mobileNo}</small></div></div>
        <button className="logout-button" onClick={handleLogout}><LogOut size={18} /><span>Logout</span></button>
      </div>
    </aside>

    {sidebarOpen && <button className="scrim" aria-label="Close navigation" onClick={() => setSidebarOpen(false)} />}

    <main>
      <header className="topbar">
        <button className="menu-button" aria-label="Open menu" onClick={() => setSidebarOpen(true)}><Menu /></button>
        <div className="mobile-brand"><span className="brand-mark">DP</span><strong>Drive Pulse</strong></div>
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
                <small>{item.dateTime} Â· {item.status}</small>
              </div>
              <ArrowRight size={16} />
            </button>)}
          </div>
          <div className="notification-popover-footer">
            <button className="secondary-button full" onClick={() => { setNotificationOpen(false); navigate('/action-center') }}>Open Disha Action Hub</button>
          </div>
        </section>
      </>}
      <div className="content"><Outlet /></div>
    </main>

    {moreOpen && <>
      <button className="more-scrim" aria-label="Close More menu" onClick={() => setMoreOpen(false)} />
      <section className="more-sheet" aria-label="More menu">
        <div className="more-sheet-head"><div><strong>{roleLabel}</strong><span>+91 {mobileNo}</span></div><button aria-label="Close More menu" onClick={() => setMoreOpen(false)}><X size={20} /></button></div>
        <button onClick={() => openMoreRoute('/action-center')}><Bell size={20} /><span><strong>Disha Action Hub</strong><small>NG action closure workflow</small></span></button>
        {showLeadershipReview && <button onClick={() => openMoreRoute('/management-review')}><FileBarChart size={20} /><span><strong>Review Center</strong><small>Executive boardroom review</small></span></button>}
        <button onClick={() => openMoreRoute('/verification')}><ShieldCheck size={20} /><span><strong>Verification</strong><small>Review closure evidence</small></span></button>
        <button onClick={() => openMoreRoute('/yokoten')}><BookOpenCheck size={20} /><span><strong>Yokoten Library</strong><small>Shared improvement practices</small></span></button>
        {showMasters && <button onClick={() => openMoreRoute('/masters')}><Settings2 size={20} /><span><strong>Masters</strong><small>Users and configuration</small></span></button>}
        <button className="mobile-logout" onClick={handleLogout}><LogOut size={20} /><span><strong>Logout</strong><small>Sign out of Drive Pulse â€“ DISHA HSC</small></span></button>
      </section>
    </>}

    <nav className="bottom-nav">
      {mobileNav.map(({ to, label, icon: Icon }) => <NavLink to={to} key={to}><Icon size={20} /><span>{label}</span></NavLink>)}
      <button className={moreOpen || isMoreRoute ? 'active' : ''} onClick={() => setMoreOpen(true)}><MoreHorizontal size={20} /><span>More</span></button>
    </nav>
  </div>
}
