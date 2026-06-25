import { useEffect } from 'react'
import { Navigate, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { canAccessAuditModule, useAuth } from './AuthContext'

export default function ProtectedRoute() {
  const { isAuthenticated, user } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login', { replace: true, state: { from: location.pathname } })
    }
  }, [isAuthenticated, navigate, location.pathname])

  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location.pathname }} />
  if (user?.must_change_password && location.pathname !== '/reset-password') return <Navigate to="/reset-password" replace />

  return <Outlet />
}

export function AuditRouteGuard() {
  const { user } = useAuth()
  const location = useLocation()

  if (!canAccessAuditModule(user)) return <Navigate to="/dashboard" replace state={{ from: location.pathname }} />
  return <Outlet />
}
