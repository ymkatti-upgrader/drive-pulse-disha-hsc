-- V1 Admin Master Import RLS fix.
-- Allows only System Administrator (DB role: Admin) and Group DISHA HSC PIC
-- (DB role: DISHA HSC PIC) to insert/update audit checklist master rows.

drop policy if exists "disha and branch pics manage checklist" on audit_checklist_master;
drop policy if exists "admin and group disha hsc import checklist" on audit_checklist_master;
drop policy if exists "admin and group disha hsc update checklist" on audit_checklist_master;

create policy "admin and group disha hsc import checklist" on audit_checklist_master
  for insert
  with check (has_role(array['Admin', 'DISHA HSC PIC']));

create policy "admin and group disha hsc update checklist" on audit_checklist_master
  for update
  using (has_role(array['Admin', 'DISHA HSC PIC']))
  with check (has_role(array['Admin', 'DISHA HSC PIC']));
