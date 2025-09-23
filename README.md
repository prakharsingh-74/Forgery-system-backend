# Complete Backend Development Prompt for Jharkhand Certificate Verification System

## Project Overview
Create a comprehensive Node.js + Express.js backend for the Jharkhand Certificate Verification System with Supabase as the database and storage solution. The system must prevent backdoor frauds through advanced security mechanisms including Change Data Capture (CDC), Database Triggers, Checksum validation, and Role-Based Access Control (RBAC).

## Technology Stack
- *Backend Framework*: Node.js with Express.js and javascript
- *Database*: Supabase (PostgreSQL)
- *Storage*: Supabase Storage for certificate files
- *Authentication*: Supabase Auth with JWT
- *Email Service*: Nodemailer with SMTP
- *File Processing*: Multer for uploads, Sharp for image processing
- *OCR*: Tesseract.js or Google Vision API
- *Validation*: Joi or Yup for request validation
- *Logging*: Winston for comprehensive logging

## Core Requirements

### 1. Database Schema Implementation
The database schema is already defined in the Supabase migrations. Implement the following tables with their relationships:

*Core Tables:*
- users - User management with RBAC
- institutions - Educational institutions registry
- certificates - Certificate records with digital hashes
- verification_requests - Certificate verification tracking
- security_alerts - Fraud detection alerts
- audit_logs - Comprehensive audit trail
- cdc_log - Change Data Capture logs
- role_permissions - RBAC permissions matrix
- approval_workflows - Sensitive operation approvals
- integrity_checks - Data integrity validation
- user_sessions - Session management

### 2. API Endpoints Structure

#### Authentication & Authorization (completed)

POST /api/auth/register - User registration with role assignment
POST /api/auth/login - User authentication with JWT
POST /api/auth/logout - Session invalidation
POST /api/auth/refresh - Token refresh
GET /api/auth/profile - User profile retrieval
PUT /api/auth/profile - Profile updates


#### Certificate Management

POST /api/certificates/upload - Certificate upload with OCR processing
POST /api/certificates/verify - Certificate verification against database
GET /api/certificates/:id - Certificate details retrieval
PUT /api/certificates/:id - Certificate updates (with approval workflow)
DELETE /api/certificates/:id - Certificate deletion (admin only)
POST /api/certificates/bulk-upload - Bulk certificate import
GET /api/certificates/search - Advanced certificate search
POST /api/certificates/validate-integrity - Integrity validation


#### Institution Management 

POST /api/institutions - Institution registration
GET /api/institutions - Institution listing with filters
GET /api/institutions/:id - Institution details
PUT /api/institutions/:id - Institution updates
DELETE /api/institutions/:id - Institution deletion
POST /api/institutions/:id/verify - Institution verification
GET /api/institutions/:id/certificates - Institution's certificates
POST /api/institutions/:id/bulk-import - Bulk certificate import


#### User Management (Admin)

GET /api/users - User listing with role filters
GET /api/users/:id - User details
PUT /api/users/:id - User updates
DELETE /api/users/:id - User deactivation
POST /api/users/:id/verify - User verification
PUT /api/users/:id/role - Role assignment
GET /api/users/:id/activity - User activity logs
POST /api/users/:id/reset-password - Admin password reset


#### Security & Monitoring

GET /api/security/alerts - Security alerts listing
POST /api/security/alerts/:id/resolve - Alert resolution
GET /api/security/audit-logs - Audit trail access
POST /api/security/integrity-check - Manual integrity validation
GET /api/security/suspicious-activity - Suspicious activity reports
POST /api/security/blacklist - IP/User blacklisting


#### Analytics & Reporting

GET /api/analytics/dashboard - Dashboard statistics
GET /api/analytics/verification-trends - Verification trends
GET /api/analytics/fraud-patterns - Fraud detection patterns
GET /api/analytics/institution-performance - Institution metrics
POST /api/analytics/generate-report - Custom report generation
GET /api/analytics/reports/:id - Report download


#### Approval Workflows

GET /api/approvals/pending - Pending approval requests
POST /api/approvals/:id/approve - Approval granting
POST /api/approvals/:id/reject - Approval rejection
GET /api/approvals/history - Approval history
POST /api/approvals/request - New approval request


#### Common Error Responses

400 - Validation error (check required fields)
401 - Invalid credentials or expired token
403 - Insufficient permissions for role
409 - Email already exists (during registration)


### 3. Security Implementation Requirements

