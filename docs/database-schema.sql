-- =============================================================
-- ATDA - Database Schema (PostgreSQL)
-- Multi-tenant + RBAC + Audit + Pesantren domain modules
-- =============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------
-- Core tenant & user tables
-- ----------------------------
CREATE TABLE pesantren (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(30) UNIQUE NOT NULL,
  name VARCHAR(150) NOT NULL,
  address TEXT,
  phone VARCHAR(30),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL, -- SUPER_ADMIN, ADMIN_PESANTREN, USTADZ_WALI_KELAS, MUSYRIF, SANTRI, WALI_SANTRI
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID REFERENCES pesantren(id),
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(30),
  password_hash TEXT,
  pin_hash TEXT,
  otp_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  UNIQUE(user_id, role_id)
);

-- ----------------------------
-- Santri profile domain
-- ----------------------------
CREATE TABLE guardians (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID NOT NULL REFERENCES pesantren(id),
  user_id UUID UNIQUE REFERENCES users(id),
  relation_type VARCHAR(30) NOT NULL, -- AYAH/IBU/WALI
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  email VARCHAR(150),
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID NOT NULL REFERENCES pesantren(id),
  name VARCHAR(100) NOT NULL,
  level VARCHAR(50),
  academic_year VARCHAR(20) NOT NULL,
  homeroom_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (pesantren_id, name, academic_year)
);

CREATE TABLE dormitories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID NOT NULL REFERENCES pesantren(id),
  name VARCHAR(100) NOT NULL,
  musyrif_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (pesantren_id, name)
);

CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID NOT NULL REFERENCES pesantren(id),
  user_id UUID UNIQUE REFERENCES users(id),
  nis VARCHAR(50) NOT NULL,
  nik_encrypted TEXT,
  full_name VARCHAR(150) NOT NULL,
  birth_place VARCHAR(100),
  birth_date DATE,
  gender VARCHAR(20),
  class_id UUID REFERENCES classes(id),
  dormitory_id UUID REFERENCES dormitories(id),
  status VARCHAR(20) NOT NULL DEFAULT 'AKTIF', -- AKTIF/CUTI/ALUMNI
  photo_url TEXT,
  enrollment_date DATE,
  graduation_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (pesantren_id, nis)
);

CREATE TABLE student_guardians (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  guardian_id UUID NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(student_id, guardian_id)
);

CREATE TABLE student_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  doc_type VARCHAR(50) NOT NULL,
  file_url TEXT NOT NULL,
  uploaded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Financial domain
-- ----------------------------
CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID UNIQUE NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  balance NUMERIC(14,2) NOT NULL DEFAULT 0,
  daily_limit NUMERIC(14,2),
  weekly_limit NUMERIC(14,2),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE wallet_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
  txn_type VARCHAR(20) NOT NULL, -- TOPUP/DEBIT/ADJUSTMENT
  amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
  channel VARCHAR(30), -- KANTIN/KOPERASI/BANK/CASH
  description TEXT,
  reference_no VARCHAR(100),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE billing_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID NOT NULL REFERENCES pesantren(id),
  code VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL, -- SPP/INFAQ/LAINNYA
  amount NUMERIC(14,2) NOT NULL,
  recurring_type VARCHAR(20) NOT NULL, -- MONTHLY/ONCE
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (pesantren_id, code)
);

CREATE TABLE student_bills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  billing_item_id UUID NOT NULL REFERENCES billing_items(id),
  period VARCHAR(20) NOT NULL, -- 2026-01
  amount_due NUMERIC(14,2) NOT NULL,
  due_date DATE,
  status VARCHAR(20) NOT NULL DEFAULT 'UNPAID', -- UNPAID/PARTIAL/PAID
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, billing_item_id, period)
);

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_bill_id UUID NOT NULL REFERENCES student_bills(id) ON DELETE CASCADE,
  amount_paid NUMERIC(14,2) NOT NULL CHECK (amount_paid > 0),
  method VARCHAR(30) NOT NULL, -- CASH/TRANSFER/VA/EWALLET
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  receipt_url TEXT,
  created_by UUID REFERENCES users(id)
);

-- ----------------------------
-- Academic & report domain
-- ----------------------------
CREATE TABLE subjects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID NOT NULL REFERENCES pesantren(id),
  name VARCHAR(100) NOT NULL,
  category VARCHAR(20) NOT NULL, -- DINIYAH/UMUM/TAHFIDZ
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE assessments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  class_id UUID NOT NULL REFERENCES classes(id),
  subject_id UUID NOT NULL REFERENCES subjects(id),
  semester VARCHAR(20) NOT NULL,
  assessment_type VARCHAR(30) NOT NULL, -- HARIAN/UTS/UAS/TASMI
  title VARCHAR(150) NOT NULL,
  assessment_date DATE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE grades (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (assessment_id, student_id)
);

CREATE TABLE report_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  semester VARCHAR(20) NOT NULL,
  academic_year VARCHAR(20) NOT NULL,
  homeroom_note TEXT,
  generated_pdf_url TEXT,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, semester, academic_year)
);

-- ----------------------------
-- Character & coaching domain
-- ----------------------------
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  attendance_scope VARCHAR(20) NOT NULL, -- KELAS/ASRAMA
  attendance_date DATE NOT NULL,
  status VARCHAR(20) NOT NULL, -- HADIR/IZIN/SAKIT/ALPA
  note TEXT,
  recorded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, attendance_scope, attendance_date)
);

CREATE TABLE violations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  violation_type VARCHAR(100) NOT NULL,
  point INT NOT NULL CHECK (point >= 0),
  severity VARCHAR(20) NOT NULL, -- RINGAN/SEDANG/BERAT
  description TEXT,
  action_taken TEXT,
  occurred_at TIMESTAMPTZ NOT NULL,
  recorded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE coaching_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL, -- TARBIYAH/AKHLAK/MOTIVASI
  note TEXT NOT NULL,
  follow_up_plan TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  title VARCHAR(150) NOT NULL,
  level VARCHAR(50),
  achieved_at DATE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Notification + audit domain
-- ----------------------------
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pesantren_id UUID REFERENCES pesantren(id),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  channel VARCHAR(20) NOT NULL, -- PUSH/WA/EMAIL/IN_APP
  title VARCHAR(150) NOT NULL,
  body TEXT NOT NULL,
  payload JSONB,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING/SENT/FAILED/READ
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  entity_name VARCHAR(100),
  entity_id UUID,
  ip_address VARCHAR(64),
  user_agent TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Helpful indexes
CREATE INDEX idx_students_pesantren ON students(pesantren_id);
CREATE INDEX idx_wallet_txn_wallet_date ON wallet_transactions(wallet_id, created_at DESC);
CREATE INDEX idx_attendance_student_date ON attendance(student_id, attendance_date DESC);
CREATE INDEX idx_grades_student ON grades(student_id);
CREATE INDEX idx_notifications_user_status ON notifications(user_id, status);
