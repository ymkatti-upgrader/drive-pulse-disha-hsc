-- Drive Pulse - DISHA HSC production database architecture
-- Supabase/PostgreSQL migration plan. Frontend code intentionally excluded.

create extension if not exists pgcrypto;

create type location_type as enum ('3S', 'Sales', 'Service', 'TES');
create type record_status as enum ('active', 'inactive', 'archived');
create type audit_status as enum ('draft', 'scheduled', 'in_progress', 'submitted', 'completed', 'cancelled');
create type audit_result as enum ('OK', 'NG', 'NA');
create type guest_impact as enum ('Direct', 'Indirect');
create type risk_level as enum ('Critical', 'Medium');
create type finding_status as enum (
  'open',
  'assigned_to_hod',
  'root_cause_pending',
  'action_plan_pending',
  'execution_pending',
  'admin_support_pending',
  'cost_approval_pending',
  'implementation_in_progress',
  'hod_submission_pending',
  'verification_pending',
  'verification_rejected',
  'ceo_closure_pending',
  'closed',
  'cancelled'
);
create type support_request_status as enum ('draft', 'admin_review', 'quotations_pending', 'ceo_approval_pending', 'approved', 'rejected', 'not_required');
create type approval_decision as enum ('pending', 'approved', 'rejected');
create type verification_decision as enum ('pending', 'accepted', 'rejected');
create type yokoten_status as enum ('not_required', 'recommended', 'ceo_pending', 'approved', 'rejected', 'shared');
create type notification_channel as enum ('in_app', 'email', 'sms', 'whatsapp');
create type notification_status as enum ('queued', 'sent', 'read', 'failed');
create type audit_action as enum ('insert', 'update', 'delete', 'status_change', 'approval', 'verification', 'notification', 'escalation', 'ai_sensei');

create table locations (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  type location_type not null,
  visibility record_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (code, name)
);

create table departments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  status record_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table roles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  scope text not null default 'Operational',
  status record_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint roles_known_names check (name in (
    'CEO', 'VP', 'DISHA HSC PIC', 'Branch DISHA PIC', 'Location Functional HOD',
    'Group Functional HOD', 'Auditor', 'PIC', 'Viewer', 'Admin'
  ))
);

create table users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  mobile_number text not null unique,
  email text unique,
  role_id uuid not null references roles(id),
  location_id uuid references locations(id),
  department_id uuid not null references departments(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_mobile_format check (mobile_number ~ '^[0-9+ -]{8,20}$')
);

create table role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references roles(id) on delete cascade,
  can_view boolean not null default false,
  can_add boolean not null default false,
  can_edit boolean not null default false,
  can_delete boolean not null default false,
  can_approve boolean not null default false,
  can_verify boolean not null default false,
  can_close boolean not null default false,
  can_export boolean not null default false,
  ai_access boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (role_id)
);

create table audit_checklist_master (
  id uuid primary key default gen_random_uuid(),
  checklist_code text not null,
  version text not null,
  section text not null,
  area text not null,
  chapter text not null,
  classification text not null,
  location_aspect text,
  evaluation_question text,
  evaluation_parameter text,
  guest_experience_impact guest_impact not null,
  risk_level risk_level generated always as (
    case
      when guest_experience_impact = 'Direct' then 'Critical'::risk_level
      else 'Medium'::risk_level
    end
  ) stored,
  facility_type location_type,
  question text not null,
  purpose text,
  checking_method text,
  additional_info text,
  sop_reference text,
  evidence_required boolean not null default false,
  department_owner_id uuid references departments(id),
  status record_status not null default 'active',
  effective_from date not null default current_date,
  effective_to date,
  created_by uuid references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (checklist_code, version)
);

