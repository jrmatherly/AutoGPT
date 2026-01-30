#!/bin/bash
# Supabase Production Secrets Generator
# Generates cryptographically secure secrets for production deployment
# Usage: ./generate-secrets.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Supabase Production Secrets Generator ===${NC}"
echo ""

# Check if .env already exists
if [ -f "../.env" ]; then
    echo -e "${YELLOW}Warning: .env file already exists${NC}"
    read -p "Do you want to backup and replace it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_FILE="../.env.backup.$(date +%Y%m%d_%H%M%S)"
        cp ../.env "$BACKUP_FILE"
        echo -e "${GREEN}Backed up to: $BACKUP_FILE${NC}"
    else
        echo "Exiting without changes"
        exit 0
    fi
fi

# Function to generate base64 secret
generate_base64() {
    local length=$1
    openssl rand -base64 "$length" | tr -d '\n'
}

# Function to generate hex secret
generate_hex() {
    local length=$1
    openssl rand -hex "$length" | tr -d '\n'
}

# Function to generate alphanumeric password
generate_password() {
    local length=${1:-32}
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
}

echo "Generating secrets (this may take a few seconds)..."
echo ""

# Generate core secrets
JWT_SECRET=$(generate_base64 48)
POSTGRES_PASSWORD=$(generate_password 32)
SECRET_KEY_BASE=$(generate_base64 48)
VAULT_ENC_KEY=$(generate_hex 16)  # Exactly 32 hex characters
LOGFLARE_API_KEY=$(generate_base64 24)
LOGFLARE_PUBLIC_TOKEN=$(generate_base64 24)
LOGFLARE_PRIVATE_TOKEN=$(generate_base64 24)
DASHBOARD_PASSWORD=$(generate_password 20)

echo -e "${GREEN}✓ Generated JWT_SECRET (48 bytes base64)${NC}"
echo -e "${GREEN}✓ Generated POSTGRES_PASSWORD (32 chars alphanumeric)${NC}"
echo -e "${GREEN}✓ Generated SECRET_KEY_BASE (48 bytes base64)${NC}"
echo -e "${GREEN}✓ Generated VAULT_ENC_KEY (32 chars hex)${NC}"
echo -e "${GREEN}✓ Generated LOGFLARE tokens${NC}"
echo -e "${GREEN}✓ Generated DASHBOARD_PASSWORD${NC}"
echo ""

# Generate JWT tokens using the JWT_SECRET
echo "Generating JWT tokens (ANON_KEY and SERVICE_ROLE_KEY)..."

# ANON_KEY payload (expires in 10 years)
ANON_PAYLOAD=$(cat <<EOF
{
  "role": "anon",
  "iss": "supabase",
  "iat": $(date +%s),
  "exp": $(date -v+10y +%s 2>/dev/null || date -d "+10 years" +%s)
}
EOF
)

# SERVICE_ROLE_KEY payload (expires in 10 years)
SERVICE_PAYLOAD=$(cat <<EOF
{
  "role": "service_role",
  "iss": "supabase",
  "iat": $(date +%s),
  "exp": $(date -v+10y +%s 2>/dev/null || date -d "+10 years" +%s)
}
EOF
)

# Note: Proper JWT generation requires jose library or similar
# For now, provide instructions for manual generation
echo ""
echo -e "${YELLOW}⚠ JWT Token Generation Required${NC}"
echo ""
echo "Use the Supabase JWT generator to create ANON_KEY and SERVICE_ROLE_KEY:"
echo "https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys"
echo ""
echo "Or use this JWT_SECRET with the generator:"
echo -e "${GREEN}JWT_SECRET=${NC} $JWT_SECRET"
echo ""
echo "Generate two tokens:"
echo "1. ANON_KEY with role: 'anon'"
echo "2. SERVICE_ROLE_KEY with role: 'service_role'"
echo ""

# Create production.env template
cat > ../production.env <<EOF
#############################################
# SUPABASE PRODUCTION CONFIGURATION
# Generated: $(date)
#############################################
#
# CRITICAL SECURITY NOTICE:
# - Never commit this file to version control
# - Store securely using a secrets manager
# - Rotate secrets every 6-12 months
# - Use separate secrets for each environment
#
#############################################

#############################################
# Database Configuration
#############################################
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_HOST=db
POSTGRES_PORT=5432
POSTGRES_DB=postgres

#############################################
# JWT & Authentication
#############################################
JWT_SECRET=${JWT_SECRET}
JWT_EXP=3600

# Generate these using the Supabase JWT generator
# https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys
# Use the JWT_SECRET above and create tokens for 'anon' and 'service_role' roles
ANON_KEY=YOUR_GENERATED_ANON_JWT_TOKEN_HERE
SERVICE_ROLE_KEY=YOUR_GENERATED_SERVICE_ROLE_JWT_TOKEN_HERE

