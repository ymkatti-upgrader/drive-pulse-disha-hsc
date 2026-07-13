BEGIN;

-- admin_create_or_update_user inserts into app_users. The BEFORE INSERT
-- trigger sync_app_users_password_reset_defaults() calls pgcrypto digest(),
-- and trigger functions execute with the invoking statement's search_path
-- unless they define their own. Supabase installs pgcrypto in `extensions`,
-- so retain the RPC's fixed allowlist while making digest() resolvable.
--
-- ALTER FUNCTION changes only the configuration of the existing exact
-- signature. Its body, return type, SECURITY DEFINER property, ownership,
-- authorization/session checks, trigger behavior, and execute grants remain
-- unchanged. Reapplying this statement is safe.
ALTER FUNCTION public.admin_create_or_update_user(
  uuid,
  text,
  uuid,
  text,
  text,
  boolean,
  text,
  text,
  text,
  text
)
SET search_path = public, extensions;

COMMIT;
