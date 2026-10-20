# Panduan uji Dashboard Pengurus

## Persiapan
1. Pastikan skrip `database/church-records.sql` telah berhasil dijalankan pada proyek Supabase yang benar.
2. Masuk lewat `portal.html` menggunakan akun pengurus yang aktif di `staff_profiles`.
3. Buka menu **Kelola Data Jemaat & Kas**. Jangan menguji dengan data pribadi asli.

## Uji input manual
1. Pilih **16 Kolom**, isi kode `UJI-KOLOM-01`, Kolom 1, nama `Kolom Percobaan`.
2. Klik **Simpan data manual**, lalu **Muat data**.
3. Pastikan baris tampil. Klik **Edit**, ubah keterangan, lalu simpan kembali.
4. Muat data dan pastikan perubahan tersimpan.

## Uji import Excel
1. Pilih **Jadwal Ibadah** dan klik **Unduh template CSV**.
2. Buka CSV dengan Excel, ganti baris contoh dengan data uji tanpa identitas pribadi.
3. Simpan sebagai CSV atau XLSX. Pilih file di halaman pengurus.
4. Periksa pratinjau, kemudian klik **Konfirmasi import ke database**.
5. Pastikan data tampil setelah **Muat data**.

## Uji keamanan (wajib sebelum data asli)
- Akun `super_admin`: akses kelima modul.
- Akun `bendahara`: hanya keuangan.
- Akun `admin`, `sekretaris`, atau `operator`: KK, anggota, kolom, dan ibadah, bukan keuangan.
- Akun tanpa `staff_profiles` aktif: ditolak.
- Coba permintaan baca/tulis yang tidak diizinkan; server Supabase harus menolak berdasarkan RLS, bukan sekadar menyembunyikan menu.

## Batasan penting
- File impor maksimal 3 MB dan 200 baris; daftar layar maksimal 100 baris.
- Impor bertahap bukan transaksi atomik: jika salah satu batch gagal, sebagian data bisa tersimpan.
- `record_key` harus kode internal unik, **jangan NIK**.
- Aplikasi belum memiliki audit log yang memadai, validasi relasi KK–anggota, persetujuan pengolahan data, backup teruji, ataupun pembukuan kas berpasangan.
- Jangan gunakan data jemaat asli atau keuangan riil sebelum pengujian izin lintas peran, backup, dan kebijakan privasi selesai.
