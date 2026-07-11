BEGIN;

CREATE OR REPLACE FUNCTION public.upsert_audit_responses(p_rows jsonb)
RETURNS SETOF audit_responses
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  WITH incoming AS (
    SELECT *
    FROM jsonb_to_recordset(COALESCE(p_rows, '[]'::jsonb)) AS rows(
      audit_id text,
      audit_uuid uuid,
      checklist_id uuid,
      dq_question_num text,
      sub_question_num text,
      sub_question_text text,
      result text,
      current_condition_observed text,
      observation text,
      comments text,
      audit_location text,
      audit_department text,
      responded_by uuid,
      pic_for_ng_user_id uuid,
      assigned_pic_user_id uuid,
      pic_for_ng_name text,
      pic_for_ng_mobile text,
      pic_for_ng text,
      status text,
      action_status text,
      closure_status text,
      verification_status text,
      is_void boolean,
      tentative_closing_date date,
      evidence_files jsonb,
      root_cause text,
      corrective_action_plan text,
      preventive_action_plan text,
      action_taken text,
      closure_remarks text,
      closure_evidence_files jsonb,
      actual_closure_date date
    )
  )
  INSERT INTO audit_responses (
    audit_id,
    audit_uuid,
    checklist_id,
    dq_question_num,
    sub_question_num,
    sub_question_text,
    result,
    current_condition_observed,
    observation,
    comments,
    audit_location,
    audit_department,
    responded_by,
    pic_for_ng_user_id,
    assigned_pic_user_id,
    pic_for_ng_name,
    pic_for_ng_mobile,
    pic_for_ng,
    status,
    action_status,
    closure_status,
    verification_status,
    is_void,
    tentative_closing_date,
    evidence_files,
    root_cause,
    corrective_action_plan,
    preventive_action_plan,
    action_taken,
    closure_remarks,
    closure_evidence_files,
    actual_closure_date
  )
  SELECT
    audit_id,
    audit_uuid,
    checklist_id,
    dq_question_num,
    sub_question_num,
    sub_question_text,
    NULLIF(BTRIM(result), '')::public.audit_result,
    current_condition_observed,
    observation,
    comments,
    audit_location,
    audit_department,
    responded_by,
    pic_for_ng_user_id,
    assigned_pic_user_id,
    pic_for_ng_name,
    pic_for_ng_mobile,
    pic_for_ng,
    status,
    action_status,
    closure_status,
    verification_status,
    COALESCE(is_void, false),
    tentative_closing_date,
    COALESCE(evidence_files, '[]'::jsonb),
    root_cause,
    corrective_action_plan,
    preventive_action_plan,
    action_taken,
    closure_remarks,
    COALESCE(closure_evidence_files, '[]'::jsonb),
    actual_closure_date
  FROM incoming
  ON CONFLICT (audit_id, checklist_id)
  DO UPDATE SET
    audit_uuid = EXCLUDED.audit_uuid,
    dq_question_num = EXCLUDED.dq_question_num,
    sub_question_num = EXCLUDED.sub_question_num,
    sub_question_text = EXCLUDED.sub_question_text,
    result = EXCLUDED.result,
    current_condition_observed = EXCLUDED.current_condition_observed,
    observation = EXCLUDED.observation,
    comments = EXCLUDED.comments,
    audit_location = EXCLUDED.audit_location,
    audit_department = EXCLUDED.audit_department,
    responded_by = EXCLUDED.responded_by,
    pic_for_ng_user_id = EXCLUDED.pic_for_ng_user_id,
    assigned_pic_user_id = EXCLUDED.assigned_pic_user_id,
    pic_for_ng_name = EXCLUDED.pic_for_ng_name,
    pic_for_ng_mobile = EXCLUDED.pic_for_ng_mobile,
    pic_for_ng = EXCLUDED.pic_for_ng,
    status = EXCLUDED.status,
    action_status = EXCLUDED.action_status,
    closure_status = EXCLUDED.closure_status,
    verification_status = EXCLUDED.verification_status,
    is_void = EXCLUDED.is_void,
    tentative_closing_date = EXCLUDED.tentative_closing_date,
    evidence_files = EXCLUDED.evidence_files,
    root_cause = EXCLUDED.root_cause,
    corrective_action_plan = EXCLUDED.corrective_action_plan,
    preventive_action_plan = EXCLUDED.preventive_action_plan,
    action_taken = EXCLUDED.action_taken,
    closure_remarks = EXCLUDED.closure_remarks,
    closure_evidence_files = EXCLUDED.closure_evidence_files,
    actual_closure_date = EXCLUDED.actual_closure_date,
    updated_at = now()
  RETURNING audit_responses.*;
END;
$$;

REVOKE ALL ON FUNCTION public.upsert_audit_responses(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.upsert_audit_responses(jsonb) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
