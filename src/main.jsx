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
import './styles.css'

if (import.meta.env.PROD) {
  registerSW({ immediate: true })
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
