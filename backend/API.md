# Rancangan endpoint API portal pengurus (belum aktif)

Semua endpoint /api/admin/* memerlukan sesi server terautentikasi, CSRF untuk perubahan, otorisasi role dan pembatasan column_id.

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | /login | Login dengan pembatasan percobaan |
| POST | /logout | Hapus sesi |
| GET | /api/admin/me | Identitas dan izin akun |
| GET/POST | /api/admin/families | Daftar/tambah KK |
| GET/PATCH | /api/admin/families/{id} | Detail/ubah KK |
| GET/POST | /api/admin/members | Daftar/tambah anggota |
| GET/PATCH | /api/admin/members/{id} | Detail/ubah anggota |
| GET/PATCH | /api/admin/columns/{id} | Informasi kolom |
| GET/POST | /api/admin/cash-transactions | Kas masuk/keluar |
| POST | /api/admin/cash-transactions/{id}/void | Pembatalan transaksi dengan alasan dan audit |
| GET | /api/admin/reports/cash | Laporan kas berdasarkan rentang tanggal |
| GET/POST | /api/admin/announcements | Pengumuman |
| GET/POST | /api/admin/users | Kelola akun, khusus super admin |
| GET | /api/admin/audit-logs | Riwayat perubahan, khusus role yang berwenang |
| GET | /api/public/columns | Hanya statistik agregat yang diizinkan untuk publik |

Sebelum implementasi, tentukan persetujuan publikasi, retensi data, backup, kebijakan akses dan struktur keuangan jemaat.
