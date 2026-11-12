-- Phone OTP sign-ups have no email address, so profiles.email must be nullable.
alter table if exists public.profiles
  alter column email drop not null;

-- Keep the profile-creation trigger compatible with phone-only accounts and
-- capture the verified phone number from auth.users.phone.
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
    coalesce(new.raw_user_meta_data ->> 'phone_number', new.phone),
    new.raw_user_meta_data ->> 'farm_name',
    new.raw_user_meta_data ->> 'location'
  );
  return new;
end;
$$;