create table audits (
  id uuid primary key default gen_random_uuid(),
  audit_no text not null unique,
  title text not null,
  location_id uuid not null references locations(id),
  department_id uuid not null references departments(id),
  auditor_id uuid not null references users(id),
  scheduled_date date not null,
  started_at timestamptz,
  submitted_at timestamptz,
  completed_at timestamptz,
  status audit_status not null default 'scheduled',
  score numeric(5,2),
  created_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table audit_responses (
  id uuid primary key default gen_random_uuid(),
  audit_id uuid not null references audits(id) on delete cascade,
  checklist_id uuid not null references audit_checklist_master(id),
  result audit_result not null,
  observation text,
  comments text,
  responded_by uuid not null references users(id),
  responded_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (audit_id, checklist_id),
  constraint ng_requires_observation check (result <> 'NG' or nullif(btrim(observation), '') is not null)
);

create table audit_findings (
  id uuid primary key default gen_random_uuid(),
  finding_no text not null unique,
  audit_response_id uuid not null unique references audit_responses(id) on delete cascade,
  audit_id uuid not null references audits(id) on delete cascade,
  checklist_id uuid not null references audit_checklist_master(id),
  location_id uuid not null references locations(id),
  owner_department_id uuid not null references departments(id),
  location_functional_hod_id uuid not null references users(id),
  current_condition text not null,
  gap_identified text,
  auditor_comments text,
  risk_level risk_level not null,
  status finding_status not null default 'open',
  target_date date not null,
  hod_submitted_at timestamptz,
  verified_at timestamptz,
  closed_at timestamptz,
  created_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table finding_evidence (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null references audit_findings(id) on delete cascade,
  storage_bucket text not null default 'finding-evidence',
  storage_path text not null,
  file_name text not null,
  mime_type text,
  file_size_bytes bigint,
  evidence_stage text not null default 'audit',
  uploaded_by uuid not null references users(id),
  uploaded_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  unique (storage_bucket, storage_path)
);

create table five_why_analysis (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null unique references audit_findings(id) on delete cascade,
  why_1 text not null,
  why_2 text,
  why_3 text,
  why_4 text,
  why_5 text,
  root_cause text not null,
  prepared_by uuid not null references users(id),
  prepared_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table improvement_actions (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null unique references audit_findings(id) on delete cascade,
  action_plan text not null,
  expected_result text not null,
  target_completion_date date not null,
  cost_involved boolean not null default false,
  estimated_cost numeric(12,2),
  status finding_status not null default 'action_plan_pending',
  created_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint estimated_cost_required_when_cost check (
    cost_involved = false or estimated_cost is not null
  )
);

create table countermeasures (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null references audit_findings(id) on delete cascade,
  improvement_action_id uuid not null references improvement_actions(id) on delete cascade,
  type text not null check (type in ('temporary', 'permanent')),
  description text not null,
  responsible_user_id uuid references users(id),
  due_date date not null,
  status text not null default 'planned' check (status in ('planned', 'in_progress', 'completed', 'cancelled')),
  completed_at timestamptz,
  created_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table collaborative_departments (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null references audit_findings(id) on delete cascade,
  department_id uuid not null references departments(id),
  nominated_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  unique (finding_id, department_id)
);

create table execution_pics (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null references audit_findings(id) on delete cascade,
  user_id uuid not null references users(id),
  nominated_by uuid not null references users(id),
  responsibility text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  unique (finding_id, user_id)
);

create unique index one_primary_execution_pic_per_finding
  on execution_pics (finding_id)
  where is_primary;

create table admin_support_requests (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null references audit_findings(id) on delete cascade,
  requested_by uuid not null references users(id),
  support_type text not null check (support_type in ('material', 'repair', 'vendor', 'other')),
  description text not null,
  cost_involved boolean not null default false,
  estimated_cost numeric(12,2),
  status support_request_status not null default 'admin_review',
  admin_owner_id uuid references users(id),
  requested_at timestamptz not null default now(),
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint support_estimated_cost_required check (cost_involved = false or estimated_cost is not null)
);

create table vendor_quotations (
  id uuid primary key default gen_random_uuid(),
  admin_support_request_id uuid not null references admin_support_requests(id) on delete cascade,
  vendor_name text not null,
  vendor_contact text,
  quotation_amount numeric(12,2) not null check (quotation_amount >= 0),
  currency text not null default 'INR',
  quotation_storage_path text,
  received_at date not null default current_date,
  is_selected boolean not null default false,
  selection_reason text,
  created_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index one_selected_vendor_quotation_per_request
  on vendor_quotations (admin_support_request_id)
  where is_selected;

create table cost_approvals (
  id uuid primary key default gen_random_uuid(),
  admin_support_request_id uuid not null unique references admin_support_requests(id) on delete cascade,
  finding_id uuid not null references audit_findings(id) on delete cascade,
  ceo_id uuid not null references users(id),
  decision approval_decision not null default 'pending',
  comments text,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cost_decision_comments check (decision <> 'rejected' or nullif(btrim(comments), '') is not null)
);

create table verification_records (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null references audit_findings(id) on delete cascade,
  verified_by uuid not null references users(id),
  decision verification_decision not null,
  comments text,
  evidence_review text,
  verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint verification_rejection_comments check (decision <> 'rejected' or nullif(btrim(comments), '') is not null)
);

create table ceo_closure_approvals (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null unique references audit_findings(id) on delete cascade,
  ceo_id uuid not null references users(id),
  decision approval_decision not null default 'pending',
  comments text,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint closure_rejection_comments check (decision <> 'rejected' or nullif(btrim(comments), '') is not null)
);

create table yokoten_recommendations (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid not null unique references audit_findings(id) on delete cascade,
  recommended_by uuid not null references users(id),
  recommendation_reason text not null,
  criticality_notes text,
  ceo_id uuid references users(id),
  status yokoten_status not null default 'recommended',
  ceo_comments text,
  decided_at timestamptz,
  shared_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint yokoten_rejection_comments check (status <> 'rejected' or nullif(btrim(ceo_comments), '') is not null)
);

create table notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_user_id uuid not null references users(id) on delete cascade,
  finding_id uuid references audit_findings(id) on delete cascade,
  audit_id uuid references audits(id) on delete cascade,
  notification_type text not null,
  title text not null,
  body text not null,
  channel notification_channel not null default 'in_app',
  status notification_status not null default 'queued',
  escalation_level integer not null default 0,
  due_at timestamptz,
  sent_at timestamptz,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references users(id),
  action audit_action not null,
  table_name text not null,
  record_id uuid,
  old_data jsonb,
  new_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

create table ai_sensei_history (
  id uuid primary key default gen_random_uuid(),
  finding_id uuid references audit_findings(id) on delete cascade,
  user_id uuid not null references users(id),
  use_case text not null check (use_case in ('root_cause', 'countermeasure', 'yokoten', 'executive_summary')),
  prompt text not null,
  response text not null,
  final_decision text not null default 'pending',
  ai_suggestion_useful boolean,
  usefulness_rating integer check (usefulness_rating between 1 and 5),
  final_action_changed_by_human boolean,
  created_at timestamptz not null default now()
);

create index idx_users_mobile on users (mobile_number);
create index idx_users_role_location_department on users (role_id, location_id, department_id);
create index idx_audits_location_status on audits (location_id, status);
create index idx_audit_findings_status on audit_findings (status);
create index idx_audit_findings_location_owner on audit_findings (location_id, owner_department_id);
create index idx_notifications_recipient_status on notifications (recipient_user_id, status);

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function current_user_role_name()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select r.name
  from users u
  join roles r on r.id = u.role_id
  where u.id = auth.uid()
    and u.is_active = true
  limit 1;
$$;

create or replace function has_role(role_names text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(current_user_role_name() = any(role_names), false);
$$;

create or replace function is_finding_participant(target_finding_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from audit_findings f
    left join audits a on a.id = f.audit_id
    where f.id = target_finding_id
      and (
        f.created_by = auth.uid()
        or a.auditor_id = auth.uid()
        or f.location_functional_hod_id = auth.uid()
        or exists (select 1 from execution_pics ep where ep.finding_id = f.id and ep.user_id = auth.uid())
        or exists (
          select 1
          from users u
          where u.id = auth.uid()
            and u.location_id = f.location_id
            and u.department_id = f.owner_department_id
        )
        or has_role(array['CEO', 'VP', 'DISHA HSC PIC', 'Group Functional HOD'])
      )
  );
$$;

create or replace function assert_finding_transition()
returns trigger
language plpgsql
as $$
declare
  has_root_cause boolean;
  has_action boolean;
  has_primary_pic boolean;
  last_verification verification_decision;
  closure_decision approval_decision;
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    select exists (select 1 from five_why_analysis where finding_id = new.id) into has_root_cause;
    select exists (select 1 from improvement_actions where finding_id = new.id) into has_action;
    select exists (select 1 from execution_pics where finding_id = new.id and is_primary = true) into has_primary_pic;
    select vr.decision
      into last_verification
      from verification_records vr
      where vr.finding_id = new.id
      order by vr.verified_at desc
      limit 1;

    if new.status in ('execution_pending', 'admin_support_pending', 'implementation_in_progress', 'hod_submission_pending', 'verification_pending', 'ceo_closure_pending', 'closed')
      and (not has_root_cause or not has_action or not has_primary_pic) then
      raise exception 'NG finding requires root cause, improvement action, and primary execution PIC before execution/submission.';
    end if;

    if new.status = 'ceo_closure_pending' and last_verification is distinct from 'accepted' then
      raise exception 'Group DISHA HSC PIC verification acceptance is required before CEO closure approval.';
    end if;

    if new.status = 'closed' then
      if not has_role(array['CEO']) then
        raise exception 'Only CEO closure approval can move a finding to closed.';
      end if;

      select decision
        into closure_decision
        from ceo_closure_approvals
        where finding_id = new.id
        order by decided_at desc nulls last, created_at desc
        limit 1;

      if closure_decision is distinct from 'approved' or last_verification is distinct from 'accepted' then
        raise exception 'Closed status requires latest Group DISHA HSC PIC verification accepted and CEO closure approval approved.';
      end if;
    end if;
  end if;

  return new;
end;
$$;

create or replace function assert_min_three_quotations()
returns trigger
language plpgsql
as $$
declare
  quote_count integer;
begin
  if tg_op = 'UPDATE' and new.cost_involved = true and new.status in ('ceo_approval_pending', 'approved') then
    select count(*) into quote_count
    from vendor_quotations
    where admin_support_request_id = new.id;

    if quote_count < 3 then
      raise exception 'Minimum 3 vendor quotations are required before CEO cost approval.';
    end if;
  end if;

  return new;
end;
$$;

create or replace function assert_cost_approval_integrity()
returns trigger
language plpgsql
as $$
declare
  support_finding_id uuid;
  quote_count integer;
begin
  select finding_id into support_finding_id
  from admin_support_requests
  where id = new.admin_support_request_id;

  if support_finding_id is distinct from new.finding_id then
    raise exception 'cost_approvals.finding_id must match admin_support_requests.finding_id.';
  end if;

  if tg_op in ('INSERT', 'UPDATE') and new.decision = 'approved' then
    select count(*) into quote_count
    from vendor_quotations
    where admin_support_request_id = new.admin_support_request_id;

    if quote_count < 3 then
      raise exception 'Minimum 3 vendor quotations are required before CEO cost approval.';
    end if;
  end if;

  return new;
end;
$$;

create or replace function assert_closure_approval_integrity()
returns trigger
language plpgsql
as $$
declare
  last_verification verification_decision;
begin
  select decision
    into last_verification
    from verification_records
    where finding_id = new.finding_id
    order by verified_at desc
    limit 1;

  if tg_op in ('INSERT', 'UPDATE') and new.decision = 'approved' and last_verification is distinct from 'accepted' then
    raise exception 'CEO closure approval requires latest Group DISHA HSC PIC verification accepted.';
  end if;

  return new;
end;
$$;

create or replace function assert_countermeasure_integrity()
returns trigger
language plpgsql
as $$
declare
  action_finding_id uuid;
begin
  select finding_id into action_finding_id
  from improvement_actions
  where id = new.improvement_action_id;

  if action_finding_id is distinct from new.finding_id then
    raise exception 'countermeasures.finding_id must match improvement_actions.finding_id.';
  end if;

  return new;
end;
$$;

create or replace function assert_finding_linkage()
returns trigger
language plpgsql
as $$
declare
  response_row audit_responses%rowtype;
begin
  select * into response_row
  from audit_responses
  where id = new.audit_response_id;

  if response_row.audit_id is distinct from new.audit_id
     or response_row.checklist_id is distinct from new.checklist_id then
    raise exception 'audit_findings.audit_id and checklist_id must match the linked audit_response_id.';
  end if;

  if new.location_functional_hod_id is null then
    raise exception 'location_functional_hod_id is required for NG findings.';
  end if;

  return new;
end;
$$;

create or replace function sync_finding_from_response()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  audit_row audits%rowtype;
  checklist_row audit_checklist_master%rowtype;
  generated_no text;
  hod_count integer;
  new_hod_id uuid;
begin
  if new.result = 'NG' then
    select * into audit_row from audits where id = new.audit_id;
    select * into checklist_row from audit_checklist_master where id = new.checklist_id;
    select count(*), min(u.id)
      into hod_count, new_hod_id
      from users u
      join roles r on r.id = u.role_id
      where u.is_active = true
        and r.name = 'Location Functional HOD'
        and u.location_id = audit_row.location_id
        and u.department_id = audit_row.department_id;

    if hod_count = 0 or new_hod_id is null then
      raise exception 'Cannot create NG finding without an auto-assignable Location Functional HOD.';
    elsif hod_count > 1 then
      raise exception 'Location Functional HOD assignment is ambiguous for this finding.';
    end if;

    generated_no := 'NG-' || to_char(now(), 'YYYYMMDDHH24MISS') || '-' || substr(new.id::text, 1, 6);

    insert into audit_findings (
      finding_no, audit_response_id, audit_id, checklist_id, location_id,
      owner_department_id, location_functional_hod_id, current_condition, auditor_comments, risk_level,
      target_date, created_by
    )
    values (
      generated_no, new.id, new.audit_id, new.checklist_id, audit_row.location_id,
      coalesce(checklist_row.department_owner_id, audit_row.department_id),
      new_hod_id,
      new.observation, new.comments, checklist_row.risk_level,
      current_date + case when checklist_row.risk_level = 'Critical' then 2 else 7 end,
      new.responded_by
    )
    on conflict (audit_response_id) do update
      set current_condition = excluded.current_condition,
          auditor_comments = excluded.auditor_comments,
          risk_level = excluded.risk_level,
          updated_at = now();
  elsif old.result = 'NG' and new.result <> 'NG' then
    update audit_findings
      set status = 'cancelled',
          closed_at = now(),
          updated_at = now()
      where audit_response_id = new.id
        and status not in ('closed', 'cancelled');
  end if;

  return new;
end;
$$;

create or replace function sync_checklist_text_fields()
returns trigger
language plpgsql
as $$
begin
  new.evaluation_question := coalesce(nullif(btrim(new.evaluation_question), ''), new.question);
  new.evaluation_parameter := nullif(btrim(new.evaluation_parameter), '');
  return new;
end;
$$;

create or replace function assert_five_why_text_fields()
returns trigger
language plpgsql
as $$
begin
  if nullif(btrim(new.why_1), '') is null then
    raise exception 'why_1 cannot be blank.';
  end if;

  if nullif(btrim(new.root_cause), '') is null then
    raise exception 'root_cause cannot be blank.';
  end if;

  return new;
end;
$$;

create or replace function assert_improvement_action_text_fields()
returns trigger
language plpgsql
as $$
begin
  if nullif(btrim(new.action_plan), '') is null then
    raise exception 'action_plan cannot be blank.';
  end if;

  return new;
end;
$$;

create or replace function create_status_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    insert into notifications (recipient_user_id, finding_id, notification_type, title, body)
    select u.id, new.id, 'finding_status_changed', 'Finding status changed',
           'Finding ' || new.finding_no || ' moved to ' || new.status::text
    from users u
    where u.is_active = true
      and (
        u.id = new.location_functional_hod_id
        or u.id = new.created_by
        or exists (select 1 from execution_pics ep where ep.finding_id = new.id and ep.user_id = u.id)
        or (new.status in ('cost_approval_pending', 'ceo_closure_pending') and exists (
          select 1 from roles r where r.id = u.role_id and r.name = 'CEO'
        ))
        or (new.status = 'verification_pending' and exists (
          select 1 from roles r where r.id = u.role_id and r.name = 'DISHA HSC PIC'
        ))
      );
  end if;

  return new;
end;
$$;

create or replace function write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  action_name audit_action;
begin
  action_name := lower(tg_op)::audit_action;

  insert into audit_logs (
    actor_user_id,
    action,
    table_name,
    record_id,
    old_data,
    new_data
  )
  values (
    auth.uid(),
    action_name,
    tg_table_name,
    case when tg_op = 'DELETE' then old.id else new.id end,
    case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end,
    case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end
  );

  return coalesce(new, old);
end;
$$;

create trigger trg_locations_updated_at before update on locations for each row execute function set_updated_at();
create trigger trg_departments_updated_at before update on departments for each row execute function set_updated_at();
create trigger trg_roles_updated_at before update on roles for each row execute function set_updated_at();
create trigger trg_users_updated_at before update on users for each row execute function set_updated_at();
create trigger trg_role_permissions_updated_at before update on role_permissions for each row execute function set_updated_at();
create trigger trg_checklist_updated_at before update on audit_checklist_master for each row execute function set_updated_at();
create trigger trg_audits_updated_at before update on audits for each row execute function set_updated_at();
create trigger trg_audit_responses_updated_at before update on audit_responses for each row execute function set_updated_at();
create trigger trg_findings_updated_at before update on audit_findings for each row execute function set_updated_at();
create trigger trg_improvement_actions_updated_at before update on improvement_actions for each row execute function set_updated_at();
create trigger trg_countermeasures_updated_at before update on countermeasures for each row execute function set_updated_at();
create trigger trg_admin_support_updated_at before update on admin_support_requests for each row execute function set_updated_at();
create trigger trg_vendor_quotations_updated_at before update on vendor_quotations for each row execute function set_updated_at();
create trigger trg_cost_approvals_updated_at before update on cost_approvals for each row execute function set_updated_at();
create trigger trg_closure_approvals_updated_at before update on ceo_closure_approvals for each row execute function set_updated_at();
create trigger trg_yokoten_updated_at before update on yokoten_recommendations for each row execute function set_updated_at();

create trigger trg_sync_finding_from_response
after insert or update of result, observation, comments on audit_responses
for each row execute function sync_finding_from_response();

create trigger trg_sync_checklist_text_fields before insert or update on audit_checklist_master for each row execute function sync_checklist_text_fields();

create trigger trg_assert_finding_transition
before update of status on audit_findings
for each row execute function assert_finding_transition();

create trigger trg_assert_finding_linkage before insert or update on audit_findings for each row execute function assert_finding_linkage();

create trigger trg_assert_min_three_quotations
before update of status on admin_support_requests
for each row execute function assert_min_three_quotations();

create trigger trg_assert_cost_approval_integrity before insert or update on cost_approvals for each row execute function assert_cost_approval_integrity();

create trigger trg_assert_closure_approval_integrity before insert or update on ceo_closure_approvals for each row execute function assert_closure_approval_integrity();

create trigger trg_assert_countermeasure_integrity before insert or update on countermeasures for each row execute function assert_countermeasure_integrity();

create trigger trg_assert_five_why_text_fields before insert or update on five_why_analysis for each row execute function assert_five_why_text_fields();

create trigger trg_assert_improvement_action_text_fields before insert or update on improvement_actions for each row execute function assert_improvement_action_text_fields();

create trigger trg_create_status_notification
after update of status on audit_findings
for each row execute function create_status_notification();

create trigger trg_audit_locations after insert or update or delete on locations for each row execute function write_audit_log();
create trigger trg_audit_departments after insert or update or delete on departments for each row execute function write_audit_log();
create trigger trg_audit_roles after insert or update or delete on roles for each row execute function write_audit_log();
create trigger trg_audit_users after insert or update or delete on users for each row execute function write_audit_log();
create trigger trg_audit_role_permissions after insert or update or delete on role_permissions for each row execute function write_audit_log();
create trigger trg_audit_checklist after insert or update or delete on audit_checklist_master for each row execute function write_audit_log();
create trigger trg_audit_audits after insert or update or delete on audits for each row execute function write_audit_log();
create trigger trg_audit_audit_responses after insert or update or delete on audit_responses for each row execute function write_audit_log();
create trigger trg_audit_findings after insert or update or delete on audit_findings for each row execute function write_audit_log();
create trigger trg_audit_evidence after insert or update or delete on finding_evidence for each row execute function write_audit_log();
create trigger trg_audit_five_why after insert or update or delete on five_why_analysis for each row execute function write_audit_log();
create trigger trg_audit_improvement_actions after insert or update or delete on improvement_actions for each row execute function write_audit_log();
create trigger trg_audit_countermeasures after insert or update or delete on countermeasures for each row execute function write_audit_log();
create trigger trg_audit_collaborative_departments after insert or update or delete on collaborative_departments for each row execute function write_audit_log();
create trigger trg_audit_execution_pics after insert or update or delete on execution_pics for each row execute function write_audit_log();
create trigger trg_audit_admin_support after insert or update or delete on admin_support_requests for each row execute function write_audit_log();
create trigger trg_audit_vendor_quotations after insert or update or delete on vendor_quotations for each row execute function write_audit_log();
create trigger trg_audit_cost_approvals after insert or update or delete on cost_approvals for each row execute function write_audit_log();
create trigger trg_audit_verifications after insert or update or delete on verification_records for each row execute function write_audit_log();
create trigger trg_audit_closure_approvals after insert or update or delete on ceo_closure_approvals for each row execute function write_audit_log();
create trigger trg_audit_yokoten after insert or update or delete on yokoten_recommendations for each row execute function write_audit_log();
create trigger trg_audit_ai_history after insert or update or delete on ai_sensei_history for each row execute function write_audit_log();

alter table locations enable row level security;
alter table departments enable row level security;
alter table roles enable row level security;
alter table users enable row level security;
alter table role_permissions enable row level security;
alter table audit_checklist_master enable row level security;
alter table audits enable row level security;
alter table audit_responses enable row level security;
alter table audit_findings enable row level security;
alter table finding_evidence enable row level security;
alter table five_why_analysis enable row level security;
alter table improvement_actions enable row level security;
alter table countermeasures enable row level security;
alter table collaborative_departments enable row level security;
alter table execution_pics enable row level security;
alter table admin_support_requests enable row level security;
alter table vendor_quotations enable row level security;
alter table cost_approvals enable row level security;
alter table verification_records enable row level security;
alter table ceo_closure_approvals enable row level security;
alter table yokoten_recommendations enable row level security;
alter table notifications enable row level security;
alter table audit_logs enable row level security;
alter table ai_sensei_history enable row level security;

create policy "active users can read active master locations" on locations
  for select using (auth.uid() is not null and visibility = 'active');
create policy "disha hsc manages locations" on locations
  for all using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));

create policy "active users can read departments" on departments
  for select using (auth.uid() is not null and status = 'active');
create policy "disha hsc manages departments" on departments
  for all using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));

create policy "active users can read roles and permissions" on roles
  for select using (auth.uid() is not null and status = 'active');
create policy "active users can read role permissions" on role_permissions
  for select using (auth.uid() is not null);
create policy "disha hsc manages roles" on roles
  for all using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));
