# Contoh UI Utama (Mobile - Flutter)

## Design Principles
- Modern, bersih, kontras tinggi, tipografi jelas.
- Bahasa sederhana untuk wali santri.
- Ikon + warna status konsisten (hijau=baik, kuning=perlu perhatian, merah=prioritas).
- Memuat nilai adab: copywriting santun, tidak menghakimi.

## 1) Login

**Komponen:**
- Input nomor HP/email
- Input password / PIN
- Tombol "Masuk"
- OTP verification screen

**Catatan UX:**
- Opsi "Mode Sederhana" (font besar + menu minimum)
- Bantuan cepat via WhatsApp admin

## 2) Dashboard Wali Santri

**Header:**
- Nama wali
- Dropdown anak (jika lebih dari satu)

**Kartu Ringkasan:**
1. Akademik (rata-rata semester + tren)
2. Keuangan (saldo wallet + tunggakan)
3. Disiplin (absensi bulan ini + poin pelanggaran)
4. Pembinaan (ringkasan catatan terakhir)

**Widget:**
- Grafik 6 bulan perkembangan nilai
- Timeline notifikasi penting
- Tombol cepat: Top-up, Bayar SPP, Unduh Raport

## 3) Halaman Detail Akademik
- Tab: Diniyah | Umum | Tahfidz
- Daftar nilai per mapel
- Grafik tren
- Catatan wali kelas
- Tombol unduh raport PDF

## 4) Halaman Keuangan
- Saldo wallet real-time
- Riwayat transaksi (filter tanggal & tipe)
- Tagihan aktif (SPP/Infaq)
- Tombol bayar + status kwitansi digital

## 5) Halaman Disiplin & Pembinaan
- Ringkasan kehadiran bulanan
- Riwayat pelanggaran (level + poin)
- Catatan pembinaan bertahap
- Riwayat apresiasi/prestasi

## 6) Dashboard Admin Pesantren
- KPI: total santri aktif, tunggakan bulan ini, tingkat kehadiran, pelanggaran berat
- Grafik tren keuangan & akademik
- Aksi cepat: tambah santri, publish raport, export laporan

## Komponen Teknis UI
- State management: Riverpod/Bloc
- Local cache: Hive/Drift (offline-first)
- Theme: light/dark + accessibility mode
- Internationalization: Bahasa Indonesia default
