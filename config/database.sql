-- =====================================================================================
-- COMPREHENSIVE SECURE DATABASE SCHEMA FOR CERTIFICATE VERIFICATION SYSTEM
-- Jharkhand Government - Advanced Security Implementation
-- =====================================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================================================
-- CORE SECURITY TABLES
-- =====================================================================================

-- Enable extensions used below
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Security Alerts (separate from basic alerts)
CREATE TABLE IF NOT EXISTS security_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  alert_type text NOT NULL,
  severity text NOT NULL CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  table_name text,
  record_id uuid,
  message text,
  details jsonb,
  detected_at timestamptz NOT NULL DEFAULT now(),
  resolved boolean NOT NULL DEFAULT false,
  resolved_by uuid,
  resolved_at timestamptz
);

-- Add missing columns to security_alerts table if they don't exist
DO $$
BEGIN
  -- Add the resolved column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'security_alerts' AND column_name = 'resolved') THEN
    ALTER TABLE security_alerts ADD COLUMN resolved boolean NOT NULL DEFAULT false;
  END IF;
  
  -- Add the resolved_by column if it doesn't exist  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'security_alerts' AND column_name = 'resolved_by') THEN
    ALTER TABLE security_alerts ADD COLUMN resolved_by uuid;
  END IF;
  
  -- Add the resolved_at column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'security_alerts' AND column_name = 'resolved_at') THEN
    ALTER TABLE security_alerts ADD COLUMN resolved_at timestamptz;
  END IF;
  
  -- Add the details column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'security_alerts' AND column_name = 'details') THEN
    ALTER TABLE security_alerts ADD COLUMN details jsonb;
  END IF;
  
  -- Add the detected_at column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'security_alerts' AND column_name = 'detected_at') THEN
    ALTER TABLE security_alerts ADD COLUMN detected_at timestamptz NOT NULL DEFAULT now();
  END IF;
END $$;

-- Change Data Capture log
CREATE TABLE IF NOT EXISTS cdc_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  operation text NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),
  record_pk text NOT NULL,
  before_data jsonb,
  after_data jsonb,
  performed_by uuid,
  session_id uuid,
  txid bigint DEFAULT txid_current(),
  performed_at timestamptz NOT NULL DEFAULT now()
);

-- Add missing columns to cdc_log table if they don't exist
DO $$
BEGIN
  -- Check if old column names exist and rename them
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'old_value') AND 
     NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'before_data') THEN
    ALTER TABLE cdc_log RENAME COLUMN old_value TO before_data;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'new_value') AND 
     NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'after_data') THEN
    ALTER TABLE cdc_log RENAME COLUMN new_value TO after_data;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'created_at') AND 
     NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'performed_at') THEN
    ALTER TABLE cdc_log RENAME COLUMN created_at TO performed_at;
  END IF;

  -- Add missing columns if they don't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'before_data') THEN
    ALTER TABLE cdc_log ADD COLUMN before_data jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'after_data') THEN
    ALTER TABLE cdc_log ADD COLUMN after_data jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'performed_by') THEN
    ALTER TABLE cdc_log ADD COLUMN performed_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'session_id') THEN
    ALTER TABLE cdc_log ADD COLUMN session_id uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'txid') THEN
    ALTER TABLE cdc_log ADD COLUMN txid bigint DEFAULT txid_current();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cdc_log' AND column_name = 'performed_at') THEN
    ALTER TABLE cdc_log ADD COLUMN performed_at timestamptz NOT NULL DEFAULT now();
  END IF;
END $$;

-- Role-based permissions registry (resource/action)
CREATE TABLE IF NOT EXISTS role_permissions (
  role text NOT NULL,
  resource text NOT NULL,
  action text NOT NULL,
  condition jsonb,
  allowed boolean NOT NULL DEFAULT true,
  PRIMARY KEY (role, resource, action)
);

-- Approval workflows for sensitive operations
CREATE TABLE IF NOT EXISTS approval_workflows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resource text NOT NULL,
  action text NOT NULL,
  record_id uuid,
  status text NOT NULL CHECK (status IN ('PENDING','APPROVED','REJECTED','CANCELLED')) DEFAULT 'PENDING',
  requested_by uuid,
  approvals jsonb,
  level_required int DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Integrity checks registry
CREATE TABLE IF NOT EXISTS integrity_checks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  record_id uuid,
  checksum text NOT NULL,
  computed_at timestamptz NOT NULL DEFAULT now(),
  verified boolean NOT NULL DEFAULT false,
  verified_at timestamptz,
  details jsonb
);

-- User sessions for RLS/session governance
CREATE TABLE IF NOT EXISTS user_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  token_hash text NOT NULL,
  ip_address text,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz,
  expires_at timestamptz,
  revoked_at timestamptz,
  is_active boolean DEFAULT true
);

-- Add missing columns to user_sessions table if they don't exist
DO $$
BEGIN
  -- Add the revoked_at column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_sessions' AND column_name = 'revoked_at') THEN
    ALTER TABLE user_sessions ADD COLUMN revoked_at timestamptz;
  END IF;
  
  -- Add the last_seen_at column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_sessions' AND column_name = 'last_seen_at') THEN
    ALTER TABLE user_sessions ADD COLUMN last_seen_at timestamptz;
  END IF;
  
  -- Add the expires_at column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_sessions' AND column_name = 'expires_at') THEN
    ALTER TABLE user_sessions ADD COLUMN expires_at timestamptz;
  END IF;
  
  -- Add the is_active column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_sessions' AND column_name = 'is_active') THEN
    ALTER TABLE user_sessions ADD COLUMN is_active boolean DEFAULT true;
  END IF;
END $$;

