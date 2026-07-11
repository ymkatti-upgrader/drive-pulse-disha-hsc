import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'
import packageJson from './package.json' with { type: 'json' }

const buildTimestamp = new Date().toISOString()

export default defineConfig({
  define: {
    __APP_VERSION__: JSON.stringify(packageJson.version || '0.0.0'),
    __BUILD_TIMESTAMP__: JSON.stringify(buildTimestamp),
  },
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      injectRegister: 'auto',
      workbox: {
        cleanupOutdatedCaches: true,
        clientsClaim: true,
        skipWaiting: true,
      },
      manifest: {
        name: 'Disha HSC Pulse',
        short_name: 'HSC Pulse',
        description: 'DISHA HanSaChu dealership audit management',
        theme_color: '#EB0A1E',
        background_color: '#F5F7FA',
        display: 'standalone',
        start_url: '/',
        icons: [
          { src: '/icon.svg', sizes: 'any', type: 'image/svg+xml', purpose: 'any maskable' },
        ],
      },
    }),
  ],
})
