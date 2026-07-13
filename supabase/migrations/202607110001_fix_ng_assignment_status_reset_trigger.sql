BEGIN;

-- normalize_ng_assignment_fields previously forced action_status back to
-- 'Assigned' on every INSERT/UPDATE of audit_responses as long as an
-- assignee was present, which is true for the entire remaining life of an
-- NG action once a PIC has been assigned. This silently reverted every
-- later workflow status (Submitted for Review, Closed, Verified, etc.) set
-- by submit_disha_action_update / review_disha_action back to 'Assigned'
-- immediately after those RPCs wrote it, because both RPCs update the same
-- row without touching the assignment columns and the BEFORE UPDATE
-- trigger ran on top of their SET clause.
--
-- Fix: only force the 'Assigned' default when the assignment is genuinely
-- new (INSERT with no status yet) or genuinely changing (assignee columns
-- differ from OLD). Routine updates that leave the assignee untouched no
-- longer touch action_status at all.

CREATE OR REPLACE FUNCTION public.normalize_ng_assignment_fields()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_assignment_exists boolean;
  v_assignment_changed boolean;
BEGIN
  v_assignment_exists := (
    NEW.assigned_pic_user_id IS NOT NULL
    OR NEW.pic_for_ng_user_id IS NOT NULL
    OR nullif(btrim(coalesce(NEW.pic_for_ng_mobile, '')), '') IS NOT NULL
  );

  IF v_assignment_exists THEN
    NEW.assigned_pic_user_id := coalesce(NEW.assigned_pic_user_id, NEW.pic_for_ng_user_id);

    IF TG_OP = 'INSERT' THEN
      v_assignment_changed := true;
    ELSE
      v_assignment_changed := (
        NEW.assigned_pic_user_id IS DISTINCT FROM OLD.assigned_pic_user_id
        OR NEW.pic_for_ng_user_id IS DISTINCT FROM OLD.pic_for_ng_user_id
        OR coalesce(NEW.pic_for_ng_mobile, '') IS DISTINCT FROM coalesce(OLD.pic_for_ng_mobile, '')
      );
    END IF;

    IF v_assignment_changed THEN
      NEW.action_status := 'Assigned';
    END IF;

    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$$;

-- Backfill NG actions already corrupted by the old trigger: rows where the
-- workflow clearly reached closure/verification but action_status was
-- silently reverted to 'Assigned' on the next unrelated write.
UPDATE audit_responses
SET
  action_status = 'Closed',
  updated_at = now()
WHERE result = 'NG'
  AND coalesce(is_void, false) = false
  AND closure_status = 'Closed'
  AND verification_status = 'Verified'
  AND action_status IS DISTINCT FROM 'Closed';

COMMIT;
