-- Admin-only audit delete RPC for unsent audits.
-- Deletes the audit row and cascades to temporary child records only when the audit
-- is still in a pre-submission state. Closed findings and closed CAPA are preserved by check.

create or replace function delete_audit_admin(p_audit_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status text;
begin
  if not (
    has_role(array['Super Admin'])
    or exists (
      select 1
      from user_access_mappings m
      where m.user_id = auth.uid()
        and m.active = true
        and (
          lower(coalesce(m.role, '')) = 'super admin'
          or lower(coalesce(m.user_type, '')) = 'system admin'
        )
    )
  ) then
    raise exception 'Only Super Admin or System Admin can delete audits.';
  end if;

  select lower(coalesce(status::text, ''))
    into v_status
  from audits
  where id = p_audit_id
  for update;

  if not found then
    raise exception 'Audit not found.';
  end if;

  if v_status in ('submitted', 'completed', 'approved', 'closed') then
    raise exception 'Submitted, completed, approved or closed audits cannot be deleted.';
  end if;

  if exists (
    select 1
    from audit_findings f
    where f.audit_id = p_audit_id
      and lower(coalesce(f.status::text, '')) = 'closed'
  ) then
    raise exception 'Closed findings cannot be deleted.';
  end if;

  if exists (
    select 1
    from audit_findings f
    join improvement_actions ia on ia.finding_id = f.id
    where f.audit_id = p_audit_id
      and lower(coalesce(ia.status::text, '')) = 'closed'
  ) then
    raise exception 'Closed CAPA cannot be deleted.';
  end if;

  delete from audits where id = p_audit_id;
end;
$$;

grant execute on function delete_audit_admin(uuid) to authenticated;
