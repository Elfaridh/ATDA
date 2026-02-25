const loadBtn = document.getElementById('loadBtn');
const guardianSelect = document.getElementById('guardianSelect');
const dashboard = document.getElementById('dashboard');
const summaryCards = document.getElementById('summaryCards');

const gradesBody = document.querySelector('#gradesTable tbody');
const billsBody = document.querySelector('#billsTable tbody');
const txBody = document.querySelector('#txTable tbody');
const charList = document.getElementById('charList');

function idr(v) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(v);
}

function setSummary(student, summary) {
  summaryCards.innerHTML = '';
  const cards = [
    ['Santri', student.name],
    ['Kelas / Asrama', `${student.kelas} / ${student.asrama}`],
    ['Rata-Rata Akademik', summary.academic_avg],
    ['Saldo Wallet', idr(summary.wallet_balance)],
    ['Tunggakan', idr(summary.arrears)],
    ['Poin Disiplin', summary.discipline_points],
  ];

  cards.forEach(([title, value]) => {
    const div = document.createElement('div');
    div.className = 'card';
    div.innerHTML = `<h3>${title}</h3><div class="value">${value}</div>`;
    summaryCards.appendChild(div);
  });
}

function fillTable(tbody, rows, mapFn) {
  tbody.innerHTML = '';
  rows.forEach((row) => {
    const tr = document.createElement('tr');
    tr.innerHTML = mapFn(row);
    tbody.appendChild(tr);
  });
}

loadBtn.addEventListener('click', async () => {
  const guardianId = guardianSelect.value;
  const res = await fetch(`/api/guardian/${guardianId}/dashboard`);
  const data = await res.json();

  setSummary(data.student, data.summary);

  fillTable(gradesBody, data.grades, (g) => `<td>${g.category}</td><td>${g.subject}</td><td>${g.score}</td><td>${g.semester}</td>`);
  fillTable(billsBody, data.bills, (b) => `<td>${b.bill_type}</td><td>${b.period}</td><td>${idr(b.amount_due)}</td><td>${idr(b.amount_paid)}</td><td>${b.status}</td>`);
  fillTable(txBody, data.transactions, (t) => `<td>${t.txn_type}</td><td>${idr(t.amount)}</td><td>${t.description}</td><td>${new Date(t.created_at).toLocaleString('id-ID')}</td>`);

  charList.innerHTML = '';
  data.character.forEach((c) => {
    const li = document.createElement('li');
    li.textContent = `${c.type}: ${c.value} (${c.date})`;
    charList.appendChild(li);
  });

  dashboard.classList.remove('hidden');
});
