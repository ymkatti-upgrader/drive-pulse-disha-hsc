alter table audit_checklist_master
  add column if not exists applicable_departments jsonb not null default '[]'::jsonb;

update audit_checklist_master
set applicable_departments = coalesce(applicable_departments, '[]'::jsonb)
where applicable_departments is null;
