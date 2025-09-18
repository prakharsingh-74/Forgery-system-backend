# Forgery System Backend

## Overview
Node.js/Express backend for Jharkhand certificate verification system. Integrates with Supabase for database and storage, supports JWT authentication, file uploads, AI/ML OCR extraction, and comprehensive audit logging.

## Setup
1. Copy `.env.example` to `.env` and fill in Supabase, JWT, and AI service details.
2. Run `npm install` in the backend directory.
3. Apply the schema in `config/database.sql` to your Supabase project.
4. Start development server: `npm run dev`

## API Endpoints
- `/auth/signup` - Register new user
- `/auth/login` - Login and get JWT
- `/auth/me` - Get current user profile
- `/institution` - Manage institutions
- `/certificates` - Manage certificates
- `/certificates/:id/subjects` - Manage certificate subjects
- `/verify` - Certificate verification workflow
- `/audit` - Audit logs (admin only)
- `/ai/extract` - AI OCR extraction
- `/hash/:certificate_id` - Certificate hash/metadata
- `/alerts` - Security alerts (admin only)

## Environment Variables
See `.env.example` for required variables.

## Database
Supabase SQL schema in `config/database.sql`. Includes RLS policies and triggers for audit logging and alerts.

## Development
- Uses nodemon for hot-reload
- All business logic in `services/`
- Controllers handle request/response
- Middleware for auth, audit, error handling

## License
MIT
