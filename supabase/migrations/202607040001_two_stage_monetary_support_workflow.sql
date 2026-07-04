BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS group_disha_review_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS group_disha_review_status text,
  ADD COLUMN IF NOT EXISTS group_disha_reviewed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS group_disha_review_date timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_review_remarks text,
  ADD COLUMN IF NOT EXISTS ceo_review_status text,
  ADD COLUMN IF NOT EXISTS ceo_reviewed_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS ceo_review_date timestamptz,
  ADD COLUMN IF NOT EXISTS ceo_review_remarks text,
  ADD COLUMN IF NOT EXISTS approval_level text,
  ADD COLUMN IF NOT EXISTS approval_history jsonb NOT NULL DEFAULT '[]'::jsonb;

UPDATE audit_responses
SET
  group_disha_review_required = coalesce(monetary_support_required, false),
  group_disha_review_status = CASE
    WHEN coalesce(monetary_support_required, false) = false THEN NULL
    WHEN coalesce(group_disha_review_status, '') <> '' THEN group_disha_review_status
    WHEN coalesce(group_disha_approval_status, '') <> '' THEN group_disha_approval_status
    ELSE 'Pending Group Review'
  END,
  group_disha_reviewed_by = coalesce(group_disha_reviewed_by, group_disha_approved_by),
  group_disha_review_date = coalesce(group_disha_review_date, group_disha_approved_at),
  group_disha_review_remarks = coalesce(group_disha_review_remarks, group_disha_comments, group_disha_approval_remarks),
  ceo_review_status = CASE
    WHEN coalesce(monetary_support_required, false) = false THEN NULL
    WHEN coalesce(ceo_review_status, '') <> '' THEN ceo_review_status
    WHEN coalesce(ceo_approval_status, '') <> '' THEN ceo_approval_status
    WHEN coalesce(group_disha_approval_status, '') = 'Approved' THEN 'Pending CEO Approval'
    ELSE NULL
  END,
  ceo_reviewed_by = coalesce(ceo_reviewed_by, ceo_approved_by),
  ceo_review_date = coalesce(ceo_review_date, ceo_approved_at),
  ceo_review_remarks = coalesce(ceo_review_remarks, ceo_comments),
  approval_level = CASE
    WHEN coalesce(monetary_support_required, false) = false THEN NULL
    WHEN coalesce(ceo_approval_status, ceo_review_status, '') = 'Approved' THEN 'Completed'
    WHEN coalesce(group_disha_approval_status, group_disha_review_status, '') = 'Approved' THEN 'CEO Review'
    ELSE 'Group Review'
  END
WHERE coalesce(monetary_support_required, false) = true
   OR coalesce(expense_approval_required, false) = true
   OR coalesce(group_disha_approval_status, '') <> ''
   OR coalesce(ceo_approval_status, '') <> '';

CREATE OR REPLACE FUNCTION public.append_approval_history(
  p_history jsonb,
  p_level text,
  p_role text,
  p_user_id uuid,
  p_decision text,
  p_remarks text,
  p_previous_status text,
  p_new_status text
)
RETURNS jsonb
LANGUAGE sql
VOLATILE
AS $$
  SELECT coalesce(p_history, '[]'::jsonb) || jsonb_build_array(
    jsonb_build_object(
      'id', gen_random_uuid(),
      'level', p_level,
      'role', p_role,
      'user_id', p_user_id,
      'decision', p_decision,
      'remarks', nullif(btrim(coalesce(p_remarks, '')), ''),
      'previous_status', p_previous_status,
      'new_status', p_new_status,
      'timestamp', now()
    )
  );
$$;