-- =====================================================================================
-- ENHANCED EXISTING TABLES (Migration-Safe Approach)
-- =====================================================================================

-- Enhanced Institutions Table - Create if not exists, then add new columns
CREATE TABLE IF NOT EXISTS institutions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text,
  contact_email text,
  created_at timestamptz DEFAULT now()
);

-- Add new columns to institutions table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'phone_number') THEN
    ALTER TABLE institutions ADD COLUMN phone_number text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'registration_number') THEN
    ALTER TABLE institutions ADD COLUMN registration_number text;
    ALTER TABLE institutions ADD CONSTRAINT institutions_registration_number_key UNIQUE (registration_number);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'verification_status') THEN
    ALTER TABLE institutions ADD COLUMN verification_status text DEFAULT 'PENDING';
    ALTER TABLE institutions ADD CONSTRAINT institutions_verification_status_check CHECK (verification_status IN ('PENDING', 'VERIFIED', 'SUSPENDED', 'REJECTED'));
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'trust_score') THEN
    ALTER TABLE institutions ADD COLUMN trust_score integer DEFAULT 50;
    ALTER TABLE institutions ADD CONSTRAINT institutions_trust_score_check CHECK (trust_score >= 0 AND trust_score <= 100);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'verification_documents') THEN
    ALTER TABLE institutions ADD COLUMN verification_documents jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'verified_by') THEN
    ALTER TABLE institutions ADD COLUMN verified_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'verified_at') THEN
    ALTER TABLE institutions ADD COLUMN verified_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'last_audit_date') THEN
    ALTER TABLE institutions ADD COLUMN last_audit_date timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'metadata') THEN
    ALTER TABLE institutions ADD COLUMN metadata jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'is_active') THEN
    ALTER TABLE institutions ADD COLUMN is_active boolean DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'institutions' AND column_name = 'updated_at') THEN
    ALTER TABLE institutions ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Enhanced Users Table - Create if not exists, then add new columns
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  name text NOT NULL,
  role text NOT NULL,
  verified boolean DEFAULT false,
  institution_id uuid,
  created_at timestamptz DEFAULT now()
);

-- For tables that should have created_at but don't
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'created_at') THEN
    ALTER TABLE users ADD COLUMN created_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add new columns to users table if they don't exist
DO $$
BEGIN
  -- Drop existing role constraint if it exists to update it
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'users' AND constraint_name = 'users_role_check') THEN
    ALTER TABLE users DROP CONSTRAINT users_role_check;
  END IF;
  
  -- Add updated role constraint
  ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('admin', 'institution', 'verifier', 'auditor', 'super_admin'));
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'phone_number') THEN
    ALTER TABLE users ADD COLUMN phone_number text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'address') THEN
    ALTER TABLE users ADD COLUMN address text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'organization') THEN
    ALTER TABLE users ADD COLUMN organization text;
  END IF;
  
  -- Security enhancements
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'last_login') THEN
    ALTER TABLE users ADD COLUMN last_login timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'failed_login_attempts') THEN
    ALTER TABLE users ADD COLUMN failed_login_attempts integer DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'account_locked_until') THEN
    ALTER TABLE users ADD COLUMN account_locked_until timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'two_factor_enabled') THEN
    ALTER TABLE users ADD COLUMN two_factor_enabled boolean DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'two_factor_secret') THEN
    ALTER TABLE users ADD COLUMN two_factor_secret text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'backup_codes') THEN
    ALTER TABLE users ADD COLUMN backup_codes text[];
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'password_changed_at') THEN
    ALTER TABLE users ADD COLUMN password_changed_at timestamptz DEFAULT now();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'must_change_password') THEN
    ALTER TABLE users ADD COLUMN must_change_password boolean DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'security_questions') THEN
    ALTER TABLE users ADD COLUMN security_questions jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'profile_picture_url') THEN
    ALTER TABLE users ADD COLUMN profile_picture_url text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'emergency_contact') THEN
    ALTER TABLE users ADD COLUMN emergency_contact jsonb;
  END IF;
  
  -- Audit fields
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'created_by') THEN
    ALTER TABLE users ADD COLUMN created_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'approved_by') THEN
    ALTER TABLE users ADD COLUMN approved_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'approved_at') THEN
    ALTER TABLE users ADD COLUMN approved_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'is_active') THEN
    ALTER TABLE users ADD COLUMN is_active boolean DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'updated_at') THEN
    ALTER TABLE users ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add foreign key constraints for users table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'users' AND constraint_name = 'fk_users_institution') THEN
    ALTER TABLE users ADD CONSTRAINT fk_users_institution FOREIGN KEY (institution_id) REFERENCES institutions(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'users' AND constraint_name = 'fk_users_created_by') THEN
    ALTER TABLE users ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'users' AND constraint_name = 'fk_users_approved_by') THEN
    ALTER TABLE users ADD CONSTRAINT fk_users_approved_by FOREIGN KEY (approved_by) REFERENCES users(id);
  END IF;
  
  -- Add foreign key constraint for user_sessions table
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'user_sessions' AND constraint_name = 'fk_user_sessions_user') THEN
    ALTER TABLE user_sessions ADD CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
  END IF;
  
  -- Add foreign key constraint for security_alerts table
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'security_alerts' AND constraint_name = 'fk_security_alerts_resolved_by') THEN
    ALTER TABLE security_alerts ADD CONSTRAINT fk_security_alerts_resolved_by FOREIGN KEY (resolved_by) REFERENCES users(id);
  END IF;
  
  -- Add foreign key constraint for approval_workflows table
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'approval_workflows' AND constraint_name = 'fk_approval_workflows_requested_by') THEN
    ALTER TABLE approval_workflows ADD CONSTRAINT fk_approval_workflows_requested_by FOREIGN KEY (requested_by) REFERENCES users(id);
  END IF;
