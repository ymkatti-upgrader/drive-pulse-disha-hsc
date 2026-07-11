BEGIN;

CREATE OR REPLACE FUNCTION public.sync_finding_from_response()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  audit_row audits%rowtype;
  checklist_row audit_checklist_master%rowtype;
  generated_no text;
  hod_count integer;
  new_hod_id uuid;
  selected_pic_id uuid;
  selected_pic_department_id uuid;
  resolved_audit_uuid uuid;
BEGIN
  resolved_audit_uuid := coalesce(new.audit_uuid, old.audit_uuid);

  IF new.result = 'NG' THEN
    IF resolved_audit_uuid IS NULL THEN
      RETURN new;
    END IF;

    SELECT *
    INTO audit_row
    FROM audits
    WHERE id = resolved_audit_uuid;

    IF audit_row.id IS NULL THEN
      RETURN new;
    END IF;

    SELECT *
    INTO checklist_row
    FROM audit_checklist_master
    WHERE id = new.checklist_id;

    selected_pic_id := coalesce(new.assigned_pic_user_id, new.pic_for_ng_user_id);

    IF selected_pic_id IS NOT NULL THEN
      SELECT u.id, u.department_id
      INTO new_hod_id, selected_pic_department_id
      FROM users u
      WHERE u.id = selected_pic_id
        AND u.is_active = true;

      IF new_hod_id IS NULL THEN
        RAISE EXCEPTION 'Cannot create NG finding because the selected PIC is inactive or invalid.';
      END IF;
    ELSE
      SELECT count(*)
      INTO hod_count
      FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.is_active = true
        AND r.name = 'Location Functional HOD'
        AND u.location_id = audit_row.location_id
        AND u.department_id = audit_row.department_id;

      SELECT u.id, u.department_id
      INTO new_hod_id, selected_pic_department_id
      FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.is_active = true
        AND r.name = 'Location Functional HOD'
        AND u.location_id = audit_row.location_id
        AND u.department_id = audit_row.department_id
      ORDER BY u.id::text
      LIMIT 1;

      IF hod_count = 0 OR new_hod_id IS NULL THEN
        RAISE EXCEPTION 'Cannot create NG finding without an auto-assignable Location Functional HOD.';
      ELSIF hod_count > 1 THEN
        RAISE EXCEPTION 'Location Functional HOD assignment is ambiguous for this finding.';
      END IF;
    END IF;

    IF coalesce(checklist_row.department_owner_id, audit_row.department_id, selected_pic_department_id) IS NULL THEN
      RAISE EXCEPTION 'Cannot create NG finding without an owner department.';
    END IF;

    generated_no := 'NG-' || to_char(now(), 'YYYYMMDDHH24MISS') || '-' || substr(new.id::text, 1, 6);

    INSERT INTO audit_findings (
      finding_no, audit_response_id, audit_id, checklist_id, location_id,
      owner_department_id, location_functional_hod_id, current_condition, auditor_comments, risk_level,
      target_date, created_by
    )
    VALUES (
      generated_no, new.id, resolved_audit_uuid, new.checklist_id, audit_row.location_id,
      coalesce(checklist_row.department_owner_id, audit_row.department_id, selected_pic_department_id),
      new_hod_id,
      new.observation, new.comments, checklist_row.risk_level,
      current_date + CASE WHEN checklist_row.risk_level = 'Critical' THEN 2 ELSE 7 END,
      new.responded_by
    )
    ON CONFLICT (audit_response_id) DO UPDATE
      SET audit_id = excluded.audit_id,
          checklist_id = excluded.checklist_id,
          location_id = excluded.location_id,
          owner_department_id = excluded.owner_department_id,
          location_functional_hod_id = excluded.location_functional_hod_id,
          current_condition = excluded.current_condition,
          auditor_comments = excluded.auditor_comments,
          risk_level = excluded.risk_level,
          updated_at = now();
  ELSIF old.result = 'NG' AND new.result <> 'NG' THEN
    UPDATE audit_findings
      SET status = 'cancelled',
          closed_at = now(),
          updated_at = now()
      WHERE audit_response_id = new.id
        AND status NOT IN ('closed', 'cancelled');
  END IF;

  RETURN new;
END;
$$;

NOTIFY pgrst, 'reload schema';

COMMIT;