#### Fraud Prevention Mechanisms
1. *Change Data Capture (CDC)*
   - Implement CDC triggers in Supabase
   - Log all data changes with user context
   - Real-time change streaming for monitoring

2. *Database Triggers*
   - Fraud detection triggers for suspicious modifications
   - Integrity validation triggers
   - Automatic alert generation triggers
   - RBAC enforcement triggers

3. *Checksum/Hash Validation*
   - Generate SHA-256 checksums for all critical data
   - Validate checksums on data access
   - Scheduled integrity checks
   - Immediate alerts on checksum mismatches

4. *Role-Based Access Control (RBAC)*
   - Context-based permissions (time, location, approval)
   - Content-based access control (data sensitivity)
   - Row-level security policies
   - Dynamic permission validation

#### Email Alert System
Implement comprehensive email alerting for:
- *Critical Security Events*: Unauthorized access attempts, data manipulation
- *Fraud Detection*: Suspicious certificate modifications, bulk changes
- *System Alerts*: Integrity check failures, system errors
- *Workflow Notifications*: Approval requests, status updates
- *User Activities*: Registration confirmations, password resets

*Email Templates Required:*
- Security breach notifications
- Fraud detection alerts
- Approval workflow notifications
- System maintenance alerts
- User account notifications

### 4. File Upload & Processing

#### Certificate Upload Flow
1. *File Upload*: Multer middleware for file handling
2. *File Validation*: Format, size, and content validation
3. *Storage*: Supabase Storage with organized folder structure
4. *OCR Processing*: Extract text and metadata from certificates
5. *Data Validation*: Validate extracted data against business rules
6. *Database Storage*: Store certificate data with digital hash
7. *Integrity Check*: Generate and store checksums

#### Supported Formats
- PDF documents
- Image formats (JPG, PNG, TIFF)
- Scanned documents with OCR processing
- Digital certificates with embedded metadata

### 5. Advanced Features Implementation

#### Real-time Monitoring
- WebSocket connections for real-time alerts
- Live dashboard updates
- Instant fraud detection notifications
- System health monitoring

#### Batch Processing
- Bulk certificate imports with validation
- Scheduled integrity checks
- Automated report generation
- Data cleanup and archival

#### API Security
- Rate limiting per user role
- Request validation and sanitization
- SQL injection prevention
- XSS protection
- CSRF protection
- Secure headers implementation

### 6. Error Handling & Logging

#### Comprehensive Logging
- Request/response logging
- Security event logging
- Error tracking with stack traces
- Performance monitoring
- User activity logging

#### Error Handling
- Standardized error responses
- Graceful error recovery
- User-friendly error messages
- Security-conscious error disclosure

### 7. Testing Requirements

#### Unit Tests
- API endpoint testing
- Database operation testing
- Security mechanism testing
- Utility function testing

#### Integration Tests
- End-to-end workflow testing
- Database trigger testing
- Email notification testing
- File upload/processing testing

#### Security Tests
- Authentication/authorization testing
- SQL injection testing
- XSS vulnerability testing
- Rate limiting testing

### 8. Environment Configuration

#### Environment Variables

# Database
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Authentication
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=24h
REFRESH_TOKEN_SECRET=your_refresh_secret

# Email Configuration
SMTP_HOST=your_smtp_host
SMTP_PORT=587
SMTP_USER=your_email
SMTP_PASS=your_password
FROM_EMAIL=noreply@jharkhand-cert-verify.gov.in

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_PATH=uploads/
ALLOWED_FILE_TYPES=pdf,jpg,jpeg,png,tiff

# Security
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100
BCRYPT_ROUNDS=12
SESSION_SECRET=your_session_secret

# OCR Service
OCR_API_KEY=your_ocr_api_key
OCR_ENDPOINT=your_ocr_endpoint

# Monitoring
LOG_LEVEL=info
ENABLE_REQUEST_LOGGING=true

### 9. Mermaid Diagram

