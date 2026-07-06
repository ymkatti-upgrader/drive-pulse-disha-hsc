import { useMemo, useState } from 'react'
import { Check, Eye, EyeOff, LockKeyhole } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { DEFAULT_PASSWORD, getRoleProfile, useAuth, validatePassword } from '../auth/AuthContext'

export default function ForcePasswordReset() {
  const [currentPassword, setCurrentPassword] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const [saving, setSaving] = useState(false)
  const { changePassword, user } = useAuth()
  const navigate = useNavigate()
  const validation = useMemo(() => validatePassword(password), [password])
  const roleProfile = useMemo(() => getRoleProfile(user), [user])
  const mustResetMessage = 'For security reasons, please change your default password before continuing.'

  function validateForm() {
    if (!currentPassword.trim()) return 'Current password is required.'
    if (password === DEFAULT_PASSWORD) return 'New password cannot be the default password.'
    if (password.length < 8) return 'New password must be at least 8 characters.'
    if (password !== confirmPassword) return 'New password and confirm password do not match.'
    if (!validation.valid) return 'New password must include uppercase, lowercase, number, and special character.'
    return ''
  }

  async function handleSubmit(event) {
    event.preventDefault()
    const formError = validateForm()
    if (formError) {
      setError(formError)
      return
    }

    setSaving(true)
    setError('')
    const result = await changePassword(currentPassword, password)
    setSaving(false)
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
        <h1>Change password</h1>
        <p>{mustResetMessage}</p>
        <p>Signed in as {user?.employee_name || 'User'} - {roleProfile.label}</p>
      </div>

      <label className="field-label" htmlFor="current-password">Current Password</label>
      <div className="password-field">
        <input
          id="current-password"
          type={showPassword ? 'text' : 'password'}
          autoComplete="current-password"
          placeholder="Enter current password"
          value={currentPassword}
          onChange={event => { setCurrentPassword(event.target.value); setError('') }}
          required
        />
        <button type="button" aria-label={showPassword ? 'Hide password' : 'Show password'} onClick={() => setShowPassword(!showPassword)}>{showPassword ? <EyeOff size={18} /> : <Eye size={18} />}</button>
      </div>

      <label className="field-label" htmlFor="new-password">New Password</label>
      <div className="password-field">
        <input
          id="new-password"
          type={showPassword ? 'text' : 'password'}
          autoComplete="new-password"
          placeholder="Enter new password"
          value={password}
          onChange={event => { setPassword(event.target.value); setError('') }}
          required
        />
      </div>

      <label className="field-label" htmlFor="confirm-password">Confirm New Password</label>
      <div className="password-field">
        <input
          id="confirm-password"
          type={showPassword ? 'text' : 'password'}
          autoComplete="new-password"
          placeholder="Confirm new password"
          value={confirmPassword}
          onChange={event => { setConfirmPassword(event.target.value); setError('') }}
          required
        />
      </div>

      <div className="password-rule-list">
        {validation.checks.map(rule => <span key={rule.key} className={rule.valid ? 'valid' : ''}><Check size={13} />{rule.label}</span>)}
      </div>

      {error && <span className="validation-message" role="alert">{error}</span>}

      <button className="primary-button full" type="submit" disabled={saving || !currentPassword || !password || !confirmPassword}>
        <LockKeyhole size={18} /> {saving ? 'Updating Password' : 'Update Password'}
      </button>
    </form>
  </main>
}
