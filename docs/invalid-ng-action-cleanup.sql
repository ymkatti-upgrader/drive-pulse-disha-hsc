SELECT
  ar.id,
  ar.audit_id,
  ar.sub_question_text AS question_text,
  ar.dq_question_num AS evaluation_item,
  a.location_id,
  a.department_id,
  ar.assigned_pic_user_id,
  ar.action_status,
  ar.created_at
FROM audit_responses ar
LEFT JOIN audits a
  ON a.id::text = ar.audit_id
WHERE coalesce(ar.is_void, false) = false
  AND (
    lower(btrim(coalesce(ar.result::text, ''))) = 'ng'
    OR nullif(btrim(coalesce(ar.action_status, '')), '') IS NOT NULL
    OR nullif(btrim(coalesce(ar.status, '')), '') IS NOT NULL
  )
  AND nullif(btrim(coalesce(ar.sub_question_text, '')), '') IS NULL
  AND nullif(btrim(coalesce(ar.dq_question_num, '')), '') IS NULL
  AND a.location_id IS NULL
  AND a.department_id IS NULL
  AND ar.assigned_pic_user_id IS NULL
  AND nullif(btrim(coalesce(ar.audit_id, '')), '') IS NULL
ORDER BY ar.created_at DESC;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS is_void boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS void_reason text,
  ADD COLUMN IF NOT EXISTS voided_at timestamptz,
  ADD COLUMN IF NOT EXISTS assigned_pic_user_id uuid,
  ADD COLUMN IF NOT EXISTS action_status text;

UPDATE audit_responses
SET assigned_pic_user_id = pic_for_ng_user_id
WHERE assigned_pic_user_id IS NULL
  AND pic_for_ng_user_id IS NOT NULL;

UPDATE audit_responses
SET action_status = 'Assigned'
WHERE action_status IS NULL
  AND is_void IS NOT TRUE
  AND (
    assigned_pic_user_id IS NOT NULL
    OR pic_for_ng_user_id IS NOT NULL
    OR nullif(btrim(coalesce(pic_for_ng_mobile, '')), '') IS NOT NULL
  );

WITH invalid_rows AS (
  SELECT ar.id
  FROM audit_responses ar
  LEFT JOIN audits a
    ON a.id::text = ar.audit_id
  WHERE coalesce(ar.is_void, false) = false
    AND (
      lower(btrim(coalesce(ar.result::text, ''))) = 'ng'
      OR nullif(btrim(coalesce(ar.action_status, '')), '') IS NOT NULL
      OR nullif(btrim(coalesce(ar.status, '')), '') IS NOT NULL
    )
    AND nullif(btrim(coalesce(ar.sub_question_text, '')), '') IS NULL
    AND nullif(btrim(coalesce(ar.dq_question_num, '')), '') IS NULL
    AND a.location_id IS NULL
    AND a.department_id IS NULL
    AND ar.assigned_pic_user_id IS NULL
    AND nullif(btrim(coalesce(ar.audit_id, '')), '') IS NULL
)
UPDATE audit_responses ar
SET
  is_void = true,
  void_reason = 'Invalid blank NG action row - missing question/location/department',
  voided_at = now()
FROM invalid_rows ir
WHERE ar.id = ir.id;
