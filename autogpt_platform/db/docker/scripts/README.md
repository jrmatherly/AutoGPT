# Supabase Security Scripts

This directory contains security automation scripts for managing your self-hosted Supabase deployment.

## Scripts Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `generate-secrets.sh` | Generate production secrets | Initial setup, new environment |
| `rotate-secrets.sh` | Rotate secrets (JWT, database, encryption keys) | Regular maintenance (6-12 months) |
| `validate-config.sh` | Validate security configuration | Before deployment, after changes |

---

## Quick Start

### Initial Setup (New Deployment)

```bash
# 1. Generate production secrets
./generate-secrets.sh

# 2. Update JWT tokens in production.env
#    (Follow instructions from step 1)

# 3. Validate configuration
./validate-config.sh

# 4. Apply configuration
cp ../production.env ../.env
chmod 600 ../.env

# 5. Deploy
cd .. && docker compose up -d
```

---

## Script Reference

### generate-secrets.sh

**Purpose:** Generate cryptographically secure secrets for all Supabase services.

**Usage:**

```bash
./generate-secrets.sh
```

**What it generates:**

- `JWT_SECRET` (48 bytes base64) - JWT signing secret
- `POSTGRES_PASSWORD` (32 chars alphanumeric) - Database password
- `SECRET_KEY_BASE` (48 bytes base64) - Realtime/Supavisor encryption
- `VAULT_ENC_KEY` (32 chars hex) - Supavisor vault encryption
- `LOGFLARE_API_KEY` (24 bytes base64) - Analytics API key
- `LOGFLARE_PUBLIC_ACCESS_TOKEN` (24 bytes base64) - Public analytics token
- `LOGFLARE_PRIVATE_ACCESS_TOKEN` (24 bytes base64) - Private analytics token
- `DASHBOARD_PASSWORD` (20 chars alphanumeric) - Studio dashboard password

**Output files:**

- `../production.env` - Template with generated secrets
- `../secrets-summary.txt` - Summary for record-keeping (delete after use)

**Next steps:**

1. Generate ANON_KEY and SERVICE_ROLE_KEY JWTs
2. Update public URLs in production.env
3. Configure SMTP credentials
4. Copy production.env to .env

**Example:**

```bash
$ ./generate-secrets.sh
=== Supabase Production Secrets Generator ===

Generating secrets (this may take a few seconds)...

✓ Generated JWT_SECRET (48 bytes base64)
✓ Generated POSTGRES_PASSWORD (32 chars alphanumeric)
✓ Generated SECRET_KEY_BASE (48 bytes base64)
✓ Generated VAULT_ENC_KEY (32 chars hex)
✓ Generated LOGFLARE tokens
✓ Generated DASHBOARD_PASSWORD

Generating JWT tokens (ANON_KEY and SERVICE_ROLE_KEY)...

⚠ JWT Token Generation Required

Use the Supabase JWT generator to create ANON_KEY and SERVICE_ROLE_KEY:
https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys

✓ Created production.env template

=== Summary ===
[...]
```

---

### rotate-secrets.sh

**Purpose:** Rotate secrets with zero-downtime strategy.

**Usage:**

```bash
# Interactive menu (default)
./rotate-secrets.sh

# Specific secret type
./rotate-secrets.sh --jwt          # Rotate JWT secret
./rotate-secrets.sh --postgres     # Rotate database password
./rotate-secrets.sh --encryption   # Rotate encryption keys
```

**Rotation types:**

#### JWT Secret Rotation

- Generates new JWT_SECRET
- Requires new ANON_KEY and SERVICE_ROLE_KEY generation
- Updates .env file
- Creates backup before changes

**When to rotate:**

- Every 12 months (recommended)
- If JWT_SECRET is compromised
- For compliance requirements

**Downtime:** ~5 minutes (manual JWT token generation)

#### Postgres Password Rotation

- Uses built-in `../utils/db-passwd.sh` utility
- Generates new password
- Updates all database role passwords
- Updates .env file

**When to rotate:**

- Every 6-12 months (recommended)
- If password is compromised
- For compliance requirements

**Downtime:** ~2 minutes (database restart)

#### Encryption Keys Rotation

- Rotates SECRET_KEY_BASE (Realtime/Supavisor)
- Rotates VAULT_ENC_KEY (Supavisor vault)
- Updates .env file
- Creates backup before changes

**When to rotate:**

- Every 12 months (recommended)
- If keys are compromised
- For compliance requirements

**Downtime:** ~30 seconds (service restart)

**Example:**

