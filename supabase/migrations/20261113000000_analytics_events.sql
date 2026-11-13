-- Analytics events table (ADR 0009): privacy-safe snake_case event names, no PII by construction.
-- Events carry params such as crop, disease, confidence_bucket, severity, source_screen, language, tier, app_version.
-- No names, phone numbers, images, precise coordinates, or other personal identifiers are ever stored here.
-- Dashboards must state their basis and date range.

create table if not exists public.analytics_events (
    id uuid primary key default gen_random_uuid(),
    event text not null,
    params jsonb not null default '{}'::jsonb,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index if not exists idx_analytics_events_event on public.analytics_events(event);
create index if not exists idx_analytics_events_created_at on public.analytics_events(created_at desc);

alter table public.analytics_events enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'analytics_events' and policyname = 'Authenticated farmers can insert events') then
    create policy "Authenticated farmers can insert events" on public.analytics_events
      for insert with check (auth.role() = 'authenticated');
  end if;
end $$;
