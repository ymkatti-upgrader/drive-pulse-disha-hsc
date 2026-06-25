-- Ensure audit response NG assignments have stable lookup and active status fields
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS pic_for_ng_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS pic_for_ng_name text,
  ADD COLUMN IF NOT EXISTS pic_for_ng_mobile text,
  ADD COLUMN IF NOT EXISTS status text;

UPDATE audit_responses
SET status = 'Open'
WHERE result = 'NG'
  AND status IS NULL;

WITH name_matches AS (
  SELECT
    ar.id AS response_id,
    u.id AS user_id,
    u.mobile_no,
    count(*) OVER (PARTITION BY ar.id) AS match_count
  FROM audit_responses ar
  JOIN app_users u
    ON btrim(u.employee_name) = btrim(coalesce(ar.pic_for_ng_name, ar.pic_for_ng))
  WHERE ar.pic_for_ng_user_id IS NULL
    AND ar.pic_for_ng_mobile IS NULL
    AND nullif(btrim(coalesce(ar.pic_for_ng_name, ar.pic_for_ng)), '') IS NOT NULL
),
unique_matches AS (
  SELECT DISTINCT response_id, user_id, mobile_no
  FROM name_matches
  WHERE match_count = 1
)
UPDATE audit_responses ar
SET
  pic_for_ng_user_id = um.user_id,
  pic_for_ng_mobile = um.mobile_no
FROM unique_matches um
WHERE ar.id = um.response_id;

COMMIT;