#############################################
# Encryption & Security Keys
#############################################
SECRET_KEY_BASE=${SECRET_KEY_BASE}
VAULT_ENC_KEY=${VAULT_ENC_KEY}
PG_META_CRYPTO_KEY=$(generate_base64 24)

#############################################
# Analytics & Logging
#############################################
LOGFLARE_API_KEY=${LOGFLARE_API_KEY}
LOGFLARE_PUBLIC_ACCESS_TOKEN=${LOGFLARE_PUBLIC_TOKEN}
LOGFLARE_PRIVATE_ACCESS_TOKEN=${LOGFLARE_PRIVATE_TOKEN}

#############################################
# Studio/Dashboard Access
#############################################
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD}

#############################################
# Public URLs - UPDATE THESE!
#############################################
SUPABASE_PUBLIC_URL=https://api.yourdomain.com
API_EXTERNAL_URL=https://api.yourdomain.com
SITE_URL=https://app.yourdomain.com

#############################################
# SMTP Configuration (Production Email)
#############################################
# Configure with your SMTP provider (SendGrid, AWS SES, etc.)
SMTP_ADMIN_EMAIL=noreply@yourdomain.com
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=YOUR_SMTP_API_KEY_HERE
SMTP_SENDER_NAME="Your App Name"

#############################################
# Connection Pooler (Supavisor)
#############################################
POOLER_TENANT_ID=production-tenant
POOLER_DEFAULT_POOL_SIZE=20
POOLER_MAX_CLIENT_CONN=100
POOLER_POOL_MODE=transaction

#############################################
# Storage Backend (Optional S3)
#############################################
# Uncomment and configure for S3-compatible storage
# STORAGE_BACKEND=s3
# GLOBAL_S3_BUCKET=your-bucket-name
# AWS_ACCESS_KEY_ID=your-aws-access-key
# AWS_SECRET_ACCESS_KEY=your-aws-secret-key
# AWS_DEFAULT_REGION=us-east-1

#############################################
# Optional: OpenAI API for Supabase AI Assistant
#############################################
# OPENAI_API_KEY=sk-...

EOF

echo -e "${GREEN}✓ Created production.env template${NC}"
echo ""

# Create secrets summary file
cat > ../secrets-summary.txt <<EOF
Supabase Production Secrets Summary
Generated: $(date)

CRITICAL: Store this file securely and delete after recording secrets

=== Core Secrets ===
JWT_SECRET: ${JWT_SECRET:0:10}... (48 bytes base64)
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:0:6}... (32 chars)
SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:10}... (48 bytes base64)
VAULT_ENC_KEY: ${VAULT_ENC_KEY:0:8}... (32 chars hex)

=== Dashboard Access ===
DASHBOARD_USERNAME: admin
DASHBOARD_PASSWORD: ${DASHBOARD_PASSWORD:0:4}... (20 chars)

=== Logflare Tokens ===
LOGFLARE_API_KEY: ${LOGFLARE_API_KEY:0:8}... (24 bytes base64)
LOGFLARE_PUBLIC_TOKEN: ${LOGFLARE_PUBLIC_TOKEN:0:8}... (24 bytes base64)
LOGFLARE_PRIVATE_TOKEN: ${LOGFLARE_PRIVATE_TOKEN:0:8}... (24 bytes base64)

=== Next Steps ===
1. Generate ANON_KEY and SERVICE_ROLE_KEY JWTs using:
   https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys

2. Update production.env with generated JWT tokens

3. Update public URLs in production.env:
   - SUPABASE_PUBLIC_URL
   - API_EXTERNAL_URL
   - SITE_URL

4. Configure SMTP credentials for production email

5. Review and update all configuration values

6. Copy production.env to .env:
   cp production.env .env

7. Securely delete this summary file:
   rm secrets-summary.txt

EOF

echo -e "${GREEN}=== Summary ===${NC}"
echo ""
echo "Generated files:"
echo "  - production.env (template with secrets)"
echo "  - secrets-summary.txt (summary, delete after use)"
echo ""
echo "Next steps:"
echo ""
echo "1. Generate JWT tokens:"
echo "   Visit: https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys"
echo "   Use JWT_SECRET: ${JWT_SECRET:0:10}..."
echo ""
echo "2. Review and update production.env:"
echo "   - Add generated ANON_KEY and SERVICE_ROLE_KEY"
echo "   - Update public URLs (SUPABASE_PUBLIC_URL, etc.)"
echo "   - Configure SMTP credentials"
echo ""
echo "3. Apply configuration:"
echo "   cp production.env .env"
echo ""
echo "4. Secure the secrets:"
echo "   chmod 600 .env"
echo "   rm secrets-summary.txt"
echo ""
echo -e "${YELLOW}⚠ SECURITY REMINDER:${NC}"
echo "  - Never commit .env or production.env to git"
echo "  - Store secrets in a secure password manager"
echo "  - Rotate secrets every 6-12 months"
echo ""
