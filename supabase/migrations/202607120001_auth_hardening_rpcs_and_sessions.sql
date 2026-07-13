BEGIN;

-- =====================================================================
-- Auth hardening, step 1 of 2: ADDITIVE ONLY.
--
-- This migration creates a server-validated session table and a set of
-- SECURITY DEFINER RPCs for login, password change/reset, and user /
-- access-mapping management. It does NOT change any existing grant or
-- RLS policy on app_users / user_access_mappings, so it cannot lock
-- anyone out - the current direct-table login flow keeps working
-- side-by-side until the frontend has been cut over to these RPCs and
-- that cutover has been tested end to end.
--
-- Step 2 (revoking anon direct SELECT of password/password_hash and
-- anon INSERT/UPDATE/DELETE on app_users / user_access_mappings) is a
-- SEPARATE migration, intentionally not included here, and must only be
-- applied after the RPC-based flow is confirmed working in production.
-- See the rollback/lockdown SQL supplied alongside this migration.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Session table. RLS is enabled with zero policies, which denies all
-- access to anon/authenticated by default - only SECURITY DEFINER
-- functions (running as the owning role) can read or write it. This
-- table is intentionally not meant to be reachable via PostgREST at all.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_sessions (
  token text PRIMARY KEY DEFAULT encode(gen_random_bytes(32), 'hex'),
  user_id uuid NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_app_sessions_user_id ON public.app_sessions (user_id);

ALTER TABLE public.app_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.app_sessions FROM anon, authenticated, PUBLIC;

-- ---------------------------------------------------------------------
-- Internal helpers. Never exposed to anon/authenticated: Postgres grants
-- EXECUTE to PUBLIC by default on every new function, and PostgREST will
-- happily serve any function the caller has EXECUTE on regardless of
-- naming convention - so each helper explicitly revokes PUBLIC EXECUTE.
-- They remain callable from other SECURITY DEFINER functions because
-- those run as the owning role, which retains implicit EXECUTE.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public._validate_password_rules(p_password text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN p_password IS NOT NULL
    AND length(p_password) >= 8
    AND p_password ~ '[A-Z]'
    AND p_password ~ '[a-z]'
    AND p_password ~ '[0-9]'
    AND p_password ~ '[^A-Za-z0-9]';
END;
$$;
REVOKE EXECUTE ON FUNCTION public._validate_password_rules(text) FROM PUBLIC;

CREATE OR REPLACE FUNCTION public._password_matches(p_entered text, p_stored_password text, p_stored_hash text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  v_entered_hash text := encode(digest(coalesce(p_entered, ''), 'sha256'), 'hex');
BEGIN
  IF nullif(btrim(coalesce(p_stored_hash, '')), '') IS NOT NULL THEN
    RETURN v_entered_hash = btrim(p_stored_hash);
  END IF;
  IF p_stored_password ~* '^[0-9a-f]{64}$' THEN
    RETURN v_entered_hash = p_stored_password;
  END IF;
  RETURN coalesce(p_entered, '') = coalesce(p_stored_password, '');
END;
$$;
REVOKE EXECUTE ON FUNCTION public._password_matches(text, text, text) FROM PUBLIC;

CREATE OR REPLACE FUNCTION public._create_session(p_user_id uuid)
RETURNS TABLE(token text, expires_at timestamptz)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_token text;
  v_expires timestamptz := now() + interval '12 hours';
BEGIN
  INSERT INTO app_sessions (user_id, expires_at)
  VALUES (p_user_id, v_expires)
  RETURNING app_sessions.token INTO v_token;

  RETURN QUERY SELECT v_token, v_expires;
END;
$$;
REVOKE EXECUTE ON FUNCTION public._create_session(uuid) FROM PUBLIC;

-- Validates a (user_id, session_token) pair: not revoked, not expired,
-- belongs to that user, and the account is still active. Raises on
-- failure (aborting the whole calling RPC, undoing any of its writes -
-- which is the correct behaviour for an authorization failure). Also
-- slides the expiry forward on every successful check.
CREATE OR REPLACE FUNCTION public._authenticate_session(p_user_id uuid, p_session_token text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_session app_sessions%ROWTYPE;
BEGIN
  IF p_user_id IS NULL OR p_session_token IS NULL OR btrim(p_session_token) = '' THEN
    RAISE EXCEPTION 'Session expired. Please sign in again.';
  END IF;

  SELECT * INTO v_session FROM app_sessions WHERE token = p_session_token FOR UPDATE;

  IF NOT FOUND
     OR v_session.user_id IS DISTINCT FROM p_user_id
     OR v_session.revoked_at IS NOT NULL
     OR v_session.expires_at < now() THEN
    RAISE EXCEPTION 'Session expired. Please sign in again.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM app_users WHERE id = p_user_id AND coalesce(active, false) = true) THEN
    RAISE EXCEPTION 'Account is inactive.';
  END IF;

  UPDATE app_sessions
  SET last_seen_at = now(), expires_at = now() + interval '12 hours'
  WHERE token = p_session_token;

  RETURN p_user_id;
END;
$$;
REVOKE EXECUTE ON FUNCTION public._authenticate_session(uuid, text) FROM PUBLIC;

-- Mirrors the existing frontend SUPER_ADMIN_MOBILE_NO structural rule so
-- behaviour is unchanged, plus any mapping row with role = 'Super Admin'.
CREATE OR REPLACE FUNCTION public._is_super_admin(p_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_mobile text;
BEGIN
  SELECT mobile_no INTO v_mobile FROM app_users WHERE id = p_user_id;
  IF v_mobile = '9964214342' THEN RETURN true; END IF;

  RETURN EXISTS (
    SELECT 1 FROM user_access_mappings
    WHERE user_id = p_user_id
      AND coalesce(active, true) = true
      AND lower(coalesce(role, '')) = 'super admin'
  );
END;
$$;
REVOKE EXECUTE ON FUNCTION public._is_super_admin(uuid) FROM PUBLIC;

-- Mirrors the current effective frontend hasAdminAccess() check.
CREATE OR REPLACE FUNCTION public._has_admin_role(p_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public._is_super_admin(p_user_id) THEN RETURN true; END IF;

  RETURN EXISTS (
    SELECT 1 FROM user_access_mappings
    WHERE user_id = p_user_id
      AND coalesce(active, true) = true
      AND (
        lower(coalesce(role, '')) IN ('admin', 'system administrator', 'system admin')
        OR lower(coalesce(user_type, '')) IN ('admin', 'system administrator', 'system admin')
      )
  );
END;
$$;
REVOKE EXECUTE ON FUNCTION public._has_admin_role(uuid) FROM PUBLIC;

-- ---------------------------------------------------------------------
-- Public RPCs
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.login_user(p_mobile_no text, p_password text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
GRANT EXECUTE ON FUNCTION public.login_user(text, text) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.logout_session(p_session_token text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE app_sessions SET revoked_at = now() WHERE token = p_session_token AND revoked_at IS NULL;
END;
$$;
GRANT EXECUTE ON FUNCTION public.logout_session(text) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.change_own_password(
  p_user_id uuid,
  p_session_token text,
  p_current_password text,
  p_new_password text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
GRANT EXECUTE ON FUNCTION public.change_own_password(uuid, text, text, text) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.admin_reset_password(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_target_mobile_no text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
GRANT EXECUTE ON FUNCTION public.admin_reset_password(uuid, text, text) TO anon, authenticated;

-- Create-or-update a single user + their (single) role mapping. Mirrors
-- MasterData.jsx's existing users-editor semantics exactly, including
-- upsert-by-mobile_no. Super Admin only, matching that screen's current
-- canAdminister = isSuperAdmin(user) gate.
CREATE OR REPLACE FUNCTION public.admin_create_or_update_user(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_target_user_id uuid,
  p_employee_name text,
  p_mobile_no text,
  p_active boolean,
  p_role text,
  p_department text,
  p_location text,
  p_user_type text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_mobile text := right(regexp_replace(coalesce(p_mobile_no, ''), '[^0-9]', '', 'g'), 10);
  v_user_id uuid;
BEGIN
  PERFORM public._authenticate_session(p_admin_user_id, p_admin_session_token);

  IF NOT public._is_super_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'Only Super Admin can manage users.';
  END IF;

  IF length(v_mobile) <> 10 THEN
    RAISE EXCEPTION 'Enter a valid 10-digit mobile number.';
  END IF;

  IF nullif(btrim(coalesce(p_employee_name, '')), '') IS NULL THEN
    RAISE EXCEPTION 'Employee name is required.';
  END IF;

  INSERT INTO app_users (id, employee_name, mobile_no, active)
  VALUES (coalesce(p_target_user_id, gen_random_uuid()), btrim(p_employee_name), v_mobile, coalesce(p_active, true))
  ON CONFLICT (mobile_no) DO UPDATE
  SET employee_name = excluded.employee_name,
      active = excluded.active,
      updated_at = now()
  RETURNING id INTO v_user_id;

  IF nullif(btrim(coalesce(p_role, '')), '') IS NOT NULL THEN
    INSERT INTO user_access_mappings (user_id, role, department, location, user_type, active)
    VALUES (v_user_id, p_role, coalesce(p_department, ''), coalesce(p_location, ''), coalesce(p_user_type, ''), true)
    ON CONFLICT (user_id, role, department, location, user_type) DO UPDATE
    SET active = true;
  END IF;

  RETURN jsonb_build_object('success', true, 'user_id', v_user_id);
END;
$$;
GRANT EXECUTE ON FUNCTION public.admin_create_or_update_user(uuid, text, uuid, text, text, boolean, text, text, text, text) TO anon, authenticated;

-- Bulk variant for MasterImport.jsx, mirroring importUsers()'s current
-- behaviour: every imported row (new or existing) is reset to the
-- default password and must_reset_password = true.
CREATE OR REPLACE FUNCTION public.admin_bulk_import_users(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_rows jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
GRANT EXECUTE ON FUNCTION public.admin_bulk_import_users(uuid, text, jsonb) TO anon, authenticated;

-- Soft-delete only: app_users.id is referenced by audit/finding/response
-- history throughout the schema with no ON DELETE CASCADE, so a hard
-- DELETE would either fail on FK violations or silently orphan
-- compliance records. "Deletion" here means deactivating the account,
-- its access mappings, and any live sessions.
CREATE OR REPLACE FUNCTION public.admin_delete_user(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_target_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public._authenticate_session(p_admin_user_id, p_admin_session_token);

  IF NOT public._is_super_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'Only Super Admin can remove users.';
  END IF;

  IF p_target_user_id = p_admin_user_id THEN
    RAISE EXCEPTION 'You cannot remove your own account.';
  END IF;

  UPDATE app_users SET active = false, account_locked = true, updated_at = now() WHERE id = p_target_user_id;
  UPDATE user_access_mappings SET active = false WHERE user_id = p_target_user_id;
  UPDATE app_sessions SET revoked_at = now() WHERE user_id = p_target_user_id AND revoked_at IS NULL;

  RETURN jsonb_build_object('success', true);
END;
$$;
GRANT EXECUTE ON FUNCTION public.admin_delete_user(uuid, text, uuid) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.admin_upsert_access_mapping(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_mapping_id uuid,
  p_target_user_id uuid,
  p_role text,
  p_department text,
  p_location text,
  p_user_type text,
  p_active boolean
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid;
BEGIN
  PERFORM public._authenticate_session(p_admin_user_id, p_admin_session_token);

  IF NOT public._is_super_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'Only Super Admin can manage access mappings.';
  END IF;

  IF p_mapping_id IS NOT NULL THEN
    UPDATE user_access_mappings
    SET role = coalesce(p_role, role),
        department = coalesce(p_department, department),
        location = coalesce(p_location, location),
        user_type = coalesce(p_user_type, user_type),
        active = coalesce(p_active, active)
    WHERE id = p_mapping_id
    RETURNING id INTO v_id;
  ELSE
    IF p_target_user_id IS NULL THEN
      RAISE EXCEPTION 'Target user is required.';
    END IF;

    INSERT INTO user_access_mappings (user_id, role, department, location, user_type, active)
    VALUES (p_target_user_id, coalesce(p_role, ''), coalesce(p_department, ''), coalesce(p_location, ''), coalesce(p_user_type, ''), coalesce(p_active, true))
    ON CONFLICT (user_id, role, department, location, user_type) DO UPDATE
    SET active = coalesce(p_active, true)
    RETURNING id INTO v_id;
  END IF;

  RETURN jsonb_build_object('success', true, 'mapping_id', v_id);
END;
$$;
GRANT EXECUTE ON FUNCTION public.admin_upsert_access_mapping(uuid, text, uuid, uuid, text, text, text, text, boolean) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.admin_delete_access_mapping(
  p_admin_user_id uuid,
  p_admin_session_token text,
  p_mapping_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public._authenticate_session(p_admin_user_id, p_admin_session_token);

  IF NOT public._is_super_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'Only Super Admin can manage access mappings.';
  END IF;

  DELETE FROM user_access_mappings WHERE id = p_mapping_id;

  RETURN jsonb_build_object('success', true);
END;
$$;
GRANT EXECUTE ON FUNCTION public.admin_delete_access_mapping(uuid, text, uuid) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';

COMMIT;