END $$;

-- Enhanced Certificates Table - Create if not exists, then add new columns
CREATE TABLE IF NOT EXISTS certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_number text UNIQUE NOT NULL,
  student_name text NOT NULL,
  roll_number text,
  course text,
  institution_id uuid REFERENCES institutions(id),
  issued_date date,
  file_url text,
  status text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Add new columns to certificates table if they don't exist
DO $$
BEGIN
  -- Drop existing status constraint if it exists to update it
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'certificates' AND constraint_name = 'certificates_status_check') THEN
    ALTER TABLE certificates DROP CONSTRAINT certificates_status_check;
  END IF;
  
  -- Add updated status constraint
  ALTER TABLE certificates ADD CONSTRAINT certificates_status_check CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED', 'SUSPENDED', 'REVOKED'));
  
  -- Security enhancements
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'checksum') THEN
    ALTER TABLE certificates ADD COLUMN checksum text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'digital_signature') THEN
    ALTER TABLE certificates ADD COLUMN digital_signature text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'integrity_verified_at') THEN
    ALTER TABLE certificates ADD COLUMN integrity_verified_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'verification_method') THEN
    ALTER TABLE certificates ADD COLUMN verification_method text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'tamper_evident_features') THEN
    ALTER TABLE certificates ADD COLUMN tamper_evident_features jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'blockchain_hash') THEN
    ALTER TABLE certificates ADD COLUMN blockchain_hash text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'qr_code_data') THEN
    ALTER TABLE certificates ADD COLUMN qr_code_data text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'watermark_data') THEN
    ALTER TABLE certificates ADD COLUMN watermark_data text;
  END IF;
  
  -- Additional metadata
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'batch_id') THEN
    ALTER TABLE certificates ADD COLUMN batch_id uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'issued_by') THEN
    ALTER TABLE certificates ADD COLUMN issued_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'verified_by') THEN
    ALTER TABLE certificates ADD COLUMN verified_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'grade_percentage') THEN
    ALTER TABLE certificates ADD COLUMN grade_percentage decimal(5,2);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'class_rank') THEN
    ALTER TABLE certificates ADD COLUMN class_rank integer;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'total_students') THEN
    ALTER TABLE certificates ADD COLUMN total_students integer;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'additional_info') THEN
    ALTER TABLE certificates ADD COLUMN additional_info jsonb;
  END IF;
  
  -- Audit and lifecycle
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'created_by') THEN
    ALTER TABLE certificates ADD COLUMN created_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'approved_by') THEN
    ALTER TABLE certificates ADD COLUMN approved_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'last_verified_at') THEN
    ALTER TABLE certificates ADD COLUMN last_verified_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'revoked_at') THEN
    ALTER TABLE certificates ADD COLUMN revoked_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'revocation_reason') THEN
    ALTER TABLE certificates ADD COLUMN revocation_reason text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'is_active') THEN
    ALTER TABLE certificates ADD COLUMN is_active boolean DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificates' AND column_name = 'updated_at') THEN
    ALTER TABLE certificates ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add foreign key constraints for certificates table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'certificates' AND constraint_name = 'fk_certificates_issued_by') THEN
    ALTER TABLE certificates ADD CONSTRAINT fk_certificates_issued_by FOREIGN KEY (issued_by) REFERENCES users(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'certificates' AND constraint_name = 'fk_certificates_verified_by') THEN
    ALTER TABLE certificates ADD CONSTRAINT fk_certificates_verified_by FOREIGN KEY (verified_by) REFERENCES users(id);
  END IF;
END $$;

-- Enhanced Certificate Subjects Table
CREATE TABLE IF NOT EXISTS certificate_subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES certificates(id),
  subject text NOT NULL,
  marks integer,
  created_at timestamptz DEFAULT now()
);

-- Add new columns to certificate_subjects table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_subjects' AND column_name = 'max_marks') THEN
    ALTER TABLE certificate_subjects ADD COLUMN max_marks integer DEFAULT 100;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_subjects' AND column_name = 'grade') THEN
    ALTER TABLE certificate_subjects ADD COLUMN grade text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_subjects' AND column_name = 'credits') THEN
    ALTER TABLE certificate_subjects ADD COLUMN credits integer;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_subjects' AND column_name = 'is_core_subject') THEN
    ALTER TABLE certificate_subjects ADD COLUMN is_core_subject boolean DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_subjects' AND column_name = 'subject_code') THEN
    ALTER TABLE certificate_subjects ADD COLUMN subject_code text;
  END IF;
END $$;

-- Update certificate_subjects foreign key constraint to include CASCADE
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'certificate_subjects' AND constraint_name = 'certificate_subjects_certificate_id_fkey') THEN
    ALTER TABLE certificate_subjects DROP CONSTRAINT certificate_subjects_certificate_id_fkey;
    ALTER TABLE certificate_subjects ADD CONSTRAINT certificate_subjects_certificate_id_fkey FOREIGN KEY (certificate_id) REFERENCES certificates(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Enhanced Verification Requests Table
CREATE TABLE IF NOT EXISTS verification_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES certificates(id),
  requested_by uuid REFERENCES users(id),
  status text NOT NULL,
  result jsonb,
  created_at timestamptz DEFAULT now()
);

