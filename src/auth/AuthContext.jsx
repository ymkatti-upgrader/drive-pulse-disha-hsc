import { createContext, useContext, useEffect, useMemo, useState } from 'react'
import { requireSupabase, supabase } from '../supabaseClient'

const AUTH_KEY = 'current_user'
const LEGACY_AUTH_KEY = 'disha-hsc-auth'
const SIT_MODE_KEY = 'disha-hsc-sit-role'
const SESSION_TOKEN_KEY = 'disha-hsc-session-token'
const SUPER_ADMIN_MOBILE_NO = '9964214342'
const SIT_MODE_ENABLED = import.meta.env.VITE_ENABLE_SIT_MODE !== 'false'
const SESSION_STORAGE_KEYS = [
  AUTH_KEY,
  LEGACY_AUTH_KEY,
  SIT_MODE_KEY,
  SESSION_TOKEN_KEY,
  'disha-hsc-notification-reads',
  'disha-hsc-audit-creation-draft',
]
const SESSION_STORAGE_PREFIXES = ['disha-hsc-audit-draft:']
export const DEFAULT_PASSWORD = 'Welcome@123'

export const sitRoleOptions = [
  {
    key: 'auditor',
    label: 'Auditor',
    role: 'Auditor',
    userType: 'Auditor',
    persona: {
      id: 'a5e1b964-94f4-49b8-a320-ef66683ef03c',
      employee_name: 'RAJANISH',
      mobile_no: '8147821716',
    },
  },
  {
    key: 'assigned-pic',
    label: 'Assigned PIC',
    role: 'Location Functional HOD',
    userType: 'Assigned PIC',
    persona: {
      id: '82838961-ea6a-4319-adb1-a481c800fcf4',
      employee_name: 'SASI KUMAR',
      mobile_no: '9008999499',
    },
  },
  {
    key: 'group-disha',
    label: 'Group DISHA HSC PIC',
    role: 'Group DISHA HSC PIC',
    userType: 'Group DISHA HSC PIC',
    persona: {
      id: 'e2147812-007c-4d44-a16b-b6f85e4ccfe2',
      employee_name: 'ARUNA',
      mobile_no: '9900027554',
    },
  },
  {
    key: 'ceo',
    label: 'CEO',
    role: 'CEO',
    userType: 'CEO',
    persona: {
      id: '54d0eeea-7705-46d6-83d6-61fa1cb061bb',
      employee_name: 'S Ramkumar',
      mobile_no: '9900035319',
    },
  },
  {
    key: 'branch-disha',
    label: 'Branch DISHA PIC',
    role: 'Branch DISHA PIC',
    userType: 'Branch DISHA PIC',
    persona: {
      id: 'a5e1b964-94f4-49b8-a320-ef66683ef03c',
      employee_name: 'RAJANISH',
      mobile_no: '8147821716',
    },
  },
  {
    key: 'viewer',
    label: 'Viewer',
    role: 'Viewer',
    userType: 'Viewer',
    persona: {
      id: 'sit-viewer',
      employee_name: 'SIT Viewer',
      mobile_no: '0000000000',
    },
  },
]

export const mockRoles = [
  'CEO',
  'Group Functional HOD',
  'Group DISHA HSC PIC',
  'Group Disha HSC PIC',
  'Branch DISHA PIC',
  'Branch Disha HSC PIC',
  'NG PIC',
  'Location Functional HOD',
  'Viewer',
  'System Administrator',
  'Admin',
  'Super Admin',
]

const passwordRules = [
  { key: 'length', label: 'Minimum 8 characters', test: value => value.length >= 8 },
  { key: 'uppercase', label: 'One uppercase letter', test: value => /[A-Z]/.test(value) },
  { key: 'lowercase', label: 'One lowercase letter', test: value => /[a-z]/.test(value) },
  { key: 'number', label: 'One number', test: value => /\d/.test(value) },
  { key: 'special', label: 'One special character', test: value => /[^A-Za-z0-9]/.test(value) },
]

const AuthContext = createContext(null)

