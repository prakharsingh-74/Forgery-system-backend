# Jharkhand Certificate Verification System Backend

A comprehensive Node.js + Express.js backend for the government certificate verification system. Powered by Supabase for database and storage, this solution focuses on robust security, fraud prevention, and seamless certificate validation.

---

## 🚀 Overview

This backend is designed for the **Jharkhand Certificate Verification System** to prevent backdoor frauds and provide real-time verification of educational certificates. It includes strong security mechanisms, real-time monitoring, and compliance with government standards.

---

## 🛠️ Technology Stack

- **Backend Framework:** Node.js, Express.js (JavaScript)
- **Database:** Supabase PostgreSQL
- **Storage:** Supabase Storage (certificate files)
- **Authentication:** Supabase Auth (JWT)
- **Email Service:** Nodemailer (SMTP)
- **File Uploads:** Multer
- **Image Processing:** Sharp
- **OCR:** Tesseract.js / Google Vision API
- **Validation:** Joi / Yup
- **Logging:** Winston

---

## 📚 Core Features

### 1. Database Schema

The database schema is defined via Supabase migrations, with the following core tables:

| Table Name            | Description                          |
|-----------------------|--------------------------------------|
| users                 | User management with RBAC            |
| institutions          | Educational institution registry     |
| certificates          | Certificate records & digital hashes |
| verification_requests | Certificate verification tracking    |
| security_alerts       | Fraud detection alerts               |
| audit_logs            | Audit trail for all ops              |
| cdc_log               | Change Data Capture logs             |
| role_permissions      | RBAC permissions matrix              |
| approval_workflows    | Sensitive operation approvals        |
| integrity_checks      | Data integrity validation            |
| user_sessions         | Session management                   |

---

### 2. API Endpoints

#### **Authentication & Authorization**
- `POST /api/auth/register` — Register user with role
- `POST /api/auth/login` — JWT login
- `POST /api/auth/logout` — Logout, invalidate session
- `POST /api/auth/refresh` — Refresh token
- `GET /api/auth/profile` — Get user profile
- `PUT /api/auth/profile` — Update profile

#### **Certificate Management**
- `POST /api/certificates/upload` — Upload w/ OCR
- `POST /api/certificates/verify` — Verify certificate
- `GET /api/certificates/:id` — Get details
- `PUT /api/certificates/:id` — Update (approval workflow)
- `DELETE /api/certificates/:id` — Delete (admin)
- `POST /api/certificates/bulk-upload` — Bulk import
- `GET /api/certificates/search` — Advanced search
- `POST /api/certificates/validate-integrity` — Integrity check

#### **Institution Management**
- `POST /api/institutions` — Register institution
- `GET /api/institutions` — List/filter institutions
- `GET /api/institutions/:id` — Institution details
- `PUT /api/institutions/:id` — Update institution
- `DELETE /api/institutions/:id` — Delete institution
- `POST /api/institutions/:id/verify` — Verify institution
- `GET /api/institutions/:id/certificates` — Get institution certificates
- `POST /api/institutions/:id/bulk-import` — Bulk import certificates

#### **User Management (Admin)**
- `GET /api/users` — List users (role filter)
- `GET /api/users/:id` — User details
- `PUT /api/users/:id` — Update user
- `DELETE /api/users/:id` — Deactivate user
- `POST /api/users/:id/verify` — Verify user
- `PUT /api/users/:id/role` — Assign role
- `GET /api/users/:id/activity` — Activity logs
- `POST /api/users/:id/reset-password` — Admin password reset

#### **Security & Monitoring**
- `GET /api/security/alerts` — List alerts
- `POST /api/security/alerts/:id/resolve` — Resolve alert
- `GET /api/security/audit-logs` — View audit trail
- `POST /api/security/integrity-check` — Manual integrity validation
- `GET /api/security/suspicious-activity` — Suspicious activity reports
- `POST /api/security/blacklist` — Blacklist IP/User

#### **Analytics & Reporting**
- `GET /api/analytics/dashboard` — Dashboard stats
- `GET /api/analytics/verification-trends` — Verification trends
- `GET /api/analytics/fraud-patterns` — Fraud detection patterns
- `GET /api/analytics/institution-performance` — Institution metrics
- `POST /api/analytics/generate-report` — Generate report
- `GET /api/analytics/reports/:id` — Download report

#### **Approval Workflows**
- `GET /api/approvals/pending` — Pending approvals
- `POST /api/approvals/:id/approve` — Grant approval
- `POST /api/approvals/:id/reject` — Reject approval
- `GET /api/approvals/history` — Approval history
- `POST /api/approvals/request` — New approval request

