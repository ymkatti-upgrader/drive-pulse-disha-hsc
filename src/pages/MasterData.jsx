import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft, Building2, ClipboardList, Edit3, MapPin, Plus, Search, ShieldCheck, Tags, Trash2, Upload, Users } from 'lucide-react'
import { PageHeader, StatusBadge } from '../components/UI'
import { isSuperAdmin, useAuth } from '../auth/AuthContext'
import { requireSupabase } from '../supabaseClient'

const masterConfig = {
  users: {
    label: 'Users',
    title: 'Users Master',
    icon: Users,
    description: 'Manage application access and workflow responsibilities.',
    fields: [
      ['employee_name', 'Full Name'],
      ['mobile_no', 'Mobile Number', 'tel'],
      ['user_type', 'Designation / User Type'],
      ['role', 'Role'],
      ['department', 'Department'],
      ['location', 'Location'],
      ['status', 'Status', 'status'],
    ],
  },
  accessMappings: {
    label: 'Access Mapping',
    title: 'Access Mapping',
    icon: ShieldCheck,
    description: 'Assign roles and location/function scope to application users.',
    fields: [
      ['employee_name', 'User'],
      ['role', 'Role'],
      ['department', 'Department'],
      ['location', 'Location'],
      ['user_type', 'User Type'],
      ['status', 'Status', 'status'],
    ],
  },
  departments: {
    label: 'Departments',
    title: 'Departments Master',
    icon: Building2,
    description: 'Maintain dealership departments and accountable heads.',
    fields: [
      ['name', 'Department Name'],
      ['status', 'Active Status', 'status'],
    ],
  },
  locations: {
    label: 'Locations',
    title: 'Locations Master',
    icon: MapPin,
    description: 'Configure dealership sites included in the audit program.',
    fields: [
      ['code', 'Location Code'],
      ['name', 'Location Name'],
      ['type', 'Type'],
      ['visibility', 'Active Status', 'status'],
    ],
  },
  checklists: {
    label: 'Checklists',
    title: 'Checklist Master',
    icon: ClipboardList,
    description: 'Maintain standard audit points, ownership and scoring rules.',
    fields: [
      ['checklist_code', 'Checklist Code'],
      ['chapter', 'Chapter'],
      ['question', 'Question'],
      ['evidence_required', 'Evidence Required', 'status'],
      ['status', 'Status', 'status'],
    ],
  },
  findings: {
    label: 'Finding Categories',
    title: 'Finding Categories Master',
    icon: Tags,
    description: 'Define risk classification, closure SLA and escalation rules.',
    fields: [
      ['categoryName', 'Category Name'],
      ['riskLevel', 'Risk Level'],
      ['slaDays', 'Default SLA Days', 'number'],
      ['escalationLevel', 'Escalation Level'],
    ],
  },
}

function mapStatus(value) {
  const flag = String(value ?? '').trim().toLowerCase()
  if (['active', 'yes', 'y', 'true', '1'].includes(flag)) return 'Active'
  if (['inactive', 'no', 'n', 'false', '0'].includes(flag)) return 'Inactive'
  return String(value ?? '')
}

function EmptyState({ label, onAddNew, message }) {
  return <div className="card master-empty"><Search size={30} /><strong>{message || 'No records found. Please import master data.'}</strong><p>{label} is empty until backend records are imported.</p><button className="primary-button" type="button" onClick={onAddNew}><Plus size={17} /> Add New</button></div>
}

function MasterEditModal({ title, fields, value, onCancel, onSave }) {
  const [form, setForm] = useState(value)

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
            ? <textarea rows="4" value={form[field.key] || ''} onChange={event => setForm(current => ({ ...current, [field.key]: event.target.value }))} />
            : <input type={field.type === 'number' ? 'number' : 'text'} value={form[field.key] || ''} onChange={event => setForm(current => ({ ...current, [field.key]: event.target.value }))} />}
        </label>)}
      </div>
      <div className="modal-actions"><button type="button" className="secondary-button" onClick={onCancel}>Cancel</button><button type="submit" className="primary-button">Save</button></div>
    </form>
  </div>
}

