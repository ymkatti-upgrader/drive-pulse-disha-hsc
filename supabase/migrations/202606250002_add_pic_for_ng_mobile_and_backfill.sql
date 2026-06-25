-- Add PIC mobile for assigned NG lookup and backfill safe exact matches
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS pic_for_ng_mobile text;

WITH name_matches AS (
  SELECT
    ar.id AS response_id,
    u.id AS user_id,
    u.mobile_no,
    count(*) OVER (PARTITION BY ar.id) AS match_count
  FROM audit_responses ar
  JOIN app_users u
    ON btrim(u.employee_name) = btrim(ar.pic_for_ng_name)
  WHERE ar.pic_for_ng_user_id IS NULL
    AND ar.pic_for_ng_mobile IS NULL
    AND ar.pic_for_ng_name IS NOT NULL
    AND btrim(ar.pic_for_ng_name) <> ''
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
