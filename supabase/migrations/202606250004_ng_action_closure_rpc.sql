-- Add NG action closure fields and a narrow RPC for assigned PIC updates.
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS root_cause text,
  ADD COLUMN IF NOT EXISTS corrective_action_plan text,
  ADD COLUMN IF NOT EXISTS preventive_action_plan text,
  ADD COLUMN IF NOT EXISTS action_taken text,
  ADD COLUMN IF NOT EXISTS closure_remarks text,
  ADD COLUMN IF NOT EXISTS closure_evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS actual_closure_date date,
  ADD COLUMN IF NOT EXISTS completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS completed_by uuid REFERENCES app_users(id);

CREATE OR REPLACE FUNCTION submit_ng_action_closure(
  p_response_id uuid,
  p_user_id uuid,
  p_root_cause text,
  p_corrective_action_plan text,
  p_preventive_action_plan text,
  p_action_taken text,
  p_closure_remarks text,
  p_actual_closure_date date,
  p_status text,
  p_closure_evidence_files jsonb DEFAULT '[]'::jsonb
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
BEGIN
  normalized_status := CASE
    WHEN p_status IN ('Completed', 'Submitted for Review') THEN 'Completed'
    WHEN p_status = 'In Progress' THEN 'In Progress'
    WHEN p_status = 'Open' THEN 'Open'
    ELSE NULL
  END;

  IF normalized_status IS NULL THEN
    RAISE EXCEPTION 'Invalid NG action status.';
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
        lower(coalesce(uam.role, '')) IN ('admin', 'super admin', 'system administrator')
        OR lower(coalesce(uam.user_type, '')) = 'system admin'
      )
  ) INTO requester_is_admin;

  IF NOT requester_is_admin
     AND response_row.pic_for_ng_user_id IS DISTINCT FROM p_user_id
     AND coalesce(response_row.pic_for_ng_mobile, '') <> coalesce(requester_mobile, '') THEN
    RAISE EXCEPTION 'You can update only NG items assigned to you.';
  END IF;

  IF normalized_status = 'Completed' THEN
    IF nullif(btrim(coalesce(p_corrective_action_plan, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Corrective Action Plan is required before completion.';
    END IF;
    IF nullif(btrim(coalesce(p_action_taken, p_closure_remarks, '')), '') IS NULL THEN
      RAISE EXCEPTION 'Action Taken / Closure Remarks is required before completion.';
    END IF;
    IF p_actual_closure_date IS NULL THEN
      RAISE EXCEPTION 'Actual Closure Date is required before completion.';
    END IF;
  END IF;

  UPDATE audit_responses
  SET
    root_cause = nullif(btrim(coalesce(p_root_cause, '')), ''),
    corrective_action_plan = nullif(btrim(coalesce(p_corrective_action_plan, '')), ''),
    preventive_action_plan = nullif(btrim(coalesce(p_preventive_action_plan, '')), ''),
    action_taken = nullif(btrim(coalesce(p_action_taken, '')), ''),
    closure_remarks = nullif(btrim(coalesce(p_closure_remarks, '')), ''),
    closure_evidence_files = coalesce(p_closure_evidence_files, '[]'::jsonb),
    actual_closure_date = p_actual_closure_date,
    status = normalized_status,
    completed_at = CASE WHEN normalized_status = 'Completed' THEN now() ELSE completed_at END,
    completed_by = CASE WHEN normalized_status = 'Completed' THEN p_user_id ELSE completed_by END,
    updated_at = now()
  WHERE id = p_response_id
  RETURNING * INTO next_row;

  RETURN next_row;
END;
$$;

GRANT EXECUTE ON FUNCTION submit_ng_action_closure(uuid, uuid, text, text, text, text, text, date, text, jsonb) TO anon, authenticated;

COMMIT;