-- Add new columns to verification_requests table if they don't exist
DO $$
BEGIN
  -- Drop existing status constraint if it exists to update it
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'verification_requests' AND constraint_name = 'verification_requests_status_check') THEN
    ALTER TABLE verification_requests DROP CONSTRAINT verification_requests_status_check;
  END IF;
  
  -- Add updated status constraint
  ALTER TABLE verification_requests ADD CONSTRAINT verification_requests_status_check CHECK (status IN ('PENDING', 'PROCESSING', 'VERIFIED', 'FAILED', 'FRAUD', 'FLAGGED', 'REJECTED', 'REQUIRES_MANUAL_REVIEW'));
  
  -- Fraud detection fields
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'risk_score') THEN
    ALTER TABLE verification_requests ADD COLUMN risk_score integer DEFAULT 0;
    ALTER TABLE verification_requests ADD CONSTRAINT verification_requests_risk_score_check CHECK (risk_score >= 0 AND risk_score <= 100);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'fraud_indicators') THEN
    ALTER TABLE verification_requests ADD COLUMN fraud_indicators jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'ml_confidence_score') THEN
    ALTER TABLE verification_requests ADD COLUMN ml_confidence_score decimal(5,4);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'verification_method') THEN
    ALTER TABLE verification_requests ADD COLUMN verification_method text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'verification_time_ms') THEN
    ALTER TABLE verification_requests ADD COLUMN verification_time_ms integer;
  END IF;
  
  -- Request metadata
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'requester_ip') THEN
    ALTER TABLE verification_requests ADD COLUMN requester_ip inet;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'requester_user_agent') THEN
    ALTER TABLE verification_requests ADD COLUMN requester_user_agent text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'api_key_used') THEN
    ALTER TABLE verification_requests ADD COLUMN api_key_used text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'batch_request_id') THEN
    ALTER TABLE verification_requests ADD COLUMN batch_request_id uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'priority') THEN
    ALTER TABLE verification_requests ADD COLUMN priority text DEFAULT 'NORMAL';
    ALTER TABLE verification_requests ADD CONSTRAINT verification_requests_priority_check CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT'));
  END IF;
  
  -- Processing details
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'processed_by') THEN
    ALTER TABLE verification_requests ADD COLUMN processed_by uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'processing_started_at') THEN
    ALTER TABLE verification_requests ADD COLUMN processing_started_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'processing_completed_at') THEN
    ALTER TABLE verification_requests ADD COLUMN processing_completed_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'manual_review_required') THEN
    ALTER TABLE verification_requests ADD COLUMN manual_review_required boolean DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'reviewer_notes') THEN
    ALTER TABLE verification_requests ADD COLUMN reviewer_notes text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'verification_requests' AND column_name = 'updated_at') THEN
    ALTER TABLE verification_requests ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add foreign key constraints for verification_requests table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'verification_requests' AND constraint_name = 'fk_verification_requests_processed_by') THEN
    ALTER TABLE verification_requests ADD CONSTRAINT fk_verification_requests_processed_by FOREIGN KEY (processed_by) REFERENCES users(id);
  END IF;
END $$;

-- Enhanced Alerts Table
CREATE TABLE IF NOT EXISTS alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL,
  severity text NOT NULL,
  message text,
  resolved boolean DEFAULT false,
  verification_request_id uuid REFERENCES verification_requests(id),
  created_at timestamptz DEFAULT now()
);

-- Add new columns to alerts table if they don't exist
DO $$
BEGIN
  -- Drop existing severity constraint if it exists to update it
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'alerts' AND constraint_name = 'alerts_severity_check') THEN
    ALTER TABLE alerts DROP CONSTRAINT alerts_severity_check;
  END IF;
  
  -- Add updated severity constraint
  ALTER TABLE alerts ADD CONSTRAINT alerts_severity_check CHECK (severity IN ('INFO', 'WARNING', 'ERROR', 'CRITICAL'));
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'related_user_id') THEN
    ALTER TABLE alerts ADD COLUMN related_user_id uuid REFERENCES users(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'related_certificate_id') THEN
    ALTER TABLE alerts ADD COLUMN related_certificate_id uuid REFERENCES certificates(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'alert_data') THEN
    ALTER TABLE alerts ADD COLUMN alert_data jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'auto_generated') THEN
    ALTER TABLE alerts ADD COLUMN auto_generated boolean DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'resolution_action') THEN
    ALTER TABLE alerts ADD COLUMN resolution_action text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'resolved_by') THEN
    ALTER TABLE alerts ADD COLUMN resolved_by uuid REFERENCES users(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'resolved_at') THEN
    ALTER TABLE alerts ADD COLUMN resolved_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'escalated') THEN
    ALTER TABLE alerts ADD COLUMN escalated boolean DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'escalated_to') THEN
    ALTER TABLE alerts ADD COLUMN escalated_to uuid REFERENCES users(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'escalated_at') THEN
    ALTER TABLE alerts ADD COLUMN escalated_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'alerts' AND column_name = 'updated_at') THEN
    ALTER TABLE alerts ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Enhanced Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  action text NOT NULL,
  table_name text NOT NULL,
  record_id uuid,
  old_value jsonb,
  new_value jsonb,
  created_at timestamptz DEFAULT now()
);

-- Add new columns to audit_logs table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'session_id') THEN
    ALTER TABLE audit_logs ADD COLUMN session_id uuid;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'affected_columns') THEN
    ALTER TABLE audit_logs ADD COLUMN affected_columns text[];
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'ip_address') THEN
    ALTER TABLE audit_logs ADD COLUMN ip_address inet;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'user_agent') THEN
    ALTER TABLE audit_logs ADD COLUMN user_agent text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'api_endpoint') THEN
    ALTER TABLE audit_logs ADD COLUMN api_endpoint text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'request_method') THEN
    ALTER TABLE audit_logs ADD COLUMN request_method text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'success') THEN
    ALTER TABLE audit_logs ADD COLUMN success boolean DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'error_message') THEN
    ALTER TABLE audit_logs ADD COLUMN error_message text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'duration_ms') THEN
    ALTER TABLE audit_logs ADD COLUMN duration_ms integer;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'additional_context') THEN
    ALTER TABLE audit_logs ADD COLUMN additional_context jsonb;
  END IF;
