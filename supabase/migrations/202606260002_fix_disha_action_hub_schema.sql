BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS pic_for_ng text,
  ADD COLUMN IF NOT EXISTS tentative_closing_date date,
  ADD COLUMN IF NOT EXISTS evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS dq_question_num text,
  ADD COLUMN IF NOT EXISTS sub_question_num text,
  ADD COLUMN IF NOT EXISTS sub_question_text text,
  ADD COLUMN IF NOT EXISTS current_condition_observed text,
  ADD COLUMN IF NOT EXISTS audit_location text,
  ADD COLUMN IF NOT EXISTS audit_department text,
  ADD COLUMN IF NOT EXISTS pic_for_ng_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS pic_for_ng_name text,
  ADD COLUMN IF NOT EXISTS pic_for_ng_mobile text,
  ADD COLUMN IF NOT EXISTS status text,
  ADD COLUMN IF NOT EXISTS action_status text,
  ADD COLUMN IF NOT EXISTS assigned_pic_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS submitted_for_review_at timestamptz,
  ADD COLUMN IF NOT EXISTS closure_status text,
  ADD COLUMN IF NOT EXISTS verification_status text,
  ADD COLUMN IF NOT EXISTS root_cause text,
  ADD COLUMN IF NOT EXISTS corrective_action_plan text,
  ADD COLUMN IF NOT EXISTS preventive_action_plan text,
  ADD COLUMN IF NOT EXISTS action_taken text,
  ADD COLUMN IF NOT EXISTS closure_remarks text,
  ADD COLUMN IF NOT EXISTS closure_evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS actual_closure_date date,
  ADD COLUMN IF NOT EXISTS completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS completed_by uuid REFERENCES app_users(id),
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
  ADD COLUMN IF NOT EXISTS review_comments text,
  ADD COLUMN IF NOT EXISTS monetary_support_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS expected_expense_amount numeric,
  ADD COLUMN IF NOT EXISTS expense_purpose text,
  ADD COLUMN IF NOT EXISTS expense_category text,
  ADD COLUMN IF NOT EXISTS expense_approval_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS expense_approver_role text,
  ADD COLUMN IF NOT EXISTS expense_approval_status text NOT NULL DEFAULT 'Not Required',
  ADD COLUMN IF NOT EXISTS ceo_approval_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS ceo_approval_status text,
  ADD COLUMN IF NOT EXISTS ceo_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS ceo_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS ceo_comments text,
  ADD COLUMN IF NOT EXISTS functional_hod_approval_status text,
  ADD COLUMN IF NOT EXISTS functional_hod_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS functional_hod_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS functional_hod_approval_remarks text,
  ADD COLUMN IF NOT EXISTS group_disha_approval_status text,
  ADD COLUMN IF NOT EXISTS group_disha_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS group_disha_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_approval_remarks text,
  ADD COLUMN IF NOT EXISTS group_hod_approval_status text,
  ADD COLUMN IF NOT EXISTS hod_approval_status text,
  ADD COLUMN IF NOT EXISTS quotation_files jsonb NOT NULL DEFAULT '[]'::jsonb;

