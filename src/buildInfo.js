const fallbackVersion = '0.0.0'
const fallbackTimestamp = 'development'

function getSupabaseHost() {
  const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || ''
  if (!supabaseUrl) return 'not-configured'

  try {
    return new URL(supabaseUrl).host
  } catch {
    return 'invalid-supabase-url'
  }
}

export const buildInfo = {
  appVersion: import.meta.env.VITE_APP_VERSION || __APP_VERSION__ || fallbackVersion,
  buildTimestamp: import.meta.env.VITE_BUILD_TIMESTAMP || __BUILD_TIMESTAMP__ || fallbackTimestamp,
  supabaseHost: getSupabaseHost(),
  mode: import.meta.env.MODE || 'unknown',
}

export function formattedBuildLabel() {
  const timestamp = buildInfo.buildTimestamp === fallbackTimestamp
    ? fallbackTimestamp
    : new Date(buildInfo.buildTimestamp).toLocaleString('en-IN', {
      dateStyle: 'medium',
      timeStyle: 'short',
    })

  return `v${buildInfo.appVersion} | ${timestamp}`
}
