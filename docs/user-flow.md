# User Flow Aplikasi ATDA

## 1. Super Admin
1. Login + OTP.
2. Buat tenant pesantren baru.
3. Atur role default dan kebijakan keamanan.
4. Monitoring audit log dan kesehatan sistem.

## 2. Admin Pesantren
1. Login.
2. Setup master data (kelas, asrama, mapel, item tagihan).
3. Input/validasi data santri + wali.
4. Menjalankan rekap keuangan & laporan periodik.
5. Publish laporan untuk pimpinan.

## 3. Ustadz / Wali Kelas
1. Login.
2. Pilih kelas binaan.
3. Buat assessment (diniyah/umum/tahfidz).
4. Input nilai, catatan perkembangan, verifikasi akhir semester.
5. Generate draft raport dan submit ke admin.

## 4. Musyrif Asrama
1. Login.
2. Input absensi asrama harian.
3. Input pelanggaran, poin, dan rencana pembinaan.
4. Input apresiasi/prestasi.
5. Trigger notifikasi wali untuk kejadian penting.

## 5. Santri
1. Login (PIN/OTP sederhana).
2. Melihat data diri, nilai, catatan pembinaan, dan wallet.
3. Menerima pengumuman resmi pesantren.

## 6. Wali Santri
1. Login sederhana (phone + OTP/PIN).
2. Pilih profil anak (jika >1 anak).
3. Melihat ringkasan:
   - Akademik (nilai & grafik)
   - Keuangan (saldo + tagihan)
   - Disiplin (absensi, pelanggaran, pembinaan)
4. Melakukan top-up wallet dan pembayaran administrasi.
5. Mengunduh raport/kwitansi dan membaca pesan resmi.

## 7. Trigger Otomatis Sistem
- Saldo wallet < batas minimum → notifikasi push + WA opsional.
- Tidak hadir/alpa → notifikasi ke wali.
- Pelanggaran berat → notifikasi prioritas tinggi.
- Raport terbit → notifikasi unduhan raport.