```bash
$ ./rotate-secrets.sh
=== Supabase Secret Rotation Tool ===

Select secret rotation option:

  1) Rotate JWT Secret (ANON_KEY, SERVICE_ROLE_KEY)
  2) Rotate Postgres Password
  3) Rotate Encryption Keys (SECRET_KEY_BASE, VAULT_ENC_KEY)
  4) Rotate All Secrets (requires manual steps)
  5) Exit

Enter choice [1-5]: 3

=== Rotating Encryption Keys ===

This will rotate:
  - SECRET_KEY_BASE (Realtime/Supavisor)
  - VAULT_ENC_KEY (Supavisor)

Continue? (y/N): y

✓ Backed up .env to: ../.env.rotation-backup.20260129_143022
✓ Updated SECRET_KEY_BASE
✓ Updated VAULT_ENC_KEY

Next steps:
1. Restart affected services:
   docker compose restart realtime supavisor

2. Verify services are healthy:
   docker compose ps
```

---

### validate-config.sh

**Purpose:** Validate security configuration before deployment.

**Usage:**

```bash
./validate-config.sh
```

**What it checks:**

**Critical Security:**

- ✅ JWT_SECRET (required, no placeholder, min 48 chars)
- ✅ ANON_KEY (required, valid JWT, no placeholder)
- ✅ SERVICE_ROLE_KEY (required, valid JWT, no placeholder)
- ✅ POSTGRES_PASSWORD (required, no placeholder, min 20 chars)
- ✅ SECRET_KEY_BASE (required, no placeholder, min 64 chars)
- ✅ VAULT_ENC_KEY (required, no placeholder, exactly 32 chars)

**Dashboard Security:**

- ✅ DASHBOARD_USERNAME (required)
- ✅ DASHBOARD_PASSWORD (required, has letters, min 12 chars)

**Configuration:**

- ✅ LOGFLARE_API_KEY (no placeholder, min 20 chars)
- ✅ Public URLs (valid HTTP/HTTPS format)

**Docker Compose:**

- ✅ Kong version check (warns if outdated)
- ✅ Kong config format version (matches Kong image version)

**Exit codes:**

- `0` - All checks passed
- `1` - Errors found (deployment not recommended)

**Example (passing):**

```bash
$ ./validate-config.sh
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

=== Logflare Configuration ===
✓ LOGFLARE_API_KEY

=== Public URLs ===
✓ SUPABASE_PUBLIC_URL
✓ API_EXTERNAL_URL
✓ SITE_URL

=== Docker Compose Validation ===
✓ Kong version: kong:3.4 (recommended)
✓ Kong configuration format: 3.0

=== Optional Configuration ===
✓ SMTP configured: smtp.sendgrid.net
✓ Storage backend: s3

=== Summary ===
Total checks: 25
Passed: 25

Configuration validation PASSED
Configuration is ready for deployment
```

**Example (with errors):**

```bash
$ ./validate-config.sh
=== Supabase Configuration Validator ===

=== Critical Security Configuration ===
✗ ERROR: JWT_SECRET contains placeholder value
  Current: your-super-secret-jwt-token...
  Generate with: openssl rand -base64 48

✗ ERROR: ANON_KEY is not a valid JWT
  JWTs should start with 'eyJ'
  Generate using Supabase JWT generator

✗ ERROR: VAULT_ENC_KEY must be exactly 32 characters
  Current length: 28
  Must be exactly 32 characters

⚠ WARNING: DASHBOARD_PASSWORD must contain at least one letter
  Numbers-only passwords are not accepted by Kong basic-auth

=== Summary ===
Total checks: 25
Passed: 21
Warnings: 1
Errors: 3

Configuration validation FAILED
Fix errors before deploying to production
```

---

## Security Best Practices

### Secret Storage

**DO:**

- ✅ Use a password manager (1Password, Bitwarden, etc.)
- ✅ Use environment variable encryption (AWS Secrets Manager, HashiCorp Vault)
- ✅ Store secrets in secure, encrypted storage
- ✅ Limit access to secrets (need-to-know basis)
- ✅ Use separate secrets for each environment (dev/staging/prod)

**DON'T:**

- ❌ Commit `.env` or `production.env` to git
- ❌ Share secrets via email or chat
- ❌ Store secrets in plaintext files
- ❌ Use the same secrets across environments
- ❌ Log secrets in application logs

### Secret Rotation

**Recommended Schedule:**

| Secret Type | Rotation Frequency | Script |
|-------------|-------------------|--------|
| JWT_SECRET | Every 12 months | `./rotate-secrets.sh --jwt` |
| POSTGRES_PASSWORD | Every 6-12 months | `./rotate-secrets.sh --postgres` |
| Encryption Keys | Every 12 months | `./rotate-secrets.sh --encryption` |
| DASHBOARD_PASSWORD | Every 3-6 months | Manual update in .env |

**Emergency Rotation (if compromised):**

1. Identify compromised secret
2. Run appropriate rotation script immediately
3. Verify all services recover
4. Investigate how secret was compromised
5. Implement additional security controls
6. Document incident

