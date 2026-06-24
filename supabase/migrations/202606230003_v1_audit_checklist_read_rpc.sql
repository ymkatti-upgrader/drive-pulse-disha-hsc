-- TEMPORARY DEV ONLY: V1 audit checklist read RPC.
-- Purpose: local V1 login does not create a Supabase auth session, so normal RLS
-- select policies cannot identify the user yet.
--
-- This reads audit_checklist_master only. It does not open public table
-- insert/update policies and must be removed after Supabase Auth is implemented.

create or replace function public.v1_get_audit_checklist_master()
returns setof public.audit_checklist_master
language sql
security definer
set search_path = public
as $$
  select *
  from audit_checklist_master
  where status = 'active'
  order by checklist_code, version, created_at;
$$;

revoke all on function public.v1_get_audit_checklist_master() from public;
grant execute on function public.v1_get_audit_checklist_master() to anon, authenticated;

comment on function public.v1_get_audit_checklist_master()
  is 'TEMPORARY DEV ONLY: V1-only audit_checklist_master read RPC for local-login checklist screens. Remove after Supabase Auth is implemented.';