create policy "disha hsc manages role permissions" on role_permissions
  for all using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));

create policy "users can read own profile or governance can read all" on users
  for select using (id = auth.uid() or has_role(array['CEO', 'VP', 'DISHA HSC PIC']));
create policy "disha hsc manages users" on users
  for all using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));

create policy "active users can read active checklist" on audit_checklist_master
  for select using (auth.uid() is not null and status = 'active');
create policy "disha and branch pics manage checklist" on audit_checklist_master
  for all using (has_role(array['DISHA HSC PIC', 'Branch DISHA PIC'])) with check (has_role(array['DISHA HSC PIC', 'Branch DISHA PIC']));

create policy "audit visibility by role and location" on audits
  for select using (
    has_role(array['CEO', 'VP', 'DISHA HSC PIC', 'Group Functional HOD'])
    or auditor_id = auth.uid()
    or exists (select 1 from users u where u.id = auth.uid() and u.location_id = audits.location_id)
  );
create policy "branch disha pic creates audits" on audits
  for insert with check (has_role(array['DISHA HSC PIC', 'Branch DISHA PIC']) and created_by = auth.uid());
create policy "auditor updates assigned audits" on audits
  for update using (auditor_id = auth.uid() or has_role(array['DISHA HSC PIC'])) with check (auditor_id = auth.uid() or has_role(array['DISHA HSC PIC']));