sequenceDiagram
    participant Client
    participant API
    participant Auth
    participant JWT
    participant Database

    Note over Client,Database: Authentication & Authorization Flow

    Client->>API: POST /api/auth/register
    API->>Auth: Validate registration data
    Auth->>Database: Create user account
    Database-->>Auth: User created
    Auth-->>API: User data (no tokens)
    API-->>Client: 201 - User registered

    Client->>API: POST /api/auth/login
    API->>Auth: Validate credentials
    Auth->>Database: Check user credentials
    Database-->>Auth: User found & verified
    Auth->>JWT: Generate access & refresh tokens
    JWT-->>Auth: Tokens created
    Auth-->>API: Tokens + user data
    API-->>Client: 200 - Login successful

    Client->>API: GET /api/auth/profile
    Note over Client,API: Authorization: Bearer {accessToken}
    API->>Auth: Verify access token
    Auth->>JWT: Validate token
    JWT-->>Auth: Token valid
    Auth->>Database: Get user profile
    Database-->>Auth: User profile data
    Auth-->>API: Profile data
    API-->>Client: 200 - Profile data

    Client->>API: PUT /api/auth/profile
    Note over Client,API: Authorization: Bearer {accessToken}
    API->>Auth: Verify token & update profile
    Auth->>Database: Update user data
    Database-->>Auth: Updated profile
    Auth-->>API: Updated profile data
    API-->>Client: 200 - Profile updated

    Client->>API: POST /api/auth/refresh
    API->>Auth: Validate refresh token
    Auth->>JWT: Verify refresh token
    JWT-->>Auth: Token valid
    Auth->>JWT: Generate new access token
    JWT-->>Auth: New access token
    Auth-->>API: New access token + user data
    API-->>Client: 200 - Token refreshed

    Client->>API: POST /api/auth/logout
    Note over Client,API: Authorization: Bearer {accessToken}
    API->>Auth: Process logout
    Auth-->>API: Logout confirmation
    API-->>Client: 200 - Logged out

### 10. Project Structure

backend/
├── src/
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── certificateController.js
│   │   ├── institutionController.js
│   │   ├── userController.js
│   │   ├── securityController.js
│   │   └── analyticsController.js
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── rbac.js
│   │   ├── validation.js
│   │   ├── rateLimit.js
│   │   └── upload.js
│   ├── models/
│   │   ├── User.js
│   │   ├── Certificate.js
│   │   ├── Institution.js
│   │   └── SecurityAlert.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── certificates.js
│   │   ├── institutions.js
│   │   ├── users.js
│   │   ├── security.js
│   │   └── analytics.js
│   ├── services/
│   │   ├── emailService.js
│   │   ├── ocrService.js
│   │   ├── fraudDetectionService.js
│   │   ├── integrityService.js
│   │   └── supabaseService.js
│   ├── utils/
│   │   ├── logger.js
│   │   ├── validators.js
│   │   ├── helpers.js
│   │   └── constants.js
│   ├── config/
│   │   ├── database.js
│   │   ├── email.js
│   │   └── security.js
│   └── app.js
├── tests/
├── uploads/
├── logs/
├── package.json
└── README.md


### 11. Deployment Considerations

#### Production Requirements
- Docker containerization
- Environment-specific configurations
- SSL/TLS certificate setup
- Load balancing configuration
- Database connection pooling
- Caching strategy (Redis)
- Monitoring and alerting setup

#### Performance Optimization
- Database query optimization
- File upload optimization
- Caching implementation
- CDN integration for static files
- API response compression

### 12. Compliance & Security Standards

#### Data Protection
- GDPR compliance for data handling
- Data encryption at rest and in transit
- Secure data deletion procedures
- Privacy policy implementation

#### Government Standards
- Indian government IT security guidelines
- Digital signature compliance
- Audit trail requirements
- Data localization compliance

## Deliverables Expected

1. *Complete Backend API* with all endpoints implemented
2. *Database Schema* with triggers and security policies
3. *Email Alert System* with comprehensive templates
4. *File Upload System* with OCR processing
5. *Security Monitoring* with real-time fraud detection
6. *API Documentation* with Postman collection
7. *Unit and Integration Tests* with good coverage
8. *Deployment Scripts* and Docker configuration
9. *Admin Dashboard APIs* for system monitoring
10. *Comprehensive Logging* and error handling

## Success Criteria

- All API endpoints functional with proper error handling
- Fraud detection system actively monitoring and alerting
- Email notifications working for all security events
- File upload and OCR processing working seamlessly
- Database triggers preventing unauthorized modifications
- RBAC system enforcing proper access controls
- Comprehensive audit trail for all operations
- Performance optimized for production load
- Security tested and vulnerability-free
- Complete documentation and testing coverage

This backend system should be production-ready, secure, and capable of handling the complex requirements of a government certificate verification system while preventing backdoor frauds through multiple layers of security.