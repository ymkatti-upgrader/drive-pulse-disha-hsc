BEGIN;

-- Authentication permission lockdown after the RPC/session cutover.
--
-- The frontend still needs a small, non-sensitive app_users projection for
-- session refresh and user/PIC labels. Remove broad table access first, then
-- grant SELECT only on those explicitly reviewed columns. In particular,
-- password, password_hash and login-history fields are not exposed.
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;

REVOKE ALL PRIVILEGES ON TABLE public.app_users FROM anon, authenticated;
GRANT SELECT (
  id,
  employee_name,
  mobile_no,
  active,
  must_reset_password,
  account_locked
) ON TABLE public.app_users TO anon, authenticated;

-- These permissive write policies belonged to the former direct-table user
-- administration flow. User mutations now go through session-validating,
-- role-checking SECURITY DEFINER RPCs.
DROP POLICY IF EXISTS "public insert app users" ON public.app_users;
DROP POLICY IF EXISTS "public update app users" ON public.app_users;
DROP POLICY IF EXISTS "public delete app users" ON public.app_users;

-- Access mappings remain directly readable because role, department and
-- location hydration depends on them. All mutations are RPC-only.
ALTER TABLE public.user_access_mappings ENABLE ROW LEVEL SECURITY;

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE public.user_access_mappings FROM anon, authenticated;
GRANT SELECT ON TABLE public.user_access_mappings TO anon, authenticated;

DROP POLICY IF EXISTS "public insert user access mappings" ON public.user_access_mappings;
DROP POLICY IF EXISTS "public update user access mappings" ON public.user_access_mappings;
DROP POLICY IF EXISTS "public delete user access mappings" ON public.user_access_mappings;

-- Sessions must only be read or changed by the owning SECURITY DEFINER RPCs.
-- RLS has no direct-access policy for this table.
ALTER TABLE public.app_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE public.app_sessions
  FROM PUBLIC, anon, authenticated, service_role;

-- Internal implementation helpers and the password-default trigger function
-- are not public API. Their owning role can still invoke them from approved
-- SECURITY DEFINER RPCs and triggers.
REVOKE EXECUTE ON FUNCTION public._validate_password_rules(text)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public._password_matches(text, text, text)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public._create_session(uuid)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public._authenticate_session(uuid, text)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public._is_super_admin(uuid)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public._has_admin_role(uuid)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.sync_app_users_password_reset_defaults()
  FROM PUBLIC, anon, authenticated, service_role;

-- Approved RPC surface. Remove PostgreSQL's default PUBLIC execute privilege,
-- then grant only the API roles used by the application and trusted backend.
REVOKE EXECUTE ON FUNCTION public.login_user(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.login_user(text, text)
  TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.logout_session(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.logout_session(text)
  TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.change_own_password(uuid, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.change_own_password(uuid, text, text, text)
  TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.admin_reset_password(uuid, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_reset_password(uuid, text, text)
  TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.admin_create_or_update_user(
  uuid, text, uuid, text, text, boolean, text, text, text, text
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_create_or_update_user(
  uuid, text, uuid, text, text, boolean, text, text, text, text
) TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.admin_bulk_import_users(uuid, text, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_bulk_import_users(uuid, text, jsonb)
  TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.admin_delete_user(uuid, text, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_delete_user(uuid, text, uuid)
  TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.admin_upsert_access_mapping(
  uuid, text, uuid, uuid, text, text, text, text, boolean
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_upsert_access_mapping(
  uuid, text, uuid, uuid, text, text, text, text, boolean
) TO anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.admin_delete_access_mapping(uuid, text, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_delete_access_mapping(uuid, text, uuid)
  TO anon, authenticated, service_role;

NOTIFY pgrst, 'reload schema';

COMMIT;
