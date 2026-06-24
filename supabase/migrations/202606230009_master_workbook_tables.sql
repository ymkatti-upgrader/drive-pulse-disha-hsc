alter type location_type add value if not exists '1S';
alter type location_type add value if not exists '2S';
alter type location_type add value if not exists 'T-SPARSH';

alter table roles add column if not exists mapped_to text;
alter table roles add column if not exists description text;

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'roles_known_names'
      and conrelid = 'roles'::regclass
  ) then
    alter table roles drop constraint roles_known_names;
  end if;
end $$;

alter table roles
  add constraint roles_known_names check (name in (
    'CEO', 'VP', 'DISHA HSC PIC', 'Branch DISHA PIC', 'Location Functional HOD',
    'Group Functional HOD', 'Auditor', 'PIC', 'Viewer', 'Admin',
    'System Administrator', 'Super Admin'
  )) not valid;

create table if not exists approval_matrix (
  id uuid primary key default gen_random_uuid(),
  approval_type text not null unique,
  approver text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists escalation_matrix (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  days numeric not null default 0,
  escalate_to text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_type, days, escalate_to)
);

create table if not exists ai_governance (
  id uuid primary key default gen_random_uuid(),
  feature text not null unique,
  enabled text,
  approver text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists evidence_governance (
  id uuid primary key default gen_random_uuid(),
  evidence_type text not null unique,
  upload_allowed text,
  edit_allowed text,
  delete_allowed text,
  retention_period text,
  owner_role text,
  mandatory text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists notification_rules (
  id uuid primary key default gen_random_uuid(),
  event text not null,
  recipient_role text not null,
  priority text,
  enabled text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event, recipient_role, priority)
);

create table if not exists system_settings (
  id uuid primary key default gen_random_uuid(),
  setting_name text not null unique,
  value text,
  description text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table locations enable row level security;
alter table departments enable row level security;
alter table roles enable row level security;
alter table role_permissions enable row level security;
alter table audit_checklist_master enable row level security;
alter table approval_matrix enable row level security;
alter table escalation_matrix enable row level security;
alter table ai_governance enable row level security;
alter table evidence_governance enable row level security;
alter table notification_rules enable row level security;
alter table system_settings enable row level security;

drop policy if exists "public read locations" on locations;
drop policy if exists "public insert locations" on locations;
drop policy if exists "public update locations" on locations;
create policy "public read locations" on locations for select using (true);
create policy "public insert locations" on locations for insert with check (true);
create policy "public update locations" on locations for update using (true) with check (true);

drop policy if exists "public read departments" on departments;
drop policy if exists "public insert departments" on departments;
drop policy if exists "public update departments" on departments;
create policy "public read departments" on departments for select using (true);
create policy "public insert departments" on departments for insert with check (true);
create policy "public update departments" on departments for update using (true) with check (true);

drop policy if exists "public read roles" on roles;
drop policy if exists "public insert roles" on roles;
drop policy if exists "public update roles" on roles;
create policy "public read roles" on roles for select using (true);
create policy "public insert roles" on roles for insert with check (true);
create policy "public update roles" on roles for update using (true) with check (true);

drop policy if exists "public read role permissions" on role_permissions;
drop policy if exists "public insert role permissions" on role_permissions;
drop policy if exists "public update role permissions" on role_permissions;
create policy "public read role permissions" on role_permissions for select using (true);
create policy "public insert role permissions" on role_permissions for insert with check (true);
create policy "public update role permissions" on role_permissions for update using (true) with check (true);

drop policy if exists "public read checklist" on audit_checklist_master;
drop policy if exists "public insert checklist" on audit_checklist_master;
drop policy if exists "public update checklist" on audit_checklist_master;
create policy "public read checklist" on audit_checklist_master for select using (true);
create policy "public insert checklist" on audit_checklist_master for insert with check (true);
create policy "public update checklist" on audit_checklist_master for update using (true) with check (true);

drop policy if exists "public read approval matrix" on approval_matrix;
drop policy if exists "public insert approval matrix" on approval_matrix;
drop policy if exists "public update approval matrix" on approval_matrix;
create policy "public read approval matrix" on approval_matrix for select using (true);
create policy "public insert approval matrix" on approval_matrix for insert with check (true);
create policy "public update approval matrix" on approval_matrix for update using (true) with check (true);

drop policy if exists "public read escalation matrix" on escalation_matrix;
drop policy if exists "public insert escalation matrix" on escalation_matrix;
drop policy if exists "public update escalation matrix" on escalation_matrix;
create policy "public read escalation matrix" on escalation_matrix for select using (true);
create policy "public insert escalation matrix" on escalation_matrix for insert with check (true);
create policy "public update escalation matrix" on escalation_matrix for update using (true) with check (true);

drop policy if exists "public read ai governance" on ai_governance;
drop policy if exists "public insert ai governance" on ai_governance;
drop policy if exists "public update ai governance" on ai_governance;
create policy "public read ai governance" on ai_governance for select using (true);
create policy "public insert ai governance" on ai_governance for insert with check (true);
create policy "public update ai governance" on ai_governance for update using (true) with check (true);

drop policy if exists "public read evidence governance" on evidence_governance;
drop policy if exists "public insert evidence governance" on evidence_governance;
drop policy if exists "public update evidence governance" on evidence_governance;
create policy "public read evidence governance" on evidence_governance for select using (true);
create policy "public insert evidence governance" on evidence_governance for insert with check (true);
create policy "public update evidence governance" on evidence_governance for update using (true) with check (true);

drop policy if exists "public read notification rules" on notification_rules;
drop policy if exists "public insert notification rules" on notification_rules;
drop policy if exists "public update notification rules" on notification_rules;
create policy "public read notification rules" on notification_rules for select using (true);
create policy "public insert notification rules" on notification_rules for insert with check (true);
create policy "public update notification rules" on notification_rules for update using (true) with check (true);

drop policy if exists "public read system settings" on system_settings;
drop policy if exists "public insert system settings" on system_settings;
drop policy if exists "public update system settings" on system_settings;
create policy "public read system settings" on system_settings for select using (true);
create policy "public insert system settings" on system_settings for insert with check (true);
create policy "public update system settings" on system_settings for update using (true) with check (true);

grant select, insert, update on locations to anon, authenticated;
grant select, insert, update on departments to anon, authenticated;
grant select, insert, update on roles to anon, authenticated;
grant select, insert, update on role_permissions to anon, authenticated;
grant select, insert, update on audit_checklist_master to anon, authenticated;
grant select, insert, update on approval_matrix to anon, authenticated;
grant select, insert, update on escalation_matrix to anon, authenticated;
grant select, insert, update on ai_governance to anon, authenticated;
grant select, insert, update on evidence_governance to anon, authenticated;
grant select, insert, update on notification_rules to anon, authenticated;
grant select, insert, update on system_settings to anon, authenticated;
