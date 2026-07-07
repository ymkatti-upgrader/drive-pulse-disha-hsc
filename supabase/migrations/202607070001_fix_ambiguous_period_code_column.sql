BEGIN;

-- next_audit_number declared a plpgsql variable named "period_code", which
-- collides with the audit_number_counters.period_code column referenced in
-- the same INSERT ... ON CONFLICT statement. Under the default
-- plpgsql.variable_conflict = 'error' setting, Postgres cannot tell whether
-- "period_code" means the variable or the column and raises:
--   ERROR: column reference "period_code" is ambiguous
-- Renaming the variable to v_period_code removes the collision.
CREATE OR REPLACE FUNCTION next_audit_number(p_created_at timestamptz DEFAULT now())
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_period_code text := to_char(COALESCE(p_created_at, now()) AT TIME ZONE 'Asia/Kolkata', 'YYMM');
  next_value integer;
BEGIN
  INSERT INTO audit_number_counters (period_code, last_value)
  VALUES (v_period_code, 1)
  ON CONFLICT (period_code)
  DO UPDATE SET last_value = audit_number_counters.last_value + 1
  RETURNING last_value INTO next_value;

  RETURN format('DHA-%s-%s', v_period_code, lpad(next_value::text, 4, '0'));
END;
$$;

GRANT EXECUTE ON FUNCTION next_audit_number(timestamptz) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