UPDATE audit_responses
SET
  action_status = coalesce(action_status, status, CASE WHEN result = 'NG' THEN 'Open' ELSE NULL END),
  assigned_pic_user_id = coalesce(assigned_pic_user_id, pic_for_ng_user_id),
  submitted_for_review_at = CASE
    WHEN submitted_for_review_at IS NULL AND coalesce(action_status, status) = 'Submitted for Review' THEN coalesce(completed_at, updated_at, now())
    ELSE submitted_for_review_at
  END,
  closure_status = coalesce(closure_status, CASE
    WHEN coalesce(action_status, status) IN ('Closed', 'Completed') THEN 'Closed'
    WHEN coalesce(action_status, status) = 'Submitted for Review' THEN 'Submitted'
    ELSE 'Open'
  END),
  verification_status = coalesce(verification_status, CASE
    WHEN coalesce(action_status, status) IN ('Closed', 'Completed') THEN 'Verified'
    WHEN coalesce(action_status, status) = 'Submitted for Review' THEN 'Pending'
    ELSE 'Not Started'
  END),
  expense_approval_required = CASE WHEN monetary_support_required THEN true ELSE false END,
  expense_approver_role = CASE WHEN monetary_support_required THEN 'CEO' ELSE NULL END,
  expense_approval_status = CASE
    WHEN monetary_support_required AND coalesce(expense_approval_status, '') IN ('', 'Not Required', 'Pending Approval') THEN 'Pending CEO Approval'
    WHEN NOT monetary_support_required THEN 'Not Required'
    ELSE expense_approval_status
  END,
  ceo_approval_required = CASE WHEN monetary_support_required THEN true ELSE false END,
  ceo_approval_status = CASE
    WHEN monetary_support_required AND coalesce(ceo_approval_status, '') = '' THEN 'Pending'
    WHEN NOT monetary_support_required THEN NULL
    ELSE ceo_approval_status
  END
WHERE
  action_status IS NULL
  OR assigned_pic_user_id IS DISTINCT FROM coalesce(assigned_pic_user_id, pic_for_ng_user_id)
  OR closure_status IS NULL
  OR verification_status IS NULL
  OR coalesce(expense_approval_required, false) IS DISTINCT FROM monetary_support_required
  OR coalesce(expense_approver_role, '') IS DISTINCT FROM CASE WHEN monetary_support_required THEN 'CEO' ELSE '' END
  OR (monetary_support_required AND coalesce(expense_approval_status, '') IN ('', 'Not Required', 'Pending Approval'))
  OR (NOT monetary_support_required AND expense_approval_status <> 'Not Required')
  OR coalesce(ceo_approval_required, false) IS DISTINCT FROM monetary_support_required
  OR (monetary_support_required AND coalesce(ceo_approval_status, '') = '')
  OR (NOT monetary_support_required AND ceo_approval_status IS NOT NULL);

INSERT INTO storage.buckets (id, name, public)
VALUES ('quotation-files', 'quotation-files', true)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'quotation files public read'
  ) THEN
    CREATE POLICY "quotation files public read"
      ON storage.objects
      FOR SELECT
      TO public
      USING (bucket_id = 'quotation-files');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'quotation files public upload'
  ) THEN
    CREATE POLICY "quotation files public upload"
      ON storage.objects
      FOR INSERT
      TO public
      WITH CHECK (bucket_id = 'quotation-files');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'quotation files public delete'
  ) THEN
    CREATE POLICY "quotation files public delete"
      ON storage.objects
      FOR DELETE
      TO public
      USING (bucket_id = 'quotation-files');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'quotation files public update'
  ) THEN
    CREATE POLICY "quotation files public update"
      ON storage.objects
      FOR UPDATE
      TO public
      USING (bucket_id = 'quotation-files')
      WITH CHECK (bucket_id = 'quotation-files');
  END IF;
END
$$;

DROP FUNCTION IF EXISTS public.submit_disha_action_update(
  uuid, uuid, text, text, text, jsonb, text, text, jsonb, date,
  boolean, uuid, text, text, text, text, text, text,
  boolean, numeric, text, text, date, text, boolean
);