END $$;

-- Enhanced Certificate Hashes Table
CREATE TABLE IF NOT EXISTS certificate_hashes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES certificates(id),
  hash text NOT NULL,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

-- Add new columns to certificate_hashes table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_hashes' AND column_name = 'hash_algorithm') THEN
    ALTER TABLE certificate_hashes ADD COLUMN hash_algorithm text DEFAULT 'SHA256';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_hashes' AND column_name = 'salt') THEN
    ALTER TABLE certificate_hashes ADD COLUMN salt text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_hashes' AND column_name = 'computed_at') THEN
    ALTER TABLE certificate_hashes ADD COLUMN computed_at timestamptz DEFAULT now();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_hashes' AND column_name = 'verified_at') THEN
    ALTER TABLE certificate_hashes ADD COLUMN verified_at timestamptz;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_hashes' AND column_name = 'is_current') THEN
    ALTER TABLE certificate_hashes ADD COLUMN is_current boolean DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'certificate_hashes' AND column_name = 'previous_hash_id') THEN
    ALTER TABLE certificate_hashes ADD COLUMN previous_hash_id uuid;
  END IF;
END $$;

-- Add foreign key constraints for certificate_hashes table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'certificate_hashes' AND constraint_name = 'fk_certificate_hashes_previous') THEN
    ALTER TABLE certificate_hashes ADD CONSTRAINT fk_certificate_hashes_previous FOREIGN KEY (previous_hash_id) REFERENCES certificate_hashes(id);
  END IF;
END $$;

-- =====================================================================================
-- UTILITY FUNCTIONS
-- =====================================================================================

-- Function to generate secure checksum
CREATE OR REPLACE FUNCTION generate_checksum(data jsonb, salt text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  computed_salt text;
BEGIN
  computed_salt := COALESCE(salt, gen_random_uuid()::text);
  RETURN encode(digest(data::text || computed_salt, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to calculate fraud risk score
CREATE OR REPLACE FUNCTION calculate_fraud_risk_score(
  certificate_data jsonb,
  verification_context jsonb
) RETURNS integer AS $$
DECLARE
  risk_score integer := 0;
  indicators jsonb;
BEGIN
  indicators := '{}';
  
  -- Check for suspicious patterns
  IF verification_context->>'ip_country' != 'IN' THEN
    risk_score := risk_score + 20;
    indicators := indicators || '{"foreign_ip": true}';
  END IF;
  
  -- Check for off-hours access
  IF EXTRACT(hour FROM now()) BETWEEN 22 AND 6 THEN
    risk_score := risk_score + 10;
    indicators := indicators || '{"off_hours": true}';
  END IF;
  
  -- Additional risk factors can be added here
  
  RETURN LEAST(risk_score, 100);
END;
$$ LANGUAGE plpgsql;

-- Function to validate session
CREATE OR REPLACE FUNCTION validate_session(session_token text)
RETURNS boolean AS $$
DECLARE
  session_exists boolean;
BEGIN
  -- Check if session exists and update is_active status
  UPDATE user_sessions 
  SET is_active = (revoked_at IS NULL AND (expires_at IS NULL OR expires_at > now())),
      last_seen_at = CASE WHEN revoked_at IS NULL AND (expires_at IS NULL OR expires_at > now()) THEN now() ELSE last_seen_at END
  WHERE token_hash = validate_session.session_token;
  
  SELECT EXISTS(
    SELECT 1 FROM user_sessions 
    WHERE token_hash = validate_session.session_token 
    AND is_active = true 
    AND (expires_at IS NULL OR expires_at > now())
  ) INTO session_exists;
  
  RETURN session_exists;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS integer AS $$
DECLARE
  cleaned_count integer;
BEGIN
  UPDATE user_sessions 
  SET revoked_at = now(),
      is_active = false
  WHERE expires_at < now() AND revoked_at IS NULL;
  
  GET DIAGNOSTICS cleaned_count = ROW_COUNT;
  RETURN cleaned_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- CDC TRIGGERS IMPLEMENTATION
-- =====================================================================================

-- CDC trigger function (generic)
CREATE OR REPLACE FUNCTION fn_cdc_log() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  user_id_text text;
  user_id_uuid uuid;
BEGIN
  -- Safely extract user ID from JWT claims
  BEGIN
    user_id_text := current_setting('request.jwt.claims', true)::jsonb->>'sub';
    user_id_uuid := user_id_text::uuid;
  EXCEPTION 
    WHEN OTHERS THEN
      user_id_uuid := null;
  END;

  IF TG_OP = 'INSERT' THEN
    INSERT INTO cdc_log(table_name, operation, record_pk, after_data, performed_by, session_id)
    VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(NEW.*)->> 'id', to_jsonb(NEW), user_id_uuid, null);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO cdc_log(table_name, operation, record_pk, before_data, after_data, performed_by, session_id)
    VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(NEW.*)->> 'id', to_jsonb(OLD), to_jsonb(NEW), user_id_uuid, null);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO cdc_log(table_name, operation, record_pk, before_data, performed_by, session_id)
    VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD.*)->> 'id', to_jsonb(OLD), user_id_uuid, null);
    RETURN OLD;
  END IF;
END;
$$;