CREATE OR REPLACE FUNCTION public.normalize_expense_approval_flow()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF COALESCE(NEW.monetary_support_required, false) = false THEN
    NEW.group_disha_review_required := false;
    NEW.expense_approval_required := false;
    NEW.expense_approver_role := NULL;
    NEW.expense_approval_status := 'Not Required';
    NEW.group_disha_approval_status := NULL;
    NEW.group_disha_approved_by := NULL;
    NEW.group_disha_approved_at := NULL;
    NEW.group_disha_comments := NULL;
    NEW.group_disha_review_status := NULL;
    NEW.group_disha_reviewed_by := NULL;
    NEW.group_disha_review_date := NULL;
    NEW.group_disha_review_remarks := NULL;
    NEW.ceo_approval_required := false;
    NEW.ceo_approval_status := NULL;
    NEW.ceo_approved_by := NULL;
    NEW.ceo_approved_at := NULL;
    NEW.ceo_comments := NULL;
    NEW.ceo_review_status := NULL;
    NEW.ceo_reviewed_by := NULL;
    NEW.ceo_review_date := NULL;
    NEW.ceo_review_remarks := NULL;
    NEW.approval_level := NULL;
    RETURN NEW;
  END IF;

  NEW.group_disha_review_required := true;
  NEW.expense_approval_required := true;

  NEW.group_disha_reviewed_by := coalesce(NEW.group_disha_reviewed_by, NEW.group_disha_approved_by);
  NEW.group_disha_review_date := coalesce(NEW.group_disha_review_date, NEW.group_disha_approved_at);
  NEW.group_disha_review_remarks := coalesce(NEW.group_disha_review_remarks, NEW.group_disha_comments, NEW.group_disha_approval_remarks);
  NEW.ceo_reviewed_by := coalesce(NEW.ceo_reviewed_by, NEW.ceo_approved_by);
  NEW.ceo_review_date := coalesce(NEW.ceo_review_date, NEW.ceo_approved_at);
  NEW.ceo_review_remarks := coalesce(NEW.ceo_review_remarks, NEW.ceo_comments);

  IF coalesce(NEW.group_disha_review_status, '') = '' THEN
    NEW.group_disha_review_status := CASE
      WHEN coalesce(NEW.group_disha_approval_status, '') <> '' THEN NEW.group_disha_approval_status
      ELSE 'Pending Group Review'
    END;
  END IF;

  IF coalesce(NEW.ceo_review_status, '') = '' AND NEW.group_disha_review_status = 'Approved' THEN
    NEW.ceo_review_status := CASE
      WHEN coalesce(NEW.ceo_approval_status, '') <> '' THEN NEW.ceo_approval_status
      ELSE 'Pending CEO Approval'
    END;
  ELSIF NEW.group_disha_review_status <> 'Approved' AND NEW.ceo_review_status NOT IN ('Rejected', 'Resubmitted') THEN
    NEW.ceo_review_status := NULL;
  END IF;

  NEW.group_disha_approval_status := CASE
    WHEN NEW.group_disha_review_status IN ('Pending Group Review', 'Resubmitted for Group Review') THEN 'Pending'
    WHEN NEW.group_disha_review_status = 'Approved' THEN 'Approved'
    WHEN NEW.group_disha_review_status = 'Rejected by Group DISHA' THEN 'Rejected'
    ELSE NEW.group_disha_approval_status
  END;
  NEW.group_disha_approval_remarks := NEW.group_disha_review_remarks;
  NEW.group_disha_comments := NEW.group_disha_review_remarks;
  NEW.group_disha_approved_by := NEW.group_disha_reviewed_by;
  NEW.group_disha_approved_at := NEW.group_disha_review_date;

  NEW.ceo_approval_status := CASE
    WHEN NEW.ceo_review_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') THEN 'Pending'
    WHEN NEW.ceo_review_status = 'Approved' THEN 'Approved'
    WHEN NEW.ceo_review_status = 'Rejected by CEO' THEN 'Rejected'
    ELSE NEW.ceo_approval_status
  END;
  NEW.ceo_comments := NEW.ceo_review_remarks;
  NEW.ceo_approved_by := NEW.ceo_reviewed_by;
  NEW.ceo_approved_at := NEW.ceo_review_date;
  NEW.ceo_approval_required := NEW.group_disha_review_status = 'Approved' OR NEW.ceo_review_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval', 'Approved', 'Rejected by CEO');

  IF NEW.ceo_review_status = 'Approved' THEN
    NEW.expense_approval_status := 'CEO Approved';
    NEW.expense_approver_role := 'CEO';
    NEW.approval_level := 'Completed';
  ELSIF NEW.ceo_review_status = 'Rejected by CEO' THEN
    NEW.expense_approval_status := 'CEO Rejected';
    NEW.expense_approver_role := 'CEO';
    NEW.approval_level := 'CEO Review';
  ELSIF NEW.ceo_review_status = 'Resubmitted for CEO Approval' THEN
    NEW.expense_approval_status := 'Resubmitted for CEO Approval';
    NEW.expense_approver_role := 'CEO';
    NEW.approval_level := 'CEO Review';
  ELSIF NEW.group_disha_review_status = 'Approved' THEN
    NEW.expense_approval_status := 'Pending CEO Approval';
    NEW.expense_approver_role := 'CEO';
    NEW.approval_level := 'CEO Review';
  ELSIF NEW.group_disha_review_status = 'Rejected by Group DISHA' THEN
    NEW.expense_approval_status := 'Rejected by Group DISHA';
    NEW.expense_approver_role := 'Group Disha HSC PIC';
    NEW.approval_level := 'Group Review';
  ELSIF NEW.group_disha_review_status = 'Resubmitted for Group Review' THEN
    NEW.expense_approval_status := 'Resubmitted for Group DISHA Review';
    NEW.expense_approver_role := 'Group Disha HSC PIC';
    NEW.approval_level := 'Group Review';
  ELSE
    NEW.expense_approval_status := 'Pending Group DISHA Review';
    NEW.expense_approver_role := 'Group Disha HSC PIC';
    NEW.approval_level := 'Group Review';
  END IF;

  RETURN NEW;
