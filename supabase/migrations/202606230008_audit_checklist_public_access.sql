alter table audit_checklist_master enable row level security;

drop policy if exists "active users can read active checklist" on audit_checklist_master;
drop policy if exists "disha and branch pics manage checklist" on audit_checklist_master;
drop policy if exists "admin and group disha hsc import checklist" on audit_checklist_master;
drop policy if exists "admin and group disha hsc update checklist" on audit_checklist_master;
drop policy if exists "public read checklist" on audit_checklist_master;
drop policy if exists "public insert checklist" on audit_checklist_master;
drop policy if exists "public update checklist" on audit_checklist_master;

create policy "public read checklist" on audit_checklist_master
  for select
  using (true);

create policy "public insert checklist" on audit_checklist_master
  for insert
  with check (true);

create policy "public update checklist" on audit_checklist_master
  for update
  using (true)
  with check (true);
