-- Finding A (SIT): a manual, undocumented change to the live database replaced
-- the permissive policies from 202606240011 with narrower ones that only allow
-- rows where audit_id LIKE 'AUD-%' (legacy client-only IDs) or audit_id equals
-- a real audits.id UUID cast to text. Real production audit numbers (e.g.
-- 'DHA-2607-0028') match neither pattern, so every response tied to a real,
-- properly-numbered audit is invisible to the app (SELECT), un-writable
-- (INSERT/UPDATE), and un-deletable (DELETE) for the anon/authenticated roles
-- the app actually uses. This restores the intended, fully permissive policies
-- (row-level scoping for this app is handled in the frontend, not via RLS --
-- see docs/frontend-role-route-action-permission-matrix.md).
BEGIN;

DROP POLICY IF EXISTS "response visibility follows audit" ON audit_responses;
DROP POLICY IF EXISTS "assigned auditor writes responses" ON audit_responses;
DROP POLICY IF EXISTS "assigned auditor updates responses before submission" ON audit_responses;
DROP POLICY IF EXISTS "audit response drafts are deletable" ON audit_responses;
DROP POLICY IF EXISTS "audit response drafts are readable" ON audit_responses;
DROP POLICY IF EXISTS "audit response drafts are insertable" ON audit_responses;
DROP POLICY IF EXISTS "audit response drafts are updatable" ON audit_responses;

CREATE POLICY "audit response drafts are readable" ON audit_responses
  FOR SELECT USING (true);

CREATE POLICY "audit response drafts are insertable" ON audit_responses
  FOR INSERT WITH CHECK (true);

CREATE POLICY "audit response drafts are updatable" ON audit_responses
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "audit response drafts are deletable" ON audit_responses
  FOR DELETE USING (true);

NOTIFY pgrst, 'reload schema';

COMMIT;
