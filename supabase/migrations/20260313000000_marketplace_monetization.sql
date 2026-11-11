-- 8. Merchant Products Table (Affiliate Marketplace)
create table public.merchant_products (
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
create table public.user_subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade unique,
    tier text default 'free' not null, -- 'free', 'premium'
    scans_used_this_week integer default 0 not null,
    expires_at timestamp with time zone,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for performance
create index idx_merchant_products_target_disease on public.merchant_products(target_disease);
create index idx_user_subscriptions_user_id on public.user_subscriptions(user_id);

-- Enable RLS
alter table public.merchant_products enable row level security;
alter table public.user_subscriptions enable row level security;

-- RLS Policies
create policy "Everyone can read merchant_products" on public.merchant_products
    for select using (true);

create policy "Users can view own user_subscriptions" on public.user_subscriptions
    for select using (auth.uid() = user_id);

create policy "Users can update own user_subscriptions" on public.user_subscriptions
    for update using (auth.uid() = user_id);

create policy "Users can insert own user_subscriptions" on public.user_subscriptions
    for insert with check (auth.uid() = user_id);

-- Seed initial affiliate marketplace products
insert into public.merchant_products (product_name, category, target_disease, price, merchant_name, affiliate_link) values
('Organic Neem Oil Concentrate', 'Organic Treatment', 'Leaf Spot', 280.00, 'AgriSupply Philippines', 'https://shopee.ph/search?keyword=neem+oil+organic'),
('Copper Fungicide Powder', 'Fungicide', 'Blight', 350.00, 'GreenFarm Solutions', 'https://shopee.ph/search?keyword=copper+fungicide'),
('Balanced NPK 16-16-16 Fertilizer', 'Fertilizer', 'Nutrient Deficiency', 450.00, 'HarvestKing Agri', 'https://shopee.ph/search?keyword=npk+16+16+16+fertilizer'),
('Bio-Pesticide Bacillus Subtilis', 'Pest Control', 'Powdery Mildew', 320.00, 'EcoAgro PH', 'https://shopee.ph/search?keyword=bacillus+subtilis+bio+fungicide');
