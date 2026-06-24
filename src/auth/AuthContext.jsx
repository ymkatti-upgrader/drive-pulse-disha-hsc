import { createContext, useContext, useMemo, useState } from 'react'
import { requireSupabase } from '../supabaseClient'

const AUTH_KEY = 'current_user'
const LEGACY_AUTH_KEY = 'disha-hsc-auth'
export const DEFAULT_PASSWORD = 'Welcome@123'

export const mockRoles = [
  'CEO',
  'Group Functional HOD',
  'Group DISHA HSC PIC',
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

function sanitizeUser(user) {
  if (!user) return null
  const { password, ...safeUser } = user
  return safeUser
}

function toSessionUser(user, mappings) {
  return {
    id: user.id,
    employee_name: user.employee_name,
    mobile_no: user.mobile_no,
    active: user.active,
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
  const roles = getUserAccess(user).map(item => item.role).filter(Boolean)
  if (roles.some(role => normalizedText(role) === 'super admin')) return 'Super Admin'
  if (roles.some(role => normalizedText(role) === 'admin')) return 'Admin'
  if (roles.some(role => normalizedText(role) === 'system administrator')) return 'System Administrator'
  if (roles.some(role => normalizedText(role) === 'branch disha hsc pic')) return 'Branch Disha HSC PIC'
  if (roles.some(role => normalizedText(role) === 'ng pic')) return 'NG PIC'
  return roles[0] || user?.role || 'Viewer'
}

export function hasFullAccess(user) {
  return getUserAccess(user).some(item => normalizedText(item.role) === 'super admin')
}

export function hasAdminAccess(user) {
  return getUserAccess(user).some(item => ['admin', 'super admin'].includes(normalizedText(item.role)))
}

export function isSystemAdmin(user) {
  return getUserAccess(user).some(item => {
    const role = normalizedText(item.role)
    const userType = normalizedText(item.user_type)
    return role === 'super admin' || role === 'system administrator' || userType === 'system admin'
  })
}

function normalizedText(value) {
  return String(value || '').trim().toLowerCase()
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

  function persistSession(nextUser) {
    const safeUser = sanitizeUser(nextUser)
    localStorage.setItem(AUTH_KEY, JSON.stringify(safeUser))
    localStorage.removeItem(LEGACY_AUTH_KEY)
    setUser(safeUser)
    return safeUser
  }

  const value = useMemo(() => ({
    user,
    users: users.map(sanitizeUser),
    passwordRules,
    isAuthenticated: Boolean(user),
    async login(mobile, password) {
      const client = requireSupabase()
      const enteredMobile = normalizeMobile(mobile)
      const enteredPassword = String(password).trim()

      const { count, error: countError } = await client
        .from('app_users')
        .select('id', { count: 'exact', head: true })
      if (countError) return { ok: false, error: countError.message || 'Unable to read backend users.' }
      if (!count) return { ok: false, error: 'No users found in backend. Please import Users Master.' }

      const { data: matchedUser, error: userError } = await client
        .from('app_users')
        .select('id, employee_name, mobile_no, password, active')
        .eq('mobile_no', enteredMobile)
        .maybeSingle()
      if (userError) return { ok: false, error: userError.message || 'Unable to validate login.' }
      if (!matchedUser) return { ok: false, error: 'Mobile number not found in Users Master.' }
      if (!matchedUser.active) return { ok: false, error: 'User is inactive. Please contact admin.' }
      if (String(matchedUser.password || '').trim() !== enteredPassword) return { ok: false, error: 'Incorrect password.' }

      const { data: mappings, error: mappingsError } = await client
        .from('user_access_mappings')
        .select('role, department, location, user_type')
        .eq('user_id', matchedUser.id)
        .eq('active', true)
      if (mappingsError) return { ok: false, error: mappingsError.message || 'Unable to read user mappings.' }

      const safeUser = persistSession(toSessionUser(matchedUser, mappings || []))
      return { ok: true, user: safeUser, mustChangePassword: false }
    },
    async changePassword(newPassword) {
      if (!user) return { ok: false, error: 'Session expired. Please sign in again.' }
      const validation = validatePassword(newPassword)
      if (!validation.valid) return { ok: false, error: 'Password does not meet the security rules.', validation }

      const client = requireSupabase()
      const { data: nextUser, error } = await client
        .from('app_users')
        .update({ password: newPassword })
        .eq('id', user.id)
        .select('id, employee_name, mobile_no, active')
        .single()
      if (error) return { ok: false, error: error.message || 'Unable to update password.' }

      persistSession({ ...user, ...toSessionUser(nextUser, user.access || []) })
      return { ok: true }
    },
    async importUsers(importedUsers) {
      const client = requireSupabase()
      const incoming = (importedUsers || []).map(normalizeImportRow).filter(Boolean)
      if (!incoming.length) return { ok: true, created: 0, updated: 0, mappings: 0, total: 0, imported: 0 }

      const mobileNumbers = [...new Set(incoming.map(row => row.mobile_no))]
      const { data: existingUsers, error: existingError } = await client
        .from('app_users')
        .select('id, mobile_no, password')
        .in('mobile_no', mobileNumbers)
      if (existingError) throw existingError

      const existingByMobile = new Map((existingUsers || []).map(row => [row.mobile_no, row]))
      const usersByMobile = new Map()
      incoming.forEach(row => {
        const existing = existingByMobile.get(row.mobile_no)
        const nextUser = usersByMobile.get(row.mobile_no) || {
          employee_name: '',
          mobile_no: row.mobile_no,
          password: '',
          active: false,
        }

        usersByMobile.set(row.mobile_no, {
          employee_name: row.employee_name || nextUser.employee_name,
          mobile_no: row.mobile_no,
          password: row.password || nextUser.password || existing?.password || DEFAULT_PASSWORD,
          active: Boolean(nextUser.active || row.active),
        })
      })

      const usersPayload = [...usersByMobile.values()]
      const { error: upsertUsersError } = await client
        .from('app_users')
        .upsert(usersPayload, { onConflict: 'mobile_no' })
      if (upsertUsersError) throw upsertUsersError

      const { data: refreshedUsers, error: refreshError } = await client
        .from('app_users')
        .select('id, employee_name, mobile_no, active')
        .in('mobile_no', mobileNumbers)
      if (refreshError) throw refreshError

      const idByMobile = new Map((refreshedUsers || []).map(row => [row.mobile_no, row.id]))
      const mappingByKey = new Map()
      incoming.forEach(row => {
        const userId = idByMobile.get(row.mobile_no)
        if (!userId) return

        const mapping = {
          user_id: userId,
          role: row.role || '',
          department: row.department || '',
          location: row.location || '',
          user_type: row.user_type || '',
          active: row.active,
        }
        const key = [mapping.user_id, mapping.role, mapping.department, mapping.location, mapping.user_type].join('|')
        if (!mappingByKey.has(key)) mappingByKey.set(key, mapping)
      })
      const mappingPayload = [...mappingByKey.values()]

      const { error: upsertMappingsError } = await client
        .from('user_access_mappings')
        .upsert(mappingPayload, { onConflict: 'user_id,role,department,location,user_type' })
      if (upsertMappingsError) throw upsertMappingsError

      setUsers(refreshedUsers || [])
      return {
        ok: true,
        created: usersPayload.filter(row => !existingByMobile.has(row.mobile_no)).length,
        updated: usersPayload.filter(row => existingByMobile.has(row.mobile_no)).length,
        mappings: mappingPayload.length,
        total: refreshedUsers?.length || 0,
        imported: incoming.length,
        uniqueUsers: usersPayload.length,
        accessMappings: mappingPayload.length,
      }
    },
    async resetUserPassword(mobile) {
      const normalizedMobile = normalizeMobile(mobile)
      if (!hasAdminAccess(user)) return { ok: false, error: 'Only Admin or Super Admin can reset passwords.' }
      if (normalizedMobile === user.mobile_no) return { ok: false, error: 'Use password reset screen to change your own password.' }

      const client = requireSupabase()
      const { data, error } = await client
        .from('app_users')
        .update({ password: DEFAULT_PASSWORD })
        .eq('mobile_no', normalizedMobile)
        .eq('active', true)
        .select('id')
      if (error) return { ok: false, error: error.message || 'Unable to reset password.' }
      if (!data?.length) return { ok: false, error: 'No active user found for that mobile number.' }
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
    logout() {
      localStorage.removeItem(AUTH_KEY)
      localStorage.removeItem(LEGACY_AUTH_KEY)
      setUser(null)
    },
  }), [user, users])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used inside AuthProvider')
  return context
}
