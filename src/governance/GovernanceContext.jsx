import { createContext, useCallback, useContext, useMemo, useState } from 'react'
import { governanceDefaults } from './governanceDefaults'

const GOVERNANCE_KEY = 'disha-hsc-governance'
const GovernanceContext = createContext(null)

function readGovernance() {
  try {
    const stored = JSON.parse(localStorage.getItem(GOVERNANCE_KEY))
    if (!stored) return governanceDefaults
    const merged = { ...governanceDefaults, ...stored }
    return {
      ...merged,
      organization: {
        ...governanceDefaults.organization,
        ...(stored.organization || {}),
        locations: Array.isArray(stored.organization?.locations) && stored.organization.locations[0]?.locationCode ? stored.organization.locations : governanceDefaults.organization.locations,
        departments: Array.isArray(stored.organization?.departments) && stored.organization.departments[0]?.departmentName ? stored.organization.departments : governanceDefaults.organization.departments,
      },
      roles: Array.isArray(stored.roles) && stored.roles[0]?.roleName ? stored.roles : governanceDefaults.roles,
      permissions: Array.isArray(stored.permissions) ? stored.permissions : governanceDefaults.permissions,
      approvalMatrix: Array.isArray(stored.approvalMatrix) ? stored.approvalMatrix : governanceDefaults.approvalMatrix,
      escalationMatrix: Array.isArray(stored.escalationMatrix) && stored.escalationMatrix[0]?.eventType ? stored.escalationMatrix : governanceDefaults.escalationMatrix,
      aiGovernance: Array.isArray(stored.aiGovernance) ? stored.aiGovernance : governanceDefaults.aiGovernance,
      evidenceGovernance: Array.isArray(stored.evidenceGovernance) ? stored.evidenceGovernance : governanceDefaults.evidenceGovernance,
      notificationRules: Array.isArray(stored.notificationRules) ? stored.notificationRules : governanceDefaults.notificationRules,
      systemSettings: Array.isArray(stored.systemSettings) && stored.systemSettings[0]?.settingName ? stored.systemSettings : governanceDefaults.systemSettings,
    }
  } catch {
    return governanceDefaults
  }
}

function timestamp() {
  return new Intl.DateTimeFormat('en-GB', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date())
}

export function GovernanceProvider({ children }) {
  const [governance, setGovernance] = useState(readGovernance)

  const persist = useCallback(updater => {
    setGovernance(current => {
      const next = typeof updater === 'function' ? updater(current) : updater
      localStorage.setItem(GOVERNANCE_KEY, JSON.stringify(next))
      return next
    })
  }, [])

  const updateSection = useCallback((section, value) => {
    persist(current => ({ ...current, [section]: typeof value === 'function' ? value(current[section]) : value }))
  }, [persist])

  const appendTrail = useCallback((action, detail, by = 'Super Admin') => {
    persist(current => ({
      ...current,
      auditTrail: [{ action, detail, by, at: timestamp() }, ...(current.auditTrail || [])].slice(0, 20),
    }))
  }, [persist])

  const resetGovernance = useCallback(() => {
    localStorage.removeItem(GOVERNANCE_KEY)
    setGovernance(governanceDefaults)
  }, [])

  const value = useMemo(() => ({ governance, updateSection, appendTrail, resetGovernance }), [governance, updateSection, appendTrail, resetGovernance])
  return <GovernanceContext.Provider value={value}>{children}</GovernanceContext.Provider>
}

export function useGovernance() {
  const context = useContext(GovernanceContext)
  if (!context) throw new Error('useGovernance must be used inside GovernanceProvider')
  return context
}