function readJson(key, fallback) {
  try {
    const stored = JSON.parse(localStorage.getItem(key))
    return stored || fallback
  } catch {
    return fallback
  }
}

function readStoredUser() {
  return readJson(AUTH_KEY, null) || readJson(LEGACY_AUTH_KEY, null)
}

function readSitRoleKey() {
  try {
    return localStorage.getItem(SIT_MODE_KEY) || ''
  } catch {
    return ''
  }
}

function readSessionToken() {
  try {
    return localStorage.getItem(SESSION_TOKEN_KEY) || ''
  } catch {
    return ''
  }
}

function clearSessionStorage() {
  SESSION_STORAGE_KEYS.forEach(key => {
    localStorage.removeItem(key)
  })

  for (let index = localStorage.length - 1; index >= 0; index -= 1) {
    const key = localStorage.key(index)
    if (!key) continue
    if (SESSION_STORAGE_PREFIXES.some(prefix => key.startsWith(prefix))) {
      localStorage.removeItem(key)
    }
  }

  try {
    sessionStorage.clear()
  } catch {
    // Ignore browsers that block sessionStorage access.
  }
}

function normalizeMobile(value) {
  if (value === null || value === undefined) return ''

  return String(value)
    .replace(/\.0$/, '')
    .replace(/\D/g, '')
    .slice(-10)
}

function normalizeActive(value) {
  const flag = String(value ?? '').trim().toLowerCase()
  if (['no', 'n', 'false', '0', 'inactive'].includes(flag)) return false
  return true
}

function normalizedText(value) {
  return String(value || '').trim().toLowerCase()
}

function normalizeAuditRole(value) {
  const role = normalizedText(value)
  if (role === 'branch disha pic') return 'branch disha hsc pic'
  if (role === 'group disha hsc pic') return 'group disha hsc pic'
  return role
}

function matchesAnyTerm(value, terms) {
  const text = normalizedText(value)
  if (!text) return false
  return terms.some(term => text.includes(normalizedText(term)))
}

function matchesUserAccess(user, terms) {
  return [user?.role, user?.user_type].some(value => matchesAnyTerm(value, terms))
    || getUserAccess(user).some(item => matchesAnyTerm(item.role, terms) || matchesAnyTerm(item.user_type, terms))
}

function sanitizeUser(user) {
  if (!user) return null
  const { password, password_hash, ...safeUser } = user
  return safeUser
}

function toSessionUser(user, mappings) {
  return {
    id: user.id,
    employee_name: user.employee_name,
    mobile_no: user.mobile_no,
    active: user.active,
    must_reset_password: Boolean(user.must_reset_password ?? user.must_change_password),
    must_change_password: Boolean(user.must_reset_password ?? user.must_change_password),
    password_changed_at: user.password_changed_at || null,
    last_login_at: user.last_login_at || null,
    failed_login_attempts: Number(user.failed_login_attempts) || 0,
    account_locked: Boolean(user.account_locked),
    access: (mappings || []).map(mapping => ({
      role: mapping.role || '',
      department: mapping.department || '',
      location: mapping.location || '',
      user_type: mapping.user_type || '',
    })),
  }
}

function normalizeImportRow(row) {
  const mobileNo = normalizeMobile(row.mobile_no || row.mobile || row.Mobile || row.MobileNo || row['MobileNo'] || row['Mobile Number'] || row.mobile_number)
  if (mobileNo.length !== 10) return null

  return {
    employee_name: String(row.employee_name || row.full_name || row.name || row.employeeName || row['Employee Name'] || '').trim(),
    mobile_no: mobileNo,
    password: String(row.password || row.Password || row['Password'] || '').trim(),
    role: String(row.role || row.Role || '').trim(),
    active: normalizeActive(row.active ?? row.is_active ?? row.status ?? row.Active ?? row['Active']),
    department: String(row.department || row.Department || '').trim(),
    location: String(row.location || row.Location || '').trim(),
    user_type: String(row.user_type || row.userType || row['User Type'] || '').trim(),
  }
}

export function validatePassword(value) {
  const checks = passwordRules.map(rule => ({ ...rule, valid: rule.test(value) }))
  return { checks, valid: checks.every(rule => rule.valid) }
}

