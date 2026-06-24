create table if not exists app_users (
  id uuid primary key default gen_random_uuid(),
  employee_name text not null,
  mobile_no text not null unique,
  password text,
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

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

create unique index if not exists user_access_mappings_unique_access
  on user_access_mappings (user_id, role, department, location, user_type)
  nulls not distinct;

create index if not exists idx_app_users_mobile_no on app_users (mobile_no);
create index if not exists idx_user_access_mappings_user_id on user_access_mappings (user_id);

drop trigger if exists set_app_users_updated_at on app_users;
create trigger set_app_users_updated_at
  before update on app_users
  for each row execute function set_updated_at();

grant select, insert, update on app_users to anon, authenticated;
grant select, insert, update on user_access_mappings to anon, authenticated;
