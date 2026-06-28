BEGIN;

CREATE OR REPLACE FUNCTION public.normalize_expense_approval_flow()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF COALESCE(NEW.monetary_support_required, false) = false THEN
    NEW.expense_approval_required := false;
    NEW.expense_approver_role := NULL;
    NEW.expense_approval_status := 'Not Required';
    NEW.group_disha_approval_status := NULL;
    NEW.group_disha_approved_by := NULL;
    NEW.group_disha_approved_at := NULL;
    NEW.group_disha_comments := NULL;
    NEW.ceo_approval_required := false;
    NEW.ceo_approval_status := NULL;
    NEW.ceo_approved_by := NULL;
    NEW.ceo_approved_at := NULL;
    NEW.ceo_comments := NULL;
    RETURN NEW;
  END IF;

  NEW.expense_approval_required := true;
  NEW.ceo_approval_required := NEW.group_disha_approval_status = 'Approved';

  IF NEW.group_disha_approval_status = 'Rejected' OR NEW.ceo_approval_status = 'Rejected' THEN
    NEW.expense_approval_status := 'Rejected';
    NEW.expense_approver_role := COALESCE(NEW.expense_approver_role, 'Group Disha HSC PIC');
  ELSIF NEW.ceo_approval_status = 'Approved' THEN
    NEW.expense_approval_status := 'Approved';
    NEW.expense_approver_role := 'CEO';
  ELSIF NEW.group_disha_approval_status = 'Approved' THEN
    NEW.expense_approval_status := 'Pending CEO Approval';
    NEW.expense_approver_role := 'CEO';
  ELSE
    NEW.expense_approval_status := 'Pending Group Disha HSC PIC Approval';
    NEW.expense_approver_role := 'Group Disha HSC PIC';
  END IF;

  IF NEW.group_disha_approval_status IS DISTINCT FROM 'Approved' AND NEW.group_disha_approval_status IS DISTINCT FROM 'Rejected' THEN
    NEW.ceo_approval_status := COALESCE(NEW.ceo_approval_status, 'Pending');
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_normalize_expense_approval_flow ON audit_responses;
CREATE TRIGGER trg_normalize_expense_approval_flow
BEFORE INSERT OR UPDATE ON audit_responses
FOR EACH ROW
EXECUTE FUNCTION public.normalize_expense_approval_flow();

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

  IF COALESCE(response_row.group_disha_approval_status, '') = 'Rejected'
     OR COALESCE(response_row.ceo_approval_status, '') = 'Rejected'
     OR COALESCE(response_row.expense_approval_status, '') = 'Rejected' THEN
    RAISE EXCEPTION 'This expense request has already been rejected.';
  END IF;

  IF COALESCE(response_row.ceo_approval_status, '') = 'Approved'
     OR COALESCE(response_row.expense_approval_status, '') = 'Approved' THEN
    RAISE EXCEPTION 'This expense request has already been approved.';
  END IF;

  stage := CASE
    WHEN COALESCE(response_row.group_disha_approval_status, '') = 'Approved' THEN 'ceo'
    ELSE 'group'
  END;

  IF stage = 'group' THEN
    IF normalized_role NOT LIKE '%group disha%' AND normalized_role NOT LIKE '%admin%' AND normalized_role NOT LIKE '%system%' THEN
      RAISE EXCEPTION 'Group Disha HSC PIC approval is required before CEO review.';
    END IF;

    UPDATE audit_responses
    SET
      expense_approval_required = true,
      expense_approver_role = CASE WHEN normalized_decision = 'Approved' THEN 'CEO' ELSE 'Group Disha HSC PIC' END,
      expense_approval_status = CASE
        WHEN normalized_decision = 'Approved' THEN 'Pending CEO Approval'
        ELSE 'Rejected'
      END,
      group_disha_approval_status = normalized_decision,
      group_disha_approved_by = p_user_id,
      group_disha_approved_at = now(),
      group_disha_comments = nullif(btrim(coalesce(p_comments, '')), ''),
      ceo_approval_required = normalized_decision = 'Approved',
      ceo_approval_status = CASE
        WHEN normalized_decision = 'Approved' THEN 'Pending'
        ELSE NULL
      END,
      ceo_approved_by = NULL,
      ceo_approved_at = NULL,
      ceo_comments = NULL,
      updated_at = now()
    WHERE id = p_response_id
    RETURNING * INTO next_row;
  ELSE
    IF normalized_role NOT LIKE '%ceo%' AND normalized_role NOT LIKE '%admin%' AND normalized_role NOT LIKE '%system%' THEN
      RAISE EXCEPTION 'CEO approval is required after Group Disha HSC PIC approval.';
    END IF;

    IF COALESCE(response_row.group_disha_approval_status, 'Pending') <> 'Approved' THEN
      RAISE EXCEPTION 'CEO approval can only be completed after Group Disha HSC PIC approval.';
    END IF;

    UPDATE audit_responses
    SET
      expense_approval_required = true,
      expense_approver_role = 'CEO',
      expense_approval_status = normalized_decision,
      ceo_approval_required = true,
      ceo_approval_status = normalized_decision,
      ceo_approved_by = p_user_id,
      ceo_approved_at = now(),
      ceo_comments = nullif(btrim(coalesce(p_comments, '')), ''),
      updated_at = now()
    WHERE id = p_response_id
    RETURNING * INTO next_row;
  END IF;

  RETURN next_row;
END;
$$;

GRANT EXECUTE ON FUNCTION public.approve_expense_request(uuid, uuid, text, text, text) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