create policy "response visibility follows audit" on audit_responses
  for select using (exists (select 1 from audits a where a.id = audit_responses.audit_id));
create policy "assigned auditor writes responses" on audit_responses
  for insert with check (
    responded_by = auth.uid()
    and exists (select 1 from audits a where a.id = audit_responses.audit_id and a.auditor_id = auth.uid())
  );
create policy "assigned auditor updates responses before submission" on audit_responses
  for update using (
    exists (select 1 from audits a where a.id = audit_responses.audit_id and a.auditor_id = auth.uid() and a.status in ('scheduled', 'in_progress'))
  );

create policy "finding visibility by participation" on audit_findings
  for select using (is_finding_participant(id));
create policy "disha can manage findings" on audit_findings
  for all using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));
create policy "hod can update owned findings" on audit_findings
  for update using (location_functional_hod_id = auth.uid()) with check (location_functional_hod_id = auth.uid());

create policy "evidence visible to finding participants" on finding_evidence
  for select using (is_finding_participant(finding_id) and is_deleted = false);
create policy "participants upload evidence" on finding_evidence
  for insert with check (uploaded_by = auth.uid() and is_finding_participant(finding_id));
create policy "disha hsc controls evidence deletion" on finding_evidence
  for update using (has_role(array['DISHA HSC PIC'])) with check (has_role(array['DISHA HSC PIC']));

