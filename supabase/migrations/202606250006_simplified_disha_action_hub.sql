-- Simplified Disha Action Hub workflow: planning, collaboration, extension, and review.
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS cause_category text,
  ADD COLUMN IF NOT EXISTS action_plan_items jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS collaboration_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS collaborator_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS collaborator_name text,
  ADD COLUMN IF NOT EXISTS collaborator_mobile text,
  ADD COLUMN IF NOT EXISTS support_department text,
  ADD COLUMN IF NOT EXISTS support_required text,
  ADD COLUMN IF NOT EXISTS support_remarks text,
  ADD COLUMN IF NOT EXISTS support_status text,
  ADD COLUMN IF NOT EXISTS extension_request_status text,
  ADD COLUMN IF NOT EXISTS extension_requested_date date,
  ADD COLUMN IF NOT EXISTS extension_reason text,
  ADD COLUMN IF NOT EXISTS reviewed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS reviewed_at timestamptz,
  ADD COLUMN IF NOT EXISTS review_comments text;

CREATE OR REPLACE FUNCTION submit_disha_action_update(
  p_response_id uuid,
  p_user_id uuid,
  p_status text,
  p_cause_category text,
  p_root_cause text,
  p_action_plan_items jsonb DEFAULT '[]'::jsonb,
  p_action_taken text DEFAULT NULL,
  p_closure_remarks text DEFAULT NULL,
  p_actual_closure_date date DEFAULT NULL,
  p_closure_evidence_files jsonb DEFAULT '[]'::jsonb,
  p_collaboration_required boolean DEFAULT false,
  p_collaborator_user_id uuid DEFAULT NULL,
  p_collaborator_name text DEFAULT NULL,
  p_collaborator_mobile text DEFAULT NULL,
  p_support_department text DEFAULT NULL,
  p_support_required text DEFAULT NULL,
  p_support_remarks text DEFAULT NULL,
  p_support_status text DEFAULT NULL,
  p_extension_requested_date date DEFAULT NULL,
  p_extension_reason text DEFAULT NULL
)
RETURNS audit_responses
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  response_row audit_responses%rowtype;
  next_row audit_responses%rowtype;
  normalized_status text;
  requester_mobile text;
  requester_is_admin boolean;
  requester_is_assigned boolean;
  requester_is_collaborator boolean;
