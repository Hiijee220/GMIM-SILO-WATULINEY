-- Jalankan sekali di Supabase SQL Editor. Tidak menyimpan data pribadi jemaat.
create table if not exists public.site_content (
  id text primary key,
  title text not null default '',
  body text not null default '',
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
alter table public.site_content enable row level security;
revoke all on public.site_content from anon, authenticated;
grant select on public.site_content to anon, authenticated;
grant insert, update on public.site_content to authenticated;
drop policy if exists "Public may read published website content" on public.site_content;
create policy "Public may read published website content" on public.site_content for select to anon,authenticated using (true);
drop policy if exists "Super admin may insert website content" on public.site_content;
create policy "Super admin may insert website content" on public.site_content for insert to authenticated
with check (exists(select 1 from public.staff_profiles s where s.user_id=(select auth.uid()) and s.active=true and s.role='super_admin') and updated_by=(select auth.uid()));
drop policy if exists "Super admin may update website content" on public.site_content;
create policy "Super admin may update website content" on public.site_content for update to authenticated
using (exists(select 1 from public.staff_profiles s where s.user_id=(select auth.uid()) and s.active=true and s.role='super_admin'))
with check (exists(select 1 from public.staff_profiles s where s.user_id=(select auth.uid()) and s.active=true and s.role='super_admin') and updated_by=(select auth.uid()));
insert into public.site_content(id,title,body) values
('profil','Profil dan Sejarah',''),
('visi','Visi Gereja',''),
('misi','Misi Gereja',''),
('pelayanan','Pendeta, BPMJ dan Komisi',''),
('ibadah','Jadwal Ibadah',''),
('pengumuman','Pengumuman Resmi',''),
('kegiatan','Kegiatan Jemaat',''),
('kontak','Kontak Gereja','')
on conflict(id) do nothing;
insert into public.site_content(id,title,body)
select 'kolom-'||n,'Kolom '||n,'' from generate_series(1,16) n
on conflict(id) do nothing;
