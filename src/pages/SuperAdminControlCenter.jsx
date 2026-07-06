import { ArrowRight, Download, Edit3, FileText, Plus, RotateCcw, ShieldCheck, Trash2, Users, Users2 } from 'lucide-react'
import { useMemo, useState } from 'react'
import { PageHeader, StatusBadge } from '../components/UI'
import { useGovernance } from '../governance/GovernanceContext'
import { DEFAULT_PASSWORD, isSystemAdmin, useAuth } from '../auth/AuthContext'

const permissionColumns = ['view', 'add', 'edit', 'delete', 'approve', 'verify', 'close', 'export', 'aiAccess']

const workbookSections = {
  locations: {
    title: 'Locations',
    section: 'organization',
    subkey: 'locations',
    idKey: 'locationCode',
    fields: [
      { key: 'locationCode', label: 'Location Code' },
      { key: 'locationName', label: 'Location Name' },
      { key: 'type', label: 'Type' },
      { key: 'active', label: 'Active' },
    ],
  },
  departments: {
    title: 'Departments',
    section: 'organization',
    subkey: 'departments',
    idKey: 'departmentName',
    fields: [
      { key: 'departmentName', label: 'Department Name' },
      { key: 'active', label: 'Active' },
    ],
  },
  roles: {
    title: 'Roles',
    section: 'roles',
    idKey: 'roleName',
    fields: [
      { key: 'roleName', label: 'Role Name' },
      { key: 'mappedTo', label: 'Mapped to' },
      { key: 'description', label: 'Description', type: 'textarea' },
      { key: 'active', label: 'Active' },
    ],
  },
  approvalMatrix: {
    title: 'Approval Matrix',
    section: 'approvalMatrix',
    idKey: 'approvalType',
    fields: [
      { key: 'approvalType', label: 'Approval Type' },
      { key: 'approver', label: 'Approver' },
    ],
  },
  escalationMatrix: {
    title: 'Escalation Matrix',
    section: 'escalationMatrix',
    idKey: 'eventType',
    fields: [
      { key: 'eventType', label: 'Event Type' },
      { key: 'days', label: 'Days', type: 'number' },
      { key: 'escalateTo', label: 'Escalate To' },
    ],
  },
  aiGovernance: {
    title: 'AI Governance',
    section: 'aiGovernance',
    idKey: 'feature',
    fields: [
      { key: 'feature', label: 'Feature' },
      { key: 'enabled', label: 'Enabled' },
      { key: 'approver', label: 'Approver' },
    ],
  },
  evidenceGovernance: {
    title: 'Evidence Governance',
    section: 'evidenceGovernance',
    idKey: 'evidenceType',
    fields: [
      { key: 'evidenceType', label: 'Evidence Type' },
      { key: 'uploadAllowed', label: 'Upload Allowed' },
      { key: 'editAllowed', label: 'Edit Allowed' },
      { key: 'deleteAllowed', label: 'Delete Allowed' },
      { key: 'retentionPeriod', label: 'Retention Period' },
      { key: 'ownerRole', label: 'Owner Role' },
      { key: 'mandatory', label: 'Mandatory' },
    ],
  },
  notificationRules: {
    title: 'Notification Rules',
    section: 'notificationRules',
    idKey: 'event',
    fields: [
      { key: 'event', label: 'Event' },
      { key: 'recipientRole', label: 'Recipient Role' },
      { key: 'priority', label: 'Priority' },
      { key: 'enabled', label: 'Enabled' },
    ],
  },
  systemSettings: {
    title: 'System Settings',
    section: 'systemSettings',
    idKey: 'settingName',
    fields: [
      { key: 'settingName', label: 'Setting Name' },
      { key: 'value', label: 'Value' },
      { key: 'description', label: 'Description', type: 'textarea' },
    ],
  },
}

