# Setup Supabase dari HP — GMIM SILO WATULINEY

## Status
Ini baru **persiapan database**, belum ada login aktif atau koneksi website ke Supabase. Jangan memasukkan data jemaat nyata sampai kebijakan RLS, backup, dan pengujian akses selesai.

## Tahap 1: buat proyek
1. Buka https://supabase.com/dashboard di Safari atau Chrome dan login.
2. Pilih **New project**.
3. Nama proyek: **gmim-silo-watuliney**.
4. Pilih region terdekat yang tersedia.
5. Buat password database yang kuat dan simpan di password manager. **Jangan kirim password ke chat atau GitHub.**
6. Tunggu proyek berstatus siap.

## Tahap 2: siapkan skema (setelah proyek siap)
1. Buka **SQL Editor** di Supabase.
2. Salin isi `supabase/001_initial_schema.sql` dari repository.
3. Jalankan SQL tersebut untuk membuat tabel awal dengan **akses klien ditutup**.
4. Jangan masukkan data asli sebelum kebijakan akses selesai diuji.

## Tahap 3: aktifkan login (belum dilakukan)
- Gunakan Supabase Auth email/password dengan email yang terverifikasi dan MFA untuk administrator.
- Buat akun super admin melalui dashboard secara terkontrol, lalu petakan UUID akun ke `staff_profiles` dengan SQL yang ditinjau.
- Terapkan kebijakan RLS per role, termasuk pembatasan data ketua kolom hanya pada kolomnya sendiri.
- Uji akses ditolak untuk pengguna yang belum login, pengguna yang tidak aktif, dan antar-kolom.
- Setelah lolos pengujian, baru hubungkan portal melalui Project URL dan **publishable key**.

## Keamanan
- **Jangan pernah bagikan** password database, access token, service_role, atau `sb_secret_...`.
- Project URL dan `sb_publishable_...` boleh digunakan di frontend **setelah RLS aman**.
- GitHub Pages adalah publik; jangan unggah file Excel jemaat atau laporan keuangan mentah.
- Backup, retensi, audit perubahan, dan persetujuan pengurus diperlukan sebelum produksi.