DROP FUNCTION IF EXISTS public.submit_disha_action_update(
  uuid, uuid, text, text, text, jsonb, text, text, jsonb, date,
  boolean, uuid, text, text, text, text, text, text,
  boolean, numeric, text, text, date, text, boolean, jsonb
);

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
    expense_approval_required = v_requires_monetary_support,
    expense_approver_role = CASE WHEN v_requires_monetary_support THEN 'CEO' ELSE NULL END,
    expense_approval_status = CASE
      WHEN v_requires_monetary_support THEN 'Pending CEO Approval'
      ELSE 'Not Required'
    END,
    ceo_approval_required = CASE
      WHEN v_requires_monetary_support THEN true
      ELSE false
    END,
    ceo_approval_status = CASE
      WHEN v_requires_monetary_support THEN 'Pending'
      ELSE NULL
    END,
    ceo_approved_by = NULL,
    ceo_approved_at = NULL,
    ceo_comments = NULL,
    submitted_for_review_at = CASE
      WHEN coalesce(v_normalized_status, action_status, status) = 'Submitted for Review' THEN coalesce(submitted_for_review_at, now())
      ELSE submitted_for_review_at
    END,
    closure_status = CASE
      WHEN coalesce(v_normalized_status, action_status, status) IN ('Closed', 'Completed') THEN 'Closed'
      WHEN coalesce(v_normalized_status, action_status, status) = 'Submitted for Review' THEN 'Submitted'
      ELSE coalesce(closure_status, 'Open')
    END,
    verification_status = CASE
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
    'status', coalesce(v_normalized_status, v_row.status)
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
BEGIN
  IF p_decision NOT IN ('Approved', 'Rejected') THEN
    RAISE EXCEPTION 'Invalid expense approval decision.';
  END IF;

  IF p_decision = 'Rejected' AND nullif(btrim(coalesce(p_comments, '')), '') IS NULL THEN
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

  IF NOT coalesce(response_row.expense_approval_required, false) THEN
    RAISE EXCEPTION 'Expense approval is not required for this action.';
  END IF;

  normalized_role := lower(coalesce(p_role, ''));

  SELECT EXISTS (
    SELECT 1
    FROM user_access_mappings uam
    WHERE uam.user_id = p_user_id
      AND coalesce(uam.active, true) = true
      AND (
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'ceo')
        OR lower(coalesce(uam.user_type, '')) IN ('admin', 'super admin', 'system admin', 'system administrator', 'ceo')
        OR lower(coalesce(uam.role, '')) LIKE '%ceo%'
        OR lower(coalesce(uam.user_type, '')) LIKE '%ceo%'
      )
  ) INTO requester_can_approve;

  IF NOT requester_can_approve THEN
    RAISE EXCEPTION 'Only CEO or System Admin can approve monetary requests.';
  END IF;

  IF normalized_role NOT LIKE '%ceo%' AND normalized_role NOT LIKE '%admin%' AND normalized_role NOT LIKE '%system%' AND normalized_role NOT LIKE '%super admin%' THEN
    RAISE EXCEPTION 'Only CEO or System Admin can approve monetary requests.';
  END IF;

  UPDATE audit_responses
  SET
    expense_approver_role = 'CEO',
    expense_approval_required = true,
    expense_approval_status = CASE
      WHEN p_decision = 'Approved' THEN 'Approved'
      ELSE 'Rejected'
    END,
    ceo_approval_required = true,
    ceo_approval_status = CASE
      WHEN p_decision = 'Approved' THEN 'Approved'
      ELSE 'Rejected'
    END,
    ceo_approved_by = p_user_id,
    ceo_approved_at = now(),
    ceo_comments = nullif(btrim(coalesce(p_comments, '')), ''),
    closure_status = CASE WHEN p_decision = 'Approved' THEN coalesce(closure_status, 'Submitted') ELSE closure_status END,
    updated_at = now()
  WHERE id = p_response_id
  RETURNING * INTO next_row;

  RETURN next_row;
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_disha_action_update(
  uuid, uuid, text, text, text, jsonb, text, text, jsonb, date,
  boolean, uuid, text, text, text, text, text, text,
  boolean, numeric, text, text, date, text, boolean, jsonb
) TO anon, authenticated;

GRANT EXECUTE ON FUNCTION public.review_disha_action(uuid, uuid, text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.approve_expense_request(uuid, uuid, text, text, text) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
