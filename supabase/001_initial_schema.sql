-- GMIM SILO WATULINEY - Supabase initial schema, private data default DENY
-- Run only in your OWN Supabase project SQL Editor. No credentials included.
create extension if not exists pgcrypto;
create table if not exists public.staff_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null,
 role text not null check(role in ('super_admin','admin','pastor','treasurer','column_leader','viewer')),
 column_no integer check(column_no between 1 and 16),
 active boolean not null default true,
 created_at timestamptz not null default now(),
 constraint column_role check (role <> 'column_leader' or column_no is not null)
);
create table if not exists public.church_columns (
 column_no integer primary key check(column_no between 1 and 16),
 name text not null,
 worship_day text, worship_time text, worship_place text,
 public_note text
);
insert into public.church_columns(column_no,name)
select n, 'Kolom '||n from generate_series(1,16) n
on conflict(column_no) do nothing;
create table if not exists public.families (
 id uuid primary key default gen_random_uuid(),
 family_code text unique not null,
 head_name text not null,
 address text, phone text,
 column_no integer not null references public.church_columns(column_no),
 created_at timestamptz not null default now()
);
create table if not exists public.members (
 id uuid primary key default gen_random_uuid(),
 family_id uuid not null references public.families(id),
 full_name text not null, birth_date date,
 membership_status text,
 created_at timestamptz not null default now()
);
create table if not exists public.cash_transactions (
 id uuid primary key default gen_random_uuid(),
 transaction_date date not null,
 type text not null check(type in ('income','expense')),
 amount numeric(15,2) not null check(amount > 0),
 category text not null, description text,
 created_by uuid references auth.users(id),
 created_at timestamptz not null default now()
);
create table if not exists public.audit_logs (
 id bigint generated always as identity primary key,
 actor_id uuid references auth.users(id),
 action text not null, table_name text not null, record_id text,
 occurred_at timestamptz not null default now()
);
alter table public.staff_profiles enable row level security;
alter table public.church_columns enable row level security;
alter table public.families enable row level security;
alter table public.members enable row level security;
alter table public.cash_transactions enable row level security;
alter table public.audit_logs enable row level security;
-- Intentionally NO client access policies yet. Even authenticated users cannot
-- access sensitive tables until role-specific policies are reviewed and tested.
revoke all on public.staff_profiles,public.church_columns,public.families,public.members,public.cash_transactions,public.audit_logs from anon,authenticated;
-- Bootstrap super admin via Supabase Auth dashboard and reviewed SQL only.
-- NEVER create users with hardcoded passwords in migrations or public GitHub.