-- Attach CDC triggers to core tables
DO $$ BEGIN
  PERFORM 1 FROM pg_trigger WHERE tgname = 'trg_cdc_users';
  IF NOT FOUND THEN
    CREATE TRIGGER trg_cdc_users AFTER INSERT OR UPDATE OR DELETE ON users FOR EACH ROW EXECUTE FUNCTION fn_cdc_log();
  END IF;
  PERFORM 1 FROM pg_trigger WHERE tgname = 'trg_cdc_institutions';
  IF NOT FOUND THEN
    CREATE TRIGGER trg_cdc_institutions AFTER INSERT OR UPDATE OR DELETE ON institutions FOR EACH ROW EXECUTE FUNCTION fn_cdc_log();
  END IF;
  PERFORM 1 FROM pg_trigger WHERE tgname = 'trg_cdc_certificates';
  IF NOT FOUND THEN
    CREATE TRIGGER trg_cdc_certificates AFTER INSERT OR UPDATE OR DELETE ON certificates FOR EACH ROW EXECUTE FUNCTION fn_cdc_log();
  END IF;
  PERFORM 1 FROM pg_trigger WHERE tgname = 'trg_cdc_verification_requests';
  IF NOT FOUND THEN
    CREATE TRIGGER trg_cdc_verification_requests AFTER INSERT OR UPDATE OR DELETE ON verification_requests FOR EACH ROW EXECUTE FUNCTION fn_cdc_log();
  END IF;
END $$;

-- Integrity checksum function (for certificates)
CREATE OR REPLACE FUNCTION fn_cert_checksum(p_row certificates) RETURNS text LANGUAGE sql IMMUTABLE AS $$
  SELECT encode(digest(coalesce(p_row.certificate_number,'') || '|' || coalesce(p_row.student_name,'') || '|' || coalesce(p_row.roll_number,'') || '|' || coalesce(p_row.course,''), 'sha256'), 'hex');
$$;

-- Add integrity fields to certificates if missing
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns WHERE table_name='certificates' AND column_name='checksum'
  ) THEN
    ALTER TABLE certificates ADD COLUMN checksum text, ADD COLUMN digital_signature text, ADD COLUMN integrity_verified_at timestamptz;
  END IF;
END $$;

-- BEFORE trigger to set checksum
CREATE OR REPLACE FUNCTION fn_cert_set_checksum() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.checksum := fn_cert_checksum(NEW);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_cert_set_checksum ON certificates;
CREATE TRIGGER trg_cert_set_checksum BEFORE INSERT OR UPDATE ON certificates FOR EACH ROW EXECUTE FUNCTION fn_cert_set_checksum();

-- Fraud detection trigger on verification_requests
CREATE OR REPLACE FUNCTION fn_vr_fraud_detection() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  hour int := EXTRACT(HOUR FROM now());
BEGIN
  -- Flag explicit fraud statuses
  IF NEW.status IN ('FRAUD','FLAGGED') THEN
    INSERT INTO security_alerts(alert_type, severity, table_name, record_id, message, details)
    VALUES ('verification_request', 'HIGH', 'verification_requests', NEW.id, 'Suspicious verification request status', jsonb_build_object('status', NEW.status, 'requested_by', NEW.requested_by));
  END IF;
  -- Off-hours activity heuristic (e.g., 00:00-05:00 UTC)
  IF hour BETWEEN 0 AND 5 THEN
    INSERT INTO security_alerts(alert_type, severity, table_name, record_id, message, details)
    VALUES ('off_hours_activity', 'MEDIUM', 'verification_requests', COALESCE(NEW.id, OLD.id), 'Activity recorded during off-hours', jsonb_build_object('op', TG_OP));
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_vr_fraud_detection ON verification_requests;
CREATE TRIGGER trg_vr_fraud_detection AFTER INSERT OR UPDATE ON verification_requests FOR EACH ROW EXECUTE FUNCTION fn_vr_fraud_detection();

-- =====================================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================================================

-- Enable RLS on all tables (safely)
DO $$
DECLARE
  table_record RECORD;
BEGIN
  FOR table_record IN 
    SELECT table_name FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('users', 'institutions', 'certificates', 'certificate_subjects', 'verification_requests', 'alerts', 'audit_logs', 'certificate_hashes', 'security_alerts', 'cdc_log', 'role_permissions', 'approval_workflows', 'integrity_checks', 'user_sessions')
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', table_record.table_name);
  END LOOP;
END $$;

-- Users table RLS policies (drop existing and recreate)
DO $$
BEGIN
  DROP POLICY IF EXISTS users_self_access ON users;
  DROP POLICY IF EXISTS users_admin_access ON users;
  
  CREATE POLICY users_self_access ON users
    FOR ALL USING (id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid);

  CREATE POLICY users_admin_access ON users
    FOR ALL TO authenticated USING (
      EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
        AND u.role IN ('admin', 'super_admin')
      )
    );
END $$;

-- Institutions table RLS policies (drop existing and recreate)
DO $$
BEGIN
  DROP POLICY IF EXISTS institutions_admin_access ON institutions;
  DROP POLICY IF EXISTS institutions_own_institution ON institutions;
  
  CREATE POLICY institutions_admin_access ON institutions
    FOR ALL TO authenticated USING (
      EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
        AND u.role IN ('admin', 'super_admin')
      )
    );

  CREATE POLICY institutions_own_institution ON institutions
    FOR SELECT TO authenticated USING (
      id = (
        SELECT institution_id FROM users 
        WHERE id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
      )
    );
END $$;

-- Certificates table RLS policies (drop existing and recreate)
DO $$
BEGIN
  DROP POLICY IF EXISTS certificates_admin_access ON certificates;
  DROP POLICY IF EXISTS certificates_institution_access ON certificates;
  DROP POLICY IF EXISTS certificates_verifier_read ON certificates;
  
  CREATE POLICY certificates_admin_access ON certificates
    FOR ALL TO authenticated USING (
      EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
        AND u.role IN ('admin', 'super_admin', 'auditor')
      )
    );

  CREATE POLICY certificates_institution_access ON certificates
    FOR ALL TO authenticated USING (
      institution_id = (
        SELECT institution_id FROM users 
        WHERE id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
        AND role = 'institution'
      )
    );

  CREATE POLICY certificates_verifier_read ON certificates
    FOR SELECT TO authenticated USING (
      EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
        AND u.role = 'verifier'
      )
    );