function SectionCard({ eyebrow, title, description, action, children }) {
  return <section className="card governance-card">
    <div className="panel-head">
      <div>
        <span className="eyebrow">{eyebrow}</span>
        <h2>{title}</h2>
        {description && <p>{description}</p>}
      </div>
      {action}
    </div>
    {children}
  </section>
}

function EditModal({ title, fields, value, onCancel, onSave }) {
  const [form, setForm] = useState(value)

  function update(key, nextValue) {
    setForm(current => ({ ...current, [key]: nextValue }))
  }

  return <div className="modal-layer">
    <button className="modal-backdrop" aria-label="Close editor" onClick={onCancel} />
    <form className="master-modal card governance-modal" onSubmit={event => { event.preventDefault(); onSave(form) }}>
      <div className="modal-head">
        <div><span className="eyebrow">EDIT MASTER DATA</span><h2>{title}</h2></div>
        <button type="button" aria-label="Close" onClick={onCancel}>x</button>
      </div>
      <div className="master-form-grid governance-form-grid">
        {fields.map(field => <label key={field.key} className={field.type === 'textarea' ? 'wide' : ''}>
          {field.label}
          {field.type === 'textarea'
            ? <textarea rows="4" value={form[field.key] || ''} onChange={event => update(field.key, event.target.value)} />
            : <input type={field.type === 'number' ? 'number' : 'text'} value={form[field.key] || ''} onChange={event => update(field.key, event.target.value)} />}
        </label>)}
      </div>
      <div className="modal-actions"><button type="button" className="secondary-button" onClick={onCancel}>Cancel</button><button type="submit" className="primary-button">Save</button></div>
    </form>
  </div>
}

function readRows(governance, config) {
  if (config.subkey) return governance[config.section][config.subkey]
  return governance[config.section]
}

function updateRows(governance, updateSection, config, rows) {
  if (config.subkey) {
    updateSection(config.section, { ...governance[config.section], [config.subkey]: rows })
    return
  }
  updateSection(config.section, rows)
}

