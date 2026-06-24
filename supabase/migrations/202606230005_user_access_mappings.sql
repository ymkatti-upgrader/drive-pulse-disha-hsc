alter table app_users
  drop column if exists role;

create table if not exists user_access_mappings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references app_users(id) on delete cascade,
  role text,
  department text,
  location text,
  user_type text,
  active boolean default true,
  created_at timestamptz default now()
);

do $$
begin
  if to_regclass('public.user_location_mappings') is not null then
    insert into user_access_mappings (user_id, role, department, location, user_type, active, created_at)
    select distinct on (user_id, department, location, user_type)
      user_id, null, department, location, user_type, active, created_at
    from user_location_mappings
    order by user_id, department, location, user_type, created_at desc
    on conflict do nothing;
  end if;
end;
$$;

create unique index if not exists user_access_mappings_unique_access
  on user_access_mappings (user_id, role, department, location, user_type)
  nulls not distinct;

create index if not exists idx_user_access_mappings_user_id on user_access_mappings (user_id);

grant select, insert, update on user_access_mappings to anon, authenticated;
