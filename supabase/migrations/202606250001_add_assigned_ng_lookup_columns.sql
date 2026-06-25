-- Add denormalized audit response columns for draft saving and PIC visibility
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS dq_question_num text,
  ADD COLUMN IF NOT EXISTS sub_question_num text,
  ADD COLUMN IF NOT EXISTS sub_question_text text,
  ADD COLUMN IF NOT EXISTS current_condition_observed text,
  ADD COLUMN IF NOT EXISTS audit_location text,
  ADD COLUMN IF NOT EXISTS audit_department text,
  ADD COLUMN IF NOT EXISTS pic_for_ng_user_id uuid REFERENCES app_users(id),
  ADD COLUMN IF NOT EXISTS pic_for_ng_name text;

COMMIT;
