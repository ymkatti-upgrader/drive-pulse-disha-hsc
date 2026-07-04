BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS audit_uuid uuid,
  ADD COLUMN IF NOT EXISTS assigned_pic_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS pic_for_ng_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS pic_for_ng_name text,
  ADD COLUMN IF NOT EXISTS pic_for_ng_mobile text,
  ADD COLUMN IF NOT EXISTS collaborator_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS collaborator_name text,
  ADD COLUMN IF NOT EXISTS collaborator_mobile text,
  ADD COLUMN IF NOT EXISTS action_status text,
  ADD COLUMN IF NOT EXISTS closure_status text,
  ADD COLUMN IF NOT EXISTS verification_status text,
  ADD COLUMN IF NOT EXISTS cause_category text,
  ADD COLUMN IF NOT EXISTS root_cause text,
  ADD COLUMN IF NOT EXISTS action_plan_items jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS action_taken text,
  ADD COLUMN IF NOT EXISTS closure_remarks text,
  ADD COLUMN IF NOT EXISTS closure_evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS quotation_files jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS actual_closure_date date,
  ADD COLUMN IF NOT EXISTS tentative_closing_date date,
  ADD COLUMN IF NOT EXISTS collaboration_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS support_department text,
  ADD COLUMN IF NOT EXISTS support_required text,
  ADD COLUMN IF NOT EXISTS support_remarks text,
  ADD COLUMN IF NOT EXISTS support_status text,
  ADD COLUMN IF NOT EXISTS monetary_support_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS expected_expense_amount numeric,
  ADD COLUMN IF NOT EXISTS expense_category text,
  ADD COLUMN IF NOT EXISTS expense_purpose text,
  ADD COLUMN IF NOT EXISTS expense_approval_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS expense_approver_role text,
  ADD COLUMN IF NOT EXISTS expense_approval_status text,
  ADD COLUMN IF NOT EXISTS group_disha_approval_status text,
  ADD COLUMN IF NOT EXISTS group_disha_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS group_disha_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_approval_remarks text,
  ADD COLUMN IF NOT EXISTS group_disha_comments text,
  ADD COLUMN IF NOT EXISTS submitted_for_review_at timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_review_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS group_disha_review_status text,
  ADD COLUMN IF NOT EXISTS group_disha_reviewed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS group_disha_review_date timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_review_remarks text,
  ADD COLUMN IF NOT EXISTS ceo_approval_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS ceo_approval_status text,
  ADD COLUMN IF NOT EXISTS ceo_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS ceo_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS ceo_comments text,
  ADD COLUMN IF NOT EXISTS ceo_review_status text,
  ADD COLUMN IF NOT EXISTS ceo_reviewed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS ceo_review_date timestamptz,
  ADD COLUMN IF NOT EXISTS ceo_review_remarks text,
  ADD COLUMN IF NOT EXISTS approval_level text,
  ADD COLUMN IF NOT EXISTS approval_history jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS extension_requested_date date,
  ADD COLUMN IF NOT EXISTS extension_reason text,
  ADD COLUMN IF NOT EXISTS extension_request_status text,
  ADD COLUMN IF NOT EXISTS reviewed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS reviewed_at timestamptz,
  ADD COLUMN IF NOT EXISTS review_comments text,
  ADD COLUMN IF NOT EXISTS completed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS assigned_at timestamptz,
  ADD COLUMN IF NOT EXISTS expense_requested_at timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_reviewed_at timestamptz,
  ADD COLUMN IF NOT EXISTS implementation_completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS verification_completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS latest_reopened_at timestamptz,
  ADD COLUMN IF NOT EXISTS lifecycle_reopen_history jsonb NOT NULL DEFAULT '[]'::jsonb;

UPDATE audit_responses
SET assigned_at = coalesce(assigned_at, created_at, updated_at, now())
WHERE result = 'NG'
  AND assigned_at IS NULL;

UPDATE audit_responses
SET expense_requested_at = coalesce(
  expense_requested_at,
  submitted_for_review_at,
  created_at,
  updated_at
)
WHERE coalesce(monetary_support_required, false) = true
  AND expense_requested_at IS NULL
  AND (
    nullif(btrim(coalesce(expense_approval_status, '')), '') IS NOT NULL
    OR expected_expense_amount IS NOT NULL
    OR nullif(btrim(coalesce(expense_purpose, '')), '') IS NOT NULL
    OR nullif(btrim(coalesce(expense_category, '')), '') IS NOT NULL
  );

UPDATE audit_responses
SET group_disha_reviewed_at = coalesce(
  group_disha_reviewed_at,
  group_disha_review_date,
  group_disha_approved_at
)
WHERE group_disha_reviewed_at IS NULL
  AND (
    group_disha_review_date IS NOT NULL
    OR group_disha_approved_at IS NOT NULL
  );

