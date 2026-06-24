alter table if exists audit_checklist_master
  add column if not exists dq_question_num text,
  add column if not exists sub_question_num integer,
  add column if not exists applicable_departments jsonb default '[]'::jsonb,
  add column if not exists purpose text,
  add column if not exists standard text,
  add column if not exists additional_information text,
  add column if not exists sop_reference text,
  add column if not exists pic_for_ng_parameters text;