export default function SuperAdminControlCenter() {
  const { governance, updateSection, appendTrail, resetGovernance } = useGovernance()
  const { resetUserPassword, user, users } = useAuth()
  const canAdminister = isSystemAdmin(user)
  const [editor, setEditor] = useState(null)
  const [resetMobile, setResetMobile] = useState('')
  const [resetMessage, setResetMessage] = useState('')

  const summary = useMemo(() => ({
    locations: governance.organization.locations.length,
    departments: governance.organization.departments.length,
    roles: governance.roles.length,
    activeRules: governance.approvalMatrix.length + governance.escalationMatrix.length + governance.aiGovernance.length + governance.notificationRules.length,
  }), [governance])

  function openEditor(type, item, index) {
    const config = workbookSections[type]
    const empty = Object.fromEntries(config.fields.map(field => [field.key, '']))
    setEditor({ type, index, title: config.title, fields: config.fields, value: item || empty })
  }

  function saveEditor(form) {
    if (!editor) return
    const config = workbookSections[editor.type]
    const rows = [...readRows(governance, config)]
    if (typeof editor.index === 'number') rows[editor.index] = form
    else rows.push(form)
    updateRows(governance, updateSection, config, rows)
    appendTrail(`${config.title} updated`, form[config.idKey] || config.title)
    setEditor(null)
  }

  function deleteItem(type, index, label) {
    const config = workbookSections[type]
    const rows = readRows(governance, config).filter((_, itemIndex) => itemIndex !== index)
    updateRows(governance, updateSection, config, rows)
    appendTrail(`${config.title} deleted`, label)
  }

  function togglePermission(role, permission) {
    updateSection('permissions', governance.permissions.map(row => row.role === role ? { ...row, [permission]: !row[permission] } : row))
    appendTrail('Role Permissions updated', `${role} ${permission} toggled`)
  }

  async function handlePasswordReset(event) {
    event.preventDefault()
    const result = await resetUserPassword(resetMobile)
    if (!result.ok) {
      setResetMessage(result.error)
      return
    }
    appendTrail('Password Reset Allowed', `Mobile ${resetMobile} reset to default password`)
    setResetMessage(`Password reset to ${DEFAULT_PASSWORD}. User must change password on next login.`)
    setResetMobile('')
  }

  function renderWorkbookTable(type, maxRows = 8) {
    const config = workbookSections[type]
    const rows = readRows(governance, config)
    return <div className="admin-table">
      {rows.slice(0, maxRows).map((row, index) => <div className="admin-row" key={`${type}-${row[config.idKey]}-${index}`}>
        <div><strong>{row[config.idKey]}</strong><span>{config.fields.slice(1).map(field => row[field.key]).filter(Boolean).join(' | ')}</span></div>
        <div><StatusBadge>{row.active || row.enabled || row.priority || row.days || row.value || '-'}</StatusBadge></div>
        <div />
        <div className="admin-row-actions">
          <button disabled={!canAdminister} onClick={() => canAdminister && openEditor(type, row, index)}><Edit3 size={16} /></button>
          <button className="danger" disabled={!canAdminister} onClick={() => canAdminister && deleteItem(type, index, row[config.idKey])}><Trash2 size={16} /></button>
        </div>
      </div>)}
      {rows.length > maxRows && <div className="admin-row"><div><strong>{rows.length - maxRows} more records</strong><span>Upload or edit from the workbook import flow for full-list changes.</span></div><div /><div /><div /></div>}
    </div>
  }

  return <div className="super-admin-page">
    <PageHeader
      eyebrow="ADMIN CONTROL CENTER"
      title="Super Admin Control Center"
      description="Workbook-aligned master data controls for Drive Pulse DISHA HSC."
      action={<div className="admin-actions">
        <button className="secondary-button" onClick={() => window.print()}><Download size={16} /> Export / Print</button>
        <button className="secondary-button" onClick={resetGovernance}><RotateCcw size={16} /> Reset Defaults</button>
      </div>}
    />

    <section className="admin-summary-grid">
      <article className="card admin-summary"><span>Locations</span><strong>{summary.locations}</strong><small>Workbook sites</small></article>
      <article className="card admin-summary"><span>Departments</span><strong>{summary.departments}</strong><small>Workbook departments</small></article>
      <article className="card admin-summary"><span>Roles</span><strong>{summary.roles}</strong><small>Workbook roles</small></article>
      <article className="card admin-summary"><span>Rules</span><strong>{summary.activeRules}</strong><small>Workbook rule rows</small></article>
    </section>

    <div className="admin-grid">
      <SectionCard eyebrow="LOCATIONS" title="Locations" description="Columns: Location Code, Location Name, Type, Active." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('locations', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('locations')}
      </SectionCard>

      <SectionCard eyebrow="DEPARTMENTS" title="Departments" description="Columns: Department Name, Active." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('departments', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('departments')}
      </SectionCard>

      <SectionCard eyebrow="ROLES" title="Roles" description="Columns: Role Name, Mapped to, Description, Active." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('roles', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('roles')}
      </SectionCard>

      <SectionCard eyebrow="ROLE PERMISSIONS" title="Role Permissions" description="Columns match the workbook permission matrix." action={<ShieldCheck size={18} />}>
        <div className="admin-permission-wrap">
          <table className="admin-matrix">
            <thead><tr><th>Role</th>{permissionColumns.map(col => <th key={col}>{col === 'aiAccess' ? 'AI Access' : col.charAt(0).toUpperCase() + col.slice(1)}</th>)}</tr></thead>
            <tbody>
              {governance.permissions.map(row => <tr key={row.role}>
                <td><strong>{row.role}</strong></td>
                {permissionColumns.map(permission => <td key={permission}><button className={`perm-pill ${row[permission] ? 'on' : 'off'}`} onClick={() => togglePermission(row.role, permission)}>{row[permission] ? 'Y' : 'N'}</button></td>)}
              </tr>)}
            </tbody>
          </table>
        </div>
      </SectionCard>

      <SectionCard eyebrow="APPROVAL MATRIX" title="Approval Matrix" description="Columns: Approval Type, Approver." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('approvalMatrix', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('approvalMatrix')}
      </SectionCard>

      <SectionCard eyebrow="ESCALATION MATRIX" title="Escalation Matrix" description="Columns: Event Type, Days, Escalate To." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('escalationMatrix', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('escalationMatrix', 10)}
      </SectionCard>

      <SectionCard eyebrow="AI GOVERNANCE" title="AI Governance" description="Columns: Feature, Enabled, Approver." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('aiGovernance', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('aiGovernance', 10)}
      </SectionCard>

      <SectionCard eyebrow="EVIDENCE GOVERNANCE" title="Evidence Governance" description="Columns: Evidence Type, Upload Allowed, Edit Allowed, Delete Allowed, Retention Period, Owner Role, Mandatory." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('evidenceGovernance', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('evidenceGovernance', 10)}
      </SectionCard>

      <SectionCard eyebrow="NOTIFICATION RULES" title="Notification Rules" description="Columns: Event, Recipient Role, Priority, Enabled." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('notificationRules', null, null)}><Plus size={16} /> Add New</button>}>
        {renderWorkbookTable('notificationRules', 10)}
      </SectionCard>

      <SectionCard eyebrow="SYSTEM SETTINGS" title="System Settings" description="Columns: Setting Name, Value, Description." action={<button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor('systemSettings', null, null)}><Plus size={16} /> Add New</button>}>
        <form className="admin-password-reset" onSubmit={handlePasswordReset}>
          <div>
            <strong>Password reset by admin</strong>
            <span>Controlled by the System Settings workbook sheet.</span>
          </div>
          <input
            type="tel"
            inputMode="numeric"
            placeholder="Enter mobile number"
            value={resetMobile}
            onChange={event => { setResetMobile(event.target.value.replace(/\D/g, '').slice(0, 10)); setResetMessage('') }}
            disabled={!canAdminister}
          />
          <button className="primary-button" disabled={!canAdminister || resetMobile.length !== 10}>Reset Password</button>
          {resetMessage && <p>{resetMessage}</p>}
        </form>
        <div className="admin-user-reset-list">
          {users.map(item => <button key={item.mobile_no || item.mobile} type="button" onClick={() => setResetMobile(item.mobile_no || item.mobile)}>
            <strong>{item.employee_name || item.name}</strong>
            <span>+91 {item.mobile_no || item.mobile} - {item.role}</span>
            <StatusBadge>{item.must_reset_password || item.must_change_password ? 'Must reset' : 'Active password'}</StatusBadge>
          </button>)}
        </div>
        <div className="admin-system-grid">
          {governance.systemSettings.slice(0, 12).map(item => <button key={item.settingName} className="admin-system-action" onClick={() => appendTrail(item.settingName, item.description || 'Workbook setting opened') }>
            <span><FileText size={16} /></span>
            <div><strong>{item.settingName}</strong><small>{item.value}</small></div>
            <ArrowRight size={16} />
          </button>)}
        </div>
      </SectionCard>

      <SectionCard eyebrow="AUDIT TRAIL" title="Complete transaction history" description="Application audit trail for changes made from this control center." action={<Users size={18} />}>
        <div className="admin-trail-list">
          {governance.auditTrail.map((item, index) => <article className="admin-trail-row" key={`${item.action}-${index}`}>
            <div><strong>{item.action}</strong><p>{item.detail}</p></div>
            <div><StatusBadge>{item.by}</StatusBadge><small>{item.at}</small></div>
          </article>)}
        </div>
      </SectionCard>
    </div>

    {editor && <EditModal title={editor.title} fields={editor.fields} value={editor.value} onCancel={() => setEditor(null)} onSave={saveEditor} />}
  </div>
}