UPDATE audit_responses
SET implementation_completed_at = coalesce(
  implementation_completed_at,
  submitted_for_review_at,
  CASE
    WHEN actual_closure_date IS NOT NULL THEN actual_closure_date::timestamptz
    ELSE NULL
  END,
  updated_at
)
WHERE implementation_completed_at IS NULL
  AND (
    nullif(btrim(coalesce(action_taken, '')), '') IS NOT NULL
    OR coalesce(jsonb_array_length(coalesce(closure_evidence_files, '[]'::jsonb)), 0) > 0
  );

UPDATE audit_responses
SET verification_completed_at = coalesce(
  verification_completed_at,
  reviewed_at,
  completed_at,
  updated_at
)
WHERE verification_completed_at IS NULL
  AND coalesce(verification_status, '') = 'Verified';

CREATE OR REPLACE FUNCTION public.append_action_lifecycle_history(
  p_history jsonb,
  p_cycle_started_at timestamptz,
  p_implementation_completed_at timestamptz,
  p_verification_completed_at timestamptz,
  p_completed_at timestamptz,
  p_reopened_at timestamptz,
  p_comments text
)
RETURNS jsonb
LANGUAGE sql
VOLATILE
AS $$
  SELECT coalesce(p_history, '[]'::jsonb) || jsonb_build_array(
    jsonb_build_object(
      'id', gen_random_uuid(),
      'cycle_started_at', p_cycle_started_at,
      'implementation_completed_at', p_implementation_completed_at,
      'verification_completed_at', p_verification_completed_at,
      'completed_at', p_completed_at,
      'reopened_at', p_reopened_at,
      'comments', nullif(btrim(coalesce(p_comments, '')), ''),
      'recorded_at', now()
    )
  );
$$;

CREATE OR REPLACE FUNCTION public.sync_action_lifecycle_defaults()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.result = 'NG'
    AND NEW.assigned_at IS NULL
    AND (
      NEW.assigned_pic_user_id IS NOT NULL
      OR NEW.pic_for_ng_user_id IS NOT NULL
      OR nullif(btrim(coalesce(NEW.pic_for_ng_name, '')), '') IS NOT NULL
    ) THEN
    NEW.assigned_at := coalesce(NEW.assigned_at, NEW.created_at, now());
  END IF;

  NEW.group_disha_reviewed_at := coalesce(
    NEW.group_disha_reviewed_at,
    NEW.group_disha_review_date,
    NEW.group_disha_approved_at
  );

  IF coalesce(NEW.monetary_support_required, false)
     AND NEW.expense_requested_at IS NULL
     AND (
       nullif(btrim(coalesce(NEW.expense_approval_status, '')), '') IS NOT NULL
       OR NEW.expected_expense_amount IS NOT NULL
       OR nullif(btrim(coalesce(NEW.expense_purpose, '')), '') IS NOT NULL
       OR nullif(btrim(coalesce(NEW.expense_category, '')), '') IS NOT NULL
     ) THEN
    NEW.expense_requested_at := coalesce(NEW.submitted_for_review_at, NEW.updated_at, now());
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_action_lifecycle_defaults ON audit_responses;
CREATE TRIGGER trg_sync_action_lifecycle_defaults
BEFORE INSERT OR UPDATE ON audit_responses
FOR EACH ROW
EXECUTE FUNCTION public.sync_action_lifecycle_defaults();

