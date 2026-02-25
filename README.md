# ATDA - Ansyitoh Tullab Daarul Amiin

kita kawal bersama calon pemimpin masa depan kita

## Fitur yang sudah jalan

- Login simulasi sebagai **Wali Santri** (pilih wali dari dropdown)
- Dashboard ringkasan anak:
  - Akademik (rata-rata nilai + detail mapel)
  - Keuangan (saldo wallet, riwayat transaksi, tagihan)
  - Karakter & pembinaan (absensi/pelanggaran/pembinaan/prestasi)
- Endpoint API siap dipakai frontend:
  - `GET /api/students?role=...&user_id=...`
  - `GET /api/guardian/<id>/dashboard`
- Healthcheck deployment: `GET /healthz`

## Tech Stack

- Backend: Python built-in HTTP server + REST handler
- Database: SQLite (otomatis dibuat + seeded saat start)
- Frontend: HTML + CSS + JavaScript (dashboard interaktif via fetch API)

## Menjalankan Lokal

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python src/app.py
```

Buka: `http://localhost:5000`

## Menjalankan via Docker

```bash
docker build -t atda-app .
docker run --rm -p 5000:5000 atda-app
```

## Struktur utama

- `src/app.py` → backend + API + seed data
- `src/templates/index.html` → halaman utama aplikasi
- `src/static/app.js` → render dashboard interaktif
- `src/static/app.css` → styling UI

## Deployment Status GitHub

Agar tidak muncul peringatan **"This branch has not been deployed"**, repository ini sekarang memiliki workflow:

- `.github/workflows/deploy-status.yml`

Workflow tersebut otomatis membuat status deployment `preview` untuk setiap push branch.

## Deploy ke GitHub Pages (agar tidak tampil README saja)

Jika deploy ke `https://<username>.github.io/<repo>/`, pastikan file `index.html` di root repository ada (sudah disediakan di project ini).

`index.html` akan otomatis mengarahkan ke:

- `./preview/`

Sehingga saat membuka link GitHub Pages, user langsung masuk ke landing page aplikasi, bukan tampilan markdown README.
