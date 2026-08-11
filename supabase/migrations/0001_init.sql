-- Griyo Suite: skema awal
-- Semua data bisnis dibagi oleh 1 baris `business`, diakses oleh user2 yang terdaftar di `business_users`.

create extension if not exists "pgcrypto";

-- ============ BUSINESS & USERS ============

create table business (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Bisnis Saya',
  address text,
  phone text,
  bank_account text,
  logo_url text,
  invoice_prefix text not null default 'INV',
  quotation_prefix text not null default 'QUO',
  receipt_prefix text not null default 'TT',
  created_at timestamptz not null default now()
);

create table business_users (
  business_id uuid not null references business(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  primary key (business_id, user_id)
);

create index on business_users (user_id);

-- Helper: business_id milik user yang sedang login
create or replace function current_business_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select business_id from business_users where user_id = auth.uid() limit 1;
$$;

-- ============ MASTER DATA ============

create table clients (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  name text not null,
  phone text,
  address text,
  notes text,
  created_at timestamptz not null default now()
);

create index on clients (business_id);

create table catalog_items (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  name text not null,
  unit text not null default 'pcs',
  default_price numeric(14,2) not null default 0,
  created_at timestamptz not null default now()
);

create index on catalog_items (business_id);

-- ============ QUOTATIONS ============

create table quotations (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  number text not null,
  client_id uuid references clients(id) on delete set null,
  status text not null default 'draft' check (status in ('draft','sent','accepted','rejected')),
  issue_date date not null default current_date,
  valid_until date,
  notes text,
  subtotal numeric(14,2) not null default 0,
  discount numeric(14,2) not null default 0,
  total numeric(14,2) not null default 0,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  unique (business_id, number)
);

create index on quotations (business_id);

create table quotation_items (
  id uuid primary key default gen_random_uuid(),
  quotation_id uuid not null references quotations(id) on delete cascade,
  catalog_item_id uuid references catalog_items(id) on delete set null,
  description text not null,
  qty numeric(14,2) not null default 1,
  unit text not null default 'pcs',
  unit_price numeric(14,2) not null default 0,
  line_total numeric(14,2) not null default 0,
  sort_order int not null default 0
);

create index on quotation_items (quotation_id);

-- ============ INVOICES ============

create table invoices (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  number text not null,
  client_id uuid references clients(id) on delete set null,
  quotation_id uuid references quotations(id) on delete set null,
  status text not null default 'unpaid' check (status in ('unpaid','partial','paid')),
  issue_date date not null default current_date,
  due_date date,
  notes text,
  subtotal numeric(14,2) not null default 0,
  discount numeric(14,2) not null default 0,
  total numeric(14,2) not null default 0,
  amount_paid numeric(14,2) not null default 0,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  unique (business_id, number)
);

create index on invoices (business_id);

create table invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices(id) on delete cascade,
  catalog_item_id uuid references catalog_items(id) on delete set null,
  description text not null,
  qty numeric(14,2) not null default 1,
  unit text not null default 'pcs',
  unit_price numeric(14,2) not null default 0,
  line_total numeric(14,2) not null default 0,
  sort_order int not null default 0
);

create index on invoice_items (invoice_id);

-- ============ FINANCE ============

create table finance_categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  name text not null,
  type text not null check (type in ('income','expense')),
  created_at timestamptz not null default now()
);

create index on finance_categories (business_id);

create table finance_transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  type text not null check (type in ('income','expense')),
  amount numeric(14,2) not null,
  category_id uuid references finance_categories(id) on delete set null,
  description text,
  txn_date date not null default current_date,
  source text not null default 'manual' check (source in ('manual','invoice_payment')),
  invoice_id uuid references invoices(id) on delete cascade,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index on finance_transactions (business_id);
create index on finance_transactions (invoice_id);

