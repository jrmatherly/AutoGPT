# Supabase Security Hardening Guide

## Quick Start

This guide provides step-by-step security hardening for your self-hosted Supabase deployment before production use.

**Estimated Time:** 30-45 minutes

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Generate Production Secrets](#step-1-generate-production-secrets)
3. [Step 2: Validate Configuration](#step-2-validate-configuration)
4. [Step 3: Update Docker Compose](#step-3-update-docker-compose)
5. [Step 4: Upgrade Kong Gateway](#step-4-upgrade-kong-gateway)
6. [Step 5: Deploy Changes](#step-5-deploy-changes)
7. [Step 6: Post-Deployment Verification](#step-6-post-deployment-verification)
8. [Maintenance & Rotation](#maintenance--rotation)

---

## Prerequisites

- [ ] Self-hosted Supabase running (Docker Compose setup)
- [ ] Access to server terminal with root/sudo privileges
- [ ] Backup of current configuration
- [ ] Staging environment for testing (recommended)

---

## Step 1: Generate Production Secrets

### 1.1 Run Secret Generation Script

```bash
cd autogpt_platform/db/docker/scripts
./generate-secrets.sh
```

**What this does:**

- Generates cryptographically secure secrets for all services
- Creates `production.env` template with secure values
- Provides summary of generated secrets

### 1.2 Review Generated Secrets

```bash
cat ../production.env
```

**Verify:**

- ✅ JWT_SECRET (48+ chars base64)
- ✅ POSTGRES_PASSWORD (32 chars alphanumeric)
- ✅ SECRET_KEY_BASE (48+ chars base64)
- ✅ VAULT_ENC_KEY (exactly 32 chars hex)
- ✅ LOGFLARE tokens generated
- ✅ DASHBOARD_PASSWORD set

### 1.3 Generate JWT Tokens

**Required:** Generate ANON_KEY and SERVICE_ROLE_KEY using the Supabase JWT generator.

**Method 1: Using Supabase Online Generator**

1. Visit: https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys
2. Input your generated `JWT_SECRET` (from production.env)
3. Generate tokens for:
   - Role: `anon` → ANON_KEY
   - Role: `service_role` → SERVICE_ROLE_KEY
4. Copy tokens to `production.env`

**Method 2: Using jose-cli (if available)**

```bash
# Install jose-cli
npm install -g jose-cli

# Read JWT_SECRET from production.env
JWT_SECRET=$(grep "^JWT_SECRET=" ../production.env | cut -d'=' -f2)

# Generate ANON_KEY
jose sign --alg HS256 --secret "$JWT_SECRET" \
  --iss "supabase" \
  --role "anon" \
  --exp $(($(date +%s) + 315360000))  # 10 years

# Generate SERVICE_ROLE_KEY
jose sign --alg HS256 --secret "$JWT_SECRET" \
  --iss "supabase" \
  --role "service_role" \
  --exp $(($(date +%s) + 315360000))  # 10 years
```

### 1.4 Update Public URLs

Edit `production.env`:

```bash
# Update with your actual domains
SUPABASE_PUBLIC_URL=https://api.yourdomain.com
API_EXTERNAL_URL=https://api.yourdomain.com
SITE_URL=https://app.yourdomain.com
```

### 1.5 Configure SMTP (Recommended)

Update SMTP settings in `production.env` with your provider credentials:

**Example (SendGrid):**

```bash
SMTP_ADMIN_EMAIL=noreply@yourdomain.com
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=SG.xxxxxxxxxxxxxxxxxxxxx
SMTP_SENDER_NAME="Your App Name"
```

**Example (AWS SES):**

```bash
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=AKIAIOSFODNN7EXAMPLE
SMTP_PASS=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

---

## Step 2: Validate Configuration

### 2.1 Apply Production Configuration

```bash
cd autogpt_platform/db/docker
cp production.env .env
chmod 600 .env  # Secure permissions
```

### 2.2 Run Configuration Validator

```bash
./scripts/validate-config.sh
```

**Expected Output:**

```bash
=== Supabase Configuration Validator ===

=== Critical Security Configuration ===
✓ JWT_SECRET
✓ ANON_KEY
✓ SERVICE_ROLE_KEY
✓ POSTGRES_PASSWORD
✓ SECRET_KEY_BASE
✓ VAULT_ENC_KEY

=== Dashboard Security ===
✓ DASHBOARD_USERNAME
✓ DASHBOARD_PASSWORD

=== Summary ===
Total checks: 25
Passed: 25
Configuration validation PASSED
```

### 2.3 Fix Any Errors

If validation fails:

1. Review error messages
2. Update `.env` with correct values
3. Re-run validator until all checks pass

**Common Issues:**

| Error | Solution |
|-------|----------|
| `JWT_SECRET contains placeholder` | Run `./scripts/generate-secrets.sh` |
| `ANON_KEY is not a valid JWT` | Generate using Supabase JWT generator |
| `VAULT_ENC_KEY must be exactly 32 characters` | Use `openssl rand -hex 16` |
| `DASHBOARD_PASSWORD must contain at least one letter` | Add letters to password (no numbers-only) |

---

## Step 3: Update Docker Compose

### 3.1 Review Current Configuration

```bash
grep "image:" docker-compose.yml | grep -E "(kong|postgres|studio)"
```

**Check versions:**

- Kong version (should upgrade to 3.4)
- Postgres version (15.x recommended)
- Studio version (latest stable)

### 3.2 Update Service Versions (Optional)

**For Kong upgrade, see separate guide:**

```bash
cat KONG_UPGRADE.md
```

### 3.3 Verify Environment Loading

Ensure docker-compose.yml loads environment variables:

```yaml
# Should be present at top of file
x-supabase-env-files: &supabase-env-files
  env_file:
    - ../../.env.default
    - path: ../../.env
      required: false
    - path: ./.env
      required: false
```

---

## Step 4: Upgrade Kong Gateway

**Follow dedicated upgrade guide:**

```bash
cd autogpt_platform/db/docker
cat KONG_UPGRADE.md
```

**Summary:**

1. Update `docker-compose.yml`: `kong:2.8.1` → `kong:3.4`
2. Update `volumes/api/kong.yml`: `_format_version: '2.1'` → `'3.0'`
3. Pull new image: `docker compose pull kong`
4. Test configuration: Validate kong.yml
5. Deploy: `docker compose up -d`

**Benefits:**

- FIPS 140-2 compliance
- Enhanced security features
- Long-term support until August 2026

---

## Step 5: Deploy Changes

### 5.1 Backup Current State

```bash
# Backup database
docker exec supabase-db pg_dump -U postgres -d postgres > \
  backup_$(date +%Y%m%d_%H%M%S).sql

# Backup configuration
tar -czf config_backup_$(date +%Y%m%d_%H%M%S).tar.gz \
  docker-compose.yml \
  volumes/api/kong.yml \
  .env
```

### 5.2 Stop Services

```bash
docker compose down
```

### 5.3 Pull Latest Images

```bash
docker compose pull
```

### 5.4 Start Services with New Configuration

```bash
docker compose up -d
```

### 5.5 Monitor Startup

```bash
# Watch all service logs
docker compose logs -f

# Check health status
docker compose ps
```

**Wait for all services to show:** `Up (healthy)`

---

## Step 6: Post-Deployment Verification

### 6.1 Verify Service Health

```bash
docker compose ps
```

**Expected:** All services showing `Up (healthy)`

### 6.2 Test Authentication

```bash
# Test Studio access (should prompt for credentials)
curl -I http://localhost:8000/

# Test anonymous API access
curl -H "apikey: $(grep ANON_KEY .env | cut -d'=' -f2)" \
  http://localhost:8000/rest/v1/
```

### 6.3 Test Database Connectivity

```bash
# Via Supavisor (session mode)
docker exec -it supabase-pooler psql \
  "postgres://postgres.production-tenant:$(grep POSTGRES_PASSWORD .env | cut -d'=' -f2)@localhost:5432/postgres"

# Should connect successfully
# Try: SELECT version();
```

### 6.4 Verify Secrets Applied

**Check database roles have new password:**

```sql
-- Connect to database
docker exec -it supabase-db psql -U postgres

-- Verify roles (should not show passwords)
\du

-- Test connection with new password
\q
```

**Check JWT secret applied:**

```bash
docker exec supabase-auth env | grep JWT_SECRET
# Should show your new JWT_SECRET
```

### 6.5 Application Testing

- [ ] **Studio Dashboard**
  - Login with DASHBOARD_USERNAME / DASHBOARD_PASSWORD
  - Navigate tables, auth, storage sections
  - Verify no errors in browser console

- [ ] **Authentication Flow**
  - Sign up new test user
  - Verify email received (if SMTP configured)
  - Sign in with test user
  - Test password reset

- [ ] **Database API**
  - Create table via Studio
  - Insert test data via API
  - Query via REST API
  - Verify RLS policies work

- [ ] **Storage API**
  - Create bucket
  - Upload test file
  - Download file
  - Delete file

---

## Maintenance & Rotation

### Secret Rotation Schedule

| Secret | Rotation Frequency | Method |
|--------|-------------------|--------|
| JWT_SECRET | Every 12 months | `./scripts/rotate-secrets.sh --jwt` |
| POSTGRES_PASSWORD | Every 6-12 months | `./scripts/rotate-secrets.sh --postgres` |
| Encryption Keys | Every 12 months | `./scripts/rotate-secrets.sh --encryption` |
| DASHBOARD_PASSWORD | Every 3-6 months | Manual update in .env |
| API Keys (if leaked) | Immediately | Follow rotation guide |

### Rotation Procedure

```bash
cd autogpt_platform/db/docker/scripts

# Interactive menu
./rotate-secrets.sh

# Or specific secret type
./rotate-secrets.sh --jwt
./rotate-secrets.sh --postgres
./rotate-secrets.sh --encryption
```

**Always:**

1. Backup before rotation
2. Test in staging first
3. Plan for brief downtime (2-5 minutes)
4. Verify services after rotation
5. Update documentation

### Security Monitoring

**Weekly:**

- [ ] Review Docker logs for errors or warnings
- [ ] Check disk usage (logs, database, storage)
- [ ] Verify all services healthy

**Monthly:**

- [ ] Review access logs for suspicious activity
- [ ] Update service versions if patches available
- [ ] Test backup restore procedure
- [ ] Review and update firewall rules

**Quarterly:**

- [ ] Full security audit
- [ ] Review RLS policies
- [ ] Update secrets (if policy requires)
- [ ] Review and update this guide

---

## Security Checklist

### Critical (Before Production)

- [ ] All placeholder secrets replaced
- [ ] ANON_KEY and SERVICE_ROLE_KEY generated with production JWT_SECRET
- [ ] POSTGRES_PASSWORD rotated from default
- [ ] DASHBOARD_PASSWORD set (with letters, not numbers-only)
- [ ] VAULT_ENC_KEY exactly 32 characters
- [ ] Configuration validated (`./scripts/validate-config.sh` passes)
- [ ] Public URLs updated to production domains
- [ ] SMTP configured for production email
- [ ] Kong upgraded to 3.4 (or latest stable)
- [ ] All services showing healthy status
- [ ] Database backup created
- [ ] Rollback procedure tested

### Recommended (Production Hardening)

- [ ] SSL/TLS configured (reverse proxy with Let's Encrypt)
- [ ] Firewall rules configured (only 443/tcp exposed)
- [ ] Database port NOT exposed to internet
- [ ] RLS policies reviewed and tested
- [ ] Rate limiting enabled on Kong
- [ ] Monitoring and alerting configured
- [ ] S3 storage configured (not file-based)
- [ ] Automated backups scheduled
- [ ] Disaster recovery plan documented
- [ ] Security incident response plan created

### Optional (Advanced)

- [ ] Multi-factor authentication for team members
- [ ] Network restrictions configured
- [ ] Read replicas for high availability
- [ ] Point-in-Time Recovery (PITR) enabled
- [ ] Custom domain with SSL certificate
- [ ] CDN for static assets
- [ ] DDoS protection (Cloudflare, AWS Shield)
- [ ] Security scanning tools integrated
- [ ] Compliance documentation (SOC2, HIPAA, etc.)

---

## Troubleshooting

### Services not starting

```bash
# Check logs
docker compose logs <service-name>

# Common issues:
# - Invalid JWT_SECRET length
# - VAULT_ENC_KEY not exactly 32 chars
# - Port conflicts
# - Insufficient disk space
```

### Authentication failures

```bash
# Verify ANON_KEY matches JWT_SECRET
docker exec supabase-auth env | grep JWT_SECRET

# Test JWT decoding
echo "YOUR_ANON_KEY" | cut -d'.' -f2 | base64 -d | jq
# Should show role: "anon"
```

### Database connection errors

```bash
# Test database password
docker exec -it supabase-db psql -U postgres
# If fails, password may not be updated

# Manually update password
docker exec -it supabase-db psql -U postgres -c \
  "ALTER USER postgres WITH PASSWORD 'your-new-password';"
```

### Kong configuration errors

```bash
# Validate kong.yml
docker run --rm -v $(pwd)/volumes/api/kong.yml:/kong.yml kong:3.4 \
  kong config parse /kong.yml

# Should output: "parse successful"
```

---

## Additional Resources

- **Supabase Self-Hosting Guide**: https://supabase.com/docs/guides/self-hosting/docker
- **Production Checklist**: https://supabase.com/docs/guides/deployment/going-into-prod
- **Security Best Practices**: https://supabase.com/docs/guides/security/product-security
- **Kong Upgrade Guide**: `KONG_UPGRADE.md` (in this directory)
- **Row Level Security**: https://supabase.com/docs/guides/database/postgres/row-level-security

---

**Security Hardening Prepared By:** Supabase Configuration Analysis
**Date:** January 2026
**Version:** 1.0
**Status:** Production Ready
