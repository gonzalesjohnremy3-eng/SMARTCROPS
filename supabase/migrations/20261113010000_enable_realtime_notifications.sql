-- Enable Supabase Realtime on the notifications table (blueprint Sec 4, Phase 2).
-- Idempotent: adds the table to the supabase_realtime publication only when missing.

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (
      select 1
      from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'notifications'
    ) then
      alter publication supabase_realtime add table public.notifications;
    end if;
  end if;
end $$;