export function getUserAccess(user) {
  return Array.isArray(user?.access) ? user.access : Array.isArray(user?.mappings) ? user.mappings : []
}

export function getPrimaryRole(user) {
  if (isSuperAdmin(user)) return 'Super Admin'
  const roles = getUserAccess(user).map(item => item.role).filter(Boolean)
  if (roles.some(role => normalizedText(role) === 'super admin')) return 'Super Admin'
  if (roles.some(role => normalizedText(role) === 'admin')) return 'Admin'
  if (roles.some(role => normalizedText(role) === 'system administrator')) return 'System Administrator'
  if (roles.some(role => normalizeAuditRole(role) === 'group disha hsc pic')) return 'Group Disha HSC PIC'
  if (roles.some(role => normalizeAuditRole(role) === 'branch disha hsc pic')) return 'Branch Disha HSC PIC'
  if (roles.some(role => normalizedText(role) === 'ng pic')) return 'NG PIC'
  return roles[0] || user?.role || 'Viewer'
}

export function hasFullAccess(user) {
  return isSuperAdmin(user) || getUserAccess(user).some(item => normalizedText(item.role) === 'super admin')
}

export function hasAdminAccess(user) {
  return isSuperAdmin(user) || getUserAccess(user).some(item => ['admin', 'super admin'].includes(normalizedText(item.role)))
}

export function isSuperAdmin(user) {
  return normalizeMobile(user?.mobile_no) === SUPER_ADMIN_MOBILE_NO
    || getUserAccess(user).some(item => normalizedText(item.role) === 'super admin')
}

export function isSystemAdmin(user) {
  return getUserAccess(user).some(item => {
    const role = normalizedText(item.role)
    const userType = normalizedText(item.user_type)
    return isSuperAdmin(user) || role === 'system administrator' || userType === 'system admin'
  })
}

export function isGroupDishaHsc(user) {
  return matchesUserAccess(user, ['group disha hsc', 'group disha hsc pic'])
}

export function canManageDishaWorkflow(user) {
  return isGroupDishaHsc(user) || isSystemAdmin(user)
}

export function canViewReports(user) {
  if (isSystemAdmin(user) || canManageDishaWorkflow(user)) return true
  const roles = getUserAccess(user).flatMap(item => [item.role, item.user_type]).map(normalizedText)
  return roles.some(role => [
    'ceo',
    'group functional hod',
    'group disha hsc pic',
    'group disha hsc',
    'branch disha pic',
    'branch disha hsc pic',
    'location functional hod',
    'auditor',
    'viewer',
    'ng pic',
  ].includes(role))
}

export function canAccessSuperAdminControls(user) {
  return isSuperAdmin(user)
}

export function canAccessAuditModule(user) {
  return canAccessFeature(user, 'audit-workbench') || canAccessFeature(user, 'conduct-audit')
}

export function canViewAuditModule(user) {
  return canAccessFeature(user, 'audit-workbench') || canAccessFeature(user, 'conduct-audit')
}

export function isCeo(user) {
  return matchesUserAccess(user, ['ceo'])
}

export function isGroupFunctionalHod(user) {
  return matchesUserAccess(user, ['group functional hod', 'group functional pic'])
}

export function isBranchDishaAuditor(user) {
  return matchesUserAccess(user, ['branch disha hsc pic', 'branch disha pic', 'auditor'])
}

export function isLocationFunctionalHod(user) {
  return matchesUserAccess(user, ['location functional hod', 'ng pic'])
}

export function isViewer(user) {
  return matchesUserAccess(user, ['viewer'])
}

