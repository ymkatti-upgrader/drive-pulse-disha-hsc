BEGIN;

ALTER TABLE audit_responses
  ADD COLUMN IF NOT EXISTS group_disha_comments text;

UPDATE audit_responses
SET group_disha_comments = coalesce(group_disha_comments, group_disha_approval_remarks)
WHERE group_disha_comments IS NULL
  AND group_disha_approval_remarks IS NOT NULL;

CREATE OR REPLACE FUNCTION public.sync_group_disha_comments()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.group_disha_comments IS NULL AND NEW.group_disha_approval_remarks IS NOT NULL THEN
    NEW.group_disha_comments := NEW.group_disha_approval_remarks;
  ELSIF NEW.group_disha_approval_remarks IS NULL AND NEW.group_disha_comments IS NOT NULL THEN
    NEW.group_disha_approval_remarks := NEW.group_disha_comments;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_group_disha_comments ON audit_responses;
CREATE TRIGGER trg_sync_group_disha_comments
BEFORE INSERT OR UPDATE ON audit_responses
FOR EACH ROW
EXECUTE FUNCTION public.sync_group_disha_comments();

NOTIFY pgrst, 'reload schema';

COMMIT;