CREATE OR REPLACE FUNCTION public.submit_disha_action_update(
  p_response_id uuid,
  p_user_id uuid,
  p_status text DEFAULT NULL,
  p_cause_category text DEFAULT NULL,
  p_root_cause text DEFAULT NULL,
  p_action_plan_items jsonb DEFAULT '[]'::jsonb,
  p_action_taken text DEFAULT NULL,
  p_closure_remarks text DEFAULT NULL,
  p_closure_evidence_files jsonb DEFAULT '[]'::jsonb,
  p_actual_closure_date date DEFAULT NULL,
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
  p_expense_category text DEFAULT NULL,
  p_expense_purpose text DEFAULT NULL,
  p_extension_requested_date date DEFAULT NULL,
  p_extension_reason text DEFAULT NULL,
  p_ceo_approval_required boolean DEFAULT false,
  p_quotation_files jsonb DEFAULT '[]'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row audit_responses%ROWTYPE;
  v_is_admin boolean := false;
  v_requester_mobile text := '';
  v_is_assigned boolean := false;
  v_is_collaborator boolean := false;
  v_normalized_status text := NULL;
  v_requires_monetary_support boolean := coalesce(p_monetary_support_required, false);
  v_next_group_status text;
  v_next_ceo_status text;
  v_next_expense_status text;
  v_next_approval_level text;
  v_next_approver_role text;
  v_marks_implementation_complete boolean := false;
BEGIN
  v_normalized_status := CASE
    WHEN p_status IN ('Assigned', 'Planning', 'In Progress', 'Submitted for Review', 'Reassigned', 'Closed') THEN p_status
    WHEN p_status IS NULL THEN NULL
    ELSE NULL
  END;

  IF p_status IS NOT NULL AND v_normalized_status IS NULL THEN
    RAISE EXCEPTION 'Invalid Disha action status.';
  END IF;

  SELECT *
  INTO v_row
  FROM audit_responses
  WHERE id = p_response_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NG action not found';
  END IF;

  IF v_row.result <> 'NG' THEN
    RAISE EXCEPTION 'Only NG responses can be updated through Disha Action Hub';
  END IF;

  IF coalesce(v_row.is_void, false) THEN
    RAISE EXCEPTION 'This NG action row is void and cannot be processed.';
  END IF;

  SELECT coalesce(mobile_no, '')
  INTO v_requester_mobile
  FROM app_users
  WHERE id = p_user_id
    AND active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Active user not found';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM user_access_mappings uam
    WHERE uam.user_id = p_user_id
      AND coalesce(uam.active, true) = true
      AND (
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system admin', 'system administrator')
        OR lower(coalesce(uam.user_type, '')) IN ('admin', 'super admin', 'system admin', 'system administrator')
      )
  ) INTO v_is_admin;

  v_is_assigned :=
    v_row.assigned_pic_user_id IS NOT DISTINCT FROM p_user_id
    OR v_row.pic_for_ng_user_id IS NOT DISTINCT FROM p_user_id
    OR (
      nullif(coalesce(v_row.pic_for_ng_mobile, ''), '') IS NOT NULL
      AND coalesce(v_row.pic_for_ng_mobile, '') = v_requester_mobile
    );

  v_is_collaborator :=
    v_row.collaborator_user_id IS NOT DISTINCT FROM p_user_id
    OR (
      nullif(coalesce(v_row.collaborator_mobile, ''), '') IS NOT NULL
      AND coalesce(v_row.collaborator_mobile, '') = v_requester_mobile
    );

  IF NOT v_is_admin AND NOT v_is_assigned AND NOT v_is_collaborator THEN
    RAISE EXCEPTION 'You are not allowed to update this NG action';
  END IF;

  IF v_is_collaborator AND NOT v_is_admin AND NOT v_is_assigned THEN
    UPDATE audit_responses
    SET
      support_remarks = nullif(btrim(coalesce(p_support_remarks, '')), ''),
      support_status = coalesce(nullif(btrim(coalesce(p_support_status, '')), ''), support_status, 'Pending'),
      updated_at = now()
    WHERE id = p_response_id;

    RETURN jsonb_build_object(
      'success', true,
      'response_id', p_response_id,
      'status', coalesce(v_normalized_status, v_row.status)
    );
  END IF;

  IF v_requires_monetary_support THEN
    IF nullif(btrim(coalesce(p_expense_purpose, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Expense Purpose missing.';
    END IF;
    IF nullif(btrim(coalesce(p_expense_category, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Expense Category missing.';
    END IF;
  END IF;

  IF v_normalized_status = 'Submitted for Review' THEN
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

  v_marks_implementation_complete :=
    v_normalized_status = 'Submitted for Review'
    AND nullif(btrim(coalesce(p_action_taken, p_closure_remarks, '')), '') IS NOT NULL
    AND coalesce(jsonb_array_length(coalesce(p_closure_evidence_files, '[]'::jsonb)), 0) > 0;

  IF v_requires_monetary_support THEN
    IF coalesce(v_row.ceo_review_status, v_row.ceo_approval_status, '') IN ('Rejected by CEO', 'Rejected') THEN
      v_next_group_status := 'Approved';
      v_next_ceo_status := 'Resubmitted for CEO Approval';
      v_next_expense_status := 'Resubmitted for CEO Approval';
      v_next_approval_level := 'CEO Review';
      v_next_approver_role := 'CEO';
    ELSIF coalesce(v_row.group_disha_review_status, v_row.group_disha_approval_status, '') IN ('Rejected by Group DISHA', 'Rejected') THEN
      v_next_group_status := 'Resubmitted for Group Review';
      v_next_ceo_status := NULL;
      v_next_expense_status := 'Resubmitted for Group DISHA Review';
      v_next_approval_level := 'Group Review';
      v_next_approver_role := 'Group Disha HSC PIC';
    ELSE
      v_next_group_status := 'Pending Group Review';
      v_next_ceo_status := NULL;
      v_next_expense_status := 'Pending Group DISHA Review';
      v_next_approval_level := 'Group Review';
      v_next_approver_role := 'Group Disha HSC PIC';
    END IF;
  ELSE
    v_next_group_status := NULL;
    v_next_ceo_status := NULL;
    v_next_expense_status := 'Not Required';
    v_next_approval_level := NULL;
    v_next_approver_role := NULL;
  END IF;

  UPDATE audit_responses
  SET
    status = coalesce(v_normalized_status, status),
    action_status = coalesce(v_normalized_status, action_status, status),
    assigned_pic_user_id = coalesce(assigned_pic_user_id, pic_for_ng_user_id),
    assigned_at = coalesce(assigned_at, v_row.assigned_at, v_row.created_at, now()),
    cause_category = nullif(btrim(coalesce(p_cause_category, '')), ''),
    root_cause = nullif(btrim(coalesce(p_root_cause, '')), ''),
    action_plan_items = coalesce(p_action_plan_items, '[]'::jsonb),
    action_taken = nullif(btrim(coalesce(p_action_taken, '')), ''),
    closure_remarks = nullif(btrim(coalesce(p_closure_remarks, '')), ''),
    closure_evidence_files = coalesce(p_closure_evidence_files, '[]'::jsonb),
    actual_closure_date = p_actual_closure_date,
    collaboration_required = coalesce(p_collaboration_required, false),
    collaborator_user_id = p_collaborator_user_id,
    collaborator_name = nullif(btrim(coalesce(p_collaborator_name, '')), ''),
    collaborator_mobile = nullif(btrim(coalesce(p_collaborator_mobile, '')), ''),
    support_department = nullif(btrim(coalesce(p_support_department, '')), ''),
    support_required = nullif(btrim(coalesce(p_support_required, '')), ''),
    support_remarks = nullif(btrim(coalesce(p_support_remarks, '')), ''),
    support_status = coalesce(nullif(btrim(coalesce(p_support_status, '')), ''), support_status, 'Pending'),
    monetary_support_required = v_requires_monetary_support,
    expected_expense_amount = CASE
      WHEN v_requires_monetary_support AND p_expected_expense_amount IS NOT NULL AND p_expected_expense_amount >= 0 THEN p_expected_expense_amount
      ELSE NULL
    END,
    expense_purpose = CASE WHEN v_requires_monetary_support THEN nullif(btrim(coalesce(p_expense_purpose, '')), '') ELSE NULL END,
    expense_category = CASE WHEN v_requires_monetary_support THEN nullif(btrim(coalesce(p_expense_category, '')), '') ELSE NULL END,
    expense_requested_at = CASE
      WHEN v_requires_monetary_support THEN coalesce(expense_requested_at, CASE WHEN v_normalized_status = 'Submitted for Review' THEN now() ELSE NULL END)
      ELSE NULL
    END,
    group_disha_review_required = v_requires_monetary_support,
    group_disha_review_status = v_next_group_status,
    group_disha_reviewed_by = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_reviewed_by END,
    group_disha_review_date = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_review_date END,
    group_disha_review_remarks = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_review_remarks END,
    group_disha_approval_status = CASE
      WHEN v_next_group_status = 'Approved' THEN 'Approved'
      WHEN v_next_group_status = 'Rejected by Group DISHA' THEN 'Rejected'
      WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN 'Pending'
      ELSE NULL
    END,
    group_disha_approved_by = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_approved_by END,
    group_disha_approved_at = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_approved_at END,
    group_disha_approval_remarks = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_approval_remarks END,
    group_disha_comments = CASE WHEN v_next_group_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN NULL ELSE group_disha_comments END,
    ceo_approval_required = v_requires_monetary_support AND v_next_group_status = 'Approved',
    ceo_review_status = v_next_ceo_status,
    ceo_reviewed_by = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_reviewed_by END,
    ceo_review_date = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_review_date END,
    ceo_review_remarks = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_review_remarks END,
    ceo_approval_status = CASE
      WHEN v_next_ceo_status = 'Approved' THEN 'Approved'
      WHEN v_next_ceo_status = 'Rejected by CEO' THEN 'Rejected'
      WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') THEN 'Pending'
      ELSE NULL
    END,
    ceo_approved_by = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_approved_by END,
    ceo_approved_at = CASE
      WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN ceo_approved_at
      ELSE ceo_approved_at
    END,
    ceo_comments = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_comments END,
    expense_approval_required = v_requires_monetary_support,
    expense_approver_role = v_next_approver_role,
    expense_approval_status = v_next_expense_status,
    approval_level = v_next_approval_level,
    submitted_for_review_at = CASE
      WHEN coalesce(v_normalized_status, action_status, status) = 'Submitted for Review' THEN coalesce(submitted_for_review_at, now())
      ELSE submitted_for_review_at
    END,
    implementation_completed_at = CASE
      WHEN v_marks_implementation_complete THEN coalesce(implementation_completed_at, now())
      ELSE implementation_completed_at
    END,
    closure_status = CASE
      WHEN v_requires_monetary_support AND v_next_expense_status = 'CEO Approved' THEN 'Submitted'
      WHEN coalesce(v_normalized_status, action_status, status) IN ('Closed', 'Completed') THEN 'Closed'
      WHEN coalesce(v_normalized_status, action_status, status) = 'Submitted for Review' THEN 'Submitted'
      ELSE coalesce(closure_status, 'Open')
    END,
    verification_status = CASE
      WHEN v_requires_monetary_support AND v_next_expense_status = 'CEO Approved' THEN 'Verification Pending'
      WHEN coalesce(v_normalized_status, action_status, status) IN ('Closed', 'Completed') THEN 'Verified'
      WHEN coalesce(v_normalized_status, action_status, status) = 'Submitted for Review' THEN 'Pending'
      ELSE coalesce(verification_status, 'Not Started')
    END,
    extension_requested_date = p_extension_requested_date,
    extension_reason = nullif(btrim(coalesce(p_extension_reason, '')), ''),
    extension_request_status = CASE
      WHEN p_extension_requested_date IS NOT NULL OR nullif(btrim(coalesce(p_extension_reason, '')), '') IS NOT NULL THEN 'Pending'
      ELSE extension_request_status
    END,
    reviewed_by = CASE WHEN coalesce(v_normalized_status, status) IN ('Planning', 'In Progress', 'Submitted for Review') THEN NULL ELSE reviewed_by END,
    reviewed_at = CASE WHEN coalesce(v_normalized_status, status) IN ('Planning', 'In Progress', 'Submitted for Review') THEN NULL ELSE reviewed_at END,
    review_comments = CASE WHEN coalesce(v_normalized_status, status) IN ('Planning', 'In Progress', 'Submitted for Review') THEN NULL ELSE review_comments END,
    quotation_files = coalesce(p_quotation_files, '[]'::jsonb),
    completed_at = CASE
      WHEN coalesce(v_normalized_status, status) IN ('Closed', 'Completed') THEN coalesce(completed_at, now())
      ELSE completed_at
    END,
    completed_by = CASE
      WHEN coalesce(v_normalized_status, status) IN ('Closed', 'Completed') THEN coalesce(completed_by, p_user_id)
      ELSE completed_by
    END,
    updated_at = now()
  WHERE id = p_response_id;

  RETURN jsonb_build_object(
    'success', true,
    'response_id', p_response_id,
    'status', coalesce(v_normalized_status, v_row.status),
    'expense_approval_status', v_next_expense_status
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.review_disha_action(
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
  v_now timestamptz := now();
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
    RAISE EXCEPTION 'Only Group DISHA HSC or System Admin can review Disha actions.';
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
    action_status = CASE
      WHEN p_decision = 'Approve Closure' THEN 'Closed'
      WHEN p_decision = 'Send Back' THEN 'Reassigned'
      ELSE action_status
    END,
    closure_status = CASE
      WHEN p_decision = 'Approve Closure' THEN 'Closed'
      WHEN p_decision = 'Send Back' THEN 'Open'
      ELSE closure_status
    END,
    verification_status = CASE
      WHEN p_decision = 'Approve Closure' THEN 'Verified'
      WHEN p_decision = 'Send Back' THEN 'Rejected'
      ELSE verification_status
    END,
    extension_request_status = CASE
      WHEN p_decision = 'Approve Extension' THEN 'Approved'
      WHEN p_decision = 'Reject Extension' THEN 'Rejected'
      ELSE extension_request_status
    END,
    lifecycle_reopen_history = CASE
      WHEN p_decision = 'Send Back' AND (
        response_row.implementation_completed_at IS NOT NULL
        OR response_row.verification_completed_at IS NOT NULL
        OR response_row.completed_at IS NOT NULL
      ) THEN public.append_action_lifecycle_history(
        lifecycle_reopen_history,
        coalesce(latest_reopened_at, assigned_at, created_at),
        implementation_completed_at,
        verification_completed_at,
        completed_at,
        v_now,
        p_review_comments
      )
      ELSE lifecycle_reopen_history
    END,
    latest_reopened_at = CASE
      WHEN p_decision = 'Send Back' THEN v_now
      ELSE latest_reopened_at
    END,
    implementation_completed_at = CASE
      WHEN p_decision = 'Send Back' THEN NULL
      ELSE implementation_completed_at
    END,
    verification_completed_at = CASE
      WHEN p_decision = 'Approve Closure' THEN coalesce(verification_completed_at, v_now)
      WHEN p_decision = 'Send Back' THEN NULL
      ELSE verification_completed_at
    END,
    reviewed_by = p_user_id,
    reviewed_at = v_now,
    review_comments = nullif(btrim(coalesce(p_review_comments, '')), ''),
    completed_at = CASE
      WHEN p_decision = 'Approve Closure' THEN coalesce(completed_at, v_now)
      WHEN p_decision = 'Send Back' THEN NULL
      ELSE completed_at
    END,
    completed_by = CASE
      WHEN p_decision = 'Approve Closure' THEN coalesce(completed_by, p_user_id)
      WHEN p_decision = 'Send Back' THEN NULL
      ELSE completed_by
    END,
    updated_at = v_now
  WHERE id = p_response_id
  RETURNING * INTO next_row;

  RETURN next_row;
END;
$$;

CREATE OR REPLACE FUNCTION public.approve_expense_request(
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
  normalized_decision text;
  stage text;
  previous_status text;
  new_status text;
  v_now timestamptz := now();
BEGIN
  normalized_role := lower(coalesce(p_role, ''));
  normalized_decision := coalesce(p_decision, '');

  IF normalized_decision NOT IN ('Approved', 'Rejected') THEN
    RAISE EXCEPTION 'Invalid expense approval decision.';
  END IF;

  IF normalized_decision = 'Rejected' AND nullif(btrim(coalesce(p_comments, '')), '') IS NULL THEN
    RAISE EXCEPTION 'Comments are required to reject an expense request.';
  END IF;

  SELECT *
  INTO response_row
  FROM audit_responses
  WHERE id = p_response_id
  FOR UPDATE;

  IF response_row.id IS NULL THEN
    RAISE EXCEPTION 'Expense request not found.';
  END IF;

  IF NOT COALESCE(response_row.expense_approval_required, response_row.monetary_support_required, false) THEN
    RAISE EXCEPTION 'Expense approval is not required for this action.';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM user_access_mappings uam
    WHERE uam.user_id = p_user_id
      AND coalesce(uam.active, true) = true
      AND (
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'group disha hsc pic', 'group disha pic', 'ceo')
        OR lower(coalesce(uam.user_type, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'group disha hsc pic', 'group disha pic', 'ceo')
        OR lower(coalesce(uam.role, '')) LIKE '%group disha%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%group disha%'
        OR lower(coalesce(uam.role, '')) LIKE '%ceo%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%ceo%'
      )
  ) INTO requester_can_approve;

  IF NOT requester_can_approve THEN
    RAISE EXCEPTION 'You are not allowed to approve expense requests.';
  END IF;

  IF coalesce(response_row.ceo_review_status, response_row.ceo_approval_status, '') = 'Approved'
     OR coalesce(response_row.expense_approval_status, '') = 'CEO Approved' THEN
    RAISE EXCEPTION 'This expense request has already been approved.';
  END IF;

  stage := CASE
    WHEN coalesce(response_row.group_disha_review_status, response_row.group_disha_approval_status, '') = 'Approved' THEN 'ceo'
    ELSE 'group'
  END;
  previous_status := coalesce(response_row.expense_approval_status, 'Not Required');

  IF stage = 'group' THEN
    IF normalized_role NOT LIKE '%group disha%' AND normalized_role NOT LIKE '%admin%' AND normalized_role NOT LIKE '%system%' THEN
      RAISE EXCEPTION 'Group Disha HSC PIC approval is required before CEO review.';
    END IF;

    new_status := CASE WHEN normalized_decision = 'Approved' THEN 'Pending CEO Approval' ELSE 'Rejected by Group DISHA' END;

    UPDATE audit_responses
    SET
      group_disha_review_required = true,
      group_disha_review_status = CASE WHEN normalized_decision = 'Approved' THEN 'Approved' ELSE 'Rejected by Group DISHA' END,
      group_disha_reviewed_by = p_user_id,
      group_disha_review_date = v_now,
      group_disha_reviewed_at = coalesce(group_disha_reviewed_at, v_now),
      group_disha_review_remarks = nullif(btrim(coalesce(p_comments, '')), ''),
      group_disha_approval_status = normalized_decision,
      group_disha_approved_by = p_user_id,
      group_disha_approved_at = v_now,
      group_disha_approval_remarks = nullif(btrim(coalesce(p_comments, '')), ''),
      group_disha_comments = nullif(btrim(coalesce(p_comments, '')), ''),
      ceo_approval_required = normalized_decision = 'Approved',
      ceo_review_status = CASE WHEN normalized_decision = 'Approved' THEN 'Pending CEO Approval' ELSE NULL END,
      ceo_reviewed_by = NULL,
      ceo_review_date = NULL,
      ceo_review_remarks = NULL,
      ceo_approval_status = CASE WHEN normalized_decision = 'Approved' THEN 'Pending' ELSE NULL END,
      ceo_approved_by = NULL,
      ceo_comments = NULL,
      expense_approval_required = true,
      expense_approver_role = CASE WHEN normalized_decision = 'Approved' THEN 'CEO' ELSE 'Group Disha HSC PIC' END,
      expense_approval_status = new_status,
      approval_level = CASE WHEN normalized_decision = 'Approved' THEN 'CEO Review' ELSE 'Group Review' END,
      approval_history = public.append_approval_history(
        approval_history,
        'Group Review',
        'Group Disha HSC PIC',
        p_user_id,
        normalized_decision,
        p_comments,
        previous_status,
        new_status
      ),
      updated_at = v_now
    WHERE id = p_response_id
    RETURNING * INTO next_row;
  ELSE
    IF normalized_role NOT LIKE '%ceo%' AND normalized_role NOT LIKE '%admin%' AND normalized_role NOT LIKE '%system%' THEN
      RAISE EXCEPTION 'CEO approval is required after Group Disha HSC PIC approval.';
    END IF;

    IF coalesce(response_row.group_disha_review_status, response_row.group_disha_approval_status, 'Pending') <> 'Approved' THEN
      RAISE EXCEPTION 'CEO approval can only be completed after Group Disha HSC PIC approval.';
    END IF;

    new_status := CASE WHEN normalized_decision = 'Approved' THEN 'CEO Approved' ELSE 'Rejected by CEO' END;

    UPDATE audit_responses
    SET
      expense_approval_required = true,
      expense_approver_role = 'CEO',
      expense_approval_status = new_status,
      ceo_approval_required = true,
      ceo_review_status = CASE WHEN normalized_decision = 'Approved' THEN 'Approved' ELSE 'Rejected by CEO' END,
      ceo_reviewed_by = p_user_id,
      ceo_review_date = v_now,
      ceo_review_remarks = nullif(btrim(coalesce(p_comments, '')), ''),
      ceo_approval_status = normalized_decision,
      ceo_approved_by = CASE WHEN normalized_decision = 'Approved' THEN p_user_id ELSE ceo_approved_by END,
      ceo_approved_at = CASE WHEN normalized_decision = 'Approved' THEN coalesce(ceo_approved_at, v_now) ELSE ceo_approved_at END,
      ceo_comments = nullif(btrim(coalesce(p_comments, '')), ''),
      approval_level = CASE WHEN normalized_decision = 'Approved' THEN 'Completed' ELSE 'CEO Review' END,
      verification_status = CASE WHEN normalized_decision = 'Approved' THEN 'Verification Pending' ELSE verification_status END,
      closure_status = CASE WHEN normalized_decision = 'Approved' THEN coalesce(closure_status, 'Submitted') ELSE closure_status END,
      approval_history = public.append_approval_history(
        approval_history,
        'CEO Review',
        'CEO',
        p_user_id,
        normalized_decision,
        p_comments,
        previous_status,
        new_status
      ),
      updated_at = v_now
    WHERE id = p_response_id
    RETURNING * INTO next_row;
  END IF;

  RETURN next_row;
END;
$$;

DROP VIEW IF EXISTS public.audit_response_lifecycle_analytics;
CREATE VIEW public.audit_response_lifecycle_analytics AS
SELECT
  ar.id AS response_id,
  ar.audit_id,
  ar.audit_uuid,
  a.audit_number,
  coalesce(a.audit_number, a.audit_no, ar.audit_id) AS audit_number_display,
  a.title AS audit_name,
  coalesce(ar.audit_location, l.name, l.code) AS location,
  coalesce(ar.audit_department, d.name) AS department,
  ar.sub_question_text AS question,
  coalesce(ar.pic_for_ng_name, pic.employee_name, assignee.employee_name) AS pic_name,
  ar.pic_for_ng_mobile AS pic_mobile,
  ar.assigned_pic_user_id,
  ar.pic_for_ng_user_id,
  ar.result,
  ar.action_status,
  ar.closure_status,
  ar.verification_status,
  ar.cause_category,
  ar.root_cause,
  ar.monetary_support_required,
  ar.expected_expense_amount,
  ar.expense_category,
  ar.expense_purpose,
  ar.expense_approval_status,
  ar.expense_approver_role,
  ar.tentative_closing_date AS due_date,
  ar.actual_closure_date,
  ar.assigned_at,
  ar.expense_requested_at,
  coalesce(ar.group_disha_reviewed_at, ar.group_disha_review_date, ar.group_disha_approved_at) AS group_disha_reviewed_at,
  ar.ceo_approved_at,
  ar.implementation_completed_at,
  ar.verification_completed_at,
  ar.completed_at,
  ar.latest_reopened_at,
  ar.lifecycle_reopen_history,
  coalesce(jsonb_array_length(coalesce(ar.lifecycle_reopen_history, '[]'::jsonb)), 0) AS reopen_count,
  ar.created_at,
  ar.updated_at,
  coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at) AS cycle_started_at,
  CASE
    WHEN ar.completed_at IS NOT NULL THEN round((extract(epoch FROM (ar.completed_at - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0)::numeric, 2)
    ELSE NULL
  END AS closure_time_days,
  CASE
    WHEN coalesce(ar.monetary_support_required, false) AND ar.ceo_approved_at IS NOT NULL THEN round((extract(epoch FROM (ar.ceo_approved_at - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0)::numeric, 2)
    ELSE NULL
  END AS financial_approval_time_days,
  CASE
    WHEN coalesce(ar.monetary_support_required, false) AND ar.ceo_approved_at IS NOT NULL AND ar.implementation_completed_at IS NOT NULL THEN round((extract(epoch FROM (ar.implementation_completed_at - ar.ceo_approved_at)) / 86400.0)::numeric, 2)
    ELSE NULL
  END AS implementation_time_days,
  CASE
    WHEN ar.implementation_completed_at IS NOT NULL AND ar.completed_at IS NOT NULL THEN round((extract(epoch FROM (ar.completed_at - ar.implementation_completed_at)) / 86400.0)::numeric, 2)
    ELSE NULL
  END AS verification_time_days,
  CASE
    WHEN ar.completed_at IS NULL THEN floor(extract(epoch FROM (now() - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0)
    ELSE floor(extract(epoch FROM (ar.completed_at - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0)
  END AS action_age_days,
  CASE
    WHEN ar.completed_at IS NOT NULL THEN 'Closed'
    WHEN floor(extract(epoch FROM (now() - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0) <= 7 THEN '0-7 Days'
    WHEN floor(extract(epoch FROM (now() - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0) <= 15 THEN '8-15 Days'
    WHEN floor(extract(epoch FROM (now() - coalesce(ar.latest_reopened_at, ar.assigned_at, ar.created_at))) / 86400.0) <= 30 THEN '16-30 Days'
    ELSE '30+ Days'
  END AS age_bucket,
  CASE
    WHEN ar.completed_at IS NOT NULL OR coalesce(ar.closure_status, '') = 'Closed' THEN 'Closed'
    WHEN coalesce(ar.verification_status, '') = 'Verification Pending' THEN 'Verification Pending'
    WHEN ar.implementation_completed_at IS NOT NULL THEN 'Verification Pending'
    WHEN coalesce(ar.monetary_support_required, false) AND coalesce(ar.expense_approval_status, '') IN ('Pending Group DISHA Review', 'Resubmitted for Group DISHA Review', 'Pending CEO Approval', 'Resubmitted for CEO Approval') THEN 'Financial Approval Pending'
    WHEN coalesce(ar.monetary_support_required, false) AND ar.ceo_approved_at IS NULL THEN 'Financial Approval Pending'
    WHEN ar.implementation_completed_at IS NULL THEN 'Implementation Pending'
    ELSE 'Open'
  END AS current_stage,
  CASE
    WHEN ar.tentative_closing_date IS NOT NULL
      AND coalesce(ar.closure_status, '') <> 'Closed'
      AND ar.completed_at IS NULL
      AND ar.tentative_closing_date < current_date THEN true
    ELSE false
  END AS is_overdue
FROM audit_responses ar
LEFT JOIN audits a ON a.id = ar.audit_uuid
LEFT JOIN locations l ON l.id = a.location_id
LEFT JOIN departments d ON d.id = a.department_id
LEFT JOIN app_users pic ON pic.id = ar.pic_for_ng_user_id
LEFT JOIN app_users assignee ON assignee.id = ar.assigned_pic_user_id
WHERE ar.result = 'NG'
  AND coalesce(ar.is_void, false) = false;

GRANT SELECT ON public.audit_response_lifecycle_analytics TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.append_action_lifecycle_history(jsonb, timestamptz, timestamptz, timestamptz, timestamptz, timestamptz, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.submit_disha_action_update(uuid, uuid, text, text, text, jsonb, text, text, jsonb, date, boolean, uuid, text, text, text, text, text, text, boolean, numeric, text, text, date, text, boolean, jsonb) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.review_disha_action(uuid, uuid, text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.approve_expense_request(uuid, uuid, text, text, text) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