const userFields = [
  { key: 'employee_name', label: 'Employee Name', placeholder: 'Enter employee name', required: true },
  { key: 'mobile_no', label: 'Mobile Number', placeholder: 'Enter 10-digit mobile number', required: true, type: 'tel', inputMode: 'numeric', pattern: '[0-9]{10}' },
  { key: 'user_type', label: 'Designation / User Type', placeholder: 'Enter designation or user type' },
  { key: 'role', label: 'Role', placeholder: 'Select role', required: true, type: 'select', optionKey: 'roles' },
  { key: 'location', label: 'Location', placeholder: 'Select location', type: 'select', optionKey: 'locations' },
  { key: 'department', label: 'Department', placeholder: 'Select department', type: 'select', optionKey: 'departments' },
  { key: 'status', label: 'Status', placeholder: 'Select status', required: true, type: 'select', options: ['Active', 'Inactive'] },
]

const accessMappingFields = [
  { key: 'user_id', label: 'User', placeholder: 'Select user', required: true, type: 'user-select' },
  { key: 'role', label: 'Role', placeholder: 'Select role', required: true, type: 'select', optionKey: 'roles' },
  { key: 'location', label: 'Location', placeholder: 'Select location', type: 'select', optionKey: 'locations' },
  { key: 'department', label: 'Department', placeholder: 'Select department', type: 'select', optionKey: 'departments' },
  { key: 'user_type', label: 'User Type', placeholder: 'Enter user type' },
  { key: 'status', label: 'Status', placeholder: 'Select status', required: true, type: 'select', options: ['Active', 'Inactive'] },
]

function StructuredUserModal({ mode, kind, value, options, onCancel, onSave }) {
  const [form, setForm] = useState(value)
  const fields = kind === 'accessMappings' ? accessMappingFields : userFields
  const entityLabel = kind === 'accessMappings' ? 'Access Mapping' : 'User'

  function update(key, nextValue) {
    setForm(current => ({ ...current, [key]: nextValue }))
  }

  function renderControl(field) {
    const common = {
      id: `${kind}-${field.key}`,
      name: field.key,
      value: form[field.key] || '',
      required: field.required,
      'aria-required': field.required || undefined,
      onChange: event => update(field.key, field.type === 'tel' ? event.target.value.replace(/\D/g, '').slice(0, 10) : event.target.value),
    }
    if (field.type === 'user-select') {
      return <select {...common}>
        <option value="">{field.placeholder}</option>
        {options.users.map(item => <option key={item.id} value={item.id}>{item.employee_name} (+91 {item.mobile_no})</option>)}
      </select>
    }
    if (field.type === 'select') {
      const values = field.options || options[field.optionKey] || []
      return <select {...common}>
        <option value="">{field.placeholder}</option>
        {values.map(item => <option key={item} value={item}>{item}</option>)}
      </select>
    }
    return <input {...common} type={field.type || 'text'} inputMode={field.inputMode} pattern={field.pattern} placeholder={field.placeholder} />
  }

  return <div className="modal-layer">
    <button className="modal-backdrop" aria-label={`Close ${entityLabel.toLowerCase()} editor`} onClick={onCancel} />
    <form className="master-modal card user-master-modal" onSubmit={event => { event.preventDefault(); onSave(form) }}>
      <div className="modal-head">
        <div><span className="eyebrow">USER ADMINISTRATION</span><h2>{mode === 'create' ? `Create ${entityLabel}` : `Edit ${entityLabel}`}</h2><p>Fields marked <span aria-hidden="true">*</span> are required.</p></div>
        <button type="button" aria-label="Close" onClick={onCancel}>x</button>
      </div>
      <div className="master-form-grid user-master-form-grid">
        {fields.map(field => <label key={field.key} htmlFor={`${kind}-${field.key}`}>
          <span className="user-field-label">{field.label}{field.required && <b aria-label="required">*</b>}</span>
          {renderControl(field)}
        </label>)}
      </div>
      <div className="modal-actions"><button type="button" className="secondary-button" onClick={onCancel}>Cancel</button><button type="submit" className="primary-button">{mode === 'create' ? 'Create' : 'Save Changes'}</button></div>
    </form>
  </div>
}

