BEGIN;

-- Phase 2A: capture the audited function independently from the legacy
-- department field. Existing audits intentionally remain NULL and require no
-- data rewrite; the application renders them as "Not Assigned".
ALTER TABLE public.audits
  ADD COLUMN IF NOT EXISTS audit_function_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.audits'::regclass
      AND conname = 'audits_audit_function_id_fkey'
  ) THEN
    ALTER TABLE public.audits
      ADD CONSTRAINT audits_audit_function_id_fkey
      FOREIGN KEY (audit_function_id)
      REFERENCES public.departments(id)
      ON DELETE SET NULL;
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS idx_audits_audit_function_id
  ON public.audits (audit_function_id);

-- Keep the existing seven-argument create_audit_with_number RPC untouched for
-- backward compatibility. Calls that include p_audit_function_id resolve to
-- this overload, which preserves numbering and all existing insert behavior.
CREATE OR REPLACE FUNCTION public.create_audit_with_number(
  p_title text,
  p_location_id uuid,
  p_department_id uuid,
  p_auditor_id uuid,
  p_scheduled_date date,
  p_created_by uuid,
  p_audit_function_id uuid,
  p_status audit_status DEFAULT 'scheduled'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  inserted_row public.audits%ROWTYPE;
BEGIN
  IF p_audit_function_id IS NULL THEN
    RAISE EXCEPTION 'Audit function is required.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.departments
    WHERE id = p_audit_function_id
      AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'Select an active audit function.';
  END IF;

  INSERT INTO public.audits (
    audit_number,
    audit_no,
    title,
    location_id,
    department_id,
    audit_function_id,
    auditor_id,
    scheduled_date,
    status,
    created_by
  )
  VALUES (
    public.next_audit_number(now()),
    NULL,
    p_title,
    p_location_id,
    p_department_id,
    p_audit_function_id,
    p_auditor_id,
    p_scheduled_date,
    COALESCE(p_status, 'scheduled'),
    p_created_by
  )
  RETURNING * INTO inserted_row;

  RETURN to_jsonb(inserted_row);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.create_audit_with_number(
  text, uuid, uuid, uuid, date, uuid, uuid, audit_status
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_audit_with_number(
  text, uuid, uuid, uuid, date, uuid, uuid, audit_status
) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
