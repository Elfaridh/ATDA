import json
import sqlite3
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / 'atda.db'


def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_conn()
    cur = conn.cursor()
    cur.executescript(
        """
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          full_name TEXT NOT NULL,
          role TEXT NOT NULL,
          phone TEXT
        );
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nis TEXT NOT NULL UNIQUE,
          full_name TEXT NOT NULL,
          kelas TEXT NOT NULL,
          asrama TEXT NOT NULL,
          status TEXT NOT NULL,
          guardian_id INTEGER NOT NULL,
          FOREIGN KEY(guardian_id) REFERENCES users(id)
        );
        CREATE TABLE IF NOT EXISTS wallet_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          txn_type TEXT NOT NULL,
          amount INTEGER NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(student_id) REFERENCES students(id)
        );
        CREATE TABLE IF NOT EXISTS bills (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          bill_type TEXT NOT NULL,
          period TEXT NOT NULL,
          amount_due INTEGER NOT NULL,
          amount_paid INTEGER NOT NULL,
          FOREIGN KEY(student_id) REFERENCES students(id)
        );
        CREATE TABLE IF NOT EXISTS grades (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          category TEXT NOT NULL,
          subject TEXT NOT NULL,
          score INTEGER NOT NULL,
          semester TEXT NOT NULL,
          FOREIGN KEY(student_id) REFERENCES students(id)
        );
        CREATE TABLE IF NOT EXISTS character_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          rec_type TEXT NOT NULL,
          value TEXT NOT NULL,
          rec_date TEXT NOT NULL,
          FOREIGN KEY(student_id) REFERENCES students(id)
        );
        """
    )

    count = cur.execute('SELECT COUNT(1) FROM users').fetchone()[0]
    if count == 0:
        cur.execute("INSERT INTO users(full_name, role, phone) VALUES (?,?,?)", ('Ahmad Wali', 'WALI_SANTRI', '08123456789'))
        cur.execute("INSERT INTO users(full_name, role, phone) VALUES (?,?,?)", ('Admin Pesantren', 'ADMIN_PESANTREN', '0811111111'))
        guardian_id = cur.lastrowid - 1
        cur.execute(
            "INSERT INTO students(nis, full_name, kelas, asrama, status, guardian_id) VALUES (?,?,?,?,?,?)",
            ('S-2026-001', 'Muhammad Fulan', 'Kelas 8A', 'Asrama Umar', 'AKTIF', guardian_id),
        )
        student_id = cur.lastrowid

        now = datetime.utcnow().isoformat()
        cur.executemany(
            "INSERT INTO wallet_transactions(student_id, txn_type, amount, description, created_at) VALUES (?,?,?,?,?)",
            [
                (student_id, 'TOPUP', 300000, 'Top-up wali', now),
                (student_id, 'DEBIT', 55000, 'Kantin pekanan', now),
            ],
        )
        cur.executemany(
            "INSERT INTO bills(student_id, bill_type, period, amount_due, amount_paid) VALUES (?,?,?,?,?)",
            [
                (student_id, 'SPP', '2026-02', 500000, 500000),
                (student_id, 'INFAQ', '2026-02', 100000, 50000),
            ],
        )
        cur.executemany(
            "INSERT INTO grades(student_id, category, subject, score, semester) VALUES (?,?,?,?,?)",
            [
                (student_id, 'DINIYAH', 'Fiqih', 85, '2025/2026-Ganjil'),
                (student_id, 'UMUM', 'Matematika', 80, '2025/2026-Ganjil'),
                (student_id, 'TAHFIDZ', 'Hafalan', 88, '2025/2026-Ganjil'),
            ],
        )
        cur.executemany(
            "INSERT INTO character_records(student_id, rec_type, value, rec_date) VALUES (?,?,?,?)",
            [
                (student_id, 'ABSENSI', 'Hadir 26/27 hari', str(datetime.utcnow().date())),
                (student_id, 'PELANGGARAN', 'Terlambat apel - 2 poin', str(datetime.utcnow().date())),
                (student_id, 'PEMBINAAN', 'Pembinaan adab pekanan berjalan baik', str(datetime.utcnow().date())),
                (student_id, 'PRESTASI', 'Juara 2 lomba pidato', str(datetime.utcnow().date())),
            ],
        )

    conn.commit()
    conn.close()


def read_file(path: Path) -> bytes:
    return path.read_bytes()