export default function MasterData() {
  const navigate = useNavigate()
  const { user, sessionToken } = useAuth()
  const [selected, setSelected] = useState('users')
  const [editor, setEditor] = useState(null)
  const [saving, setSaving] = useState(false)
  const [data, setData] = useState({
    users: [],
    accessMappings: [],
    departments: [],
    locations: [],
    checklists: [],
    findings: [],
  })
  const [lookupOptions, setLookupOptions] = useState({ users: [], roles: [], departments: [], locations: [] })
  const [mobileDetailOpen, setMobileDetailOpen] = useState(false)
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const canAdminister = isSuperAdmin(user)

  useEffect(() => {
    let cancelled = false

    async function load() {
      try {
        const client = requireSupabase()
        const [departmentsResult, locationsResult, rolesResult, checklistResult, usersResult, mappingsResult] = await Promise.all([
          client.from('departments').select('id, name, status'),
          client.from('locations').select('id, code, name, type, visibility'),
          client.from('roles').select('id, name'),
          client.from('audit_checklist_master').select('id, checklist_code, chapter, question, evidence_required, status'),
          client.from('app_users').select('id, employee_name, mobile_no, active'),
          client.from('user_access_mappings').select('id, user_id, role, department, location, user_type, active'),
        ])

        if (cancelled) return

        const mappingsByUser = new Map()
        for (const mapping of (mappingsResult.data || []).filter(item => item.active !== false)) {
          if (!mappingsByUser.has(mapping.user_id)) mappingsByUser.set(mapping.user_id, [])
          mappingsByUser.get(mapping.user_id).push(mapping)
        }

        const users = (usersResult.data || []).map(user => {
          const mappings = mappingsByUser.get(user.id) || []
          const uniqueRoles = [...new Set(mappings.map(item => item.role).filter(Boolean))]
          const uniqueDepartments = [...new Set(mappings.map(item => item.department).filter(Boolean))]
          const uniqueLocations = [...new Set(mappings.map(item => item.location).filter(Boolean))]
          return {
            id: user.id,
            user_id: user.id,
            employee_name: user.employee_name,
            mobile_no: user.mobile_no,
            role: uniqueRoles.join(', '),
            department: uniqueDepartments.join(', '),
            location: uniqueLocations.join(', '),
            accessRole: uniqueRoles[0] || '',
            accessDepartment: uniqueDepartments[0] || '',
            accessLocation: uniqueLocations[0] || '',
            user_type: mappings.find(item => item.user_type)?.user_type || '',
            active: mapStatus(user.active),
            status: mapStatus(user.active),
          }
        })

        const userById = new Map(users.map(item => [item.id, item]))
        const accessMappings = (mappingsResult.data || []).map(mapping => ({
          ...mapping,
          employee_name: userById.get(mapping.user_id)?.employee_name || 'Unknown user',
          mobile_no: userById.get(mapping.user_id)?.mobile_no || '',
          status: mapStatus(mapping.active),
        }))

        setData({
          users,
          accessMappings,
          departments: (departmentsResult.data || []).map(row => ({ id: row.id, name: row.name, status: mapStatus(row.status) })),
          locations: (locationsResult.data || []).map(row => ({ id: row.id, code: row.code, name: row.name, type: row.type, visibility: mapStatus(row.visibility) })),
          checklists: (checklistResult.data || []).map(row => ({ id: row.id, version: row.version, checklist_code: row.checklist_code, chapter: row.chapter, question: row.question, evidence_required: mapStatus(row.evidence_required), status: mapStatus(row.status) })),
          findings: [],
        })
        setLookupOptions({
          users,
          roles: [...new Set([...(rolesResult.data || []).map(row => row.name), ...accessMappings.map(row => row.role)].filter(Boolean))].sort(),
          departments: [...new Set((departmentsResult.data || []).map(row => row.name).filter(Boolean))].sort(),
          locations: [...new Set((locationsResult.data || []).flatMap(row => [row.code, row.name]).filter(Boolean))].sort(),
        })
      } catch (error) {
        if (!cancelled) {
          setData({ users: [], accessMappings: [], departments: [], locations: [], checklists: [], findings: [] })
          console.error('Master data load failed', error)
        }
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    load()
    return () => { cancelled = true }
  }, [])

  const config = masterConfig[selected]
  const rows = data[selected] || []
  const filteredRows = useMemo(() => {
    const query = search.trim().toLowerCase()
    return query ? rows.filter(row => Object.values(row).some(value => String(value).toLowerCase().includes(query))) : rows
  }, [rows, search])

  function selectMaster(key) {
    setSelected(key)
    setSearch('')
    setMobileDetailOpen(true)
  }

  function openEditor(row = null) {
    if (!canAdminister) return
    const empty = Object.fromEntries(config.fields.map(([key]) => [key, '']))
    setEditor({ row, mode: row ? 'edit' : 'create', value: row ? { ...empty, ...row } : { ...empty, status: 'Active' } })
  }

  function closeEditor() {
    if (saving) return
    setEditor(null)
  }

  async function saveEditor(form) {
    if (!canAdminister || saving || !selected) return
    setSaving(true)
    try {
      const client = requireSupabase()
      if (selected === 'users') {
        const { data: rpcData, error: rpcError } = await client.rpc('admin_create_or_update_user', {
          p_admin_user_id: user?.id,
          p_admin_session_token: sessionToken,
          p_target_user_id: form.user_id || form.id || null,
          p_employee_name: form.employee_name || '',
          p_mobile_no: String(form.mobile_no || '').replace(/\D/g, '').slice(-10),
          p_active: mapStatus(form.status) === 'Active' || String(form.status || '').toLowerCase() === 'active',
          p_role: form.role || '',
          p_department: form.department || '',
          p_location: form.location || '',
          p_user_type: form.user_type || '',
        })
        if (rpcError) throw rpcError
        if (!rpcData?.success) throw new Error(rpcData?.error || 'Unable to save user.')
      } else if (selected === 'accessMappings') {
        const { data: rpcData, error: rpcError } = await client.rpc('admin_upsert_access_mapping', {
          p_admin_user_id: user?.id,
          p_admin_session_token: sessionToken,
          p_mapping_id: form.id || null,
          p_target_user_id: form.user_id || null,
          p_role: form.role || '',
          p_department: form.department || '',
          p_location: form.location || '',
          p_user_type: form.user_type || '',
          p_active: mapStatus(form.status) === 'Active',
        })
        if (rpcError) throw rpcError
        if (!rpcData?.success) throw new Error(rpcData?.error || 'Unable to save access mapping.')
      } else if (selected === 'departments') {
        const result = await client.from('departments').upsert({
          id: form.id || undefined,
          name: form.name || '',
          status: mapStatus(form.status) === 'Active' ? 'active' : 'inactive',
        }, { onConflict: 'name' })
        if (result.error) throw result.error
      } else if (selected === 'locations') {
        const result = await client.from('locations').upsert({
          id: form.id || undefined,
          code: form.code || '',
          name: form.name || '',
          type: form.type || '3S',
          visibility: mapStatus(form.visibility) === 'Active' ? 'active' : 'inactive',
        }, { onConflict: 'code,name' })
        if (result.error) throw result.error
      } else if (selected === 'checklists') {
        const result = await client.from('audit_checklist_master').upsert({
          id: form.id || undefined,
          version: form.version || 'v1',
          checklist_code: form.checklist_code || '',
          chapter: form.chapter || '',
          question: form.question || '',
          evidence_required: String(form.evidence_required || '').toLowerCase() === 'yes' || String(form.evidence_required || '').toLowerCase() === 'active',
          status: mapStatus(form.status) === 'Active' ? 'active' : 'inactive',
        }, { onConflict: 'checklist_code,version' })
        if (result.error) throw result.error
      } else if (selected === 'findings') {
        setData(current => ({
          ...current,
          findings: editor?.row
            ? current.findings.map(item => item.id === editor.row.id ? { ...item, ...form } : item)
            : [{ id: `finding-${Date.now()}`, ...form }, ...current.findings],
        }))
      }
      const refresh = await Promise.resolve()
      if (refresh) {
        setEditor(null)
        window.location.reload()
      }
    } catch (error) {
      console.error('Master save failed', error)
      setSaving(false)
      return
    }
    setSaving(false)
  }

  async function deleteRow(row) {
    if (!canAdminister || !row?.id || saving) return
    setSaving(true)
    try {
      const client = requireSupabase()
      if (selected === 'users') {
        const { data: rpcData, error: rpcError } = await client.rpc('admin_delete_user', {
          p_admin_user_id: user?.id,
          p_admin_session_token: sessionToken,
          p_target_user_id: row.id,
        })
        if (rpcError) throw rpcError
        if (!rpcData?.success) throw new Error(rpcData?.error || 'Unable to remove user.')
      } else if (selected === 'accessMappings') {
        const { data: rpcData, error: rpcError } = await client.rpc('admin_delete_access_mapping', {
          p_admin_user_id: user?.id,
          p_admin_session_token: sessionToken,
          p_mapping_id: row.id,
        })
        if (rpcError) throw rpcError
        if (!rpcData?.success) throw new Error(rpcData?.error || 'Unable to remove access mapping.')
      } else if (selected === 'departments') {
        const result = await client.from('departments').delete().eq('id', row.id)
        if (result.error) throw result.error
      } else if (selected === 'locations') {
        const result = await client.from('locations').delete().eq('id', row.id)
        if (result.error) throw result.error
      } else if (selected === 'checklists') {
        const result = await client.from('audit_checklist_master').delete().eq('id', row.id)
        if (result.error) throw result.error
      } else if (selected === 'findings') {
        setData(current => ({ ...current, findings: current.findings.filter(item => item.id !== row.id) }))
        setSaving(false)
        return
      }
      window.location.reload()
    } catch (error) {
      console.error('Master delete failed', error)
    }
    setSaving(false)
  }

  return <>
    <PageHeader eyebrow="ADMINISTRATION" title="Master Data" description="Manage users, departments, locations and audit standards." />
    <div className={`master-layout ${mobileDetailOpen ? 'mobile-detail-open' : ''}`}>
      <aside className="card master-nav">
        {Object.entries(masterConfig).map(([key, item]) => {
          const Icon = item.icon
          return <button className={selected === key ? 'active' : ''} key={key} onClick={() => selectMaster(key)}><Icon /><span className="master-nav-label">{item.label}</span><b>{data[key].length}</b></button>
        })}
      </aside>

      <section className="master-workspace">
        <button className="master-mobile-back" onClick={() => setMobileDetailOpen(false)}><ArrowLeft size={18} /> Back to master list</button>
        <div className="master-head">
          <div><h2>{config.title}</h2><p>{config.description}</p></div>
          <div className="master-head-actions">
            <button className="secondary-button" disabled={!canAdminister} onClick={() => canAdminister && navigate('/masters/import')}><Upload size={17} /> Import</button>
            <button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor()}><Plus size={17} /> Add New</button>
          </div>
        </div>
        <div className="master-toolbar"><div className="search-bar"><Search size={18} /><input value={search} onChange={event => setSearch(event.target.value)} placeholder={`Search ${config.label.toLowerCase()}`} /></div><span>{filteredRows.length} records</span></div>

        {loading ? <div className="card master-empty"><Search size={30} /><strong>Loading master data...</strong><p>Please wait while backend records are loaded.</p></div> : filteredRows.length ? <div className="card master-data-table"><div className="master-table-scroll"><div className="master-table-grid" style={{ '--cols': config.fields.length, '--table-width': `${Math.max(760, config.fields.length * 150 + 120)}px` }}><div className="master-table-head">{config.fields.map(([, label]) => <span key={label}>{label}</span>)}<span>Actions</span></div>{filteredRows.map(row => <div className="master-table-row" key={row.id}>{config.fields.map(([key, , type]) => <div data-label={config.fields.find(field => field[0] === key)[1]} key={key}>{type === 'status' ? <StatusBadge>{row[key] || '-'}</StatusBadge> : <span>{row[key] || '-'}</span>}</div>)}<div className="row-actions" data-label="Actions"><button disabled={!canAdminister} aria-label="Edit record" onClick={() => canAdminister && openEditor(row)}><Edit3 size={16} /> <span>Edit</span></button><button disabled={!canAdminister} className="delete-action" aria-label="Delete record" onClick={() => canAdminister && deleteRow(row)}><Trash2 size={16} /> <span>Delete</span></button></div></div>)}</div></div></div> : <EmptyState label={config.title} message={selected === 'checklists' ? 'No checklist records found. Please import checklist master.' : 'No records found. Please import master data.'} onAddNew={() => ['users', 'accessMappings'].includes(selected) ? openEditor() : navigate('/masters/import')} />}
      </section>
    </div>
    {editor && (selected === 'users' || selected === 'accessMappings'
      ? <StructuredUserModal mode={editor.mode} kind={selected} value={editor.value} options={lookupOptions} onCancel={closeEditor} onSave={saveEditor} />
      : <MasterEditModal title={`${editor.mode === 'create' ? 'Create' : 'Edit'} ${config.title}`} fields={config.fields.map(([key, label, type]) => ({ key, label, type }))} value={editor.value} onCancel={closeEditor} onSave={saveEditor} />)}
  </>
}
