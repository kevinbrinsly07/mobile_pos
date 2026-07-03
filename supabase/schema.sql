-- Modern Android POS (Flutter + Supabase)
-- Run in Supabase SQL Editor.

create extension if not exists pgcrypto;

-- =========================
-- Core org + store + profile
-- =========================
create table if not exists organizations (
  id bigint generated always as identity primary key,
  name text not null,
  timezone text not null default 'UTC',
  currency text not null default 'USD',
  tax_rate_default integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists stores (
  id bigint generated always as identity primary key,
  organization_id bigint not null references organizations(id) on delete cascade,
  name text not null,
  address text,
  phone text,
  created_at timestamptz not null default now()
);

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  organization_id bigint not null references organizations(id) on delete restrict,
  store_id bigint not null references stores(id) on delete restrict,
  full_name text not null default '',
  email text,
  role text not null check (role in ('owner', 'admin', 'manager', 'cashier')) default 'cashier',
  pin_code_hash text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- =========================
-- Catalog
-- =========================
create table if not exists categories (
  id bigint generated always as identity primary key,
  store_id bigint not null references stores(id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique(store_id, name)
);

create table if not exists products (
  id bigint generated always as identity primary key,
  store_id bigint not null references stores(id) on delete cascade,
  name text not null,
  sku text,
  barcode text,
  category_id bigint references categories(id) on delete set null,
  price integer not null,
  cost integer not null default 0,
  tax_rate integer not null default 0,
  stock_qty integer not null default 0,
  low_stock_threshold integer not null default 0,
  unit text not null default 'each',
  image_url text,
  is_active boolean not null default true,
  has_variants boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_products_store on products(store_id);
create index if not exists idx_products_barcode on products(barcode);

create table if not exists product_variants (
  id bigint generated always as identity primary key,
  product_id bigint not null references products(id) on delete cascade,
  name text not null,
  price_delta integer not null default 0,
  sku text,
  stock_qty integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists modifiers (
  id bigint generated always as identity primary key,
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists product_modifiers (
  product_id bigint not null references products(id) on delete cascade,
  modifier_id bigint not null references modifiers(id) on delete cascade,
  price_delta integer not null default 0,
  primary key (product_id, modifier_id)
);

-- =========================
-- Procurement + customers + discounts
-- =========================
create table if not exists suppliers (
  id bigint generated always as identity primary key,
  name text not null,
  phone text,
  email text,
  created_at timestamptz not null default now()
);

create table if not exists purchase_orders (
  id bigint generated always as identity primary key,
  supplier_id bigint not null references suppliers(id) on delete restrict,
  store_id bigint not null references stores(id) on delete cascade,
  status text not null check (status in ('draft', 'ordered', 'received', 'cancelled')) default 'draft',
  created_at timestamptz not null default now()
);

create table if not exists purchase_order_items (
  id bigint generated always as identity primary key,
  purchase_order_id bigint not null references purchase_orders(id) on delete cascade,
  product_id bigint not null references products(id) on delete restrict,
  qty integer not null,
  unit_cost integer not null,
  received_qty integer not null default 0
);

create table if not exists customers (
  id bigint generated always as identity primary key,
  store_id bigint not null references stores(id) on delete cascade,
  name text not null,
  phone text,
  email text,
  loyalty_points integer not null default 0,
  total_spent integer not null default 0,
  visits integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists discounts (
  id bigint generated always as identity primary key,
  store_id bigint not null references stores(id) on delete cascade,
  name text not null,
  type text not null check (type in ('percent', 'flat')),
  value integer not null,
  applies_to text not null check (applies_to in ('cart', 'product', 'category')),
  promo_code text,
  min_purchase integer not null default 0,
  active_from timestamptz,
  active_to timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- =========================
-- Shift + sales
-- =========================
create table if not exists shifts (
  id bigint generated always as identity primary key,
  cashier_id uuid not null references profiles(id) on delete restrict,
  store_id bigint not null references stores(id) on delete cascade,
  opening_float integer not null,
  closing_float integer,
  opened_at timestamptz not null default now(),
  closed_at timestamptz,
  status text not null check (status in ('open', 'closed')) default 'open'
);

create table if not exists sales (
  id bigint generated always as identity primary key,
  store_id bigint not null references stores(id) on delete cascade,
  shift_id bigint references shifts(id) on delete set null,
  cashier_id uuid not null references profiles(id) on delete restrict,
  customer_id bigint references customers(id) on delete set null,
  subtotal integer not null,
  discount_total integer not null default 0,
  tax_total integer not null default 0,
  total integer not null,
  payment_method text not null check (payment_method in ('cash', 'card', 'mobile_wallet', 'split')),
  amount_tendered integer not null default 0,
  change_due integer not null default 0,
  status text not null check (status in ('completed', 'refunded', 'voided', 'held')) default 'completed',
  receipt_number text,
  created_at timestamptz not null default now()
);

create table if not exists sale_items (
  id bigint generated always as identity primary key,
  sale_id bigint not null references sales(id) on delete cascade,
  product_id bigint not null references products(id) on delete restrict,
  variant_id bigint references product_variants(id) on delete set null,
  product_name text not null,
  unit_price integer not null,
  quantity integer not null,
  modifiers_snapshot jsonb not null default '[]'::jsonb,
  discount_applied integer not null default 0,
  line_total integer not null
);

create table if not exists sale_payments (
  id bigint generated always as identity primary key,
  sale_id bigint not null references sales(id) on delete cascade,
  method text not null check (method in ('cash', 'card', 'mobile_wallet')),
  amount integer not null
);

create table if not exists stock_movements (
  id bigint generated always as identity primary key,
  product_id bigint not null references products(id) on delete restrict,
  change_qty integer not null,
  reason text not null check (reason in ('sale', 'restock', 'adjustment', 'refund', 'transfer')),
  reference_id text,
  created_by uuid references profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists loyalty_transactions (
  id bigint generated always as identity primary key,
  customer_id bigint not null references customers(id) on delete cascade,
  points_change integer not null,
  reason text not null,
  sale_id bigint references sales(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists audit_log (
  id bigint generated always as identity primary key,
  user_id uuid references profiles(id) on delete set null,
  action text not null,
  table_name text not null,
  record_id text,
  details jsonb,
  created_at timestamptz not null default now()
);

-- =========================
-- Helper functions
-- =========================
create or replace function current_profile()
returns profiles
language sql
stable
as $$
  select * from profiles where id = auth.uid() limit 1;
$$;

create or replace function is_admin_like()
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from profiles p
    where p.id = auth.uid()
      and p.role in ('owner', 'admin')
      and p.is_active = true
  );
$$;

create or replace function can_access_store(target_store_id bigint)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from profiles p
    where p.id = auth.uid()
      and p.is_active = true
      and (
        (p.role in ('owner','admin') and exists (
          select 1 from stores s where s.id = target_store_id and s.organization_id = p.organization_id
        ))
        or p.store_id = target_store_id
      )
  );
$$;

create table if not exists receipt_sequences (
  store_id bigint primary key references stores(id) on delete cascade,
  last_number bigint not null default 0
);

create or replace function next_receipt_number(p_store_id bigint)
returns text
language plpgsql
security definer
as $$
declare
  next_num bigint;
begin
  insert into receipt_sequences(store_id, last_number)
  values (p_store_id, 0)
  on conflict (store_id) do nothing;

  update receipt_sequences
  set last_number = last_number + 1
  where store_id = p_store_id
  returning last_number into next_num;

  return 'S' || p_store_id::text || '-' || lpad(next_num::text, 8, '0');
end;
$$;

create or replace function set_receipt_number()
returns trigger
language plpgsql
as $$
begin
  if new.receipt_number is null then
    new.receipt_number := next_receipt_number(new.store_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_sales_receipt_number on sales;
create trigger trg_sales_receipt_number
before insert on sales
for each row execute function set_receipt_number();

create or replace function log_stock_on_sale_item()
returns trigger
language plpgsql
as $$
begin
  update products
  set stock_qty = stock_qty - new.quantity
  where id = new.product_id;

  insert into stock_movements(product_id, change_qty, reason, reference_id, created_by)
  select new.product_id, -new.quantity, 'sale', new.sale_id::text, s.cashier_id
  from sales s where s.id = new.sale_id;

  return new;
end;
$$;

drop trigger if exists trg_sale_item_stock on sale_items;
create trigger trg_sale_item_stock
after insert on sale_items
for each row execute function log_stock_on_sale_item();

create or replace function reverse_stock_on_refund()
returns trigger
language plpgsql
as $$
begin
  if old.status <> 'refunded' and new.status = 'refunded' then
    update products p
    set stock_qty = p.stock_qty + si.quantity
    from sale_items si
    where si.sale_id = new.id
      and si.product_id = p.id;

    insert into stock_movements(product_id, change_qty, reason, reference_id, created_by)
    select si.product_id, si.quantity, 'refund', new.id::text, auth.uid()
    from sale_items si
    where si.sale_id = new.id;
  end if;

  if old.status <> 'voided' and new.status = 'voided' then
    update products p
    set stock_qty = p.stock_qty + si.quantity
    from sale_items si
    where si.sale_id = new.id
      and si.product_id = p.id;

    insert into stock_movements(product_id, change_qty, reason, reference_id, created_by)
    select si.product_id, si.quantity, 'refund', new.id::text, auth.uid()
    from sale_items si
    where si.sale_id = new.id;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_sales_reverse_stock on sales;
create trigger trg_sales_reverse_stock
after update on sales
for each row execute function reverse_stock_on_refund();

create or replace function create_profile_on_signup()
returns trigger
language plpgsql
security definer
as $$
declare
  first_org_id bigint;
  first_store_id bigint;
begin
  select id into first_org_id from organizations order by id limit 1;
  select id into first_store_id from stores where organization_id = first_org_id order by id limit 1;

  insert into profiles(id, full_name, email, role, organization_id, store_id)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.email,
    'cashier',
    first_org_id,
    first_store_id
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function create_profile_on_signup();

create or replace function adjust_stock(p_product_id bigint, p_change_qty integer, p_reason text)
returns void
language plpgsql
security definer
as $$
begin
  update products set stock_qty = stock_qty + p_change_qty where id = p_product_id;

  insert into stock_movements(product_id, change_qty, reason, reference_id, created_by)
  values (p_product_id, p_change_qty, p_reason, null, auth.uid());
end;
$$;

create or replace function create_sale_with_items(
  p_store_id bigint,
  p_shift_id bigint,
  p_cashier_id uuid,
  p_customer_id bigint,
  p_subtotal integer,
  p_discount_total integer,
  p_tax_total integer,
  p_total integer,
  p_amount_tendered integer,
  p_change_due integer,
  p_items jsonb,
  p_payments jsonb
)
returns bigint
language plpgsql
security definer
as $$
declare
  v_sale_id bigint;
  v_payment_method text := 'split';
  item jsonb;
  pay jsonb;
begin
  if jsonb_array_length(p_payments) = 1 then
    v_payment_method := case
      when (p_payments->0->>'method') = 'mobileWallet' then 'mobile_wallet'
      else lower(p_payments->0->>'method')
    end;
  end if;

  insert into sales(
    store_id, shift_id, cashier_id, customer_id, subtotal, discount_total, tax_total,
    total, payment_method, amount_tendered, change_due, status
  )
  values (
    p_store_id, p_shift_id, p_cashier_id, p_customer_id, p_subtotal, p_discount_total,
    p_tax_total, p_total, v_payment_method, p_amount_tendered, p_change_due, 'completed'
  )
  returning id into v_sale_id;

  for item in select * from jsonb_array_elements(p_items)
  loop
    insert into sale_items(
      sale_id, product_id, variant_id, product_name, unit_price, quantity,
      modifiers_snapshot, discount_applied, line_total
    )
    values (
      v_sale_id,
      (item->>'product_id')::bigint,
      nullif(item->>'variant_id', '')::bigint,
      item->>'product_name',
      (item->>'unit_price')::integer,
      (item->>'quantity')::integer,
      coalesce(item->'modifiers_snapshot', '[]'::jsonb),
      coalesce((item->>'discount_applied')::integer, 0),
      (item->>'line_total')::integer
    );
  end loop;

  for pay in select * from jsonb_array_elements(p_payments)
  loop
    insert into sale_payments(sale_id, method, amount)
    values (
      v_sale_id,
      case
        when lower(pay->>'method') = 'mobilewallet' then 'mobile_wallet'
        else lower(pay->>'method')
      end,
      (pay->>'amount')::integer
    );
  end loop;

  if p_customer_id is not null then
    update customers
    set loyalty_points = loyalty_points + floor(p_total / 100)::integer,
        total_spent = total_spent + p_total,
        visits = visits + 1
    where id = p_customer_id;

    insert into loyalty_transactions(customer_id, points_change, reason, sale_id)
    values (p_customer_id, floor(p_total / 100)::integer, 'purchase', v_sale_id);
  end if;

  return v_sale_id;
end;
$$;

create or replace function refund_sale(p_sale_id bigint, p_reason text)
returns void
language plpgsql
security definer
as $$
begin
  update sales
  set status = 'refunded'
  where id = p_sale_id
    and status = 'completed';

  insert into audit_log(user_id, action, table_name, record_id, details)
  values (auth.uid(), 'refund', 'sales', p_sale_id::text, jsonb_build_object('reason', p_reason));
end;
$$;

create or replace function sales_summary(p_store_id bigint)
returns table(
  revenue_cents integer,
  transactions integer,
  avg_basket_cents integer,
  cash_cents integer,
  card_cents integer,
  wallet_cents integer
)
language sql
stable
as $$
  with s as (
    select *
    from sales
    where store_id = p_store_id
      and status = 'completed'
      and created_at::date = current_date
  )
  select
    coalesce(sum(total), 0)::integer as revenue_cents,
    count(*)::integer as transactions,
    coalesce(avg(total), 0)::integer as avg_basket_cents,
    coalesce(sum(case when payment_method = 'cash' then total else 0 end), 0)::integer as cash_cents,
    coalesce(sum(case when payment_method = 'card' then total else 0 end), 0)::integer as card_cents,
    coalesce(sum(case when payment_method = 'mobile_wallet' then total else 0 end), 0)::integer as wallet_cents
  from s;
$$;

create or replace function top_products(p_store_id bigint, p_limit integer default 10)
returns table(product_name text, qty_sold integer)
language sql
stable
as $$
  select si.product_name, sum(si.quantity)::integer as qty_sold
  from sale_items si
  join sales s on s.id = si.sale_id
  where s.store_id = p_store_id
    and s.status = 'completed'
  group by si.product_name
  order by qty_sold desc
  limit p_limit;
$$;

-- =========================
-- RLS
-- =========================
alter table organizations enable row level security;
alter table stores enable row level security;
alter table profiles enable row level security;
alter table categories enable row level security;
alter table products enable row level security;
alter table product_variants enable row level security;
alter table modifiers enable row level security;
alter table product_modifiers enable row level security;
alter table suppliers enable row level security;
alter table purchase_orders enable row level security;
alter table purchase_order_items enable row level security;
alter table customers enable row level security;
alter table discounts enable row level security;
alter table shifts enable row level security;
alter table sales enable row level security;
alter table sale_items enable row level security;
alter table sale_payments enable row level security;
alter table receipt_sequences enable row level security;
alter table stock_movements enable row level security;
alter table loyalty_transactions enable row level security;
alter table audit_log enable row level security;

create policy if not exists org_read on organizations
for select using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.organization_id = organizations.id and p.is_active
  )
);

create policy if not exists stores_rw on stores
for all using (can_access_store(id))
with check (can_access_store(id));

create policy if not exists profiles_rw on profiles
for all using (
  id = auth.uid() or
  (is_admin_like() and organization_id = (select organization_id from current_profile()))
)
with check (
  id = auth.uid() or
  (is_admin_like() and organization_id = (select organization_id from current_profile()))
);

create policy if not exists categories_rw on categories
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists products_rw on products
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists po_rw on purchase_orders
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists customers_rw on customers
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists discounts_rw on discounts
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists shifts_rw on shifts
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists sales_rw on sales
for all using (can_access_store(store_id))
with check (can_access_store(store_id));

create policy if not exists sale_items_rw on sale_items
for all using (
  exists (
    select 1 from sales s where s.id = sale_items.sale_id and can_access_store(s.store_id)
  )
)
with check (
  exists (
    select 1 from sales s where s.id = sale_items.sale_id and can_access_store(s.store_id)
  )
);

create policy if not exists sale_payments_rw on sale_payments
for all using (
  exists (
    select 1 from sales s where s.id = sale_payments.sale_id and can_access_store(s.store_id)
  )
)
with check (
  exists (
    select 1 from sales s where s.id = sale_payments.sale_id and can_access_store(s.store_id)
  )
);

create policy if not exists stock_movements_read on stock_movements
for select using (
  exists (
    select 1
    from products p
    where p.id = stock_movements.product_id
      and can_access_store(p.store_id)
  )
);

create policy if not exists audit_log_read on audit_log
for select using (is_admin_like());

-- =========================
-- Seed data
-- =========================
insert into organizations (name, timezone, currency, tax_rate_default)
values ('Demo Organization', 'UTC', 'USD', 800)
on conflict do nothing;

insert into stores (organization_id, name, address, phone)
select o.id, 'Main Store', '123 Demo Street', '+1-555-0100'
from organizations o
where o.name = 'Demo Organization'
on conflict do nothing;

insert into categories (store_id, name, sort_order)
select s.id, c.name, c.sort_order
from stores s
cross join (values ('Beverages', 1), ('Snacks', 2), ('Household', 3)) as c(name, sort_order)
where s.name = 'Main Store'
on conflict do nothing;

insert into products (store_id, name, sku, barcode, category_id, price, cost, tax_rate, stock_qty, low_stock_threshold, unit, is_active)
select
  s.id,
  p.name,
  p.sku,
  p.barcode,
  c.id,
  p.price,
  p.cost,
  800,
  p.stock_qty,
  10,
  'each',
  true
from stores s
join categories c on c.store_id = s.id
join (
  values
    ('Cola 330ml', 'BEV-001', '1001001001', 'Beverages', 250, 120, 120),
    ('Orange Juice 1L', 'BEV-002', '1001001002', 'Beverages', 450, 230, 80),
    ('Potato Chips', 'SNK-001', '1002001001', 'Snacks', 300, 140, 60),
    ('Dish Soap', 'HOU-001', '1003001001', 'Household', 700, 350, 40)
) as p(name, sku, barcode, category_name, price, cost, stock_qty)
  on p.category_name = c.name
where s.name = 'Main Store'
on conflict do nothing;

-- Demo admin profile note:
-- 1) Create user in Supabase Auth (email/password) from dashboard.
-- 2) Then run the update below with that user UUID.
-- update profiles
-- set role = 'admin',
--     organization_id = (select id from organizations where name='Demo Organization' limit 1),
--     store_id = (select id from stores where name='Main Store' limit 1),
--     pin_code_hash = encode(digest('1234', 'sha256'), 'hex')
-- where id = 'PUT_AUTH_USER_UUID_HERE';
