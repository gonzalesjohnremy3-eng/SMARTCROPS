-- 8. Merchant Products Table (Affiliate Marketplace)
create table if not exists public.merchant_products (
    id uuid primary key default gen_random_uuid(),
    product_name text not null,
    category text not null, -- 'Fungicide', 'Fertilizer', 'Organic Treatment'
    target_disease text not null,
    price numeric(10,2) not null,
    merchant_name text not null,
    affiliate_link text not null,
    image_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 9. User Subscriptions Table (Freemium & Quota Tracking)
create table if not exists public.user_subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade unique,
    tier text default 'free' not null, -- 'free', 'premium'
    scans_used_this_week integer default 0 not null,
    expires_at timestamp with time zone,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for performance
create index if not exists idx_merchant_products_target_disease on public.merchant_products(target_disease);
create index if not exists idx_user_subscriptions_user_id on public.user_subscriptions(user_id);

-- Enable RLS
alter table public.merchant_products enable row level security;
alter table public.user_subscriptions enable row level security;

-- RLS Policies (Idempotent check)
do $$ 
begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'merchant_products' and policyname = 'Everyone can read merchant_products') then
    create policy "Everyone can read merchant_products" on public.merchant_products for select using (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'user_subscriptions' and policyname = 'Users can view own user_subscriptions') then
    create policy "Users can view own user_subscriptions" on public.user_subscriptions for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'user_subscriptions' and policyname = 'Users can update own user_subscriptions') then
    create policy "Users can update own user_subscriptions" on public.user_subscriptions for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'user_subscriptions' and policyname = 'Users can insert own user_subscriptions') then
    create policy "Users can insert own user_subscriptions" on public.user_subscriptions for insert with check (auth.uid() = user_id);
  end if;
end $$;

-- Seed initial affiliate marketplace products (insert if not exists by product_name)
insert into public.merchant_products (product_name, category, target_disease, price, merchant_name, affiliate_link)
select 'Organic Neem Oil Concentrate', 'Organic Treatment', 'Leaf Spot', 280.00, 'AgriSupply Philippines', 'https://shopee.ph/search?keyword=neem+oil+organic'
where not exists (select 1 from public.merchant_products where product_name = 'Organic Neem Oil Concentrate');

insert into public.merchant_products (product_name, category, target_disease, price, merchant_name, affiliate_link)
select 'Copper Fungicide Powder', 'Fungicide', 'Blight', 350.00, 'GreenFarm Solutions', 'https://shopee.ph/search?keyword=copper+fungicide'
where not exists (select 1 from public.merchant_products where product_name = 'Copper Fungicide Powder');

insert into public.merchant_products (product_name, category, target_disease, price, merchant_name, affiliate_link)
select 'Balanced NPK 16-16-16 Fertilizer', 'Fertilizer', 'Nutrient Deficiency', 450.00, 'HarvestKing Agri', 'https://shopee.ph/search?keyword=npk+16+16+16+fertilizer'
where not exists (select 1 from public.merchant_products where product_name = 'Balanced NPK 16-16-16 Fertilizer');

insert into public.merchant_products (product_name, category, target_disease, price, merchant_name, affiliate_link)
select 'Bio-Pesticide Bacillus Subtilis', 'Pest Control', 'Powdery Mildew', 320.00, 'EcoAgro PH', 'https://shopee.ph/search?keyword=bacillus+subtilis+bio+fungicide'
where not exists (select 1 from public.merchant_products where product_name = 'Bio-Pesticide Bacillus Subtilis');
