-- Rolls back two earlier migrations, on request:
--   20261122000000_close_self_granted_premium
--   20261128000000_profile_avatars

-- 1) close_self_granted_premium: let farmers set their own subscription again.
--    This re-opens the self-granted Agri Pro hole.
drop policy if exists "Farmers can create a free subscription" on public.user_subscriptions;
drop policy if exists "Farmers can update their own usage but not their tier" on public.user_subscriptions;

drop policy if exists "Users can update own user_subscriptions" on public.user_subscriptions;
create policy "Users can update own user_subscriptions"
  on public.user_subscriptions for update using (auth.uid() = user_id);

drop policy if exists "Users can insert own user_subscriptions" on public.user_subscriptions;
create policy "Users can insert own user_subscriptions"
  on public.user_subscriptions for insert with check (auth.uid() = user_id);

-- 2) profile_avatars: remove the policies and the column.
--    This permanently deletes every saved avatar_url. The `avatars` storage
--    bucket and its files are left alone (remove them from the dashboard).
drop policy if exists "Users can upload own avatar" on storage.objects;
drop policy if exists "Users can read own avatar" on storage.objects;
drop policy if exists "Users can update own avatar" on storage.objects;
drop policy if exists "Users can delete own avatar" on storage.objects;

alter table public.profiles drop column if exists avatar_url;
