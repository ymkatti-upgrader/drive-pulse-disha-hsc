-- Add optional evidence file storage for audit draft responses
BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS evidence_files jsonb NOT NULL DEFAULT '[]'::jsonb;

COMMIT;
