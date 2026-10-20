# Portal Pengurus GMIM SILO WATULINEY — Backend (persiapan)

Folder ini berisi **rancangan database PostgreSQL**, **daftar API**, dan kebijakan keamanan untuk membangun portal pengurus. Ini **bukan aplikasi login aktif**. GitHub Pages tidak dapat menjalankan PHP/Laravel, server API, atau database.

## Modul yang direncanakan
- Login aman dan sesi server, reset kata sandi, MFA untuk admin.
- Akun admin gereja, pendeta, bendahara, ketua kolom, dan petugas baca.
- Data keluarga/KK: kode keluarga, kepala keluarga, kolom, alamat dan telepon (rahasia).
- Data anggota jemaat: terhubung ke keluarga/KK.
- 16 kolom: jadwal, pelayanan dan agregat publik yang disetujui.
- Keuangan: akun kas, pemasukan/pengeluaran, koreksi melalui pembatalan yang diaudit, rekap.
- Pengumuman, kegiatan, dan pembaruan website publik dengan persetujuan.
- Audit log perubahan.

## Hak akses yang harus diterapkan pada server
| Peran | Akses |
|---|---|
| Super admin | Pengaturan dan akun, seluruh modul |
| Admin gereja | Data jemaat, KK, jadwal dan konten |
| Pendeta | Data pastoral yang diizinkan, laporan |
| Bendahara | Transaksi dan laporan keuangan |
| Ketua kolom | Data jemaat **kolom sendiri** saja |
| Viewer | Data sesuai izin baca |

Akses tidak boleh hanya disembunyikan di UI: **semua endpoint** harus memeriksa sesi, peran, dan lingkup kolom pada server.

## Persyaratan produksi
1. Hosting backend (contoh Laravel 12 + PostgreSQL) dengan HTTPS dan backup terenkripsi.
2. Simpan secret, password hash Argon2id, kredensial database dan API key **hanya** di environment backend, tidak di repository publik.
3. Gunakan session cookie HttpOnly + Secure + SameSite, CSRF protection, rate limit login, MFA admin, validasi input, audit trail, dan pemulihan akun.
4. Gunakan migrasi dan kontrol akses sebelum memasukkan data nyata.
5. Publik hanya boleh menerima angka agregat yang disetujui; jangan mengekspos nama keluarga, alamat pribadi, atau transaksi individu.
6. Buat akun admin pertama melalui proses provisioning server yang aman, **bukan password bawaan**.

Lihat `schema.sql` untuk rancangan awal. Setelah layanan backend tersedia, implementasikan migrasi Laravel, controller, policy, validasi, dan tes hak akses.
