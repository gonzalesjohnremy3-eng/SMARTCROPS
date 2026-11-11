-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- 1. Profiles Table (Linked to Supabase Auth)
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    full_name text not null,
    email text not null,
    phone_number text,
    farm_name text,
    location text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Crops Table (Master Catalog)
create table public.crops (
    id uuid primary key default gen_random_uuid(),
    crop_name text not null unique,
    optimal_conditions jsonb default '{}'::jsonb,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. User Crops Table (Many-to-Many relation for user's main crops)
create table public.user_crops (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    crop_id uuid not null references public.crops(id) on delete cascade,
    added_at timestamp with time zone default timezone('utc'::text, now()) not null,
    constraint unique_user_crop unique (user_id, crop_id)
);

-- 4. Scan History Table
create table public.scan_history (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    image_url text not null,
    disease_detected text not null,
    confidence_score numeric(5,2) not null,
    common_crop text not null,
    recommended_actions jsonb default '[]'::jsonb,
    scanned_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Notifications Table
create table public.notifications (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    title text not null,
    message text not null,
    scan_id uuid references public.scan_history(id) on delete set null,
    is_read boolean default false not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 6. AI Keys Pool Table (Backend management for multi-API key rotation)
create table public.ai_keys_pool (
    id uuid primary key default gen_random_uuid(),
    provider text not null, -- 'OpenAI', 'Gemini'
    api_key_encrypted text not null,
    daily_quota_limit integer default 100 not null,
    current_usage_count integer default 0 not null,
    is_active boolean default true not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for performance (Postgres best practices)
create index idx_user_crops_user_id on public.user_crops(user_id);
create index idx_scan_history_user_id on public.scan_history(user_id);
create index idx_scan_history_scanned_at on public.scan_history(scanned_at desc);
create index idx_notifications_user_id on public.notifications(user_id);
create index idx_notifications_created_at on public.notifications(created_at desc);

-- Enable Row Level Security (RLS) on all user-facing tables
alter table public.profiles enable row level security;
alter table public.crops enable row level security;
alter table public.user_crops enable row level security;
alter table public.scan_history enable row level security;
alter table public.notifications enable row level security;
alter table public.ai_keys_pool enable row level security;

-- RLS Policies

-- Profiles: Users can view and update their own profile
create policy "Users can view own profile" on public.profiles
    for select using (auth.uid() = id);

create policy "Users can insert own profile" on public.profiles
    for insert with check (auth.uid() = id);

create policy "Users can update own profile" on public.profiles
    for update using (auth.uid() = id);

-- Crops: Everyone can read master crops catalog
create policy "Everyone can read crops catalog" on public.crops
    for select using (true);

-- User Crops: Users manage their own selected crops
create policy "Users can view own user_crops" on public.user_crops
    for select using (auth.uid() = user_id);

create policy "Users can insert own user_crops" on public.user_crops
    for insert with check (auth.uid() = user_id);

create policy "Users can delete own user_crops" on public.user_crops
    for delete using (auth.uid() = user_id);

-- Scan History: Users view and insert their own scan history
create policy "Users can view own scan_history" on public.scan_history
    for select using (auth.uid() = user_id);

create policy "Users can insert own scan_history" on public.scan_history
    for insert with check (auth.uid() = user_id);

-- Notifications: Users view and update their own notifications
create policy "Users can view own notifications" on public.notifications
    for select using (auth.uid() = user_id);

create policy "Users can update own notifications" on public.notifications
    for update using (auth.uid() = user_id);

create policy "Users can insert own notifications" on public.notifications
    for insert with check (auth.uid() = user_id);

-- AI Keys Pool: Only accessible by service role / edge functions (no public access)
create policy "No direct public access to ai_keys_pool" on public.ai_keys_pool
    for all using (false);

-- Function & Trigger to automatically create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email, phone_number, farm_name, location)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', 'Farmer'),
    new.email,
    new.raw_user_meta_data ->> 'phone_number',
    new.raw_user_meta_data ->> 'farm_name',
    new.raw_user_meta_data ->> 'location'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Seed initial master crops data
insert into public.crops (crop_name, optimal_conditions) values
('Pechay', '{"temperature_range": "15-25°C", "soil": "Rich, well-drained loam", "watering": "Regular, keep moist"}'::jsonb),
('Corn', '{"temperature_range": "20-30°C", "soil": "Deep, fertile, well-drained", "watering": "Moderate to high"}'::jsonb),
('Rice', '{"temperature_range": "20-35°C", "soil": "Clayey loam, water-retaining", "watering": "Submerged/Paddy flooding"}'::jsonb),
('Tomato', '{"temperature_range": "18-27°C", "soil": "Silt loam, pH 6.0-6.8", "watering": "Consistent moisture, avoid leaf wetting"}'::jsonb),
('Eggplant', '{"temperature_range": "22-30°C", "soil": "Sandy loam, rich in organic matter", "watering": "Regular watering"}'::jsonb);