create policy "five why visible to participants" on five_why_analysis
  for select using (is_finding_participant(finding_id));
create policy "location hod owns five why" on five_why_analysis
  for all using (
    exists (select 1 from audit_findings f where f.id = five_why_analysis.finding_id and f.location_functional_hod_id = auth.uid())
  ) with check (
    prepared_by = auth.uid()
    and exists (select 1 from audit_findings f where f.id = five_why_analysis.finding_id and f.location_functional_hod_id = auth.uid())
  );

create policy "improvement action visible to participants" on improvement_actions
  for select using (is_finding_participant(finding_id));
create policy "location hod owns improvement action" on improvement_actions
  for all using (
    exists (select 1 from audit_findings f where f.id = improvement_actions.finding_id and f.location_functional_hod_id = auth.uid())
  ) with check (
    created_by = auth.uid()
    and exists (select 1 from audit_findings f where f.id = improvement_actions.finding_id and f.location_functional_hod_id = auth.uid())
  );

create policy "countermeasures visible to participants" on countermeasures
  for select using (is_finding_participant(finding_id));
create policy "hod and pics update countermeasures" on countermeasures
  for all using (
    exists (select 1 from audit_findings f where f.id = countermeasures.finding_id and f.location_functional_hod_id = auth.uid())
    or responsible_user_id = auth.uid()
  ) with check (created_by = auth.uid() or responsible_user_id = auth.uid());

