-- Profile photos.
-- The client uploads to avatars/<user_id>/avatar.<ext> (a replacement overwrites
-- the same object) and stores the public URL in profiles.avatar_url.
alter table public.profiles
    add column if not exists avatar_url text;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update
set public = excluded.public;

-- Authenticated farmers can add a photo only inside their own folder.
drop policy if exists "Users can upload own avatar" on storage.objects;
create policy "Users can upload own avatar"
on storage.objects for insert
to authenticated
with check (
    bucket_id = 'avatars'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);

-- Replacing a photo (upsert) needs read and update on the same folder.
drop policy if exists "Users can read own avatar" on storage.objects;
create policy "Users can read own avatar"
on storage.objects for select
to authenticated
using (
    bucket_id = 'avatars'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can update own avatar" on storage.objects;
create policy "Users can update own avatar"
on storage.objects for update
to authenticated
using (
    bucket_id = 'avatars'
    and (select auth.uid())::text = (storage.foldername(name))[1]
)
with check (
    bucket_id = 'avatars'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);

-- Authenticated farmers can delete only their own photo.
drop policy if exists "Users can delete own avatar" on storage.objects;
create policy "Users can delete own avatar"
on storage.objects for delete
to authenticated
using (
    bucket_id = 'avatars'
    and (select auth.uid())::text = (storage.foldername(name))[1]
);
