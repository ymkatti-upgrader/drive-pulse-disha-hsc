BEGIN;

-- =====================================================================
-- Fixes a critical defect in 202607120001_auth_hardening_rpcs_and_sessions.sql
-- discovered during live validation: every RPC that calls pgcrypto's
-- digest() failed with "function digest(...) does not exist".
--
-- Root cause: Supabase installs pgcrypto in the `extensions` schema, not
-- `public`, and the anon/authenticated roles' default search_path
-- includes `extensions` (confirmed live: the pre-existing trigger
-- sync_app_users_password_reset_defaults(), which has no SET search_path
-- override, successfully calls digest() using that default path).
-- login_user, change_own_password, admin_reset_password and
-- admin_bulk_import_users were all created with `SET search_path =
-- public`, which excludes `extensions` and made digest() unresolvable
-- inside those functions (and inside _password_matches, which they call
-- and which inherits the caller's active search_path).
--
-- Fix: add `extensions` to the search_path of every affected function.
-- This keeps the explicit-allowlist protection against search_path
-- injection (still a fixed, non-caller-controlled path) while restoring
-- digest() resolution. No other function needs this change - the rest
-- never call digest().
-- =====================================================================

CREATE OR REPLACE FUNCTION public.login_user(p_mobile_no text, p_password text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_mobile text := right(regexp_replace(coalesce(p_mobile_no, ''), '[^0-9]', '', 'g'), 10);
  v_user app_users%ROWTYPE;
  v_failed integer;
  v_session record;
  v_access jsonb;
BEGIN
  IF length(v_mobile) <> 10 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Enter a valid 10-digit mobile number.');
  END IF;

  SELECT * INTO v_user FROM app_users WHERE mobile_no = v_mobile;

  IF NOT FOUND OR NOT coalesce(v_user.active, false) THEN
    RETURN jsonb_build_object('success', false, 'error', 'User profile not found or not approved. Please contact Super Admin.');
  END IF;

  IF coalesce(v_user.account_locked, false) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Account is locked. Please contact Super Admin.');
  END IF;

  IF NOT public._password_matches(p_password, v_user.password, v_user.password_hash) THEN
    v_failed := coalesce(v_user.failed_login_attempts, 0) + 1;
    UPDATE app_users
    SET failed_login_attempts = v_failed,
        account_locked = v_failed >= 5,
        updated_at = now()
    WHERE id = v_user.id;

    IF v_failed >= 5 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Account locked after too many failed attempts. Please contact Super Admin.');
    END IF;
    RETURN jsonb_build_object('success', false, 'error', 'Incorrect password.');
  END IF;

  UPDATE app_users
  SET last_login_at = now(), failed_login_attempts = 0, account_locked = false, updated_at = now()
  WHERE id = v_user.id
  RETURNING * INTO v_user;

  SELECT coalesce(jsonb_agg(jsonb_build_object('role', role, 'department', department, 'location', location, 'user_type', user_type)), '[]'::jsonb)
  INTO v_access
  FROM user_access_mappings
  WHERE user_id = v_user.id AND coalesce(active, true) = true;

  SELECT * INTO v_session FROM public._create_session(v_user.id);

  RETURN jsonb_build_object(
    'success', true,
    'session_token', v_session.token,
    'expires_at', v_session.expires_at,
    'user', jsonb_build_object(
      'id', v_user.id,
      'employee_name', v_user.employee_name,
      'mobile_no', v_user.mobile_no,
      'active', v_user.active,
      'must_reset_password', coalesce(v_user.must_reset_password, false),
      'password_changed_at', v_user.password_changed_at,
      'last_login_at', v_user.last_login_at,
      'failed_login_attempts', v_user.failed_login_attempts,
      'account_locked', v_user.account_locked
    ),
    'access', v_access
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.change_own_password(
  p_user_id uuid,
  p_session_token text,
  p_current_password text,
  p_new_password text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_user app_users%ROWTYPE;
  v_hash text;
BEGIN
  PERFORM public._authenticate_session(p_user_id, p_session_token);

  SELECT * INTO v_user FROM app_users WHERE id = p_user_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Session expired. Please sign in again.');
  END IF;

  IF NOT public._password_matches(p_current_password, v_user.password, v_user.password_hash) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Current password does not match.');
  END IF;

  IF btrim(coalesce(p_new_password, '')) = 'Welcome@123' THEN
    RETURN jsonb_build_object('success', false, 'error', 'New password cannot be the default password.');
  END IF;

  IF NOT public._validate_password_rules(p_new_password) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Password does not meet the security rules.');
  END IF;

  v_hash := encode(digest(p_new_password, 'sha256'), 'hex');

  UPDATE app_users
  SET password = v_hash,
      password_hash = v_hash,
      must_reset_password = false,
      password_changed_at = now(),
      last_login_at = now(),
      failed_login_attempts = 0,
      account_locked = false,
      updated_at = now()
  WHERE id = p_user_id;

  RETURN jsonb_build_object('success', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_reset_password(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_target_mobile_no text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_mobile text := right(regexp_replace(coalesce(p_target_mobile_no, ''), '[^0-9]', '', 'g'), 10);
  v_hash text;
  v_target_id uuid;
BEGIN
  PERFORM public._authenticate_session(p_admin_user_id, p_admin_session_token);

  IF NOT public._has_admin_role(p_admin_user_id) THEN
    RAISE EXCEPTION 'Only Admin or Super Admin can reset passwords.';
  END IF;

  SELECT id INTO v_target_id FROM app_users WHERE mobile_no = v_mobile AND active = true;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'No active user found for that mobile number.');
  END IF;

  IF v_target_id = p_admin_user_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Use password reset screen to change your own password.');
  END IF;

  v_hash := encode(digest('Welcome@123', 'sha256'), 'hex');

  UPDATE app_users
  SET password = v_hash,
      password_hash = v_hash,
      must_reset_password = true,
      password_changed_at = NULL,
      last_login_at = NULL,
      failed_login_attempts = 0,
      account_locked = false,
      updated_at = now()
  WHERE id = v_target_id;

  RETURN jsonb_build_object('success', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_bulk_import_users(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_rows jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_row jsonb;
  v_mobile text;
  v_user_id uuid;
  v_created integer := 0;
  v_updated integer := 0;
  v_mappings integer := 0;
  v_default_hash text := encode(digest('Welcome@123', 'sha256'), 'hex');
BEGIN
  PERFORM public._authenticate_session(p_admin_user_id, p_admin_session_token);

  IF NOT public._is_super_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'Only Super Admin can import users.';
  END IF;

  FOR v_row IN SELECT * FROM jsonb_array_elements(coalesce(p_rows, '[]'::jsonb))
  LOOP
    v_mobile := right(regexp_replace(coalesce(v_row->>'mobile_no', ''), '[^0-9]', '', 'g'), 10);
    IF length(v_mobile) <> 10 THEN
      CONTINUE;
    END IF;

    IF EXISTS (SELECT 1 FROM app_users WHERE mobile_no = v_mobile) THEN
      v_updated := v_updated + 1;
    ELSE
      v_created := v_created + 1;
    END IF;

    INSERT INTO app_users (employee_name, mobile_no, active)
    VALUES (btrim(coalesce(v_row->>'employee_name', '')), v_mobile, coalesce((v_row->>'active')::boolean, false))
    ON CONFLICT (mobile_no) DO UPDATE
    SET employee_name = coalesce(nullif(btrim(excluded.employee_name), ''), app_users.employee_name),
        active = excluded.active,
        password = v_default_hash,
        password_hash = v_default_hash,
        must_reset_password = true,
        password_changed_at = NULL,
        last_login_at = NULL,
        failed_login_attempts = 0,
        account_locked = false,
        updated_at = now()
    RETURNING id INTO v_user_id;

    IF nullif(btrim(coalesce(v_row->>'role', '')), '') IS NOT NULL THEN
      INSERT INTO user_access_mappings (user_id, role, department, location, user_type, active)
      VALUES (
        v_user_id,
        coalesce(v_row->>'role', ''),
        coalesce(v_row->>'department', ''),
        coalesce(v_row->>'location', ''),
        coalesce(v_row->>'user_type', ''),
        coalesce((v_row->>'active')::boolean, false)
      )
      ON CONFLICT (user_id, role, department, location, user_type) DO UPDATE
      SET active = excluded.active;
      v_mappings := v_mappings + 1;
    END IF;
  END LOOP;

  RETURN jsonb_build_object('success', true, 'created', v_created, 'updated', v_updated, 'mappings', v_mappings, 'total', v_created + v_updated);
END;
$$;

NOTIFY pgrst, 'reload schema';

COMMIT;
