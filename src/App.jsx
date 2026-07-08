import { Navigate, Route, Routes } from 'react-router-dom'
import AppShell from './components/AppShell'
import Login from './pages/Login'
import ForcePasswordReset from './pages/ResetPassword'
import Dashboard from './pages/Dashboard'
import AuditCreation from './pages/AuditCreation'
import ConductAudit from './pages/ConductAudit'
import Verification from './pages/Verification'
import Reports from './pages/Reports'
import ManagementReviewCenter from './pages/ManagementReviewCenter'
import SuperAdminControlCenter from './pages/SuperAdminControlCenter'
import MasterData from './pages/MasterData'
import MasterImport from './pages/MasterImport'
import YokotenLibrary from './pages/YokotenLibrary'
import ActionCenter from './pages/ActionCenter'
import ProtectedRoute, { FeatureRouteGuard } from './auth/ProtectedRoute'
import { isSuperAdmin, useAuth } from './auth/AuthContext'

export default function App() {
  const { isAuthenticated, user } = useAuth()
  const mustResetPassword = Boolean(user?.must_reset_password ?? user?.must_change_password)
  return <Routes>
    <Route path="/login" element={isAuthenticated ? <Navigate to={mustResetPassword ? '/force-password-reset' : '/dashboard'} replace /> : <Login />} />
    <Route element={<ProtectedRoute />}>
      <Route path="/force-password-reset" element={<ForcePasswordReset />} />
      <Route path="/reset-password" element={<Navigate to="/force-password-reset" replace />} />
      <Route element={<AppShell />}>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/audits/new" element={<FeatureRouteGuard feature="audit-workbench"><AuditCreation /></FeatureRouteGuard>} />
        <Route path="/audits/:id/conduct" element={<FeatureRouteGuard feature="conduct-audit"><ConductAudit /></FeatureRouteGuard>} />
        <Route path="/improvements" element={<Navigate to="/action-center" replace />} />
        <Route path="/improvements/:id" element={<Navigate to="/action-center" replace />} />
        <Route path="/capa" element={<Navigate to="/action-center" replace />} />
        <Route path="/capa/:id" element={<Navigate to="/action-center" replace />} />
        <Route path="/verification" element={<FeatureRouteGuard feature="verification"><Verification /></FeatureRouteGuard>} />
        <Route path="/yokoten" element={<FeatureRouteGuard feature="yokoten"><YokotenLibrary /></FeatureRouteGuard>} />
        <Route path="/reports" element={<FeatureRouteGuard feature="reports"><Reports /></FeatureRouteGuard>} />
        <Route path="/management-review" element={<FeatureRouteGuard feature="management-review"><ManagementReviewCenter /></FeatureRouteGuard>} />
        <Route path="/super-admin" element={<AdminOnly><SuperAdminControlCenter /></AdminOnly>} />
        <Route path="/action-center" element={<ActionCenter />} />
        <Route path="/masters" element={<AdminOnly><MasterData /></AdminOnly>} />
        <Route path="/masters/import" element={<AdminOnly><MasterImport /></AdminOnly>} />
        <Route path="/master-data" element={<Navigate to="/masters" replace />} />
      </Route>
    </Route>
    <Route path="*" element={<Navigate to={isAuthenticated ? mustResetPassword ? '/force-password-reset' : '/dashboard' : '/login'} replace />} />
  </Routes>
}

function AdminOnly({ children }) {
  const { user } = useAuth()
  return isSuperAdmin(user) ? children : <Navigate to="/dashboard" replace />
}
