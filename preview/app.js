const roles = [
  'Super Admin',
  'Admin Pesantren',
  'Ustadz/Wali Kelas',
  'Musyrif Asrama',
  'Santri',
  'Wali Santri'
];

const modules = {
  dashboard: `
    <h2>Dashboard Wali Santri</h2>
    <div class="grid">
      <article class="card"><h3>Akademik</h3><div class="metric">82.5</div><small>Rata-rata semester</small></article>
      <article class="card"><h3>Saldo Wallet</h3><div class="metric">Rp 245.000</div><small>Batas minimum Rp 100.000</small></article>
      <article class="card"><h3>Kehadiran</h3><div class="metric">96%</div><small>30 hari terakhir</small></article>
      <article class="card"><h3>Poin Disiplin</h3><div class="metric">8</div><span class="status warn">Perlu pembinaan ringan</span></article>
    </div>
    <article class="card" style="margin-top:14px;">
      <h3>Notifikasi Penting</h3>
      <ul class="list">
        <li>Raport Semester Ganjil sudah terbit.</li>
        <li>Top-up wallet diterima Rp 100.000.</li>
        <li>Absensi asrama: hadir tepat waktu 7 hari berturut-turut.</li>
      </ul>
    </article>
  `,
  santri: `
    <h2>Modul Data Santri</h2>
    <div class="grid">
      <article class="card"><h3>Identitas</h3><ul class="list"><li>NIS, NIK terenkripsi</li><li>Alamat, tanggal lahir</li><li>Foto & dokumen</li></ul></article>
      <article class="card"><h3>Akademik Dasar</h3><ul class="list"><li>Kelas aktif</li><li>Riwayat pendidikan</li><li>Status: Aktif/Cuti/Alumni</li></ul></article>
      <article class="card"><h3>Relasi Wali</h3><ul class="list"><li>Data ayah/ibu/wali</li><li>Kontak terverifikasi</li><li>Hak akses per anak</li></ul></article>
    </div>
  `,
  keuangan: `
    <h2>Modul Keuangan</h2>
    <div class="grid">
      <article class="card"><h3>E-Wallet Internal</h3><ul class="list"><li>Top-up wali</li><li>Pengeluaran kantin/koperasi</li><li>Batas harian/mingguan</li></ul></article>
      <article class="card"><h3>Administrasi</h3><ul class="list"><li>SPP</li><li>Infaq</li><li>Tunggakan & histori</li></ul></article>
      <article class="card"><h3>Kwitansi</h3><span class="status ok">PDF Digital</span><p style="color:#9bb0d3">Unduh ulang kapan saja oleh wali/admin.</p></article>
    </div>
  `,
  akademik: `
    <h2>Modul Akademik & Raport</h2>
    <div class="grid">
      <article class="card"><h3>Kategori Nilai</h3><ul class="list"><li>Diniyah</li><li>Umum</li><li>Tahfidz</li></ul></article>
      <article class="card"><h3>Raport Digital</h3><ul class="list"><li>Per semester</li><li>Grafik perkembangan</li><li>Catatan wali kelas</li></ul></article>
      <article class="card"><h3>Arsip</h3><span class="status ok">Tersimpan cloud</span><p style="color:#9bb0d3">Akses raport tahun sebelumnya.</p></article>
    </div>
  `,
  karakter: `
    <h2>Modul Karakter & Pembinaan</h2>
    <div class="grid">
      <article class="card"><h3>Absensi</h3><ul class="list"><li>Kelas harian</li><li>Asrama harian</li><li>Rekap bulanan</li></ul></article>
      <article class="card"><h3>Pelanggaran</h3><ul class="list"><li>Poin kedisiplinan</li><li>Tingkat pelanggaran</li><li>Tindak lanjut</li></ul></article>
      <article class="card"><h3>Tarbiyah</h3><ul class="list"><li>Catatan pembinaan</li><li>Follow-up plan</li><li>Apresiasi prestasi</li></ul></article>
    </div>
  `,
  notifikasi: `
    <h2>Sistem Notifikasi</h2>
    <div class="grid">
      <article class="card"><h3>Channel</h3><ul class="list"><li>Push Notification</li><li>WhatsApp (opsional)</li><li>Email (opsional)</li></ul></article>
      <article class="card"><h3>Trigger</h3><ul class="list"><li>Saldo di bawah batas</li><li>Tidak hadir/alpa</li><li>Pelanggaran</li><li>Raport terbit</li></ul></article>
      <article class="card"><h3>Status</h3><span class="status ok">Realtime</span><p style="color:#9bb0d3">Riwayat pesan resmi tersimpan.</p></article>
    </div>
  `,
  keamanan: `
    <h2>Keamanan & Privasi</h2>
    <div class="grid">
      <article class="card"><h3>Autentikasi</h3><ul class="list"><li>OTP</li><li>PIN</li><li>Session JWT</li></ul></article>
      <article class="card"><h3>Proteksi Data</h3><ul class="list"><li>Enkripsi field sensitif</li><li>RBAC bertingkat</li><li>Audit log aktivitas</li></ul></article>
      <article class="card"><h3>Kebijakan Akses</h3><span class="status danger">Strict</span><p style="color:#9bb0d3">Wali hanya melihat data anaknya sendiri.</p></article>
    </div>
  `,
};

const roleList = document.getElementById('roleList');
const view = document.getElementById('view');
const buttons = [...document.querySelectorAll('#moduleMenu button')];

roles.forEach((role) => {
  const pill = document.createElement('span');
  pill.className = 'role-pill';
  pill.textContent = role;
  roleList.appendChild(pill);
});

function render(moduleName) {
  view.innerHTML = modules[moduleName] ?? '<p>Modul tidak ditemukan.</p>';
}

buttons.forEach((btn) => {
  btn.addEventListener('click', () => {
    buttons.forEach((b) => b.classList.remove('active'));
    btn.classList.add('active');
    render(btn.dataset.module);
  });
});

render('dashboard');