---

### 3. Security Features

#### **Fraud Prevention**
- **CDC Triggers:** Log all changes with user context
- **Triggers:** Detect fraud, enforce RBAC, validate integrity
- **Checksums:** SHA-256 for critical data, validate on access
- **RBAC:** Context/row/content-based, dynamic permissions

#### **Email Alerts**
Comprehensive notifications for:
- Security breaches
- Fraud detection
- Approval workflow events
- System maintenance
- User account actions

---

### 4. File Upload & Processing

- **Supported Formats:** PDF, JPG, PNG, TIFF
- **Flow:** Multer → Validation → Supabase Storage → OCR → Data Validation → Database w/ hash → Integrity check

---

### 5. Advanced Features

- **Real-time Monitoring:** WebSocket alerts, live dashboard
- **Batch Processing:** Bulk imports, scheduled checks, automated reports, archival
- **API Security:** Rate limiting, sanitization, SQLi/XSS/CSRF protection, secure headers

---

### 6. Error Handling & Logging

- **Logging:** Requests, security events, errors, performance, user activity
- **Error Handling:** Standard codes, user-friendly messages, graceful recovery

| Status Code | Meaning                                      |
|-------------|----------------------------------------------|
| 400         | Validation error (required fields)           |
| 401         | Invalid credentials or expired token         |
| 403         | Insufficient permissions                     |
| 409         | Email already exists (registration conflict) |

---

### 7. Testing

- **Unit Tests:** API, DB operations, security, utilities
- **Integration Tests:** End-to-end, triggers, emails, uploads
- **Security Tests:** Auth, SQLi, XSS, rate limiting

---

### 8. Environment Configuration

Set these in `.env`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=24h
REFRESH_TOKEN_SECRET=your_refresh_secret
SMTP_HOST=your_smtp_host
SMTP_PORT=587
SMTP_USER=your_email
SMTP_PASS=your_password
FROM_EMAIL=govt. mail id
MAX_FILE_SIZE=10485760
UPLOAD_PATH=uploads/
ALLOWED_FILE_TYPES=pdf,jpg,jpeg,png,tiff
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100
BCRYPT_ROUNDS=12
SESSION_SECRET=your_session_secret
OCR_API_KEY=your_ocr_api_key
OCR_ENDPOINT=your_ocr_endpoint
LOG_LEVEL=info
ENABLE_REQUEST_LOGGING=true
```

---

### 9. System Flow (Diagram)

#### Authentication & Authorization Sequence

![Authentication Sequence Diagram](https://github.com/user-attachments/assets/020ee619-d827-440c-81c0-9e32b020ad02)

---

### 10. Project Structure

```
backend/
├── src/
│   ├── controllers/        # Route controllers
│   ├── middleware/         # Auth, RBAC, validation, uploads
│   ├── models/             # Data models
│   ├── routes/             # API endpoints
│   ├── services/           # External services (email, OCR, fraud)
│   ├── utils/              # Helpers, validators, constants
│   ├── config/             # DB, email, security configs
│   └── app.js              # Entry point
├── tests/                  # Unit & integration tests
├── uploads/                # Uploaded files
├── logs/                   # Log files
├── package.json
└── README.md
```

---

### 11. Deployment & Optimization

#### **Production Checklist**
- Docker containerization
- Env-specific configs
- SSL/TLS setup
- Load balancing
- Connection pooling (DB)
- Redis caching
- Monitoring & alerts

#### **Performance**
- Query optimization
- Upload optimization
- CDN for static files
- API compression

---

### 12. Compliance & Security

| Compliance         | Implementation Highlights                  |
|--------------------|--------------------------------------------|
| **GDPR**           | Data encryption, secure deletion           |
| **Govt. IT norms** | Digital signature, audit trails, data loc. |

---

## 🎯 Deliverables

1. **Backend API**—All endpoints implemented
2. **Database Schema**—With triggers & policies
3. **Email Alerts**—Comprehensive templates
4. **File Upload System**—With OCR
5. **Security Monitoring**—Real-time fraud detection
6. **API Docs**—Postman collection
7. **Testing**—Unit & integration coverage
8. **Deployment Scripts**—Docker setup
9. **Admin Dashboard APIs**—Monitoring
10. **Comprehensive Logging**—Error handling

---

> **This backend is production-ready, secure, and tailored for government-level certificate verification, actively preventing backdoor fraud and ensuring reliable, compliant operations.**