### File Permissions

```bash
# Secure .env file (owner read/write only)
chmod 600 ../.env

# Secure backup files
chmod 600 ../.env.backup.*
chmod 600 ../.env.rotation-backup.*

# Secure script files (owner read/write/execute)
chmod 700 ./*.sh
```

### Backup Strategy

**Before any changes:**

```bash
# Backup configuration
cp ../.env ../.env.backup.$(date +%Y%m%d_%H%M%S)

# Backup database
docker exec supabase-db pg_dump -U postgres -d postgres > \
  backup_$(date +%Y%m%d_%H%M%S).sql

# Backup all Docker volumes
docker run --rm -v supabase_db_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/db_data_$(date +%Y%m%d).tar.gz /data
```

**Regular backups:**

- Daily database dumps (automated via cron)
- Weekly full volume backups
- Monthly offsite/cloud backups
- Test restore procedures quarterly

---

## Troubleshooting

### Script won't execute

**Problem:**

```bash
$ ./generate-secrets.sh
bash: ./generate-secrets.sh: Permission denied
```

**Solution:**

```bash
chmod +x *.sh
```

---

### "openssl command not found"

**Problem:**

```bash
$ ./generate-secrets.sh
openssl: command not found
```

**Solution:**

**macOS:**

```bash
# OpenSSL should be pre-installed
# If missing, install via Homebrew
brew install openssl
```

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get update
sudo apt-get install openssl
```

**Linux (RHEL/CentOS/Rocky):**

```bash
sudo yum install openssl
```

---

### Validation fails with "ANON_KEY is not a valid JWT"

**Problem:**

```bash
✗ ERROR: ANON_KEY is not a valid JWT
  JWTs should start with 'eyJ'
```

**Solution:**

1. Generate JWT using your JWT_SECRET
2. Visit: https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys
3. Input JWT_SECRET from `.env`
4. Generate token with role: `anon`
5. Copy token to `.env` as `ANON_KEY`
6. Repeat for `service_role` → `SERVICE_ROLE_KEY`

---

### "VAULT_ENC_KEY must be exactly 32 characters"

**Problem:**

```bash
✗ ERROR: VAULT_ENC_KEY must be exactly 32 characters
  Current length: 28
```

**Solution:**

```bash
# Generate exactly 32 hex characters
openssl rand -hex 16

# Update in .env:
VAULT_ENC_KEY=<32-character-hex-value>
```

---

### Rotation fails - "db-passwd.sh not found"

**Problem:**

```bash
Error: db-passwd.sh not found
This script should be in autogpt_platform/db/docker/utils/
```

**Solution:**

```bash
# Verify file exists
ls -la ../utils/db-passwd.sh

# If missing, update from repository
cd /path/to/AutoGPT
git pull origin master

# Or manually download from:
# https://github.com/supabase/supabase/blob/master/docker/utils/db-passwd.sh
```

---

## Advanced Usage

### Custom Secret Generation

If you need to generate additional secrets:

```bash
# Base64 encoded secret (various lengths)
openssl rand -base64 24   # 24 bytes (32 chars)
openssl rand -base64 32   # 32 bytes (43 chars)
openssl rand -base64 48   # 48 bytes (64 chars)

# Hex encoded secret
openssl rand -hex 16      # 32 hex characters
openssl rand -hex 32      # 64 hex characters

# Alphanumeric password
LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32

# Password with symbols
LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c 32
```

### Automated Rotation via Cron

**Example cron job for quarterly JWT rotation:**

```bash
# Edit crontab
crontab -e

# Add quarterly rotation (Jan 1, Apr 1, Jul 1, Oct 1 at 2 AM)
0 2 1 1,4,7,10 * /path/to/autogpt_platform/db/docker/scripts/rotate-secrets.sh --encryption
```

**Note:** JWT rotation requires manual JWT token generation, so full automation is not recommended.

---

## Contributing

### Adding New Scripts

When adding new security scripts:

1. Follow bash best practices:
   - Use `set -euo pipefail` for error handling
   - Add color output for readability
   - Include comprehensive error messages
   - Create backups before destructive operations

2. Update this README with:
   - Script purpose and usage
   - Example output
   - Troubleshooting section

3. Test thoroughly:
   - Test in development environment first
   - Verify rollback procedures work
   - Document all edge cases

---

## Additional Resources

- **Supabase Self-Hosting**: https://supabase.com/docs/guides/self-hosting/docker
- **Security Guide**: `../SECURITY_HARDENING.md`
- **Kong Upgrade Guide**: `../KONG_UPGRADE.md`
- **OpenSSL Documentation**: https://www.openssl.org/docs/

---

**Last Updated:** January 2026
**Maintainer:** AutoGPT Platform Team
**Version:** 1.0
