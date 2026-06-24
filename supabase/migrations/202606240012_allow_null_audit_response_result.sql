-- Allow draft audit responses to save before a score/result is selected
BEGIN;

ALTER TABLE audit_responses
  ALTER COLUMN result DROP NOT NULL;

COMMIT;
