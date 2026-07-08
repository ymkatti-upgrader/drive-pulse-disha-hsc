import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL?.trim()
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY?.trim()

if (import.meta.env.DEV) {
  console.log('SUPABASE URL EXISTS:', !!supabaseUrl)
  console.log('SUPABASE KEY EXISTS:', !!supabaseAnonKey)
}

export const supabase = supabaseUrl && supabaseAnonKey
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

export function requireSupabase() {
  if (supabase) return supabase
  throw new Error('Supabase is not configured. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
}