function buildSitModeUser(baseUser, sitRoleKey) {
  if (!SIT_MODE_ENABLED || !baseUser || !isSuperAdmin(baseUser) || !sitRoleKey) return baseUser

  const option = sitRoleOptions.find(item => item.key === sitRoleKey)
  if (!option) return baseUser

  const persona = option.persona || {}
  return {
    ...baseUser,
    id: persona.id || baseUser.id,
    employee_name: persona.employee_name || baseUser.employee_name,
    mobile_no: persona.mobile_no || baseUser.mobile_no,
    role: option.role,
    user_type: option.userType,
    access: [{
      role: option.role,
      department: 'All',
      location: 'All',
      user_type: option.userType,
    }],
    must_reset_password: false,
    must_change_password: false,
    __sitMode: true,
    __sitRoleKey: option.key,
    __sitRoleLabel: option.label,
    __realUserId: baseUser.id,
    __realUserMobileNo: baseUser.mobile_no,
  }
}

export function getAccessScopeValues(user, key) {
  return [...new Set(
    getUserAccess(user)
      .flatMap(item => splitScopeValues(item?.[key]))
      .map(value => String(value || '').trim())
      .filter(Boolean),
  )]
}

const ROLE_PROFILES = {
  'system-admin': {
    id: 'system-admin',
    label: 'System Administrator',
    dashboardName: 'Administration Dashboard',
    dashboardTone: 'admin',
    dashboardEyebrow: 'SYSTEM CONTROL',
    description: 'Application administration, masters, user access, audit setup, and platform governance.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Administrative home' },
      { feature: 'action-center', label: 'Action Center', description: 'Full action workspace' },
      { feature: 'audit-workbench', label: 'Audit Control', description: 'Create and assign audits' },
      { feature: 'masters', label: 'Masters', description: 'Users, roles, locations, checklist' },
      { feature: 'reports', label: 'Reports', description: 'Cross-functional analytics' },
    ],
    features: ['dashboard', 'action-center', 'audit-workbench', 'masters', 'reports', 'super-admin'],
  },
  ceo: {
    id: 'ceo',
    label: 'CEO',
    dashboardName: 'Executive Dashboard',
    dashboardTone: 'executive',
    dashboardEyebrow: 'STRATEGIC OVERSIGHT',
    description: 'Executive KPIs, financial approvals, repeat findings, and cross-location performance.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Executive overview' },
      { feature: 'financial-approvals', label: 'Financial Approvals', description: 'CEO approval queue' },
      { feature: 'reports', label: 'Reports', description: 'Enterprise analytics' },
      { feature: 'management-review', label: 'Audit Details', description: 'Read-only strategic review' },
    ],
    features: ['dashboard', 'action-center', 'reports', 'management-review'],
  },
  'group-disha': {
    id: 'group-disha',
    label: 'Group DISHA HSC PIC',
    dashboardName: 'Governance Dashboard',
    dashboardTone: 'governance',
    dashboardEyebrow: 'AUDIT GOVERNANCE',
    description: 'Review queues, financial technical scrutiny, verification flow, and multi-location monitoring.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Governance overview' },
      { feature: 'management-review', label: 'Audit Monitoring', description: 'Audit and CAPA governance' },
      { feature: 'review-queue', label: 'Review Queue', description: 'CAPA and closure reviews' },
      { feature: 'financial-review', label: 'Financial Review Queue', description: 'Technical recommendation stage' },
      { feature: 'verification', label: 'Verification Queue', description: 'Evidence review queue' },
      { feature: 'reports', label: 'Reports', description: 'Governance analytics' },
    ],
    features: ['dashboard', 'action-center', 'verification', 'management-review', 'reports', 'yokoten'],
  },
  'group-functional-hod': {
    id: 'group-functional-hod',
    label: 'Group Functional PIC / HOD',
    dashboardName: 'Department Governance Dashboard',
    dashboardTone: 'department',
    dashboardEyebrow: 'DEPARTMENT GOVERNANCE',
    description: 'Department analytics, pending reviews, and cross-location action performance for your function.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Department home' },
      { feature: 'action-center', label: 'My Department Work', description: 'Department NG, CAPA, and reviews' },
      { feature: 'reports', label: 'Reports', description: 'Department reports' },
    ],
    features: ['dashboard', 'action-center', 'reports'],
  },
  'branch-auditor': {
    id: 'branch-auditor',
    label: 'Branch DISHA PIC',
    dashboardName: 'Audit Dashboard',
    dashboardTone: 'audit',
    dashboardEyebrow: 'AUDIT EXECUTION',
    description: 'Assigned audits, findings capture, verification, and audit history for your scope.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Audit home' },
      { feature: 'action-center', label: 'Action Center', description: 'Review and verification workspace' },
      { feature: 'audit-workbench', label: 'My Audits', description: 'Assigned and draft audits' },
      { feature: 'conduct-audit', label: 'Conduct Audit', description: 'Execution workbench' },
      { feature: 'verification', label: 'Verification', description: 'Closure verification' },
      { feature: 'reports', label: 'Audit History', description: 'Read-only audit history' },
    ],
    features: ['dashboard', 'action-center', 'audit-workbench', 'conduct-audit', 'verification', 'reports', 'yokoten'],
  },
  'location-functional-hod': {
    id: 'location-functional-hod',
    label: 'Location Functional HOD',
    dashboardName: 'Action Dashboard',
    dashboardTone: 'action',
    dashboardEyebrow: 'ACTION OWNERSHIP',
    description: 'Assigned actions, CAPA progress, collaboration, financial requests, and resubmissions.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Action owner home' },
      { feature: 'action-center', label: 'My Work', description: 'Assigned CAPA and collaboration' },
      { feature: 'reports', label: 'History', description: 'Read-only action history' },
    ],
    features: ['dashboard', 'action-center', 'reports'],
  },
  viewer: {
    id: 'viewer',
    label: 'Viewer',
    dashboardName: 'Reporting Dashboard',
    dashboardTone: 'viewer',
    dashboardEyebrow: 'READ ONLY',
    description: 'Read-only dashboards, reports, and audit history without workflow actions.',
    navigation: [
      { feature: 'dashboard', label: 'Dashboard', description: 'Reporting home' },
      { feature: 'reports', label: 'Reports', description: 'Read-only analytics' },
    ],
    features: ['dashboard', 'reports'],
  },
}

