alter table app_users enable row level security;
alter table user_access_mappings enable row level security;
alter table locations enable row level security;
alter table departments enable row level security;
alter table roles enable row level security;
alter table audit_checklist_master enable row level security;
alter table approval_matrix enable row level security;
alter table escalation_matrix enable row level security;
alter table ai_governance enable row level security;
alter table evidence_governance enable row level security;
alter table notification_rules enable row level security;
alter table system_settings enable row level security;

drop policy if exists "public delete app users" on app_users;
create policy "public delete app users" on app_users
  for delete
  using (true);

drop policy if exists "public delete user access mappings" on user_access_mappings;
create policy "public delete user access mappings" on user_access_mappings
  for delete
  using (true);

drop policy if exists "public delete locations" on locations;
create policy "public delete locations" on locations
  for delete
  using (true);

drop policy if exists "public delete departments" on departments;
create policy "public delete departments" on departments
  for delete
  using (true);

drop policy if exists "public delete roles" on roles;
create policy "public delete roles" on roles
  for delete
  using (true);

drop policy if exists "public delete checklist" on audit_checklist_master;
create policy "public delete checklist" on audit_checklist_master
  for delete
  using (true);

drop policy if exists "public delete approval matrix" on approval_matrix;
create policy "public delete approval matrix" on approval_matrix
  for delete
  using (true);

drop policy if exists "public delete escalation matrix" on escalation_matrix;
create policy "public delete escalation matrix" on escalation_matrix
  for delete
  using (true);

drop policy if exists "public delete ai governance" on ai_governance;
create policy "public delete ai governance" on ai_governance
  for delete
  using (true);

drop policy if exists "public delete evidence governance" on evidence_governance;
create policy "public delete evidence governance" on evidence_governance
  for delete
  using (true);

drop policy if exists "public delete notification rules" on notification_rules;
create policy "public delete notification rules" on notification_rules
  for delete
  using (true);

drop policy if exists "public delete system settings" on system_settings;
create policy "public delete system settings" on system_settings
  for delete
  using (true);
