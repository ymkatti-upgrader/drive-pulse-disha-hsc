-- Allow audit draft persistence for evaluation rows
BEGIN;

ALTER TABLE audit_responses
  ALTER COLUMN result DROP NOT NULL;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS pic_for_ng text,
  ADD COLUMN IF NOT EXISTS tentative_closing_date date,
  ADD COLUMN IF NOT EXISTS evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb;

COMMIT;
