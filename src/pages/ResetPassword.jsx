import { useMemo, useState } from 'react'
import { Check, Eye, EyeOff, LockKeyhole } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuth, validatePassword } from '../auth/AuthContext'

export default function ResetPassword() {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const { changePassword, user } = useAuth()
  const navigate = useNavigate()
  const validation = useMemo(() => validatePassword(password), [password])

  async function handleSubmit(event) {
    event.preventDefault()
    if (password !== confirmPassword) {
      setError('Passwords do not match.')
      return
    }
    const result = await changePassword(password)
    if (!result.ok) {
      setError(result.error)
      return
    }
    navigate('/dashboard', { replace: true })
  }

  return <main className="login-page-simple">
    <form className="login-card card" onSubmit={handleSubmit} noValidate>
      <div className="login-app-brand">
        <span className="brand-mark large">DP</span>
        <div><strong>Drive Pulse - DISHA HSC</strong><span>Mandatory first-login password reset</span></div>
      </div>

      <div className="login-heading">
        <h1>Reset password</h1>
        <p>Mobile login ID: +91 {user?.mobile_no}. Create a new password before accessing dashboard.</p>
      </div>

      <label className="field-label" htmlFor="new-password">New Password</label>
      <div className="password-field">
        <input id="new-password" type={showPassword ? 'text' : 'password'} autoComplete="new-password" placeholder="Enter new password" value={password} onChange={event => { setPassword(event.target.value); setError('') }} required />
        <button type="button" aria-label={showPassword ? 'Hide password' : 'Show password'} onClick={() => setShowPassword(!showPassword)}>{showPassword ? <EyeOff size={18} /> : <Eye size={18} />}</button>
      </div>

      <label className="field-label" htmlFor="confirm-password">Confirm Password</label>
      <div className="password-field">
        <input id="confirm-password" type={showPassword ? 'text' : 'password'} autoComplete="new-password" placeholder="Confirm new password" value={confirmPassword} onChange={event => { setConfirmPassword(event.target.value); setError('') }} required />
      </div>

      <div className="password-rule-list">
        {validation.checks.map(rule => <span key={rule.key} className={rule.valid ? 'valid' : ''}><Check size={13} />{rule.label}</span>)}
      </div>

      {error && <span className="validation-message" role="alert">{error}</span>}

      <button className="primary-button full" type="submit" disabled={!validation.valid || !confirmPassword}>
        <LockKeyhole size={18} /> Update Password
      </button>
    </form>
  </main>
}
