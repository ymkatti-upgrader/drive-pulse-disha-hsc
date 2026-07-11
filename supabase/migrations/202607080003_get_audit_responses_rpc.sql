BEGIN;

CREATE OR REPLACE FUNCTION public.get_audit_responses(p_audit_id text)
RETURNS SETOF audit_responses
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT *
  FROM public.audit_responses
  WHERE audit_id = p_audit_id
    AND COALESCE(is_void, false) = false
  ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST;
$$;

REVOKE ALL ON FUNCTION public.get_audit_responses(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_audit_responses(text) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