END $$;

-- Verification requests RLS policies (drop existing and recreate)
DO $$
BEGIN
  DROP POLICY IF EXISTS verification_requests_requester_access ON verification_requests;
  DROP POLICY IF EXISTS verification_requests_admin_access ON verification_requests;
  
  CREATE POLICY verification_requests_requester_access ON verification_requests
    FOR ALL TO authenticated USING (
      requested_by = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
    );

  CREATE POLICY verification_requests_admin_access ON verification_requests
    FOR ALL TO authenticated USING (
      EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
        AND u.role IN ('admin', 'super_admin', 'auditor')
      )
    );
END $$;

-- Security alerts RLS policies (admin and auditor only)
DO $$
BEGIN
  DROP POLICY IF EXISTS security_alerts_admin_access ON security_alerts;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'security_alerts') THEN
    CREATE POLICY security_alerts_admin_access ON security_alerts
      FOR ALL TO authenticated USING (
        EXISTS (
          SELECT 1 FROM users u 
          WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
          AND u.role IN ('admin', 'super_admin', 'auditor')
        )
      );
  END IF;
END $$;

-- CDC log RLS policies (admin and auditor only)
DO $$
BEGIN
  DROP POLICY IF EXISTS cdc_log_admin_access ON cdc_log;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cdc_log') THEN
    CREATE POLICY cdc_log_admin_access ON cdc_log
      FOR SELECT TO authenticated USING (
        EXISTS (
          SELECT 1 FROM users u 
          WHERE u.id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
          AND u.role IN ('admin', 'super_admin', 'auditor')
        )
      );
  END IF;
END $$;

-- User sessions self-access policy
DO $$
BEGIN
  DROP POLICY IF EXISTS user_sessions_self_access ON user_sessions;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_sessions') THEN
    CREATE POLICY user_sessions_self_access ON user_sessions
      FOR ALL TO authenticated USING (
        user_id = (current_setting('app.current_user_id', true)::jsonb->>'user_id')::uuid
      );
  END IF;
END $$;

-- =====================================================================================
-- PERFORMANCE OPTIMIZATION INDEXES
-- =====================================================================================

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_users_email_role ON users(email, role);
CREATE INDEX IF NOT EXISTS idx_users_institution_role ON users(institution_id, role) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_users_last_login ON users(last_login) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_users_failed_attempts ON users(failed_login_attempts) WHERE failed_login_attempts > 0;

CREATE INDEX IF NOT EXISTS idx_certificates_institution_status ON certificates(institution_id, status);
CREATE INDEX IF NOT EXISTS idx_certificates_student_name ON certificates(student_name);
CREATE INDEX IF NOT EXISTS idx_certificates_number_checksum ON certificates(certificate_number, checksum);
CREATE INDEX IF NOT EXISTS idx_certificates_created_verified ON certificates(created_at, last_verified_at);

CREATE INDEX IF NOT EXISTS idx_verification_requests_user_created ON verification_requests(requested_by, created_at);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status_risk ON verification_requests(status, risk_score);
CREATE INDEX IF NOT EXISTS idx_verification_requests_certificate_status ON verification_requests(certificate_id, status);

-- Partial indexes for active/pending records
CREATE INDEX IF NOT EXISTS idx_active_users ON users(id, email) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_pending_certificates ON certificates(id, institution_id) WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_pending_verifications ON verification_requests(id, requested_by) WHERE status IN ('PENDING', 'PROCESSING');
CREATE INDEX IF NOT EXISTS idx_open_alerts ON alerts(id, type, severity) WHERE resolved = false;

-- GIN indexes for JSONB columns
CREATE INDEX IF NOT EXISTS idx_verification_requests_result_gin ON verification_requests USING GIN (result);
CREATE INDEX IF NOT EXISTS idx_verification_requests_fraud_indicators_gin ON verification_requests USING GIN (fraud_indicators);
CREATE INDEX IF NOT EXISTS idx_security_alerts_details_gin ON security_alerts USING GIN (details);
CREATE INDEX IF NOT EXISTS idx_cdc_log_before_data_gin ON cdc_log USING GIN (before_data);
CREATE INDEX IF NOT EXISTS idx_cdc_log_after_data_gin ON cdc_log USING GIN (after_data);

-- Covering indexes for frequently accessed columns
CREATE INDEX IF NOT EXISTS idx_institutions_covering ON institutions(id, name, verification_status, is_active);
CREATE INDEX IF NOT EXISTS idx_certificates_covering ON certificates(id, certificate_number, student_name, status, institution_id);

