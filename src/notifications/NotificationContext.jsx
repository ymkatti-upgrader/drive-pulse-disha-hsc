import { createContext, useCallback, useContext, useMemo, useState } from 'react'
import { isInProgressAuditStatus, useAudits } from '../audits/AuditContext'
import { getPrimaryRole, useAuth } from '../auth/AuthContext'
import { useOptionalCapas } from '../capa/CapaContext'
import { useYokoten } from '../yokoten/YokotenContext'

const NOTIFICATION_KEY = 'disha-hsc-notification-reads'
const NotificationContext = createContext(null)

function readStoredIds() {
  try {
    const stored = JSON.parse(localStorage.getItem(NOTIFICATION_KEY))
    return Array.isArray(stored) ? stored : []
  } catch {
    return []
  }
}

function formatDateTime(date) {
  return new Intl.DateTimeFormat('en-GB', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date)
}

function addHours(date, hours) {
  const next = new Date(date)
  next.setHours(next.getHours() + hours)
  return next
}

function parseDate(value) {
  if (!value) return null
  const parsed = new Date(value)
  return Number.isNaN(parsed.getTime()) ? null : parsed
}

function dayKey(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function isDueTomorrow(value, now) {
  const date = parseDate(value)
  if (!date) return false
  const tomorrow = new Date(now)
  tomorrow.setDate(tomorrow.getDate() + 1)
  return dayKey(date) === dayKey(tomorrow)
}

function isPastDue(value, now) {
  const date = parseDate(value)
  if (!date) return false
  return dayKey(date) < dayKey(now)
}

function buildNotification(id, data) {
  return {
    id,
    priority: data.priority || 'Normal',
    category: data.category,
    title: data.title,
    detail: data.detail,
    dateTime: data.dateTime,
    timestamp: data.timestamp || Date.now(),
    status: data.status || 'Unread',
    actionLink: data.actionLink,
    read: false,
  }
}

function buildNotifications({ role, audits, capas, stories, aiHistory }) {
  const now = new Date()
  const assignedAuditCount = audits.filter(item => item.status !== 'Completed').length
  const dueTomorrowAudits = audits.filter(item => (['Scheduled', 'In Progress', 'In progress'].includes(item.status) || isInProgressAuditStatus(item.status)) && isDueTomorrow(item.date || item.targetDate || item.due, now))
  const overdueAudits = audits.filter(item => (['Scheduled', 'In Progress', 'In progress'].includes(item.status) || isInProgressAuditStatus(item.status)) && isPastDue(item.date || item.targetDate || item.due, now))
  const submittedAudits = audits.filter(item => item.status === 'Submitted')
  const activeActions = capas.filter(item => !['Closed', 'Yokoten Shared', 'Cancelled'].includes(item.status))
  const rootCausePending = activeActions.filter(item => item.status === 'Root Cause Analysis' || !item.rootCauseSummary)
  const countermeasurePending = activeActions.filter(item => item.status === 'Countermeasure Planned')
  const approvalPending = activeActions.filter(item => item.status === 'Approval Pending')
  const overdueActions = activeActions.filter(item => isPastDue(item.targetDate || item.due || item.countermeasurePlan?.targetCompletionDate, now))
  const evidenceUploaded = activeActions.filter(item => item.status === 'Evidence Uploaded')
  const verificationPending = activeActions.filter(item => ['Evidence Uploaded', 'Verification Pending'].includes(item.status))
  const failedVerifications = capas.filter(item => item.verification?.effectivenessRating === 'Not Effective')
  const reopenedActions = capas.filter(item => Array.isArray(item.verificationHistory) && item.verificationHistory.some(entry => entry.effectivenessRating === 'Not Effective'))
  const pendingStories = stories.filter(item => ['Submitted', 'Pending Review'].includes(item.status))
  const approvedStories = stories.filter(item => item.status === 'Approved')
  const sharedStories = stories.filter(item => item.status === 'Shared')
  const pendingAi = aiHistory.filter(item => !['Accepted', 'Edited & Accepted', 'Rejected'].includes(item.reviewStatus))
  const acceptedAi = aiHistory.filter(item => ['Accepted', 'Edited & Accepted'].includes(item.reviewStatus))
  const items = []

  if (assignedAuditCount > 0) items.push(buildNotification('AUD-ASSIGNED', { priority: 'High', category: 'Audit Notifications', title: 'Audit Assigned', detail: `${assignedAuditCount} audit${assignedAuditCount > 1 ? 's are' : ' is'} assigned to the current team.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/audits/new' }))
  if (dueTomorrowAudits.length > 0) items.push(buildNotification('AUD-DUE', { priority: 'Critical', category: 'Audit Notifications', title: 'Audit Due Tomorrow', detail: `${dueTomorrowAudits.length} scheduled audit${dueTomorrowAudits.length > 1 ? 's are' : ' is'} due tomorrow.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/audits/new' }))
  if (overdueAudits.length > 0) items.push(buildNotification('AUD-OVER', { priority: 'Critical', category: 'Audit Notifications', title: 'Audit Overdue', detail: `${overdueAudits.length} assigned audit${overdueAudits.length > 1 ? 's have' : ' has'} passed the expected completion date.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/audits/new' }))
  if (submittedAudits.length > 0) items.push(buildNotification('AUD-SUB', { priority: 'Normal', category: 'Audit Notifications', title: 'Audit Submitted', detail: `${submittedAudits.length} audit${submittedAudits.length > 1 ? 's have' : ' has'} been submitted.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/dashboard' }))

  if (activeActions.length > 0) items.push(buildNotification('IMP-NEW', { priority: 'High', category: 'Improvement Action Notifications', title: 'Improvement Actions Active', detail: `${activeActions.length} improvement action${activeActions.length > 1 ? 's are' : ' is'} active.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))
  if (rootCausePending.length > 0) items.push(buildNotification('IMP-RC', { priority: 'Medium', category: 'Improvement Action Notifications', title: 'Root Cause Pending', detail: `${rootCausePending.length} improvement action${rootCausePending.length > 1 ? 's need' : ' needs'} root cause analysis.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))
  if (countermeasurePending.length > 0) items.push(buildNotification('IMP-CM', { priority: 'High', category: 'Improvement Action Notifications', title: 'Countermeasure Pending', detail: `${countermeasurePending.length} action${countermeasurePending.length > 1 ? 's are' : ' is'} waiting for countermeasure planning.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))
  if (approvalPending.length > 0) items.push(buildNotification('IMP-AP', { priority: 'Critical', category: 'Improvement Action Notifications', title: 'Approval Pending', detail: `${approvalPending.length} countermeasure${approvalPending.length > 1 ? 's are' : ' is'} pending approval.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))
  if (overdueActions.length > 0) items.push(buildNotification('IMP-OV', { priority: 'Critical', category: 'Improvement Action Notifications', title: 'Overdue Action', detail: `${overdueActions.length} improvement action${overdueActions.length > 1 ? 's are' : ' is'} overdue.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))
  if (evidenceUploaded.length > 0) items.push(buildNotification('IMP-EV', { priority: 'Medium', category: 'Improvement Action Notifications', title: 'Evidence Uploaded', detail: `${evidenceUploaded.length} action${evidenceUploaded.length > 1 ? 's have' : ' has'} evidence uploaded.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/verification' }))

  if (verificationPending.length > 0) items.push(buildNotification('VER-PEND', { priority: 'High', category: 'Verification Notifications', title: 'Verification Pending', detail: `${verificationPending.length} action${verificationPending.length > 1 ? 's are' : ' is'} awaiting auditor verification.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/verification' }))
  if (failedVerifications.length > 0) items.push(buildNotification('VER-FAIL', { priority: 'Critical', category: 'Verification Notifications', title: 'Verification Failed', detail: `${failedVerifications.length} countermeasure${failedVerifications.length > 1 ? 's were' : ' was'} marked not effective.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/verification' }))
  if (reopenedActions.length > 0) items.push(buildNotification('VER-RE', { priority: 'High', category: 'Verification Notifications', title: 'Action Reopened', detail: `${reopenedActions.length} action${reopenedActions.length > 1 ? 's have' : ' has'} been reopened after verification.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))

  if (pendingStories.length > 0) items.push(buildNotification('YOK-SUB', { priority: 'Normal', category: 'Yokoten Notifications', title: 'Yokoten Submitted', detail: `${pendingStories.length} success stor${pendingStories.length > 1 ? 'ies are' : 'y is'} waiting for review.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/yokoten' }))
  if (approvedStories.length > 0) items.push(buildNotification('YOK-APP', { priority: 'Medium', category: 'Yokoten Notifications', title: 'Yokoten Approved', detail: `${approvedStories.length} shared improvement${approvedStories.length > 1 ? 's are' : ' is'} approved for library use.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/yokoten' }))
  if (sharedStories.length > 0) items.push(buildNotification('YOK-SHA', { priority: 'Normal', category: 'Yokoten Notifications', title: 'Yokoten Shared', detail: `${sharedStories.length} proven improvement${sharedStories.length > 1 ? 's have' : ' has'} been shared across locations.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/yokoten' }))

  if (pendingAi.length > 0) items.push(buildNotification('AI-REV', { priority: 'High', category: 'AI Sensei Notifications', title: 'AI Suggestion Awaiting Review', detail: `${pendingAi.length} AI suggestion${pendingAi.length > 1 ? 's are' : ' is'} waiting for PIC review.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))
  if (acceptedAi.length > 0) items.push(buildNotification('AI-ACC', { priority: 'Normal', category: 'AI Sensei Notifications', title: 'AI Suggestion Accepted', detail: `${acceptedAi.length} AI suggestion${acceptedAi.length > 1 ? 's have' : ' has'} been accepted.`, dateTime: formatDateTime(now), timestamp: now.getTime(), actionLink: '/improvements' }))

  const scoped = role === 'Group DISHA HSC PIC'
    ? items.filter(item => item.category === 'Audit Notifications' || item.category === 'Verification Notifications' || item.category === 'AI Sensei Notifications')
    : role === 'Location Functional HOD'
      ? items.filter(item => item.category === 'Improvement Action Notifications' || item.category === 'Verification Notifications' || item.category === 'AI Sensei Notifications' || item.category === 'Yokoten Notifications')
      : items

  return scoped
}

export function NotificationProvider({ children }) {
  const { user } = useAuth()
  const { audits: liveAudits } = useAudits()
  const capaContext = useOptionalCapas()
  const capas = capaContext?.capas || []
  const { stories } = useYokoten()
  const [readIds, setReadIds] = useState(readStoredIds)

  const notifications = useMemo(() => {
    const aiHistory = capas.flatMap(item => Array.isArray(item.aiSenseiHistory) ? item.aiSenseiHistory : [])
    return buildNotifications({
      role: getPrimaryRole(user) || 'Viewer',
      audits: liveAudits,
      capas,
      stories,
      aiHistory,
    }).sort((a, b) => b.timestamp - a.timestamp).map(item => ({ ...item, read: readIds.includes(item.id), status: readIds.includes(item.id) ? 'Read' : 'Unread' }))
  }, [user, liveAudits, capas, stories, readIds])

  const value = useMemo(() => {
    const unreadCount = notifications.filter(item => !item.read).length
    return {
      notifications,
      unreadCount,
      markRead(id) {
        setReadIds(current => {
          const next = current.includes(id) ? current : [id, ...current]
          localStorage.setItem(NOTIFICATION_KEY, JSON.stringify(next))
          return next
        })
      },
      markAllRead() {
        const next = notifications.map(item => item.id)
        localStorage.setItem(NOTIFICATION_KEY, JSON.stringify(next))
        setReadIds(next)
      },
      clearReadState() {
        localStorage.removeItem(NOTIFICATION_KEY)
        setReadIds([])
      },
    }
  }, [notifications])

  return <NotificationContext.Provider value={value}>{children}</NotificationContext.Provider>
}

export function useNotifications() {
  const context = useContext(NotificationContext)
  if (!context) throw new Error('useNotifications must be used inside NotificationProvider')
  return context
}