END;
$$;

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
    ceo_approved_at = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_approved_at END,
    ceo_comments = CASE WHEN v_next_ceo_status IN ('Pending CEO Approval', 'Resubmitted for CEO Approval') OR v_next_ceo_status IS NULL THEN NULL ELSE ceo_comments END,
    expense_approval_required = v_requires_monetary_support,
    expense_approver_role = v_next_approver_role,
    expense_approval_status = v_next_expense_status,
    approval_level = v_next_approval_level,
    submitted_for_review_at = CASE
      WHEN coalesce(v_normalized_status, action_status, status) = 'Submitted for Review' THEN coalesce(submitted_for_review_at, now())
      ELSE submitted_for_review_at
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
      WHEN coalesce(v_normalized_status, status) IN ('Submitted for Review', 'Closed', 'Completed') THEN now()
      ELSE completed_at
    END,
    completed_by = CASE
      WHEN coalesce(v_normalized_status, status) IN ('Submitted for Review', 'Closed', 'Completed') THEN p_user_id
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
      group_disha_review_date = now(),
      group_disha_review_remarks = nullif(btrim(coalesce(p_comments, '')), ''),
      group_disha_approval_status = normalized_decision,
      group_disha_approved_by = p_user_id,
      group_disha_approved_at = now(),
      group_disha_approval_remarks = nullif(btrim(coalesce(p_comments, '')), ''),
      group_disha_comments = nullif(btrim(coalesce(p_comments, '')), ''),
      ceo_approval_required = normalized_decision = 'Approved',
      ceo_review_status = CASE WHEN normalized_decision = 'Approved' THEN 'Pending CEO Approval' ELSE NULL END,
      ceo_reviewed_by = NULL,
      ceo_review_date = NULL,
      ceo_review_remarks = NULL,
      ceo_approval_status = CASE WHEN normalized_decision = 'Approved' THEN 'Pending' ELSE NULL END,
      ceo_approved_by = NULL,
      ceo_approved_at = NULL,
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
      updated_at = now()
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
      ceo_review_date = now(),
      ceo_review_remarks = nullif(btrim(coalesce(p_comments, '')), ''),
      ceo_approval_status = normalized_decision,
      ceo_approved_by = p_user_id,
      ceo_approved_at = now(),
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
      updated_at = now()
    WHERE id = p_response_id
    RETURNING * INTO next_row;
  END IF;

  RETURN next_row;
END;
$$;

GRANT EXECUTE ON FUNCTION public.approve_expense_request(uuid, uuid, text, text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.submit_disha_action_update(uuid, uuid, text, text, text, jsonb, text, text, jsonb, date, boolean, uuid, text, text, text, text, text, text, boolean, numeric, text, text, date, text, boolean, jsonb) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