create policy "collaborative departments visible to participants" on collaborative_departments
  for select using (is_finding_participant(finding_id));
create policy "hod nominates collaborative departments" on collaborative_departments
  for all using (
    exists (select 1 from audit_findings f where f.id = collaborative_departments.finding_id and f.location_functional_hod_id = auth.uid())
  ) with check (
    nominated_by = auth.uid()
    and exists (select 1 from audit_findings f where f.id = collaborative_departments.finding_id and f.location_functional_hod_id = auth.uid())
  );

create policy "execution pics visible to participants" on execution_pics
  for select using (is_finding_participant(finding_id));
create policy "hod nominates execution pics" on execution_pics
  for all using (
    exists (select 1 from audit_findings f where f.id = execution_pics.finding_id and f.location_functional_hod_id = auth.uid())
  ) with check (
    nominated_by = auth.uid()
    and exists (select 1 from audit_findings f where f.id = execution_pics.finding_id and f.location_functional_hod_id = auth.uid())
  );

create policy "admin support visible to participants" on admin_support_requests
  for select using (is_finding_participant(finding_id) or has_role(array['Admin']));
create policy "hod requests admin support" on admin_support_requests
  for insert with check (
    requested_by = auth.uid()
    and exists (select 1 from audit_findings f where f.id = admin_support_requests.finding_id and f.location_functional_hod_id = auth.uid())
  );
