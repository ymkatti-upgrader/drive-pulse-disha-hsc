create or replace function reset_audit_checklist_master()
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_count integer;
begin
  delete from audit_checklist_master;
  get diagnostics deleted_count = row_count;

  return json_build_object(
    'success', true,
    'deleted_count', deleted_count
  );
end;
$$;

grant execute on function reset_audit_checklist_master() to anon;
grant execute on function reset_audit_checklist_master() to authenticated;