create table payments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  invoice_id uuid not null references invoices(id) on delete cascade,
  amount numeric(14,2) not null,
  method text not null default 'cash',
  paid_date date not null default current_date,
  notes text,
  finance_transaction_id uuid references finance_transactions(id) on delete set null,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index on payments (invoice_id);

-- ============ RECEIPTS (Tanda Terima) ============

create table receipts (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,
  number text not null,
  client_id uuid references clients(id) on delete set null,
  invoice_id uuid references invoices(id) on delete set null,
  kind text not null default 'goods' check (kind in ('goods','payment')),
  description text not null,
  given_by text,
  received_by text,
  issue_date date not null default current_date,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  unique (business_id, number)
);

create index on receipts (business_id);

-- ============ TRIGGER: payment -> finance_transaction otomatis ============

create or replace function handle_payment_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  new_txn_id uuid;
  inv record;
begin
  insert into finance_transactions (business_id, type, amount, description, txn_date, source, invoice_id, created_by)
  values (new.business_id, 'income', new.amount, 'Pembayaran invoice', new.paid_date, 'invoice_payment', new.invoice_id, new.created_by)
  returning id into new_txn_id;

  update payments set finance_transaction_id = new_txn_id where id = new.id;

  select * into inv from invoices where id = new.invoice_id;
  update invoices
  set amount_paid = inv.amount_paid + new.amount,
      status = case
        when inv.amount_paid + new.amount >= inv.total then 'paid'
        when inv.amount_paid + new.amount > 0 then 'partial'
        else 'unpaid'
      end
  where id = new.invoice_id;

  return new;
end;
$$;

create trigger trg_payment_insert
after insert on payments
for each row execute function handle_payment_insert();

create or replace function handle_payment_delete()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  inv record;
begin
  delete from finance_transactions where id = old.finance_transaction_id;

  select * into inv from invoices where id = old.invoice_id;
  update invoices
  set amount_paid = greatest(inv.amount_paid - old.amount, 0),
      status = case
        when greatest(inv.amount_paid - old.amount, 0) >= inv.total and inv.total > 0 then 'paid'
        when greatest(inv.amount_paid - old.amount, 0) > 0 then 'partial'
        else 'unpaid'
      end
  where id = old.invoice_id;

  return old;
end;
$$;

create trigger trg_payment_delete
after delete on payments
for each row execute function handle_payment_delete();

-- ============ RLS ============

alter table business enable row level security;
alter table business_users enable row level security;
alter table clients enable row level security;
alter table catalog_items enable row level security;
alter table quotations enable row level security;
alter table quotation_items enable row level security;
alter table invoices enable row level security;
alter table invoice_items enable row level security;
alter table finance_categories enable row level security;
alter table finance_transactions enable row level security;
alter table payments enable row level security;
alter table receipts enable row level security;

create policy "member can read business" on business
  for select using (id = current_business_id());
create policy "member can update business" on business
  for update using (id = current_business_id());

create policy "member can read business_users of own business" on business_users
  for select using (business_id = current_business_id());

create policy "member full access clients" on clients
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access catalog_items" on catalog_items
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access quotations" on quotations
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access quotation_items" on quotation_items
  for all using (
    quotation_id in (select id from quotations where business_id = current_business_id())
  ) with check (
    quotation_id in (select id from quotations where business_id = current_business_id())
  );

create policy "member full access invoices" on invoices
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access invoice_items" on invoice_items
  for all using (
    invoice_id in (select id from invoices where business_id = current_business_id())
  ) with check (
    invoice_id in (select id from invoices where business_id = current_business_id())
  );

create policy "member full access finance_categories" on finance_categories
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access finance_transactions" on finance_transactions
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access payments" on payments
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

create policy "member full access receipts" on receipts
  for all using (business_id = current_business_id()) with check (business_id = current_business_id());

-- ============ SEED HELPER: buat business + link user pertama ============
-- Dijalankan manual sekali via SQL editor Supabase setelah user pertama signup, lihat README setup.
