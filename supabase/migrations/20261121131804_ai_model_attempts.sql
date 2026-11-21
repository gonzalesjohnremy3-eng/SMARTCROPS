create table public.ai_model_attempts (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    user_id uuid not null references public.profiles(id) on delete cascade,
    key_id uuid references public.ai_keys_pool(id) on delete set null,
    provider text not null,
    model text not null,
    status text not null check (status in ('success', 'error')),
    error text
);

alter table public.ai_model_attempts enable row level security;

create policy "No direct public access to ai_model_attempts" on public.ai_model_attempts
    for all using (false);

create index ai_model_attempts_model_created_at_idx
    on public.ai_model_attempts (model, created_at desc);
