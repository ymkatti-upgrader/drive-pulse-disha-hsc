BEGIN;

CREATE OR REPLACE VIEW public.audit_response_lifecycle_analytics AS
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
INNER JOIN audits a ON a.id = ar.audit_uuid
LEFT JOIN locations l ON l.id = a.location_id
LEFT JOIN departments d ON d.id = a.department_id
LEFT JOIN app_users pic ON pic.id = ar.pic_for_ng_user_id
LEFT JOIN app_users assignee ON assignee.id = ar.assigned_pic_user_id
WHERE ar.result = 'NG'
  AND coalesce(ar.is_void, false) = false
  AND ar.audit_uuid IS NOT NULL
  AND coalesce(a.status, '') <> 'Draft';

GRANT SELECT ON public.audit_response_lifecycle_analytics TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