function resolveRoleProfileId(user) {
  if (isSuperAdmin(user)) return 'system-admin'
  if (isCeo(user)) return 'ceo'
  if (isGroupDishaHsc(user)) return 'group-disha'
  if (isGroupFunctionalHod(user)) return 'group-functional-hod'
  if (isBranchDishaAuditor(user)) return 'branch-auditor'
  if (isLocationFunctionalHod(user)) return 'location-functional-hod'
  return 'viewer'
}

export function getRoleProfile(user) {
  return ROLE_PROFILES[resolveRoleProfileId(user)] || ROLE_PROFILES.viewer
}

export function canAccessFeature(user, feature) {
  return getRoleProfile(user).features.includes(feature)
}

function splitScopeValues(value) {
  if (Array.isArray(value)) return value.flatMap(item => splitScopeValues(item))
  return String(value || '')
    .split(',')
    .map(part => part.trim())
    .filter(Boolean)
}

export function canAccessScope(user, { department, location } = {}) {
  const access = getUserAccess(user)
  if (!access.length) return true
  if (hasFullAccess(user)) return true

  const wantedDepartments = splitScopeValues(department).map(normalizedText).filter(Boolean)
  const wantedLocations = splitScopeValues(location).map(normalizedText).filter(Boolean)
  return access.some(item => {
    const itemDepartments = splitScopeValues(item.department).map(normalizedText).filter(Boolean)
    const itemLocations = splitScopeValues(item.location).map(normalizedText).filter(Boolean)
    const departmentAllowed = !wantedDepartments.length || itemDepartments.includes('all') || !itemDepartments.length || wantedDepartments.some(departmentValue => itemDepartments.includes(departmentValue))
    const locationAllowed = !wantedLocations.length || itemLocations.includes('all') || !itemLocations.length || wantedLocations.some(locationValue => itemLocations.includes(locationValue))
    return departmentAllowed && locationAllowed
  })
}

