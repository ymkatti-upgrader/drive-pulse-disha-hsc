BEGIN;

ALTER TABLE audits
  ADD COLUMN IF NOT EXISTS audit_number text;

ALTER TABLE audits
  DROP CONSTRAINT IF EXISTS audits_auditor_id_fkey;

ALTER TABLE audits
  ADD CONSTRAINT audits_auditor_id_fkey
  FOREIGN KEY (auditor_id) REFERENCES app_users(id) NOT VALID;

ALTER TABLE audits
  DROP CONSTRAINT IF EXISTS audits_created_by_fkey;

ALTER TABLE audits
  ADD CONSTRAINT audits_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES app_users(id) NOT VALID;

CREATE TABLE IF NOT EXISTS audit_number_counters (
  period_code text PRIMARY KEY,
  last_value integer NOT NULL DEFAULT 0
);

CREATE OR REPLACE FUNCTION next_audit_number(p_created_at timestamptz DEFAULT now())
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  period_code text := to_char(COALESCE(p_created_at, now()) AT TIME ZONE 'Asia/Kolkata', 'YYMM');
  next_value integer;
BEGIN
  INSERT INTO audit_number_counters (period_code, last_value)
  VALUES (period_code, 1)
  ON CONFLICT (period_code)
  DO UPDATE SET last_value = audit_number_counters.last_value + 1
  RETURNING last_value INTO next_value;

  RETURN format('DHA-%s-%s', period_code, lpad(next_value::text, 4, '0'));
END;
$$;

WITH ordered_audits AS (
  SELECT
    id,
    to_char(created_at AT TIME ZONE 'Asia/Kolkata', 'YYMM') AS period_code,
    row_number() OVER (
      PARTITION BY to_char(created_at AT TIME ZONE 'Asia/Kolkata', 'YYMM')
      ORDER BY created_at, id
    ) AS sequence_number
  FROM audits
  WHERE COALESCE(NULLIF(btrim(audit_number), ''), '') = ''
)
UPDATE audits AS audit_row
SET audit_number = format('DHA-%s-%s', ordered_audits.period_code, lpad(ordered_audits.sequence_number::text, 4, '0'))
FROM ordered_audits
WHERE audit_row.id = ordered_audits.id;

UPDATE audits
SET audit_no = audit_number
WHERE audit_number IS NOT NULL
  AND audit_no IS DISTINCT FROM audit_number;

INSERT INTO audit_number_counters (period_code, last_value)
SELECT
  substring(audit_number FROM 5 FOR 4) AS period_code,
  max(substring(audit_number FROM 10 FOR 4)::integer) AS last_value
FROM audits
WHERE audit_number ~ '^DHA-[0-9]{4}-[0-9]{4}$'
GROUP BY 1
ON CONFLICT (period_code)
DO UPDATE SET last_value = GREATEST(audit_number_counters.last_value, EXCLUDED.last_value);

ALTER TABLE audits
  ALTER COLUMN audit_number SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_audits_audit_number_unique
  ON audits (audit_number);

CREATE OR REPLACE FUNCTION sync_and_protect_audit_number()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.audit_number IS DISTINCT FROM OLD.audit_number THEN
    RAISE EXCEPTION 'audit_number cannot be edited';
  END IF;

  IF NEW.audit_number IS NULL OR btrim(NEW.audit_number) = '' THEN
    NEW.audit_number := COALESCE(NULLIF(btrim(NEW.audit_no), ''), next_audit_number(COALESCE(NEW.created_at, now())));
  END IF;

  NEW.audit_no := NEW.audit_number;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_and_protect_audit_number ON audits;
CREATE TRIGGER trg_sync_and_protect_audit_number
BEFORE INSERT OR UPDATE ON audits
FOR EACH ROW
EXECUTE FUNCTION sync_and_protect_audit_number();

CREATE OR REPLACE FUNCTION create_audit_with_number(
  p_title text,
  p_location_id uuid,
  p_department_id uuid,
  p_auditor_id uuid,
  p_scheduled_date date,
  p_created_by uuid,
  p_status audit_status DEFAULT 'scheduled'
)
RETURNS audits
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  inserted_row audits%ROWTYPE;
BEGIN
  INSERT INTO audits (
    audit_number,
    audit_no,
    title,
    location_id,
    department_id,
    auditor_id,
    scheduled_date,
    status,
    created_by
  )
  VALUES (
    next_audit_number(now()),
    NULL,
    p_title,
    p_location_id,
    p_department_id,
    p_auditor_id,
    p_scheduled_date,
    COALESCE(p_status, 'scheduled'),
    p_created_by
  )
  RETURNING * INTO inserted_row;

  RETURN inserted_row;
END;
$$;

GRANT EXECUTE ON FUNCTION next_audit_number(timestamptz) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_audit_with_number(text, uuid, uuid, uuid, date, uuid, audit_status) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
