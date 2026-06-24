-- Ensure audit draft response columns exist for PIC and closing date
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS pic_for_ng text,
  ADD COLUMN IF NOT EXISTS tentative_closing_date date,
  ADD COLUMN IF NOT EXISTS evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb;

COMMIT;