export function filterByUserAccess(user, rows, getScope) {
  return (rows || []).filter(row => canAccessScope(user, getScope(row)))
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(readStoredUser)
  const [users, setUsers] = useState([])
  const [sitRoleKey, setSitRoleKey] = useState(readSitRoleKey)
  const [sessionToken, setSessionToken] = useState(readSessionToken)
  const effectiveUser = useMemo(() => buildSitModeUser(user, sitRoleKey), [user, sitRoleKey])

  // Cached sessions can carry a must_reset_password value that predates a
  // later admin/DB correction. Revalidate it against the backend on
  // initialization instead of trusting the stale cached copy indefinitely.
  useEffect(() => {
    if (!user?.id || !supabase) return
    let cancelled = false

    supabase
      .from('app_users')
      .select('must_reset_password, active, account_locked')
      .eq('id', user.id)
      .maybeSingle()
      .then(({ data, error }) => {
        if (cancelled || error || !data) return
        const freshMustReset = Boolean(data.must_reset_password)
        setUser(current => {
          if (!current || current.id !== user.id) return current
          if (
            current.must_reset_password === freshMustReset
            && current.active === data.active
            && current.account_locked === Boolean(data.account_locked)
          ) return current

          const nextUser = {
            ...current,
            must_reset_password: freshMustReset,
            must_change_password: freshMustReset,
            active: data.active,
            account_locked: Boolean(data.account_locked),
          }
          localStorage.setItem(AUTH_KEY, JSON.stringify(nextUser))
          return nextUser
        })
      })

    return () => {
      cancelled = true
    }
  }, [user?.id])

  function persistSession(nextUser, token) {
    const safeUser = sanitizeUser(nextUser)
    const tokenToKeep = token || readSessionToken()
    clearSessionStorage()
    localStorage.setItem(AUTH_KEY, JSON.stringify(safeUser))
    localStorage.removeItem(LEGACY_AUTH_KEY)
    if (tokenToKeep) localStorage.setItem(SESSION_TOKEN_KEY, tokenToKeep)
    setSessionToken(tokenToKeep || '')
    setUser(safeUser)
    return safeUser
  }

  const value = useMemo(() => ({
    user: effectiveUser,
    actualUser: user,
    users: users.map(sanitizeUser),
    passwordRules,
    sessionToken,
    isAuthenticated: Boolean(user),
    sitModeEnabled: SIT_MODE_ENABLED,
    sitModeAvailable: SIT_MODE_ENABLED && isSuperAdmin(user),
    sitRoleKey,
    sitRoleOptions,
    setSitRole(nextRoleKey) {
      if (!SIT_MODE_ENABLED || !isSuperAdmin(user)) return
      const normalizedRoleKey = String(nextRoleKey || '')
      if (normalizedRoleKey && !sitRoleOptions.some(option => option.key === normalizedRoleKey)) return
      if (normalizedRoleKey) localStorage.setItem(SIT_MODE_KEY, normalizedRoleKey)
      else localStorage.removeItem(SIT_MODE_KEY)
      setSitRoleKey(normalizedRoleKey)
    },
    clearSitRole() {
      localStorage.removeItem(SIT_MODE_KEY)
      setSitRoleKey('')
    },
    async login(mobile, password) {
      try {
        const client = requireSupabase()
        const enteredMobile = normalizeMobile(mobile)
        const enteredPassword = String(password).trim()

        const { data, error } = await client.rpc('login_user', {
          p_mobile_no: enteredMobile,
          p_password: enteredPassword,
        })
        if (error) {
          console.error('Login RPC failed', error)
          return { ok: false, error: error.message || 'Unable to connect to backend.' }
        }
        if (!data?.success) {
          return { ok: false, error: data?.error || 'Unable to sign in.' }
        }

        const sessionUser = toSessionUser(data.user, data.access || [])
        const safeUser = persistSession(sessionUser, data.session_token)
        localStorage.removeItem(SIT_MODE_KEY)
        setSitRoleKey('')
        return {
          ok: true,
          user: safeUser,
          mustResetPassword: Boolean(safeUser.must_reset_password || safeUser.must_change_password),
          mustChangePassword: Boolean(safeUser.must_reset_password || safeUser.must_change_password),
        }
      } catch (error) {
        const message = String(error?.message || '')
        if (message.includes('Supabase is not configured')) {
          return { ok: false, error: 'Supabase is not configured. Please contact administrator.' }
        }
        console.error('Login failed', error)
        return { ok: false, error: message || 'Unable to connect to backend.' }
      }
    },
    async changePassword(currentPassword, newPassword) {
      if (!user) return { ok: false, error: 'Session expired. Please sign in again.' }
      const enteredCurrentPassword = String(currentPassword ?? '').trim()
      const validation = validatePassword(newPassword)
      if (String(newPassword).trim() === DEFAULT_PASSWORD) return { ok: false, error: 'New password cannot be the default password.', validation }
      if (!validation.valid) return { ok: false, error: 'Password does not meet the security rules.', validation }

      const client = requireSupabase()
      const { data, error } = await client.rpc('change_own_password', {
        p_user_id: user.id,
        p_session_token: sessionToken,
        p_current_password: enteredCurrentPassword,
        p_new_password: String(newPassword),
      })
      if (error) return { ok: false, error: error.message || 'Unable to update password.' }
      if (!data?.success) return { ok: false, error: data?.error || 'Unable to update password.', validation }

      const now = new Date().toISOString()
      persistSession({
        ...user,
        must_reset_password: false,
        must_change_password: false,
        password_changed_at: now,
        last_login_at: now,
        failed_login_attempts: 0,
        account_locked: false,
      })
      return { ok: true }
    },
    async importUsers(importedUsers) {
      const client = requireSupabase()
      const incoming = (importedUsers || []).map(normalizeImportRow).filter(Boolean)
      if (!incoming.length) return { ok: true, created: 0, updated: 0, mappings: 0, total: 0, imported: 0 }

      const mobileNumbers = [...new Set(incoming.map(row => row.mobile_no))]
      const { data, error } = await client.rpc('admin_bulk_import_users', {
        p_admin_user_id: user?.id,
        p_admin_session_token: sessionToken,
        p_rows: incoming,
      })
      if (error) throw error
      if (!data?.success) throw new Error(data?.error || 'Unable to import users.')

      const { data: refreshedUsers, error: refreshError } = await client
        .from('app_users')
        .select('id, employee_name, mobile_no, active')
        .in('mobile_no', mobileNumbers)
      if (refreshError) throw refreshError

      setUsers(refreshedUsers || [])
      return {
        ok: true,
        created: data.created || 0,
        updated: data.updated || 0,
        mappings: data.mappings || 0,
        total: data.total || 0,
        imported: incoming.length,
        uniqueUsers: data.total || 0,
        accessMappings: data.mappings || 0,
      }
    },
    async resetUserPassword(mobile) {
      const normalizedMobile = normalizeMobile(mobile)
      if (!hasAdminAccess(user)) return { ok: false, error: 'Only Admin or Super Admin can reset passwords.' }
      if (normalizedMobile === user.mobile_no) return { ok: false, error: 'Use password reset screen to change your own password.' }

      const client = requireSupabase()
      const { data, error } = await client.rpc('admin_reset_password', {
        p_admin_user_id: user.id,
        p_admin_session_token: sessionToken,
        p_target_mobile_no: normalizedMobile,
      })
      if (error) return { ok: false, error: error.message || 'Unable to reset password.' }
      if (!data?.success) return { ok: false, error: data?.error || 'Unable to reset password.' }
      return { ok: true }
    },
    setRole(role) {
      setUser(current => {
        if (!current) return current
        const nextUser = { ...current, role }
        localStorage.setItem(AUTH_KEY, JSON.stringify(nextUser))
        return nextUser
      })
    },
    async logout() {
      try {
        if (supabase && sessionToken) await supabase.rpc('logout_session', { p_session_token: sessionToken })
        if (supabase) {
          const { data } = await supabase.auth.getSession()
          if (data?.session) await supabase.auth.signOut()
        }
      } catch (error) {
        console.error('Supabase sign out failed', error)
      } finally {
        clearSessionStorage()
        setSitRoleKey('')
        setSessionToken('')
        setUser(null)
      }
    },
  }), [effectiveUser, sitRoleKey, sessionToken, user, users])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used inside AuthProvider')
  return context
}
