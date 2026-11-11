-- 7. Crop Calendar Events Table (Personalized Crop Calendar Feature)
create table if not exists public.crop_calendar_events (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    crop_id uuid references public.crops(id) on delete set null,
    event_title text not null,
    event_category text not null, -- 'Nutrition', 'Water Management', 'Pest Control', 'Harvesting'
    scheduled_date timestamp with time zone not null,
    is_completed boolean default false not null,
    priority text default 'Normal' not null, -- 'High', 'Normal', 'Weather-Adjusted'
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index for performance
create index if not exists idx_crop_calendar_user_id on public.crop_calendar_events(user_id);
create index if not exists idx_crop_calendar_scheduled_date on public.crop_calendar_events(scheduled_date asc);

-- Enable RLS
alter table public.crop_calendar_events enable row level security;

-- RLS Policies (Idempotent check)
do $$ 
begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'crop_calendar_events' and policyname = 'Users can view own crop_calendar_events') then
    create policy "Users can view own crop_calendar_events" on public.crop_calendar_events for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'crop_calendar_events' and policyname = 'Users can insert own crop_calendar_events') then
    create policy "Users can insert own crop_calendar_events" on public.crop_calendar_events for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'crop_calendar_events' and policyname = 'Users can update own crop_calendar_events') then
    create policy "Users can update own crop_calendar_events" on public.crop_calendar_events for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'crop_calendar_events' and policyname = 'Users can delete own crop_calendar_events') then
    create policy "Users can delete own crop_calendar_events" on public.crop_calendar_events for delete using (auth.uid() = user_id);
  end if;
end $$;
