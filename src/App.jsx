import { Navigate, Route, Routes } from 'react-router-dom'
import AppShell from './components/AppShell'
import Login from './pages/Login'
import ResetPassword from './pages/ResetPassword'
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
import ProtectedRoute from './auth/ProtectedRoute'
import { isSystemAdmin, useAuth } from './auth/AuthContext'

export default function App() {
  const { isAuthenticated, user } = useAuth()
  return <Routes>
    <Route path="/login" element={isAuthenticated ? <Navigate to={user?.must_change_password ? '/reset-password' : '/dashboard'} replace /> : <Login />} />
    <Route element={<ProtectedRoute />}>
      <Route path="/reset-password" element={<ResetPassword />} />
      <Route element={<AppShell />}>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/audits/new" element={<AuditCreation />} />
        <Route path="/audits/:id/conduct" element={<ConductAudit />} />
        <Route path="/improvements" element={<Navigate to="/action-center" replace />} />
        <Route path="/improvements/:id" element={<Navigate to="/action-center" replace />} />
        <Route path="/capa" element={<Navigate to="/action-center" replace />} />
        <Route path="/capa/:id" element={<Navigate to="/action-center" replace />} />
        <Route path="/verification" element={<Verification />} />
        <Route path="/yokoten" element={<YokotenLibrary />} />
        <Route path="/reports" element={<Reports />} />
        <Route path="/management-review" element={<ManagementReviewCenter />} />
        <Route path="/super-admin" element={<AdminOnly><SuperAdminControlCenter /></AdminOnly>} />
        <Route path="/action-center" element={<ActionCenter />} />
        <Route path="/masters" element={<AdminOnly><MasterData /></AdminOnly>} />
        <Route path="/masters/import" element={<AdminOnly><MasterImport /></AdminOnly>} />
        <Route path="/master-data" element={<Navigate to="/masters" replace />} />
      </Route>
    </Route>
    <Route path="*" element={<Navigate to={isAuthenticated ? user?.must_change_password ? '/reset-password' : '/dashboard' : '/login'} replace />} />
  </Routes>
}

function AdminOnly({ children }) {
  const { user } = useAuth()
  return isSystemAdmin(user) ? children : <Navigate to="/dashboard" replace />
}
