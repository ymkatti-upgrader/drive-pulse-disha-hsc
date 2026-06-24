alter table app_users enable row level security;
alter table user_access_mappings enable row level security;

drop policy if exists "public read app users" on app_users;
drop policy if exists "public insert app users" on app_users;
drop policy if exists "public update app users" on app_users;

create policy "public read app users" on app_users
  for select
  using (true);

create policy "public insert app users" on app_users
  for insert
  with check (true);

create policy "public update app users" on app_users
  for update
  using (true)
  with check (true);

drop policy if exists "public read user access mappings" on user_access_mappings;
drop policy if exists "public insert user access mappings" on user_access_mappings;
drop policy if exists "public update user access mappings" on user_access_mappings;

create policy "public read user access mappings" on user_access_mappings
  for select
  using (true);

create policy "public insert user access mappings" on user_access_mappings
  for insert
  with check (true);

create policy "public update user access mappings" on user_access_mappings
  for update
  using (true)
  with check (true);
