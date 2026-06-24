BEGIN;

UPDATE audit_checklist_master
SET
  sub_question_num = COALESCE(
    sub_question_num,
    NULLIF(substring(version FROM 'v[0-9]+-[A-Z0-9]+-([0-9]{3})'), '')::integer
  ),
  dq_question_num = COALESCE(dq_question_num, checklist_code)
WHERE status = 'active'
  AND (
    sub_question_num IS NULL
    OR dq_question_num IS NULL
  );

COMMIT;
