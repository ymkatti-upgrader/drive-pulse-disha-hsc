BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE app_users
  ADD COLUMN IF NOT EXISTS password_hash text,
  ADD COLUMN IF NOT EXISTS must_reset_password boolean NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS password_changed_at timestamptz,
  ADD COLUMN IF NOT EXISTS last_login_at timestamptz,
  ADD COLUMN IF NOT EXISTS failed_login_attempts integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS account_locked boolean NOT NULL DEFAULT FALSE;

UPDATE app_users
SET
  password_hash = coalesce(
    password_hash,
    encode(digest(coalesce(nullif(btrim(password), ''), 'Welcome@123'), 'sha256'), 'hex')
  ),
  must_reset_password = CASE
    WHEN coalesce(nullif(btrim(password), ''), 'Welcome@123') = 'Welcome@123' THEN true
    ELSE false
  END,
  password_changed_at = CASE
    WHEN coalesce(nullif(btrim(password), ''), 'Welcome@123') = 'Welcome@123' THEN NULL
    ELSE coalesce(password_changed_at, updated_at, created_at, now())
  END,
  last_login_at = last_login_at,
  failed_login_attempts = coalesce(failed_login_attempts, 0),
  account_locked = coalesce(account_locked, false)
WHERE true;

CREATE OR REPLACE FUNCTION public.sync_app_users_password_reset_defaults()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.password_hash := coalesce(
    encode(digest('Welcome@123', 'sha256'), 'hex')
  );
  NEW.password := NEW.password_hash;
  NEW.must_reset_password := true;
  NEW.password_changed_at := NULL;
  NEW.last_login_at := NULL;
  NEW.failed_login_attempts := 0;
  NEW.account_locked := false;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_app_users_password_reset_defaults ON app_users;
CREATE TRIGGER trg_sync_app_users_password_reset_defaults
BEFORE INSERT ON app_users
FOR EACH ROW
EXECUTE FUNCTION public.sync_app_users_password_reset_defaults();

GRANT EXECUTE ON FUNCTION public.sync_app_users_password_reset_defaults() TO anon, authenticated;

COMMIT;
