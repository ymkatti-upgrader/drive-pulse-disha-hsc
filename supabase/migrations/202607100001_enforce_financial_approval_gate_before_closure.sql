-- Bug 3 fix (SIT finding): review_disha_action allowed 'Approve Closure' on NG items
-- that required monetary/expense approval even when that approval chain had not
-- reached its terminal 'Completed' state (approval_level, set by
-- approve_expense_request in 202607040001). This let a financial NG be closed and
-- verified with its required Group DISHA + CEO sign-off never finished.
BEGIN;

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

  -- Financial approval gate: an NG item that required monetary/expense support
  -- cannot be closed/verified until its two-stage approval (Group DISHA, then
  -- CEO) has actually reached the terminal 'Completed' approval_level.
  IF p_decision = 'Approve Closure'
     AND coalesce(response_row.monetary_support_required, false) = true
     AND coalesce(response_row.approval_level, '') <> 'Completed' THEN
    RAISE EXCEPTION 'This item requires financial approval before it can be closed. Current approval stage: %', coalesce(response_row.approval_level, 'Not started');
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

GRANT EXECUTE ON FUNCTION public.review_disha_action(uuid, uuid, text, text) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
