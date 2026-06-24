import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from './AuthContext'

export default function ProtectedRoute() {
  const { isAuthenticated, user } = useAuth()
  const location = useLocation()

  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location.pathname }} />
  if (user?.must_change_password && location.pathname !== '/reset-password') return <Navigate to="/reset-password" replace />

  return <Outlet />
}
