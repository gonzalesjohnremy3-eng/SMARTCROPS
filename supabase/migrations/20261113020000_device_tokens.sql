-- Device tokens for FCM push delivery (Phase 2).
-- The app uploads the signed-in user's token on startup and on refresh.
-- Campaign senders use the service role only; users can never read other users' tokens.

create table if not exists public.device_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    token text not null,
    platform text not null default 'android',
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique (user_id, token)
);

create index if not exists idx_device_tokens_user_id on public.device_tokens(user_id);

alter table public.device_tokens enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'device_tokens' and policyname = 'Users can view own device_tokens') then
    create policy "Users can view own device_tokens" on public.device_tokens
      for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'device_tokens' and policyname = 'Users can insert own device_tokens') then
    create policy "Users can insert own device_tokens" on public.device_tokens
      for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'device_tokens' and policyname = 'Users can update own device_tokens') then
    create policy "Users can update own device_tokens" on public.device_tokens
      for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'device_tokens' and policyname = 'Users can delete own device_tokens') then
    create policy "Users can delete own device_tokens" on public.device_tokens
      for delete using (auth.uid() = user_id);
  end if;
end $$;
