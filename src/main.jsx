import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { registerSW } from 'virtual:pwa-register'
import App from './App'
import { AuditProvider } from './audits/AuditContext'
import { AuthProvider } from './auth/AuthContext'
import { CapaProvider } from './capa/CapaContext'
import { GovernanceProvider } from './governance/GovernanceContext'
import { NotificationProvider } from './notifications/NotificationContext'
import { YokotenProvider } from './yokoten/YokotenContext'
import { buildInfo } from './buildInfo'
import './styles.css'

function getServiceWorkerStatus() {
  if (!('serviceWorker' in navigator)) return 'unsupported'
  const controller = navigator.serviceWorker.controller ? 'controlled' : 'not-controlled'
  return `${controller}; ready-check-pending`
}

function logStartupDiagnostics(serviceWorkerStatus) {
  console.info('[DISHA HSC Pulse startup]', {
    appVersion: buildInfo.appVersion,
    buildTimestamp: buildInfo.buildTimestamp,
    supabaseHost: buildInfo.supabaseHost,
    currentRoute: window.location.pathname,
    mode: buildInfo.mode,
    serviceWorkerStatus,
  })
}

if (import.meta.env.PROD) {
  const updateServiceWorker = registerSW({
    immediate: true,
    onNeedRefresh() {
      console.info('[DISHA HSC Pulse PWA] New build available; refreshing service worker cache.')
      updateServiceWorker(true)
    },
    onOfflineReady() {
      console.info('[DISHA HSC Pulse PWA] Offline cache is ready.')
    },
    onRegisteredSW(_, registration) {
      const serviceWorkerStatus = registration
        ? `registered; ${navigator.serviceWorker.controller ? 'controlled' : 'not-controlled'}`
        : getServiceWorkerStatus()
      logStartupDiagnostics(serviceWorkerStatus)

      if (registration) {
        window.addEventListener('focus', () => registration.update())
        document.addEventListener('visibilitychange', () => {
          if (document.visibilityState === 'visible') registration.update()
        })
      }
    },
    onRegisterError(error) {
      console.error('[DISHA HSC Pulse PWA] Service worker registration failed.', error)
      logStartupDiagnostics(`registration-error: ${error?.message || 'unknown'}`)
    },
  })
} else {
  logStartupDiagnostics('disabled-in-development')
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <AuditProvider>
          <GovernanceProvider>
            <CapaProvider>
              <YokotenProvider>
                <NotificationProvider><App /></NotificationProvider>
              </YokotenProvider>
            </CapaProvider>
          </GovernanceProvider>
        </AuditProvider>
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>,
)
