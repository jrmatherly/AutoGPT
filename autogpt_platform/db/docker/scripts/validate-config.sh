#!/bin/bash
# Supabase Configuration Validator
# Validates security configuration before production deployment
# Usage: ./validate-config.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Supabase Configuration Validator ===${NC}"
echo ""

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Check if .env exists
if [ ! -f "../.env" ]; then
    echo -e "${RED}✗ ERROR: .env file not found${NC}"
    echo "  Run ./generate-secrets.sh to create production secrets"
    exit 1
fi

# Load environment variables
set -a
source ../.env
set +a

# Function to check variable
check_var() {
    local var_name=$1
    local var_value=${!var_name:-}
    local check_type=$2
    local description=$3

    CHECKS=$((CHECKS + 1))

    case "$check_type" in
        required)
            if [ -z "$var_value" ]; then
                echo -e "${RED}✗ ERROR: $var_name is not set${NC}"
                echo "  $description"
                ERRORS=$((ERRORS + 1))
                return 1
            fi
            ;;
        placeholder)
            if [[ "$var_value" == *"your-"* ]] || [[ "$var_value" == *"secret"* ]]; then
                echo -e "${RED}✗ ERROR: $var_name contains placeholder value${NC}"
                echo "  Current: ${var_value:0:30}..."
                echo "  $description"
                ERRORS=$((ERRORS + 1))
                return 1
            fi
            ;;
        min_length)
            local min_len=$4
            if [ ${#var_value} -lt "$min_len" ]; then
                echo -e "${YELLOW}⚠ WARNING: $var_name is shorter than recommended ($min_len chars)${NC}"
                echo "  Current length: ${#var_value}"
                echo "  $description"
                WARNINGS=$((WARNINGS + 1))
                return 1
            fi
            ;;
        exact_length)
            local exact_len=$4
            if [ ${#var_value} -ne "$exact_len" ]; then
                echo -e "${RED}✗ ERROR: $var_name must be exactly $exact_len characters${NC}"
                echo "  Current length: ${#var_value}"
                echo "  $description"
                ERRORS=$((ERRORS + 1))
                return 1
            fi
            ;;
        jwt)
            if [[ ! "$var_value" =~ ^eyJ ]]; then
                echo -e "${RED}✗ ERROR: $var_name is not a valid JWT${NC}"
                echo "  JWTs should start with 'eyJ'"
                echo "  $description"
                ERRORS=$((ERRORS + 1))
                return 1
            fi
            ;;
        url)
            if [[ ! "$var_value" =~ ^https?:// ]]; then
                echo -e "${YELLOW}⚠ WARNING: $var_name should be a valid URL${NC}"
                echo "  Current: $var_value"
                echo "  $description"
                WARNINGS=$((WARNINGS + 1))
                return 1
            fi
            ;;
    esac

    echo -e "${GREEN}✓ $var_name${NC}"
    return 0
}

echo "=== Critical Security Configuration ==="
echo ""

# JWT Secret
check_var JWT_SECRET required "JWT secret for signing tokens" && \
check_var JWT_SECRET placeholder "Generate with: openssl rand -base64 48" && \
check_var JWT_SECRET min_length 48 "Minimum 48 characters recommended"

# JWT Tokens
check_var ANON_KEY required "Anonymous API key" && \
check_var ANON_KEY jwt "Generate using Supabase JWT generator" && \
check_var ANON_KEY placeholder "Must be valid JWT, not placeholder"

check_var SERVICE_ROLE_KEY required "Service role API key" && \
check_var SERVICE_ROLE_KEY jwt "Generate using Supabase JWT generator" && \
check_var SERVICE_ROLE_KEY placeholder "Must be valid JWT, not placeholder"

# Database Password
check_var POSTGRES_PASSWORD required "Database password" && \
check_var POSTGRES_PASSWORD placeholder "Generate with: openssl rand -base64 32" && \
check_var POSTGRES_PASSWORD min_length 20 "Minimum 20 characters recommended"

# Encryption Keys
check_var SECRET_KEY_BASE required "Realtime/Supavisor encryption key" && \
check_var SECRET_KEY_BASE placeholder "Generate with: openssl rand -base64 48" && \
check_var SECRET_KEY_BASE min_length 64 "Minimum 64 characters required"

check_var VAULT_ENC_KEY required "Supavisor vault encryption key" && \
check_var VAULT_ENC_KEY placeholder "Generate with: openssl rand -hex 16" && \
check_var VAULT_ENC_KEY exact_length 32 "Must be exactly 32 characters"

echo ""
echo "=== Dashboard Security ==="
echo ""

check_var DASHBOARD_USERNAME required "Studio dashboard username"

check_var DASHBOARD_PASSWORD required "Studio dashboard password" && \
check_var DASHBOARD_PASSWORD placeholder "Must not contain placeholder" && \
check_var DASHBOARD_PASSWORD min_length 12 "Minimum 12 characters recommended"

# Validate password contains letters
if [[ ! "${DASHBOARD_PASSWORD:-}" =~ [A-Za-z] ]]; then
    echo -e "${RED}✗ ERROR: DASHBOARD_PASSWORD must contain at least one letter${NC}"
    echo "  Numbers-only passwords are not accepted by Kong basic-auth"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== Logflare Configuration ==="
echo ""

check_var LOGFLARE_API_KEY placeholder "Generate with: openssl rand -base64 24" && \
check_var LOGFLARE_API_KEY min_length 20 "Minimum 20 characters recommended"

echo ""
echo "=== Public URLs ==="
echo ""

check_var SUPABASE_PUBLIC_URL url "Should be your public domain"
check_var API_EXTERNAL_URL url "Should be your public API domain"
check_var SITE_URL url "Should be your frontend domain"

# Check if URLs are still localhost (warning for production)
if [[ "${SUPABASE_PUBLIC_URL:-}" == *"localhost"* ]]; then
    echo -e "${YELLOW}⚠ WARNING: SUPABASE_PUBLIC_URL uses localhost${NC}"
    echo "  Update for production deployment"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=== Docker Compose Validation ==="
echo ""

# Check Kong version
KONG_IMAGE=$(grep "image: kong:" ../docker-compose.yml | head -1 | awk '{print $2}')
if [[ "$KONG_IMAGE" == "kong:2.8.1" ]]; then
    echo -e "${YELLOW}⚠ WARNING: Kong 2.8.1 is outdated${NC}"
    echo "  Recommended: Upgrade to Kong 3.4 LTS"
    echo "  See: KONG_UPGRADE.md"
    WARNINGS=$((WARNINGS + 1))
elif [[ "$KONG_IMAGE" =~ kong:3\.[4-9] ]]; then
    echo -e "${GREEN}✓ Kong version: $KONG_IMAGE (recommended)${NC}"
else
    echo -e "${YELLOW}⚠ WARNING: Kong version: $KONG_IMAGE${NC}"
    echo "  Consider upgrading to Kong 3.4 LTS"
    WARNINGS=$((WARNINGS + 1))
fi

# Check kong.yml format version
KONG_FORMAT=$(grep "_format_version:" ../volumes/api/kong.yml | head -1 | awk '{print $2}' | tr -d "'\"")
if [[ "$KONG_IMAGE" =~ kong:3\. ]] && [[ "$KONG_FORMAT" != "3.0" ]]; then
    echo -e "${RED}✗ ERROR: Kong 3.x requires _format_version: '3.0'${NC}"
    echo "  Current format version: $KONG_FORMAT"
    echo "  Update volumes/api/kong.yml"
    ERRORS=$((ERRORS + 1))
elif [[ "$KONG_FORMAT" == "3.0" ]]; then
    echo -e "${GREEN}✓ Kong configuration format: $KONG_FORMAT${NC}"
else
    echo -e "${GREEN}✓ Kong configuration format: $KONG_FORMAT${NC}"
fi

echo ""
echo "=== Optional Configuration ==="
echo ""

# SMTP (optional but recommended for production)
if [ -z "${SMTP_HOST:-}" ] || [[ "${SMTP_HOST:-}" == *"supabase-mail"* ]]; then
    echo -e "${YELLOW}⚠ INFO: SMTP not configured (using development mail server)${NC}"
    echo "  Configure production SMTP for reliable email delivery"
    echo "  Update: SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS"
else
    echo -e "${GREEN}✓ SMTP configured: ${SMTP_HOST:-}${NC}"
fi

# Storage backend
if [ "${STORAGE_BACKEND:-file}" == "file" ]; then
    echo -e "${YELLOW}⚠ INFO: Using file-based storage${NC}"
    echo "  Consider S3-compatible storage for production"
    echo "  See: docker-compose.s3.yml"
else
    echo -e "${GREEN}✓ Storage backend: ${STORAGE_BACKEND:-}${NC}"
fi

echo ""
echo "=== Summary ==="
echo ""
echo "Total checks: $CHECKS"
echo -e "${GREEN}Passed: $((CHECKS - ERRORS - WARNINGS))${NC}"

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Errors: $ERRORS${NC}"
    echo ""
    echo -e "${RED}Configuration validation FAILED${NC}"
    echo "Fix errors before deploying to production"
    exit 1
else
    echo ""
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Configuration validation PASSED with warnings${NC}"
        echo "Review warnings before production deployment"
        exit 0
    else
        echo -e "${GREEN}Configuration validation PASSED${NC}"
        echo "Configuration is ready for deployment"
        exit 0
    fi
fi
