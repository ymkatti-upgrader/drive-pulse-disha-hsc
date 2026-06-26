BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS quotation_files jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS group_disha_approval_status text,
  ADD COLUMN IF NOT EXISTS group_disha_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS group_disha_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS group_disha_approval_remarks text,
  ADD COLUMN IF NOT EXISTS functional_hod_approval_status text,
  ADD COLUMN IF NOT EXISTS functional_hod_approved_by uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS functional_hod_approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS functional_hod_approval_remarks text,
  ADD COLUMN IF NOT EXISTS group_hod_approval_status text,
  ADD COLUMN IF NOT EXISTS hod_approval_status text;

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
  v_user app_users%ROWTYPE;
  v_is_admin boolean := false;
  v_requires_expense_approval boolean := false;
  v_requires_ceo_approval boolean := false;
BEGIN
  SELECT * INTO v_row
  FROM audit_responses
  WHERE id = p_response_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NG action not found';
  END IF;

  IF v_row.result <> 'NG' THEN
    RAISE EXCEPTION 'Only NG responses can be updated through Disha Action Hub';
  END IF;

  SELECT * INTO v_user
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
      AND uam.active = true
      AND (
        uam.user_type ILIKE '%System Admin%'
        OR uam.role ILIKE '%Super Admin%'
        OR uam.role ILIKE '%System Admin%'
      )
  ) INTO v_is_admin;

  IF NOT (
    v_row.pic_for_ng_user_id = p_user_id
    OR v_is_admin
    OR v_row.collaborator_user_id = p_user_id
  ) THEN
    RAISE EXCEPTION 'You are not allowed to update this NG action';
  END IF;

  v_requires_expense_approval := COALESCE(p_monetary_support_required, false);
  v_requires_ceo_approval := v_requires_expense_approval;

  IF v_requires_expense_approval THEN
    IF nullif(btrim(coalesce(p_expense_purpose, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Expense Purpose missing.';
    END IF;
    IF nullif(btrim(coalesce(p_expense_category, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Expense Category missing.';
    END IF;
  END IF;

  UPDATE audit_responses
  SET
    status = COALESCE(p_status, status),
    cause_category = p_cause_category,
    root_cause = p_root_cause,
    action_plan_items = COALESCE(p_action_plan_items, '[]'::jsonb),
    action_taken = p_action_taken,
    closure_remarks = p_closure_remarks,
    closure_evidence_files = COALESCE(p_closure_evidence_files, '[]'::jsonb),
    actual_closure_date = p_actual_closure_date,
    collaboration_required = COALESCE(p_collaboration_required, false),
    collaborator_user_id = p_collaborator_user_id,
    collaborator_name = p_collaborator_name,
    collaborator_mobile = p_collaborator_mobile,
    support_department = p_support_department,
    support_required = p_support_required,
    support_remarks = p_support_remarks,
    support_status = p_support_status,
    monetary_support_required = COALESCE(p_monetary_support_required, false),
    expected_expense_amount = CASE
      WHEN v_requires_expense_approval AND p_expected_expense_amount IS NOT NULL AND p_expected_expense_amount >= 0 THEN p_expected_expense_amount
      ELSE NULL
    END,
    expense_category = CASE WHEN v_requires_expense_approval THEN p_expense_category ELSE NULL END,
    expense_purpose = CASE WHEN v_requires_expense_approval THEN p_expense_purpose ELSE NULL END,
    expense_approval_status = CASE WHEN v_requires_expense_approval THEN 'Pending Approval' ELSE 'Not Required' END,
    group_disha_approval_status = CASE WHEN v_requires_expense_approval THEN 'Pending' ELSE NULL END,
    functional_hod_approval_status = CASE WHEN v_requires_expense_approval THEN 'Pending' ELSE NULL END,
    ceo_approval_required = v_requires_ceo_approval,
    ceo_approval_status = CASE WHEN v_requires_ceo_approval THEN 'Pending' ELSE NULL END,
    extension_requested_date = p_extension_requested_date,
    extension_reason = p_extension_reason,
    quotation_files = COALESCE(p_quotation_files, '[]'::jsonb),
    completed_at = CASE
      WHEN p_status IN ('Submitted for Review', 'Closed', 'Completed') THEN now()
      ELSE completed_at
    END,
    completed_by = CASE
      WHEN p_status IN ('Submitted for Review', 'Closed', 'Completed') THEN p_user_id
      ELSE completed_by
    END,
    updated_at = now()
  WHERE id = p_response_id;

  RETURN jsonb_build_object(
    'success', true,
    'response_id', p_response_id,
    'status', p_status
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_disha_action_update(
  uuid, uuid, text, text, text, jsonb, text, text, jsonb, date,
  boolean, uuid, text, text, text, text, text, text,
  boolean, numeric, text, text, date, text, boolean, jsonb
) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