BEGIN
  normalized_status := CASE
    WHEN p_status IN ('Assigned', 'Planning', 'In Progress', 'Submitted for Review', 'Reassigned') THEN p_status
    ELSE NULL
  END;

  IF normalized_status IS NULL THEN
    RAISE EXCEPTION 'Invalid Disha action status.';
  END IF;

  SELECT * INTO response_row
  FROM audit_responses
  WHERE id = p_response_id
  FOR UPDATE;

  IF response_row.id IS NULL THEN
    RAISE EXCEPTION 'Assigned NG item not found.';
  END IF;

  IF response_row.result <> 'NG' THEN
    RAISE EXCEPTION 'Only NG responses can be updated.';
  END IF;

  SELECT mobile_no INTO requester_mobile
  FROM app_users
  WHERE id = p_user_id;

  SELECT EXISTS (
    SELECT 1
    FROM user_access_mappings uam
    WHERE uam.user_id = p_user_id
      AND coalesce(uam.active, true) = true
      AND (
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system admin', 'system administrator')
        OR lower(coalesce(uam.user_type, '')) IN ('admin', 'super admin', 'system admin', 'system administrator')
      )
  ) INTO requester_is_admin;

  requester_is_assigned :=
    response_row.pic_for_ng_user_id IS NOT DISTINCT FROM p_user_id
    OR (
      nullif(coalesce(response_row.pic_for_ng_mobile, ''), '') IS NOT NULL
      AND coalesce(response_row.pic_for_ng_mobile, '') = coalesce(requester_mobile, '')
    );

  requester_is_collaborator :=
    response_row.collaborator_user_id IS NOT DISTINCT FROM p_user_id
    OR (
      nullif(coalesce(response_row.collaborator_mobile, ''), '') IS NOT NULL
      AND coalesce(response_row.collaborator_mobile, '') = coalesce(requester_mobile, '')
    );

  IF NOT requester_is_admin AND NOT requester_is_assigned AND NOT requester_is_collaborator THEN
    RAISE EXCEPTION 'You can update only NG actions assigned to you or collaboration requests assigned to you.';
  END IF;

  IF requester_is_collaborator AND NOT requester_is_admin AND NOT requester_is_assigned THEN
    UPDATE audit_responses
    SET
      support_remarks = nullif(btrim(coalesce(p_support_remarks, '')), ''),
      support_status = nullif(btrim(coalesce(p_support_status, '')), ''),
      updated_at = now()
    WHERE id = p_response_id
    RETURNING * INTO next_row;

    RETURN next_row;
  END IF;

  IF normalized_status = 'Submitted for Review' THEN
    IF nullif(btrim(coalesce(p_cause_category, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Cause Category missing.';
    END IF;
    IF nullif(btrim(coalesce(p_root_cause, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Main Root Cause missing.';
    END IF;
    IF coalesce(jsonb_array_length(coalesce(p_action_plan_items, '[]'::jsonb)), 0) = 0 THEN
      RAISE EXCEPTION 'At least one Action Plan row missing.';
    END IF;
    IF nullif(btrim(coalesce(p_action_taken, p_closure_remarks, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Action Taken / Closure Remarks missing.';
    END IF;
    IF p_actual_closure_date IS NULL THEN
      RAISE EXCEPTION 'Actual Closure Date missing.';
    END IF;
  END IF;

  UPDATE audit_responses
  SET
    status = normalized_status,
    cause_category = nullif(btrim(coalesce(p_cause_category, '')), ''),
    root_cause = nullif(btrim(coalesce(p_root_cause, '')), ''),
    action_plan_items = coalesce(p_action_plan_items, '[]'::jsonb),
    action_taken = nullif(btrim(coalesce(p_action_taken, '')), ''),
    closure_remarks = nullif(btrim(coalesce(p_closure_remarks, '')), ''),
    actual_closure_date = p_actual_closure_date,
    closure_evidence_files = coalesce(p_closure_evidence_files, '[]'::jsonb),
    collaboration_required = coalesce(p_collaboration_required, false),
    collaborator_user_id = p_collaborator_user_id,
    collaborator_name = nullif(btrim(coalesce(p_collaborator_name, '')), ''),
    collaborator_mobile = nullif(btrim(coalesce(p_collaborator_mobile, '')), ''),
    support_department = nullif(btrim(coalesce(p_support_department, '')), ''),
    support_required = nullif(btrim(coalesce(p_support_required, '')), ''),
    support_remarks = nullif(btrim(coalesce(p_support_remarks, '')), ''),
    support_status = coalesce(nullif(btrim(coalesce(p_support_status, '')), ''), support_status, 'Pending'),
    extension_requested_date = p_extension_requested_date,
    extension_reason = nullif(btrim(coalesce(p_extension_reason, '')), ''),
    extension_request_status = CASE
      WHEN p_extension_requested_date IS NOT NULL OR nullif(btrim(coalesce(p_extension_reason, '')), '') IS NOT NULL THEN 'Pending'
      ELSE extension_request_status
    END,
    reviewed_by = CASE WHEN normalized_status IN ('Planning', 'In Progress', 'Submitted for Review') THEN NULL ELSE reviewed_by END,
    reviewed_at = CASE WHEN normalized_status IN ('Planning', 'In Progress', 'Submitted for Review') THEN NULL ELSE reviewed_at END,
    review_comments = CASE WHEN normalized_status IN ('Planning', 'In Progress', 'Submitted for Review') THEN NULL ELSE review_comments END,
    updated_at = now()
  WHERE id = p_response_id
  RETURNING * INTO next_row;

  RETURN next_row;
END;
$$;

CREATE OR REPLACE FUNCTION review_disha_action(
  p_response_id uuid,
  p_user_id uuid,
  p_decision text,
  p_review_comments text DEFAULT NULL
)
RETURNS audit_responses
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  response_row audit_responses%rowtype;
  next_row audit_responses%rowtype;
  requester_can_review boolean;
BEGIN
  SELECT * INTO response_row
  FROM audit_responses
  WHERE id = p_response_id
  FOR UPDATE;

  IF response_row.id IS NULL THEN
    RAISE EXCEPTION 'Assigned NG item not found.';
  END IF;

  IF response_row.result <> 'NG' THEN
    RAISE EXCEPTION 'Only NG responses can be reviewed.';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM user_access_mappings uam
    WHERE uam.user_id = p_user_id
      AND coalesce(uam.active, true) = true
      AND (
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'group disha pic', 'group disha hsc pic')
        OR lower(coalesce(uam.user_type, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'group disha pic', 'group disha hsc pic')
        OR lower(coalesce(uam.role, '')) LIKE '%group disha%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%group disha%'
      )
  ) INTO requester_can_review;

  IF NOT requester_can_review THEN
    RAISE EXCEPTION 'Only Group DISHA PIC or System Admin can review Disha actions.';
  END IF;

  IF p_decision NOT IN ('Approve Closure', 'Send Back', 'Approve Extension', 'Reject Extension') THEN
    RAISE EXCEPTION 'Invalid review decision.';
  END IF;

  IF p_decision IN ('Send Back', 'Reject Extension') AND nullif(btrim(coalesce(p_review_comments, '')), '') IS NULL THEN
    RAISE EXCEPTION 'Review comments are required.';
  END IF;

  UPDATE audit_responses
  SET
    status = CASE
      WHEN p_decision = 'Approve Closure' THEN 'Closed'
      WHEN p_decision = 'Send Back' THEN 'Reassigned'
      ELSE status
    END,
    extension_request_status = CASE
      WHEN p_decision = 'Approve Extension' THEN 'Approved'
      WHEN p_decision = 'Reject Extension' THEN 'Rejected'
      ELSE extension_request_status
    END,
    reviewed_by = p_user_id,
    reviewed_at = now(),
    review_comments = nullif(btrim(coalesce(p_review_comments, '')), ''),
    completed_at = CASE WHEN p_decision = 'Approve Closure' THEN now() ELSE completed_at END,
    completed_by = CASE WHEN p_decision = 'Approve Closure' THEN coalesce(completed_by, p_user_id) ELSE completed_by END,
    updated_at = now()
  WHERE id = p_response_id
  RETURNING * INTO next_row;

  RETURN next_row;
END;
$$;

GRANT EXECUTE ON FUNCTION submit_disha_action_update(uuid, uuid, text, text, text, jsonb, text, text, date, jsonb, boolean, uuid, text, text, text, text, text, text, date, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION review_disha_action(uuid, uuid, text, text) TO anon, authenticated;

COMMIT;
