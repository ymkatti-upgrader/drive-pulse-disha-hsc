import { useEffect } from 'react'
import { Navigate, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { canAccessFeature, canViewAuditModule, useAuth } from './AuthContext'

export default function ProtectedRoute() {
  const { isAuthenticated, user } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()
  const mustResetPassword = Boolean(user?.must_reset_password ?? user?.must_change_password)

  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login', { replace: true, state: { from: location.pathname } })
    }
  }, [isAuthenticated, navigate, location.pathname])

  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location.pathname }} />
  if (mustResetPassword && location.pathname !== '/force-password-reset') return <Navigate to="/force-password-reset" replace />

  return <Outlet />
}

export function AuditRouteGuard() {
  const { user } = useAuth()
  const location = useLocation()

  if (!canViewAuditModule(user)) return <Navigate to="/dashboard" replace state={{ from: location.pathname }} />
  return <Outlet />
}

export function FeatureRouteGuard({ feature, children }) {
  const { user } = useAuth()
  const location = useLocation()

  if (!canAccessFeature(user, feature)) return <Navigate to="/dashboard" replace state={{ from: location.pathname }} />
  return children
}