class Handler(BaseHTTPRequestHandler):
    def _send(self, code=200, content_type='text/plain; charset=utf-8', body=b''):
        self.send_response(code)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_json(self, data, code=200):
        self._send(code, 'application/json; charset=utf-8', json.dumps(data).encode('utf-8'))

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == '/':
            html = read_file(BASE_DIR / 'templates' / 'index.html').decode('utf-8')
            conn = get_conn()
            guardians = conn.execute("SELECT id, full_name, phone FROM users WHERE role='WALI_SANTRI'").fetchall()
            conn.close()
            options = ''.join([f'<option value="{g["id"]}">{g["full_name"]} ({g["phone"]})</option>' for g in guardians])
            html = html.replace('{{GUARDIAN_OPTIONS}}', options)
            self._send(200, 'text/html; charset=utf-8', html.encode('utf-8'))
            return

        if path.startswith('/static/'):
            rel = path.replace('/static/', '')
            fpath = BASE_DIR / 'static' / rel
            if not fpath.exists():
                self._send(404, body=b'Not Found')
                return
            ctype = 'text/plain; charset=utf-8'
            if rel.endswith('.css'):
                ctype = 'text/css; charset=utf-8'
            elif rel.endswith('.js'):
                ctype = 'application/javascript; charset=utf-8'
            self._send(200, ctype, read_file(fpath))
            return

        if path == '/healthz':
            self._send_json({'ok': True})
            return

        if path == '/api/students':
            query = parse_qs(parsed.query)
            role = query.get('role', [None])[0]
            user_id = query.get('user_id', [None])[0]
            conn = get_conn()
            if role == 'WALI_SANTRI' and user_id:
                rows = conn.execute(
                    'SELECT s.*, u.full_name AS guardian FROM students s JOIN users u ON s.guardian_id = u.id WHERE guardian_id = ?',
                    (user_id,),
                ).fetchall()
            else:
                rows = conn.execute(
                    'SELECT s.*, u.full_name AS guardian FROM students s JOIN users u ON s.guardian_id = u.id'
                ).fetchall()
            conn.close()
            self._send_json([dict(r) for r in rows])
            return

        if path.startswith('/api/guardian/') and path.endswith('/dashboard'):
            parts = path.split('/')
            guardian_id = int(parts[3])
            conn = get_conn()
            student = conn.execute('SELECT * FROM students WHERE guardian_id=? LIMIT 1', (guardian_id,)).fetchone()
            if not student:
                conn.close()
                self._send_json({'error': 'not found'}, 404)
                return
            sid = student['id']
            txns = conn.execute('SELECT * FROM wallet_transactions WHERE student_id=? ORDER BY id DESC', (sid,)).fetchall()
            bills = conn.execute('SELECT * FROM bills WHERE student_id=?', (sid,)).fetchall()
            grades = conn.execute('SELECT * FROM grades WHERE student_id=?', (sid,)).fetchall()
            chars = conn.execute('SELECT * FROM character_records WHERE student_id=?', (sid,)).fetchall()
            conn.close()

            balance = sum(t['amount'] if t['txn_type'] == 'TOPUP' else -t['amount'] for t in txns)
            avg = round(sum(g['score'] for g in grades) / len(grades), 2) if grades else 0
            arrears = sum(max(0, b['amount_due'] - b['amount_paid']) for b in bills)
            discipline_points = sum(2 for c in chars if c['rec_type'] == 'PELANGGARAN')

            payload = {
                'student': {
                    'id': student['id'],
                    'name': student['full_name'],
                    'kelas': student['kelas'],
                    'asrama': student['asrama'],
                },
                'summary': {
                    'wallet_balance': balance,
                    'academic_avg': avg,
                    'arrears': arrears,
                    'discipline_points': discipline_points,
                },
                'grades': [dict(g) for g in grades],
                'bills': [
                    {
                        **dict(b),
                        'status': 'PAID' if b['amount_paid'] >= b['amount_due'] else 'PARTIAL',
                    }
                    for b in bills
                ],
                'transactions': [dict(t) for t in txns],
                'character': [
                    {'type': c['rec_type'], 'value': c['value'], 'date': c['rec_date']}
                    for c in chars
                ],
            }
            self._send_json(payload)
            return

        self._send(404, body=b'Not Found')


def run():
    init_db()
    server = HTTPServer(('0.0.0.0', 5000), Handler)
    print('ATDA app running at http://0.0.0.0:5000')
    server.serve_forever()


if __name__ == '__main__':
    run()
