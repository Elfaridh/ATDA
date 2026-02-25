# Aplikasi Manajemen Santri & Wali Santri Terpadu (ATDA)

Blueprint siap produksi untuk sistem manajemen pesantren yang amanah, transparan, dan selaras kultur tarbiyah.

## 1) Visi Produk

Aplikasi ini dirancang untuk:
- Mengelola data santri terpusat (akademik, karakter, keuangan, administrasi).
- Menyediakan dashboard wali santri real-time dengan informasi proporsional.
- Mengurangi proses manual dan meningkatkan akurasi administrasi.
- Menjaga keamanan data sensitif berbasis RBAC, audit log, dan enkripsi.

## 2) Arsitektur Solusi

### Komponen Utama
1. **Mobile App (Flutter)**
   - Super Admin, Admin Pesantren, Ustadz/Wali Kelas, Musyrif, Santri, Wali Santri.
   - Mode sederhana untuk wali santri (font besar, navigasi ringkas).
   - Offline-first local cache + background sync.

2. **Backend API (REST + OpenAPI)**
   - Framework: FastAPI / NestJS (keduanya mendukung validasi kuat dan RBAC).
   - Endpoint role-based dan tenant-aware (multi-pesantren).
   - Integrasi notifikasi (push, WhatsApp opsional, email opsional).

3. **Database Relasional (PostgreSQL)**
   - Skema multi-tenant (`pesantren_id` pada entitas domain).
   - Soft delete + audit trail.
   - Encryption at rest (TDE/provider-managed) + field-level encryption untuk NIK/kontak sensitif.

4. **Object Storage**
   - Foto profil, dokumen penting, raport PDF, kwitansi.
   - Signed URL dengan TTL pendek.

5. **Queue & Worker**
   - Trigger notifikasi otomatis (saldo menipis, absen, pelanggaran, raport terbit).

## 3) Fitur Wajib yang Terpenuhi

- Role & hak akses lengkap: Super Admin, Admin, Ustadz/Wali Kelas, Musyrif, Santri, Wali Santri.
- Modul data santri lengkap (profil, asrama/kelas, wali, status).
- Modul keuangan (e-wallet internal, SPP/infaq, tunggakan, kwitansi digital).
- Modul akademik (diniyah/umum/tahfidz, raport digital + grafik).
- Modul karakter (absensi, pelanggaran, pembinaan, apresiasi).
- Dashboard wali santri real-time terfilter.
- Notifikasi multi-channel.
- Keamanan & privasi berlapis.

## 4) Deliverables di Repository

- **Database schema**: `docs/database-schema.sql`
- **API spec (OpenAPI)**: `docs/api-spec.yaml`
- **User flow (per role)**: `docs/user-flow.md`
- **Contoh UI utama**: `docs/ui-wireframes.md`

## 5) Strategi Implementasi Bertahap

### Fase 1 (MVP - 8 s.d. 12 minggu)
- Auth + RBAC + manajemen santri
- Keuangan inti (wallet + pembayaran admin)
- Akademik dasar + raport PDF
- Dashboard wali + notifikasi push

### Fase 2
- Offline-first penuh + conflict resolution
- WhatsApp gateway + email
- Multi pesantren penuh (cross-tenant admin)
- Analitik tren akademik/disiplin

### Fase 3 (Visioner)
- AI insight: risiko penurunan prestasi/pelanggaran
- Ringkasan naratif perkembangan karakter
- Musyawarah wali santri (forum terstruktur)

## 6) Prinsip Produk Berbasis Nilai Pesantren

- **Amanah**: data valid, jejak audit jelas.
- **Transparan**: wali mendapat informasi penting tanpa membuka data internal berlebihan.
- **Adab & Akhlak**: terminologi, notifikasi, dan narasi disusun edukatif, bukan menghukum.
- **Tarbiyah**: indikator karakter bersifat pembinaan bertahap.

## 7) Cara Preview Cepat

Jalankan server statis dari root project:

```bash
python3 -m http.server 4173
```

Lalu buka:

- `http://localhost:4173/preview/`

Preview ini menampilkan prototipe UI interaktif untuk membantu stakeholder melakukan validasi cepat sebelum implementasi mobile native.
