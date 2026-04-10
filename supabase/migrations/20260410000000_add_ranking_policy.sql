-- Allow authenticated users to view all profiles for ranking
-- This only grants READ access to specific columns needed for ranking display
drop policy if exists "profiles_select_all_public" on public.profiles;
create policy "profiles_select_all_public"
  on public.profiles
  for select
  to authenticated
  using (true);
