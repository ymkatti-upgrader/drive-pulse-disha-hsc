import { useState } from 'react'
import { ArrowRight, Check, Eye, EyeOff } from 'lucide-react'
import { useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'

function normalizeMobile(value) {
  if (value === null || value === undefined) return ''

  return String(value)
    .replace(/\.0$/, '')
    .replace(/\D/g, '')
    .slice(-10)
}

export default function Login() {
  const [mobile, setMobile] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const { login } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()

  function handleMobileChange(event) {
    const enteredDigits = event.target.value.replace(/\D/g, '')
    const digits = enteredDigits.slice(0, 10)
    setMobile(digits)
    setError(enteredDigits.length > 10 ? 'Mobile number must be exactly 10 digits.' : '')
  }

  async function handleSubmit(event) {
    event.preventDefault()
    if (mobile.length !== 10) {
      setError('Mobile number must be exactly 10 digits.')
      return
    }
    if (!password) return
    setSubmitting(true)
    setError('')
    let result
    try {
      result = await login(mobile, password)
    } catch (error) {
      setSubmitting(false)
      setError(error.message || 'Unable to connect to backend.')
      return
    }
    setSubmitting(false)
    if (!result.ok) {
      setError(result.error)
      return
    }
    navigate(result.mustResetPassword || result.mustChangePassword ? '/force-password-reset' : location.state?.from || '/dashboard', { replace: true })
  }

  return <main className="login-page-simple">
    <form className="login-card card" onSubmit={handleSubmit} noValidate>
      <div className="login-app-brand">
        <span className="brand-mark large">DP</span>
        <div><strong>Drive Pulse – DISHA HSC</strong><span>Toyota HanSaChu Audit & Continuous Improvement Platform</span></div>
      </div>

      <div className="login-heading"><h1>Sign in</h1><p>Enter your registered mobile number and password to continue.</p></div>

      <label className="field-label" htmlFor="mobile">Mobile Number</label>
      <input
        id="mobile"
        className={error ? 'field-error' : ''}
        type="tel"
        inputMode="numeric"
        autoComplete="tel"
        placeholder="Enter registered mobile number"
        value={mobile}
        onChange={handleMobileChange}
        onBlur={() => mobile && mobile.length !== 10 && setError('Mobile number must be exactly 10 digits.')}
        required
      />
      {error && <span className="validation-message" role="alert">{error}</span>}

      <label className="field-label" htmlFor="password">Password</label>
      <div className="password-field">
        <input id="password" type={showPassword ? 'text' : 'password'} autoComplete="current-password" placeholder="Enter password" value={password} onChange={event => setPassword(event.target.value)} required />
        <button type="button" aria-label={showPassword ? 'Hide password' : 'Show password'} onClick={() => setShowPassword(!showPassword)}>{showPassword ? <EyeOff size={18} /> : <Eye size={18} />}</button>
      </div>

      <div className="form-options">
        <label className="checkbox"><input type="checkbox" defaultChecked /><span><Check size={13} /></span>Remember Me</label>
        <button type="button" className="text-button" onClick={() => setError('For security reasons, please change your default password before continuing.')}>Forgot Password?</button>
      </div>
      <button className="primary-button full" type="submit" disabled={!password || submitting}>{submitting ? 'Signing In' : 'Sign In'} <ArrowRight size={18} /></button>
    </form>
  </main>
}
