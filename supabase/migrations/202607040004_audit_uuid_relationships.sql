BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS audit_uuid uuid;

UPDATE audit_responses ar
SET audit_uuid = a.id
FROM audits a
WHERE ar.audit_uuid IS NULL
  AND ar.audit_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  AND a.id = ar.audit_id::uuid;

UPDATE audit_responses ar
SET audit_uuid = a.id
FROM audits a
WHERE ar.audit_uuid IS NULL
  AND (
    btrim(coalesce(ar.audit_id, '')) = btrim(coalesce(a.audit_number, ''))
    OR btrim(coalesce(ar.audit_id, '')) = btrim(coalesce(a.audit_no, ''))
  );

CREATE INDEX IF NOT EXISTS idx_audit_responses_audit_uuid
  ON audit_responses (audit_uuid);

CREATE UNIQUE INDEX IF NOT EXISTS idx_audit_responses_audit_uuid_checklist_unique
  ON audit_responses (audit_uuid, checklist_id)
  WHERE audit_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_audits_audit_number_unique
  ON audits (audit_number);

ALTER TABLE audit_responses
  DROP CONSTRAINT IF EXISTS audit_responses_audit_uuid_fkey;

ALTER TABLE audit_responses
  ADD CONSTRAINT audit_responses_audit_uuid_fkey
  FOREIGN KEY (audit_uuid) REFERENCES audits(id) ON DELETE CASCADE NOT VALID;

CREATE OR REPLACE FUNCTION public.sync_audit_response_audit_keys()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  resolved_audit_id uuid;
  resolved_audit_ref text;
BEGIN
  IF NEW.audit_uuid IS NULL AND nullif(btrim(coalesce(NEW.audit_id, '')), '') IS NOT NULL THEN
    IF NEW.audit_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
      SELECT id
      INTO resolved_audit_id
      FROM audits
      WHERE id = NEW.audit_id::uuid;
    ELSE
      SELECT id
      INTO resolved_audit_id
      FROM audits
      WHERE btrim(coalesce(audit_number, '')) = btrim(NEW.audit_id)
         OR btrim(coalesce(audit_no, '')) = btrim(NEW.audit_id)
      ORDER BY created_at DESC
      LIMIT 1;
    END IF;

    NEW.audit_uuid := resolved_audit_id;
  END IF;

  IF NEW.audit_uuid IS NOT NULL AND nullif(btrim(coalesce(NEW.audit_id, '')), '') IS NULL THEN
    SELECT coalesce(nullif(btrim(audit_number), ''), nullif(btrim(audit_no), ''), id::text)
    INTO resolved_audit_ref
    FROM audits
    WHERE id = NEW.audit_uuid;

    NEW.audit_id := resolved_audit_ref;
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.sync_finding_from_response()
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
  resolved_audit_uuid uuid;
BEGIN
  resolved_audit_uuid := coalesce(new.audit_uuid, old.audit_uuid);

  IF new.result = 'NG' THEN
    IF resolved_audit_uuid IS NULL THEN
      RETURN new;
    END IF;

    SELECT * INTO audit_row
    FROM audits
    WHERE id = resolved_audit_uuid;

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
      generated_no, new.id, resolved_audit_uuid, new.checklist_id, audit_row.location_id,
      coalesce(checklist_row.department_owner_id, audit_row.department_id),
      new_hod_id,
      new.observation, new.comments, checklist_row.risk_level,
      current_date + CASE WHEN checklist_row.risk_level = 'Critical' THEN 2 ELSE 7 END,
      new.responded_by
    )
    ON CONFLICT (audit_response_id) DO UPDATE
      SET audit_id = excluded.audit_id,
          checklist_id = excluded.checklist_id,
          location_id = excluded.location_id,
          owner_department_id = excluded.owner_department_id,
          location_functional_hod_id = excluded.location_functional_hod_id,
          current_condition = excluded.current_condition,
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

DROP TRIGGER IF EXISTS trg_sync_audit_response_audit_keys ON audit_responses;
CREATE TRIGGER trg_sync_audit_response_audit_keys
BEFORE INSERT OR UPDATE ON audit_responses
FOR EACH ROW
EXECUTE FUNCTION public.sync_audit_response_audit_keys();

DROP VIEW IF EXISTS public.audit_response_audit_uuid_validation;
CREATE VIEW public.audit_response_audit_uuid_validation AS
SELECT
  ar.id AS response_id,
  ar.audit_id AS legacy_audit_id,
  ar.audit_uuid,
  ar.checklist_id,
  ar.result,
  ar.created_at,
  ar.updated_at
FROM audit_responses ar
WHERE ar.audit_uuid IS NULL;

GRANT SELECT ON public.audit_response_audit_uuid_validation TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
