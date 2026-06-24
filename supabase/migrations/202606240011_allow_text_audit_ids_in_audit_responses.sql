-- Allow local audit IDs such as AUD-... in audit_responses draft saves
BEGIN;

ALTER TABLE audit_responses
  DROP CONSTRAINT IF EXISTS audit_responses_audit_id_fkey;

DROP POLICY IF EXISTS "response visibility follows audit" ON audit_responses;
DROP POLICY IF EXISTS "assigned auditor writes responses" ON audit_responses;
DROP POLICY IF EXISTS "assigned auditor updates responses before submission" ON audit_responses;

ALTER TABLE audit_responses
  ALTER COLUMN audit_id TYPE text USING audit_id::text;

CREATE POLICY "audit response drafts are readable" ON audit_responses
  FOR SELECT USING (true);

CREATE POLICY "audit response drafts are insertable" ON audit_responses
  FOR INSERT WITH CHECK (true);

CREATE POLICY "audit response drafts are updatable" ON audit_responses
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE OR REPLACE FUNCTION sync_finding_from_response()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  audit_row audits%rowtype;
  checklist_row audit_checklist_master%rowtype;
  generated_no text;
  hod_count integer;
  new_hod_id uuid;
BEGIN
  IF new.result = 'NG' THEN
    IF new.audit_id IS NULL
       OR new.audit_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
      RETURN new;
    END IF;

    SELECT * INTO audit_row
    FROM audits
    WHERE id = new.audit_id::uuid;

    IF audit_row.id IS NULL THEN
      RETURN new;
    END IF;

    SELECT * INTO checklist_row
    FROM audit_checklist_master
    WHERE id = new.checklist_id;

    SELECT count(*), min(u.id)
      INTO hod_count, new_hod_id
      FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.is_active = true
        AND r.name = 'Location Functional HOD'
        AND u.location_id = audit_row.location_id
        AND u.department_id = audit_row.department_id;

    IF hod_count = 0 OR new_hod_id IS NULL THEN
      RAISE EXCEPTION 'Cannot create NG finding without an auto-assignable Location Functional HOD.';
    ELSIF hod_count > 1 THEN
      RAISE EXCEPTION 'Location Functional HOD assignment is ambiguous for this finding.';
    END IF;

    generated_no := 'NG-' || to_char(now(), 'YYYYMMDDHH24MISS') || '-' || substr(new.id::text, 1, 6);

    INSERT INTO audit_findings (
      finding_no, audit_response_id, audit_id, checklist_id, location_id,
      owner_department_id, location_functional_hod_id, current_condition, auditor_comments, risk_level,
      target_date, created_by
    )
    VALUES (
      generated_no, new.id, new.audit_id::uuid, new.checklist_id, audit_row.location_id,
      coalesce(checklist_row.department_owner_id, audit_row.department_id),
      new_hod_id,
      new.observation, new.comments, checklist_row.risk_level,
      current_date + CASE WHEN checklist_row.risk_level = 'Critical' THEN 2 ELSE 7 END,
      new.responded_by
    )
    ON CONFLICT (audit_response_id) DO UPDATE
      SET current_condition = excluded.current_condition,
          auditor_comments = excluded.auditor_comments,
          risk_level = excluded.risk_level,
          updated_at = now();
  ELSIF old.result = 'NG' AND new.result <> 'NG' THEN
    UPDATE audit_findings
      SET status = 'cancelled',
          closed_at = now(),
          updated_at = now()
      WHERE audit_response_id = new.id
        AND status NOT IN ('closed', 'cancelled');
  END IF;

  RETURN new;
END;
$$;

COMMIT;
