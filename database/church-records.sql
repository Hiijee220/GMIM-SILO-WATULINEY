-- Jalankan sekali di Supabase SQL Editor. Periksa kebijakan sebelum data asli.
create table if not exists public.church_records (
 id uuid primary key default gen_random_uuid(),
 kind text not null check(kind in ('kk','anggota','kolom','ibadah','keuangan')),
 record_key text not null,
 kolom_number integer check(kolom_number between 1 and 16),
 payload jsonb not null default '{}'::jsonb,
 created_by uuid not null references auth.users(id),
 updated_at timestamptz not null default now(),
 unique(kind,record_key)
);
create index if not exists church_records_kind_idx on public.church_records(kind);
create index if not exists church_records_kolom_idx on public.church_records(kolom_number);
alter table public.church_records enable row level security;
revoke all on public.church_records from anon;
grant select,insert,update on public.church_records to authenticated;
drop policy if exists church_records_select on public.church_records;
drop policy if exists church_records_insert on public.church_records;
drop policy if exists church_records_update on public.church_records;
-- Peran diperiksa dari tabel staff_profiles, bukan dari data yang dikirim browser.
create policy church_records_select on public.church_records for select to authenticated
using (exists(select 1 from public.staff_profiles p where p.user_id=(select auth.uid()) and p.active=true and (
p.role='super_admin' or
(kind in ('kk','anggota','kolom','ibadah') and p.role in ('admin','sekretaris','operator')) or
(kind='keuangan' and p.role='bendahara')
)));
create policy church_records_insert on public.church_records for insert to authenticated
with check (created_by=(select auth.uid()) and exists(select 1 from public.staff_profiles p where p.user_id=(select auth.uid()) and p.active=true and (
p.role='super_admin' or
(kind in ('kk','anggota','kolom','ibadah') and p.role in ('admin','sekretaris','operator')) or
(kind='keuangan' and p.role='bendahara')
)));
create policy church_records_update on public.church_records for update to authenticated
using (exists(select 1 from public.staff_profiles p where p.user_id=(select auth.uid()) and p.active=true and (
p.role='super_admin' or
(kind in ('kk','anggota','kolom','ibadah') and p.role in ('admin','sekretaris','operator')) or
(kind='keuangan' and p.role='bendahara')
)))
with check (exists(select 1 from public.staff_profiles p where p.user_id=(select auth.uid()) and p.active=true and (
p.role='super_admin' or
(kind in ('kk','anggota','kolom','ibadah') and p.role in ('admin','sekretaris','operator')) or
(kind='keuangan' and p.role='bendahara')
)));
-- Tidak ada kebijakan DELETE; penghapusan data dinonaktifkan.
