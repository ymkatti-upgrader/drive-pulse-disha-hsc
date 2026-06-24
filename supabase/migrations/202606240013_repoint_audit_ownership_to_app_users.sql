-- Repoint audit ownership to app_users so draft saves use the logged-in app user UUID
BEGIN;

ALTER TABLE audit_responses
  DROP CONSTRAINT IF EXISTS audit_responses_responded_by_fkey;

ALTER TABLE audit_responses
  ADD CONSTRAINT audit_responses_responded_by_fkey
  FOREIGN KEY (responded_by) REFERENCES app_users(id) NOT VALID;

ALTER TABLE audit_findings
  DROP CONSTRAINT IF EXISTS audit_findings_created_by_fkey;

ALTER TABLE audit_findings
  ADD CONSTRAINT audit_findings_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES app_users(id) NOT VALID;

COMMIT;