create policy "admin updates support requests" on admin_support_requests
  for update using (has_role(array['Admin', 'DISHA HSC PIC'])) with check (has_role(array['Admin', 'DISHA HSC PIC']));

create policy "quotations visible to support participants" on vendor_quotations
  for select using (
    exists (select 1 from admin_support_requests r where r.id = vendor_quotations.admin_support_request_id and is_finding_participant(r.finding_id))
    or has_role(array['Admin', 'CEO'])
  );
create policy "admin manages quotations" on vendor_quotations
  for all using (has_role(array['Admin', 'DISHA HSC PIC'])) with check (created_by = auth.uid() and has_role(array['Admin', 'DISHA HSC PIC']));

create policy "ceo and participants read cost approvals" on cost_approvals
  for select using (has_role(array['CEO']) or is_finding_participant(finding_id));
create policy "ceo decides cost approvals" on cost_approvals
  for update using (has_role(array['CEO']) and ceo_id = auth.uid()) with check (has_role(array['CEO']) and ceo_id = auth.uid());
create policy "admin creates cost approvals for ceo" on cost_approvals
  for insert with check (has_role(array['Admin', 'DISHA HSC PIC']));

create policy "verification visible to participants" on verification_records
  for select using (is_finding_participant(finding_id));
create policy "group disha verifies solutions" on verification_records
  for insert with check (verified_by = auth.uid() and has_role(array['DISHA HSC PIC']));

