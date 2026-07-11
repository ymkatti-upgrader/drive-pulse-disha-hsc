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
  legacy_hod_count integer := 0;
  legacy_hod_id uuid;
  legacy_hod_department_id uuid;
  selected_pic_id uuid;
  selected_pic_name text;
  selected_pic_mobile text;
  resolved_audit_uuid uuid;
  legacy_owner_department_id uuid;
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

    -- audit_responses/app_users is the current NG assignment source of truth.
    -- audit_findings is legacy compatibility only, so every lookup below is best effort.
    IF selected_pic_id IS NOT NULL THEN
      SELECT au.employee_name, au.mobile_no
      INTO selected_pic_name, selected_pic_mobile
      FROM app_users au
      WHERE au.id = selected_pic_id
        AND coalesce(au.active, true) = true;

      SELECT u.id, u.department_id
      INTO legacy_hod_id, legacy_hod_department_id
      FROM users u
      WHERE u.id = selected_pic_id
        AND u.is_active = true;

      IF legacy_hod_id IS NULL THEN
        SELECT u.id, u.department_id
        INTO legacy_hod_id, legacy_hod_department_id
        FROM users u
        WHERE u.is_active = true
          AND (
            (
              nullif(btrim(coalesce(selected_pic_mobile, '')), '') IS NOT NULL
              AND regexp_replace(coalesce(u.mobile_number, ''), '\D', '', 'g') = regexp_replace(selected_pic_mobile, '\D', '', 'g')
            )
            OR (
              nullif(btrim(coalesce(selected_pic_name, '')), '') IS NOT NULL
              AND lower(btrim(coalesce(u.full_name, ''))) = lower(btrim(selected_pic_name))
            )
          )
        ORDER BY u.id::text
        LIMIT 1;
      END IF;
    ELSE
      SELECT count(*)
      INTO legacy_hod_count
      FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.is_active = true
        AND r.name = 'Location Functional HOD'
        AND u.location_id = audit_row.location_id
        AND (
          audit_row.department_id IS NULL
          OR u.department_id = audit_row.department_id
        );

      IF legacy_hod_count = 1 THEN
        SELECT u.id, u.department_id
        INTO legacy_hod_id, legacy_hod_department_id
        FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE u.is_active = true
          AND r.name = 'Location Functional HOD'
          AND u.location_id = audit_row.location_id
          AND (
            audit_row.department_id IS NULL
            OR u.department_id = audit_row.department_id
          )
        ORDER BY u.id::text
        LIMIT 1;
      END IF;
    END IF;

    legacy_owner_department_id := coalesce(
      checklist_row.department_owner_id,
      audit_row.department_id,
      legacy_hod_department_id
    );

    IF legacy_hod_id IS NULL OR legacy_owner_department_id IS NULL THEN
      RETURN new;
    END IF;

    generated_no := 'NG-' || to_char(now(), 'YYYYMMDDHH24MISS') || '-' || substr(new.id::text, 1, 6);

    BEGIN
      INSERT INTO audit_findings (
        finding_no, audit_response_id, audit_id, checklist_id, location_id,
        owner_department_id, location_functional_hod_id, current_condition, auditor_comments, risk_level,
        target_date, created_by
      )
      VALUES (
        generated_no, new.id, resolved_audit_uuid, new.checklist_id, audit_row.location_id,
        legacy_owner_department_id,
        legacy_hod_id,
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
    EXCEPTION WHEN OTHERS THEN
      RETURN new;
    END;
  ELSIF TG_OP = 'UPDATE' AND old.result = 'NG' AND new.result IS DISTINCT FROM 'NG' THEN
    BEGIN
      UPDATE audit_findings
        SET status = 'cancelled',
            closed_at = now(),
            updated_at = now()
        WHERE audit_response_id = new.id
          AND status NOT IN ('closed', 'cancelled');
    EXCEPTION WHEN OTHERS THEN
      RETURN new;
    END;
  END IF;

  RETURN new;
END;
$$;

NOTIFY pgrst, 'reload schema';

COMMIT;