-- Security monitoring indexes
CREATE INDEX IF NOT EXISTS idx_security_alerts_severity_status ON security_alerts(severity, resolved, detected_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON user_sessions(user_id, is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_action ON audit_logs(user_id, action, created_at);
CREATE INDEX IF NOT EXISTS idx_cdc_log_table_operation ON cdc_log(table_name, operation, performed_at);

-- Time-based indexes for cleanup and archival
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_cdc_log_performed_at ON cdc_log(performed_at);
CREATE INDEX IF NOT EXISTS idx_security_alerts_detected_at ON security_alerts(detected_at);

-- JSONB indexes
CREATE INDEX IF NOT EXISTS idx_vr_result_gin ON verification_requests USING GIN (result);

-- Composite indexes for common filters
CREATE INDEX IF NOT EXISTS idx_cert_institution_status_created ON certificates(institution_id, status, created_at);
CREATE INDEX IF NOT EXISTS idx_vr_by_requester_status_created ON verification_requests(requested_by, status, created_at);

-- Partial indexes for active/pending workflows and sessions
CREATE INDEX IF NOT EXISTS idx_vr_pending ON verification_requests(created_at) WHERE status IN ('PENDING','PROCESSING');
CREATE INDEX IF NOT EXISTS idx_sessions_active ON user_sessions(user_id, expires_at) WHERE revoked_at IS NULL;

-- Legacy indexes that might already exist
CREATE INDEX IF NOT EXISTS idx_cert_number ON certificates(certificate_number);
CREATE INDEX IF NOT EXISTS idx_institution_name ON institutions(name);
CREATE INDEX IF NOT EXISTS idx_alert_type ON alerts(type);
CREATE INDEX IF NOT EXISTS idx_user_phone ON users(phone_number);

-- Unique constraints for data integrity (safely add if not exists)
DO $$
BEGIN
  -- Check for the exclude constraint using a more comprehensive approach
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint c 
    JOIN pg_class t ON c.conrelid = t.oid 
    WHERE t.relname = 'certificate_hashes' 
    AND c.conname = 'unique_current_certificate_hash'
  ) THEN
    ALTER TABLE certificate_hashes ADD CONSTRAINT unique_current_certificate_hash 
      EXCLUDE (certificate_id WITH =) WHERE (is_current = true);
  END IF;
END $$;

-- Email case-insensitive unique index (safely create)
DROP INDEX IF EXISTS idx_users_email_lower;
CREATE UNIQUE INDEX idx_users_email_lower ON users (lower(email));

-- Additional constraints (safely add)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'role_permissions' AND constraint_name = 'valid_role_check') THEN
    ALTER TABLE role_permissions ADD CONSTRAINT valid_role_check 
      CHECK (role IN ('admin', 'institution', 'verifier', 'auditor', 'super_admin'));
  END IF;
END $$;

-- =====================================================================================
-- DEFAULT DATA SETUP
-- =====================================================================================

-- Insert default role permissions
INSERT INTO role_permissions (role, resource, action) VALUES
  ('super_admin', '*', 'CREATE'),
  ('super_admin', '*', 'READ'),
  ('super_admin', '*', 'UPDATE'),
  ('super_admin', '*', 'DELETE'),
  ('admin', 'certificates', 'CREATE'),
  ('admin', 'certificates', 'READ'),
  ('admin', 'certificates', 'UPDATE'),
  ('admin', 'institutions', 'READ'),
  ('admin', 'users', 'READ'),
  ('admin', 'verification_requests', 'READ'),
  ('institution', 'certificates', 'CREATE'),
  ('institution', 'certificates', 'READ'),
  ('institution', 'certificates', 'UPDATE'),
  ('verifier', 'certificates', 'READ'),
  ('verifier', 'verification_requests', 'CREATE'),
  ('verifier', 'verification_requests', 'READ'),
  ('auditor', 'audit_logs', 'READ'),
  ('auditor', 'security_alerts', 'READ'),
  ('auditor', 'cdc_log', 'READ')
ON CONFLICT (role, resource, action) DO NOTHING;

-- =====================================================================================
-- SCHEDULED MAINTENANCE FUNCTIONS
-- =====================================================================================

-- Function to archive old logs
CREATE OR REPLACE FUNCTION archive_old_logs(retention_days integer DEFAULT 365)
RETURNS integer AS $$
DECLARE
  archived_count integer := 0;
BEGIN
  -- Archive old audit logs
  WITH archived AS (
    DELETE FROM audit_logs 
    WHERE created_at < (now() - make_interval(days => retention_days))
    RETURNING *
  )
  SELECT count(*) INTO archived_count FROM archived;
  
  -- Archive old CDC logs
  DELETE FROM cdc_log 
  WHERE created_at < (now() - make_interval(days => retention_days));
  
  RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update security scores
CREATE OR REPLACE FUNCTION update_security_scores()
RETURNS void AS $$
BEGIN
  -- Update institution trust scores based on verification success rate
  UPDATE institutions 
  SET trust_score = LEAST(
    GREATEST(
      50 + (
        SELECT COALESCE(
          (COUNT(*) FILTER (WHERE vr.status = 'VERIFIED') * 50.0 / NULLIF(COUNT(*), 0))::integer - 25,
          0
        )
        FROM certificates c
        JOIN verification_requests vr ON c.id = vr.certificate_id
        WHERE c.institution_id = institutions.id
        AND vr.created_at > (now() - interval '30 days')
      ),
      0
    ),
    100
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================================

COMMENT ON TABLE security_alerts IS 'Advanced fraud detection and security alert system';
COMMENT ON TABLE cdc_log IS 'Change Data Capture log for comprehensive audit trail';
COMMENT ON TABLE role_permissions IS 'Granular role-based access control with context-aware permissions';
COMMENT ON TABLE approval_workflows IS 'Multi-step approval process for sensitive operations';
COMMENT ON TABLE integrity_checks IS 'Automated data integrity validation and checksum verification';
COMMENT ON TABLE user_sessions IS 'Comprehensive session management with security monitoring';

COMMENT ON FUNCTION generate_checksum IS 'Generate secure SHA256 checksum with optional salt';
COMMENT ON FUNCTION calculate_fraud_risk_score IS 'Calculate fraud risk score based on various indicators';
COMMENT ON FUNCTION validate_session IS 'Validate user session token and expiry';
COMMENT ON FUNCTION cleanup_expired_sessions IS 'Cleanup expired user sessions';

-- =====================================================================================
-- END OF SCHEMA
-- =====================================================================================
