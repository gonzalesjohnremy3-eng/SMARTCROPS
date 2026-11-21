-- Close the self-granted Agri Pro hole. A farmer must never be able to set
-- their own subscription tier; only a server-side billing flow may do so.

drop policy if exists "Users can update own user_subscriptions" on public.user_subscriptions;
drop policy if exists "Users can insert own user_subscriptions" on public.user_subscriptions;

create policy "Farmers can create a free subscription"
on public.user_subscriptions for insert
with check (auth.uid() = user_id and tier = 'free');

create policy "Farmers can update their own usage but not their tier"
on public.user_subscriptions for update
using (auth.uid() = user_id and tier = 'free')
with check (auth.uid() = user_id and tier = 'free');

create or replace function public.grant_pro_tester(p_user uuid, p_expires_at timestamptz)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_subscriptions (user_id, tier, expires_at)
  values (p_user, 'premium', p_expires_at)
  on conflict (user_id) do update
    set tier = excluded.tier, expires_at = excluded.expires_at;
end;
$$;

revoke all on function public.grant_pro_tester(uuid, timestamptz) from public, anon, authenticated;
grant execute on function public.grant_pro_tester(uuid, timestamptz) to service_role;
