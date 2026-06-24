alter table locations enable row level security;
alter table departments enable row level security;
alter table roles enable row level security;
alter table audit_checklist_master enable row level security;

drop policy if exists "public read locations" on locations;
drop policy if exists "public read departments" on departments;
drop policy if exists "public read roles" on roles;
drop policy if exists "public read checklist" on audit_checklist_master;

create policy "public read locations" on locations
  for select
  using (true);

create policy "public read departments" on departments
  for select
  using (true);

create policy "public read roles" on roles
  for select
  using (true);

create policy "public read checklist" on audit_checklist_master
  for select
  using (true);
