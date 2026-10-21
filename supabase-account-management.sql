-- Jalankan sekali di Supabase SQL Editor sebagai pemilik proyek.
-- Akun baru dibuat melalui Authentication > Users > Add user.
-- Jangan menyimpan password pada staff_profiles.
alter table public.staff_profiles add column if not exists commission_name text;
alter table public.staff_profiles add column if not exists kolom_number integer;
alter table public.staff_profiles add column if not exists updated_at timestamptz default now();
alter table public.staff_profiles drop constraint if exists staff_profiles_kolom_number_check;
alter table public.staff_profiles add constraint staff_profiles_kolom_number_check check (kolom_number is null or kolom_number between 1 and 16);

create or replace function public.manage_staff_account(
  p_user_id uuid, p_full_name text, p_role text, p_active boolean,
  p_commission_name text default null, p_kolom_number integer default null
) returns void language plpgsql security definer set search_path = ''
as $$
declare v_caller uuid := (select auth.uid());
begin
  if v_caller is null or not exists (
    select 1 from public.staff_profiles
    where user_id=v_caller and role='super_admin' and active=true
  ) then raise exception 'Hanya Super Admin aktif yang dapat mengelola akun'; end if;
  if p_user_id is null or not exists (select 1 from auth.users where id=p_user_id) then
    raise exception 'UID tidak ditemukan di Authentication > Users'; end if;
  if p_role not in ('super_admin','pendeta','ketua_bpmj','sekretaris','bendahara','komisi_pelayanan','ketua_kolom','pengurus_kolom','admin','operator') then
    raise exception 'Jabatan tidak dikenali'; end if;
  if length(trim(coalesce(p_full_name,''))) < 2 or length(p_full_name)>160 then
    raise exception 'Nama harus berisi 2-160 karakter'; end if;
  if p_kolom_number is not null and (p_kolom_number < 1 or p_kolom_number > 16) then
    raise exception 'Nomor kolom harus 1-16'; end if;
  if p_user_id=v_caller and (p_role <> 'super_admin' or p_active=false) then
    raise exception 'Tidak boleh mencabut akses Super Admin milik sendiri'; end if;
  insert into public.staff_profiles(user_id,full_name,role,active,commission_name,kolom_number,updated_at)
  values(p_user_id,trim(p_full_name),p_role,p_active,nullif(trim(p_commission_name),''),p_kolom_number,now())
  on conflict(user_id) do update set full_name=excluded.full_name,role=excluded.role,
    active=excluded.active,commission_name=excluded.commission_name,
    kolom_number=excluded.kolom_number,updated_at=now();
end;$$;
revoke all on function public.manage_staff_account(uuid,text,text,boolean,text,integer) from public,anon;
grant execute on function public.manage_staff_account(uuid,text,text,boolean,text,integer) to authenticated;

create or replace function public.list_staff_accounts()
returns table(user_id uuid,full_name text,role text,active boolean,commission_name text,kolom_number integer)
language plpgsql security definer set search_path = ''
as $$
begin
  if (select auth.uid()) is null or not exists
   (select 1 from public.staff_profiles s where s.user_id=(select auth.uid()) and s.role='super_admin' and s.active=true)
  then raise exception 'Akses ditolak'; end if;
  return query select s.user_id,s.full_name,s.role,s.active,s.commission_name,s.kolom_number
  from public.staff_profiles s order by s.full_name limit 500;
end;$$;
revoke all on function public.list_staff_accounts() from public,anon;
grant execute on function public.list_staff_accounts() to authenticated;
