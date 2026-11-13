-- Storage bucket for crop scan images.
-- The client uploads to <user_id>/<uuid>.jpg and receives a public URL that is
-- passed to the scan-crop Edge Function, which never sees the raw file bytes.
insert into storage.buckets (id, name, public)
values ('scan-images', 'scan-images', true)
on conflict (id) do update
set public = excluded.public;

-- Authenticated farmers can upload only into their own folder.
drop policy if exists "Users can upload own scan images" on storage.objects;
create policy "Users can upload own scan images"
on storage.objects for insert
to authenticated
with check (
    bucket_id = 'scan-images'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);

-- Authenticated farmers can read only their own images.
drop policy if exists "Users can read own scan images" on storage.objects;
create policy "Users can read own scan images"
on storage.objects for select
to authenticated
using (
    bucket_id = 'scan-images'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);

-- Authenticated farmers can delete only their own images.
drop policy if exists "Users can delete own scan images" on storage.objects;
create policy "Users can delete own scan images"
on storage.objects for delete
to authenticated
using (
    bucket_id = 'scan-images'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);
