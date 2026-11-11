-- 10. Cooperative Admins Table
create table if not exists public.cooperative_admins (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade unique,
    cooperative_name text not null,
    region text not null,
    role text default 'admin' not null, -- 'admin', 'extension_officer'
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 11. Cooperative Members Table (Linking Farmers to Cooperatives)
create table if not exists public.cooperative_members (
    id uuid primary key default gen_random_uuid(),
    cooperative_id uuid not null references public.cooperative_admins(id) on delete cascade,
    farmer_id uuid not null references public.profiles(id) on delete cascade,
    joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
    constraint unique_coop_member unique (cooperative_id, farmer_id)
);

-- 12. Broadcast Advisories Table (Bulk alerts sent by cooperative admins)
create table if not exists public.broadcast_advisories (
    id uuid primary key default gen_random_uuid(),
    cooperative_id uuid not null references public.cooperative_admins(id) on delete cascade,
    title text not null,
    message text not null,
    severity text default 'Warning' not null, -- 'Critical', 'Warning', 'Info'
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for performance
create index if not exists idx_cooperative_admins_user_id on public.cooperative_admins(user_id);
create index if not exists idx_cooperative_members_coop_id on public.cooperative_members(cooperative_id);
create index if not exists idx_broadcast_advisories_coop_id on public.broadcast_advisories(cooperative_id);

-- Enable RLS
alter table public.cooperative_admins enable row level security;
alter table public.cooperative_members enable row level security;
alter table public.broadcast_advisories enable row level security;

-- RLS Policies (Idempotent check)
do $$ 
begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'cooperative_admins' and policyname = 'Cooperative admins can manage own record') then
    create policy "Cooperative admins can manage own record" on public.cooperative_admins for all using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'cooperative_members' and policyname = 'Cooperative members viewable by admins and members') then
    create policy "Cooperative members viewable by admins and members" on public.cooperative_members for select using (auth.uid() = farmer_id or exists (select 1 from public.cooperative_admins ca where ca.id = cooperative_id and ca.user_id = auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'broadcast_advisories' and policyname = 'Broadcast advisories readable by all authenticated users') then
    create policy "Broadcast advisories readable by all authenticated users" on public.broadcast_advisories for select using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'broadcast_advisories' and policyname = 'Cooperative admins can insert broadcast advisories') then
    create policy "Cooperative admins can insert broadcast advisories" on public.broadcast_advisories for insert with check (exists (select 1 from public.cooperative_admins ca where ca.id = cooperative_id and ca.user_id = auth.uid()));
  end if;
end $$;
