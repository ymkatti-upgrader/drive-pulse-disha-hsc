-- Add monetary support approval flow for Disha Action Hub.
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS monetary_support_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS expected_expense_amount numeric,
  ADD COLUMN IF NOT EXISTS expense_purpose text,
  ADD COLUMN IF NOT EXISTS expense_category text,
  ADD COLUMN IF NOT EXISTS expense_approval_status text NOT NULL DEFAULT 'Not Required',
  ADD COLUMN IF NOT EXISTS group_disha_approval_status text,
  ADD COLUMN IF NOT EXISTS group_disha_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS group_disha_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_comments text,
  ADD COLUMN IF NOT EXISTS functional_hod_approval_status text,
  ADD COLUMN IF NOT EXISTS functional_hod_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS functional_hod_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS functional_hod_comments text,
  ADD COLUMN IF NOT EXISTS ceo_approval_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS ceo_approval_status text,
  ADD COLUMN IF NOT EXISTS ceo_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS ceo_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS ceo_comments text;

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
  p_monetary_support_required boolean DEFAULT false,
  p_expected_expense_amount numeric DEFAULT NULL,
  p_expense_purpose text DEFAULT NULL,
  p_expense_category text DEFAULT NULL,
  p_ceo_approval_required boolean DEFAULT false,
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
  requires_expense_approval boolean;
  requires_ceo boolean;
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

  requires_expense_approval := coalesce(p_monetary_support_required, false) AND coalesce(p_expected_expense_amount, 0) > 0;
  requires_ceo := requires_expense_approval AND (coalesce(p_ceo_approval_required, false) OR coalesce(p_expected_expense_amount, 0) >= 10000);

  IF requires_expense_approval THEN
    IF nullif(btrim(coalesce(p_expense_purpose, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Expense Purpose missing.';
    END IF;
    IF nullif(btrim(coalesce(p_expense_category, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Expense Category missing.';
    END IF;
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
    monetary_support_required = coalesce(p_monetary_support_required, false),
    expected_expense_amount = CASE WHEN requires_expense_approval THEN p_expected_expense_amount ELSE NULL END,
    expense_purpose = CASE WHEN requires_expense_approval THEN nullif(btrim(coalesce(p_expense_purpose, '')), '') ELSE NULL END,
    expense_category = CASE WHEN requires_expense_approval THEN nullif(btrim(coalesce(p_expense_category, '')), '') ELSE NULL END,
    expense_approval_status = CASE WHEN requires_expense_approval THEN 'Pending Approval' ELSE 'Not Required' END,
    group_disha_approval_status = CASE WHEN requires_expense_approval THEN 'Pending' ELSE NULL END,
    group_disha_approved_by = CASE WHEN requires_expense_approval THEN group_disha_approved_by ELSE NULL END,
    group_disha_approved_at = CASE WHEN requires_expense_approval THEN group_disha_approved_at ELSE NULL END,
    group_disha_comments = CASE WHEN requires_expense_approval THEN group_disha_comments ELSE NULL END,
    functional_hod_approval_status = CASE WHEN requires_expense_approval THEN 'Pending' ELSE NULL END,
    functional_hod_approved_by = CASE WHEN requires_expense_approval THEN functional_hod_approved_by ELSE NULL END,
    functional_hod_approved_at = CASE WHEN requires_expense_approval THEN functional_hod_approved_at ELSE NULL END,
    functional_hod_comments = CASE WHEN requires_expense_approval THEN functional_hod_comments ELSE NULL END,
    ceo_approval_required = requires_ceo,
    ceo_approval_status = CASE WHEN requires_ceo THEN 'Pending' ELSE NULL END,
    ceo_approved_by = CASE WHEN requires_ceo THEN ceo_approved_by ELSE NULL END,
    ceo_approved_at = CASE WHEN requires_ceo THEN ceo_approved_at ELSE NULL END,
    ceo_comments = CASE WHEN requires_ceo THEN ceo_comments ELSE NULL END,
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

CREATE OR REPLACE FUNCTION approve_expense_request(
  p_response_id uuid,
  p_user_id uuid,
  p_role text,
  p_decision text,
  p_comments text DEFAULT NULL
)
RETURNS audit_responses
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  response_row audit_responses%rowtype;
  next_row audit_responses%rowtype;
  requester_can_approve boolean;
  normalized_role text;
  next_group_status text;
  next_functional_status text;
  next_ceo_status text;
BEGIN
  IF p_decision NOT IN ('Approved', 'Rejected') THEN
    RAISE EXCEPTION 'Invalid expense approval decision.';
  END IF;

  IF p_decision = 'Rejected' AND nullif(btrim(coalesce(p_comments, '')), '') IS NULL THEN
    RAISE EXCEPTION 'Comments are required to reject an expense request.';
  END IF;

  SELECT * INTO response_row
  FROM audit_responses
  WHERE id = p_response_id
  FOR UPDATE;

  IF response_row.id IS NULL THEN
    RAISE EXCEPTION 'Expense request not found.';
  END IF;

  IF coalesce(response_row.expense_approval_status, 'Not Required') = 'Not Required' THEN
    RAISE EXCEPTION 'Expense approval is not required for this action.';
  END IF;

  normalized_role := lower(coalesce(p_role, ''));

  SELECT EXISTS (
    SELECT 1
    FROM user_access_mappings uam
    WHERE uam.user_id = p_user_id
      AND coalesce(uam.active, true) = true
      AND (
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'group disha pic', 'group disha hsc pic', 'group functional hod', 'functional hod', 'ceo')
        OR lower(coalesce(uam.user_type, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'group disha pic', 'group disha hsc pic', 'group functional hod', 'functional hod', 'ceo')
        OR lower(coalesce(uam.role, '')) LIKE '%group disha%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%group disha%'
        OR lower(coalesce(uam.role, '')) LIKE '%functional hod%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%functional hod%'
        OR lower(coalesce(uam.role, '')) LIKE '%ceo%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%ceo%'
      )
  ) INTO requester_can_approve;

  IF NOT requester_can_approve THEN
    RAISE EXCEPTION 'You are not allowed to approve expense requests.';
  END IF;

  next_group_status := coalesce(response_row.group_disha_approval_status, 'Pending');
  next_functional_status := coalesce(response_row.functional_hod_approval_status, 'Pending');
  next_ceo_status := coalesce(response_row.ceo_approval_status, 'Pending');

  IF normalized_role LIKE '%system admin%' OR normalized_role LIKE '%admin%' OR normalized_role LIKE '%super admin%' THEN
    next_group_status := p_decision;
    next_functional_status := p_decision;
    IF coalesce(response_row.ceo_approval_required, false) THEN
      next_ceo_status := p_decision;
    END IF;
  ELSIF normalized_role LIKE '%ceo%' THEN
    IF NOT coalesce(response_row.ceo_approval_required, false) THEN
      RAISE EXCEPTION 'CEO approval is not required for this expense.';
    END IF;
    next_ceo_status := p_decision;
  ELSIF normalized_role LIKE '%functional hod%' THEN
    next_functional_status := p_decision;
  ELSE
    next_group_status := p_decision;
  END IF;

  UPDATE audit_responses
  SET
    group_disha_approval_status = next_group_status,
    group_disha_approved_by = CASE WHEN next_group_status <> coalesce(response_row.group_disha_approval_status, '') THEN p_user_id ELSE group_disha_approved_by END,
    group_disha_approved_at = CASE WHEN next_group_status <> coalesce(response_row.group_disha_approval_status, '') THEN now() ELSE group_disha_approved_at END,
    group_disha_comments = CASE WHEN next_group_status <> coalesce(response_row.group_disha_approval_status, '') THEN nullif(btrim(coalesce(p_comments, '')), '') ELSE group_disha_comments END,
    functional_hod_approval_status = next_functional_status,
    functional_hod_approved_by = CASE WHEN next_functional_status <> coalesce(response_row.functional_hod_approval_status, '') THEN p_user_id ELSE functional_hod_approved_by END,
    functional_hod_approved_at = CASE WHEN next_functional_status <> coalesce(response_row.functional_hod_approval_status, '') THEN now() ELSE functional_hod_approved_at END,
    functional_hod_comments = CASE WHEN next_functional_status <> coalesce(response_row.functional_hod_approval_status, '') THEN nullif(btrim(coalesce(p_comments, '')), '') ELSE functional_hod_comments END,
    ceo_approval_status = CASE WHEN coalesce(response_row.ceo_approval_required, false) THEN next_ceo_status ELSE ceo_approval_status END,
    ceo_approved_by = CASE WHEN coalesce(response_row.ceo_approval_required, false) AND next_ceo_status <> coalesce(response_row.ceo_approval_status, '') THEN p_user_id ELSE ceo_approved_by END,
    ceo_approved_at = CASE WHEN coalesce(response_row.ceo_approval_required, false) AND next_ceo_status <> coalesce(response_row.ceo_approval_status, '') THEN now() ELSE ceo_approved_at END,
    ceo_comments = CASE WHEN coalesce(response_row.ceo_approval_required, false) AND next_ceo_status <> coalesce(response_row.ceo_approval_status, '') THEN nullif(btrim(coalesce(p_comments, '')), '') ELSE ceo_comments END,
    expense_approval_status = CASE
      WHEN p_decision = 'Rejected' THEN 'Rejected'
      WHEN next_group_status = 'Approved'
        AND next_functional_status = 'Approved'
        AND (NOT coalesce(response_row.ceo_approval_required, false) OR next_ceo_status = 'Approved') THEN 'Approved'
      ELSE 'Pending Approval'
    END,
    updated_at = now()
  WHERE id = p_response_id
  RETURNING * INTO next_row;

  RETURN next_row;
END;
$$;

GRANT EXECUTE ON FUNCTION submit_disha_action_update(uuid, uuid, text, text, text, jsonb, text, text, date, jsonb, boolean, uuid, text, text, text, text, text, text, boolean, numeric, text, text, boolean, date, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION approve_expense_request(uuid, uuid, text, text, text) TO anon, authenticated;

COMMIT;
