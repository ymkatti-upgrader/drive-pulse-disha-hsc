import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft, Building2, ClipboardList, Edit3, MapPin, Plus, Search, Tags, Trash2, Upload, Users } from 'lucide-react'
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
      ['role', 'Role'],
      ['department', 'Department'],
      ['location', 'Location'],
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

export default function MasterData() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const [selected, setSelected] = useState('users')
  const [editor, setEditor] = useState(null)
  const [saving, setSaving] = useState(false)
  const [data, setData] = useState({
    users: [],
    departments: [],
    locations: [],
    checklists: [],
    findings: [],
  })
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const canAdminister = isSuperAdmin(user)

  useEffect(() => {
    let cancelled = false

    async function load() {
      try {
        const client = requireSupabase()
        const [departmentsResult, locationsResult, checklistResult, usersResult, mappingsResult] = await Promise.all([
          client.from('departments').select('id, name, status'),
          client.from('locations').select('id, code, name, type, visibility'),
          client.from('audit_checklist_master').select('id, checklist_code, chapter, question, evidence_required, status'),
          client.from('app_users').select('id, employee_name, mobile_no, active'),
          client.from('user_access_mappings').select('user_id, role, department, location, user_type, active').eq('active', true),
        ])

        if (cancelled) return

        const mappingsByUser = new Map()
        for (const mapping of mappingsResult.data || []) {
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
            active: mapStatus(user.active),
          }
        })

        setData({
          users,
          departments: (departmentsResult.data || []).map(row => ({ id: row.id, name: row.name, status: mapStatus(row.status) })),
          locations: (locationsResult.data || []).map(row => ({ id: row.id, code: row.code, name: row.name, type: row.type, visibility: mapStatus(row.visibility) })),
          checklists: (checklistResult.data || []).map(row => ({ id: row.id, version: row.version, checklist_code: row.checklist_code, chapter: row.chapter, question: row.question, evidence_required: mapStatus(row.evidence_required), status: mapStatus(row.status) })),
          findings: [],
        })
      } catch (error) {
        if (!cancelled) {
          setData({ users: [], departments: [], locations: [], checklists: [], findings: [] })
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
  }

  function openEditor(row = null) {
    if (!canAdminister) return
    const empty = Object.fromEntries(config.fields.map(([key]) => [key, '']))
    setEditor({ row, value: row ? { ...empty, ...row } : empty })
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
        const payload = {
          id: form.user_id || form.id || undefined,
          employee_name: form.employee_name || '',
          mobile_no: String(form.mobile_no || '').replace(/\D/g, '').slice(-10),
          active: mapStatus(form.status) === 'Active' || String(form.status || '').toLowerCase() === 'active',
        }
        const userResult = await client.from('app_users').upsert(payload, { onConflict: 'mobile_no' }).select('id')
        if (userResult.error) throw userResult.error
        const userId = userResult.data?.[0]?.id || payload.id
        const mappingPayload = {
          user_id: userId,
          role: form.role || '',
          department: form.department || '',
          location: form.location || '',
          user_type: form.user_type || '',
          active: true,
        }
        const mappingResult = await client.from('user_access_mappings').upsert(mappingPayload, { onConflict: 'user_id,role,department,location,user_type' })
        if (mappingResult.error) throw mappingResult.error
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
        const result = await client.from('app_users').delete().eq('id', row.id)
        if (result.error) throw result.error
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
    <div className="master-layout">
      <aside className="card master-nav">
        {Object.entries(masterConfig).map(([key, item]) => {
          const Icon = item.icon
          return <button className={selected === key ? 'active' : ''} key={key} onClick={() => selectMaster(key)}><Icon /><span className="master-nav-label">{item.label}</span><b>{data[key].length}</b></button>
        })}
      </aside>

      <section className="master-workspace">
        <button className="master-mobile-back" onClick={() => navigate('/dashboard')}><ArrowLeft size={18} /> Back to Dashboard</button>
        <div className="master-head">
          <div><h2>{config.title}</h2><p>{config.description}</p></div>
          <div className="master-head-actions">
            <button className="secondary-button" disabled={!canAdminister} onClick={() => canAdminister && navigate('/masters/import')}><Upload size={17} /> Import</button>
            <button className="primary-button" disabled={!canAdminister} onClick={() => canAdminister && openEditor()}><Plus size={17} /> Add New</button>
          </div>
        </div>
        <div className="master-toolbar"><div className="search-bar"><Search size={18} /><input value={search} onChange={event => setSearch(event.target.value)} placeholder={`Search ${config.label.toLowerCase()}`} /></div><span>{filteredRows.length} records</span></div>

        {loading ? <div className="card master-empty"><Search size={30} /><strong>Loading master data...</strong><p>Please wait while backend records are loaded.</p></div> : filteredRows.length ? <div className="card master-data-table"><div className="master-table-scroll"><div className="master-table-grid" style={{ '--cols': config.fields.length, '--table-width': `${Math.max(760, config.fields.length * 150 + 120)}px` }}><div className="master-table-head">{config.fields.map(([, label]) => <span key={label}>{label}</span>)}<span>Actions</span></div>{filteredRows.map(row => <div className="master-table-row" key={row.id}>{config.fields.map(([key, , type]) => <div data-label={config.fields.find(field => field[0] === key)[1]} key={key}>{type === 'status' ? <StatusBadge>{row[key] || '-'}</StatusBadge> : <span>{row[key] || '-'}</span>}</div>)}<div className="row-actions" data-label="Actions"><button disabled={!canAdminister} aria-label="Edit record" onClick={() => canAdminister && openEditor(row)}><Edit3 size={16} /> <span>Edit</span></button><button disabled={!canAdminister} className="delete-action" aria-label="Delete record" onClick={() => canAdminister && deleteRow(row)}><Trash2 size={16} /> <span>Delete</span></button></div></div>)}</div></div></div> : <EmptyState label={config.title} message={selected === 'checklists' ? 'No checklist records found. Please import checklist master.' : 'No records found. Please import master data.'} onAddNew={() => navigate('/masters/import')} />}
      </section>
    </div>
    {editor && <MasterEditModal title={`Edit ${config.title}`} fields={config.fields} value={editor.value} onCancel={closeEditor} onSave={saveEditor} />}
  </>
}
