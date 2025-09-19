-- Supabase schema for certificate verification system
-- Users

-- Institutions
CREATE TABLE institutions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text,
  contact_email text,
  created_at timestamptz DEFAULT now()
);

-- Users
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'institution', 'verifier')),
  verified boolean DEFAULT false,
  institution_id uuid,
  phone_number text,
  address text,
  organization text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE users ADD CONSTRAINT fk_users_institution FOREIGN KEY (institution_id) REFERENCES institutions(id);
-- Migration: Add new columns and index for enhanced registration
ALTER TABLE users
  ADD COLUMN organization text,
  ADD COLUMN phone_number text,
  ADD COLUMN address text;

CREATE INDEX IF NOT EXISTS idx_user_phone ON users(phone_number);
-- Ensure email uniqueness regardless of case
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_email_lower ON users (lower(email));
CREATE INDEX idx_user_phone ON users(phone_number);

-- Certificates
CREATE TABLE certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_number text UNIQUE NOT NULL,
  student_name text NOT NULL,
  roll_number text,
  course text,
  institution_id uuid REFERENCES institutions(id),
  issued_date date,
  file_url text,
  status text NOT NULL CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED')),
  created_at timestamptz DEFAULT now()
);

-- Certificate Subjects
CREATE TABLE certificate_subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES certificates(id),
  subject text NOT NULL,
  marks integer,
  created_at timestamptz DEFAULT now()
);

-- Verification Requests
CREATE TABLE verification_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES certificates(id),
  requested_by uuid REFERENCES users(id),
  status text NOT NULL CHECK (status IN ('PENDING', 'PROCESSING', 'VERIFIED', 'FAILED', 'FRAUD', 'FLAGGED', 'REJECTED')),
  result jsonb,
  created_at timestamptz DEFAULT now()
);

-- Analytics indexes for dashboard and history
CREATE INDEX IF NOT EXISTS idx_vr_req_by_created ON verification_requests(requested_by, created_at);
CREATE INDEX IF NOT EXISTS idx_vr_req_by_status ON verification_requests(requested_by, status);
CREATE INDEX IF NOT EXISTS idx_vr_created ON verification_requests(created_at);

-- Safe migration for status constraint
-- ALTER TABLE verification_requests DROP CONSTRAINT IF EXISTS verification_requests_status_check;
-- ALTER TABLE verification_requests ADD CONSTRAINT verification_requests_status_check CHECK (status IN ('PENDING', 'PROCESSING', 'VERIFIED', 'FAILED', 'FRAUD', 'FLAGGED', 'REJECTED'));

-- Alerts
CREATE TABLE alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL,
  severity text NOT NULL,
  message text,
  resolved boolean DEFAULT false,
  verification_request_id uuid REFERENCES verification_requests(id),
  created_at timestamptz DEFAULT now()
);

-- Audit Logs
CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  action text NOT NULL,
  table_name text NOT NULL,
  record_id uuid,
  old_value jsonb,
  new_value jsonb,
  created_at timestamptz DEFAULT now()
);

-- Certificate Hashes
CREATE TABLE certificate_hashes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES certificates(id),
  hash text NOT NULL,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX idx_cert_number ON certificates(certificate_number);
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_institution_name ON institutions(name);
CREATE INDEX idx_alert_type ON alerts(type);

-- RLS policies and triggers to be added as needed