create policy "closure approvals visible to participants" on ceo_closure_approvals
  for select using (has_role(array['CEO']) or is_finding_participant(finding_id));
create policy "ceo decides closure approvals" on ceo_closure_approvals
  for update using (has_role(array['CEO']) and ceo_id = auth.uid()) with check (has_role(array['CEO']) and ceo_id = auth.uid());
create policy "disha sends closure to ceo" on ceo_closure_approvals
  for insert with check (has_role(array['DISHA HSC PIC']));

create policy "yokoten visible to governance and participants" on yokoten_recommendations
  for select using (has_role(array['CEO', 'VP', 'DISHA HSC PIC']) or is_finding_participant(finding_id));
create policy "disha recommends yokoten" on yokoten_recommendations
  for insert with check (recommended_by = auth.uid() and has_role(array['DISHA HSC PIC']));
create policy "ceo approves yokoten" on yokoten_recommendations
  for update using (has_role(array['CEO']) or has_role(array['DISHA HSC PIC'])) with check (has_role(array['CEO']) or has_role(array['DISHA HSC PIC']));

create policy "users read own notifications" on notifications
  for select using (recipient_user_id = auth.uid());
create policy "users mark own notifications read" on notifications
  for update using (recipient_user_id = auth.uid()) with check (recipient_user_id = auth.uid());
create policy "system governance creates notifications" on notifications
  for insert with check (has_role(array['DISHA HSC PIC', 'Admin', 'CEO']));

create policy "governance reads audit logs" on audit_logs
  for select using (has_role(array['CEO', 'VP', 'DISHA HSC PIC']));

create policy "ai history visible by finding participant" on ai_sensei_history
  for select using (user_id = auth.uid() or is_finding_participant(finding_id));
create policy "permitted roles create ai history" on ai_sensei_history
  for insert with check (
    user_id = auth.uid()
    and exists (
      select 1
      from users u
      join role_permissions rp on rp.role_id = u.role_id
      where u.id = auth.uid()
        and rp.ai_access = true
    )
  );
