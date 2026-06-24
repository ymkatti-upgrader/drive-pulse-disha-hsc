-- TEMPORARY DEV ONLY: V1 audit checklist import bypass.
-- Purpose: local V1 login does not create a Supabase auth session, so normal RLS
-- policies cannot identify the admin importer yet.
--
-- This does not open public writes to audit_checklist_master. It exposes one
-- SECURITY DEFINER RPC for audit checklist import only. Remove this after
-- Supabase Auth is implemented.

create or replace function public.v1_import_audit_checklist_master(
  rows_payload jsonb
)
returns setof public.audit_checklist_master
language plpgsql
security definer
set search_path = public
as $$
begin
  if rows_payload is null or jsonb_typeof(rows_payload) <> 'array' then
    raise exception 'rows_payload must be a JSON array.'
      using errcode = '22023';
  end if;

  return query
  with input_rows as (
    select *
    from jsonb_to_recordset(rows_payload) as row_data(
      checklist_code text,
      version text,
      section text,
      area text,
      chapter text,
      classification text,
      location_aspect text,
      evaluation_question text,
      evaluation_parameter text,
      guest_experience_impact text,
      facility_type text,
      question text,
      purpose text,
      checking_method text,
      additional_info text,
      sop_reference text,
      evidence_required boolean,
      department_owner_id uuid,
      department_owner_name text,
      status text
    )
  ),
  normalized_rows as (
    select
      nullif(input_rows.checklist_code, '') as checklist_code,
      nullif(input_rows.version, '') as version,
      coalesce(nullif(input_rows.section, ''), 'DISHA HSC') as section,
      coalesce(nullif(input_rows.area, ''), 'DISHA HSC') as area,
      coalesce(nullif(input_rows.chapter, ''), 'DISHA HSC') as chapter,
      coalesce(nullif(input_rows.classification, ''), 'General') as classification,
      nullif(input_rows.location_aspect, '') as location_aspect,
      coalesce(input_rows.evaluation_question, '') as evaluation_question,
      coalesce(input_rows.evaluation_parameter, '') as evaluation_parameter,
      coalesce(nullif(input_rows.guest_experience_impact, ''), 'Direct')::guest_impact as guest_experience_impact,
      nullif(input_rows.facility_type, '')::location_type as facility_type,
      coalesce(nullif(input_rows.question, ''), 'Checklist question') as question,
      nullif(input_rows.purpose, '') as purpose,
      nullif(input_rows.checking_method, '') as checking_method,
      nullif(input_rows.additional_info, '') as additional_info,
      nullif(input_rows.sop_reference, '') as sop_reference,
      coalesce(input_rows.evidence_required, false) as evidence_required,
      coalesce(input_rows.department_owner_id, departments.id) as department_owner_id,
      coalesce(nullif(input_rows.status, ''), 'active')::record_status as status
    from input_rows
    left join departments
      on lower(departments.name) = lower(nullif(input_rows.department_owner_name, ''))
    where nullif(input_rows.checklist_code, '') is not null
      and nullif(input_rows.version, '') is not null
  )
  insert into audit_checklist_master (
    checklist_code,
    version,
    section,
    area,
    chapter,
    classification,
    location_aspect,
    evaluation_question,
    evaluation_parameter,
    guest_experience_impact,
    facility_type,
    question,
    purpose,
    checking_method,
    additional_info,
    sop_reference,
    evidence_required,
    department_owner_id,
    status
  )
  select
    normalized_rows.checklist_code,
    normalized_rows.version,
    normalized_rows.section,
    normalized_rows.area,
    normalized_rows.chapter,
    normalized_rows.classification,
    normalized_rows.location_aspect,
    normalized_rows.evaluation_question,
    normalized_rows.evaluation_parameter,
    normalized_rows.guest_experience_impact,
    normalized_rows.facility_type,
    normalized_rows.question,
    normalized_rows.purpose,
    normalized_rows.checking_method,
    normalized_rows.additional_info,
    normalized_rows.sop_reference,
    normalized_rows.evidence_required,
    normalized_rows.department_owner_id,
    normalized_rows.status
  from normalized_rows
  on conflict (checklist_code, version) do update set
    section = excluded.section,
    area = excluded.area,
    chapter = excluded.chapter,
    classification = excluded.classification,
    location_aspect = excluded.location_aspect,
    evaluation_question = excluded.evaluation_question,
    evaluation_parameter = excluded.evaluation_parameter,
    guest_experience_impact = excluded.guest_experience_impact,
    facility_type = excluded.facility_type,
    question = excluded.question,
    purpose = excluded.purpose,
    checking_method = excluded.checking_method,
    additional_info = excluded.additional_info,
    sop_reference = excluded.sop_reference,
    evidence_required = excluded.evidence_required,
    department_owner_id = excluded.department_owner_id,
    status = excluded.status
  returning audit_checklist_master.*;
end;
$$;

drop function if exists public.v1_import_audit_checklist_master(text, jsonb);

revoke all on function public.v1_import_audit_checklist_master(jsonb) from public;
grant execute on function public.v1_import_audit_checklist_master(jsonb) to anon, authenticated;

comment on function public.v1_import_audit_checklist_master(jsonb)
  is 'TEMPORARY DEV ONLY: V1-only audit_checklist_master import RPC for local-login admin flow. Remove after Supabase Auth is implemented.';
