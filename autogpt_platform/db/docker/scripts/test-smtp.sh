#!/bin/bash
# SMTP Configuration Test Script
#
# This script tests your SMTP configuration by sending a test email
# and verifying the auth service can connect to the SMTP server.
#
# Usage:
#   ./test-smtp.sh [--email test@example.com]
#
# Arguments:
#   --email EMAIL    Email address to send test to (optional)
#
# Example:
#   ./test-smtp.sh
#   ./test-smtp.sh --email admin@yourdomain.com

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
TEST_EMAIL=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --email)
            TEST_EMAIL="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--email EMAIL]"
            echo ""
            echo "Test SMTP configuration for Supabase"
            echo ""
            echo "Options:"
            echo "  --email EMAIL    Email address to send test to"
            echo ""
            echo "Example:"
            echo "  $0 --email admin@yourdomain.com"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=== Supabase SMTP Configuration Test ===${NC}"
echo ""

cd "$DOCKER_DIR"

# Load environment variables
if [ ! -f .env ]; then
    echo -e "${RED}✗ .env file not found${NC}"
    echo "Please create .env file with SMTP configuration"
    exit 1
fi

# Source environment file
set -a
source .env
set +a

# Check if auth service is running
echo -e "${BLUE}Checking auth service...${NC}"
if ! docker compose ps | grep -q "supabase-auth.*running"; then
    echo -e "${RED}✗ Supabase auth service is not running${NC}"
    echo "Start with: docker compose up -d"
    exit 1
fi
echo -e "${GREEN}✓ Auth service is running${NC}"
echo ""

# Validate SMTP configuration
echo -e "${BLUE}Validating SMTP configuration...${NC}"

SMTP_ERRORS=0

if [ -z "${SMTP_HOST:-}" ]; then
    echo -e "${RED}✗ SMTP_HOST is not set${NC}"
    SMTP_ERRORS=$((SMTP_ERRORS + 1))
else
    echo -e "${GREEN}✓ SMTP_HOST: $SMTP_HOST${NC}"
fi

if [ -z "${SMTP_PORT:-}" ]; then
    echo -e "${RED}✗ SMTP_PORT is not set${NC}"
    SMTP_ERRORS=$((SMTP_ERRORS + 1))
else
    echo -e "${GREEN}✓ SMTP_PORT: $SMTP_PORT${NC}"
fi

if [ -z "${SMTP_ADMIN_EMAIL:-}" ]; then
    echo -e "${RED}✗ SMTP_ADMIN_EMAIL is not set${NC}"
    SMTP_ERRORS=$((SMTP_ERRORS + 1))
else
    echo -e "${GREEN}✓ SMTP_ADMIN_EMAIL: $SMTP_ADMIN_EMAIL${NC}"
fi

if [ -z "${SMTP_USER:-}" ]; then
    echo -e "${YELLOW}⚠ SMTP_USER is not set (may be optional)${NC}"
else
    echo -e "${GREEN}✓ SMTP_USER: ${SMTP_USER:0:10}...${NC}"
fi

if [ -z "${SMTP_PASS:-}" ]; then
    echo -e "${YELLOW}⚠ SMTP_PASS is not set (may be optional)${NC}"
else
    echo -e "${GREEN}✓ SMTP_PASS: ********${NC}"
fi

echo ""

if [ $SMTP_ERRORS -gt 0 ]; then
    echo -e "${RED}SMTP configuration incomplete. Please update .env file.${NC}"
    exit 1
fi

# Test SMTP connectivity
echo -e "${BLUE}Testing SMTP server connectivity...${NC}"

# Try to connect to SMTP server
if docker compose exec -T auth sh -c "timeout 5 nc -zv $SMTP_HOST $SMTP_PORT" 2>&1 | grep -q "open\|succeeded"; then
    echo -e "${GREEN}✓ Successfully connected to $SMTP_HOST:$SMTP_PORT${NC}"
else
    echo -e "${RED}✗ Failed to connect to $SMTP_HOST:$SMTP_PORT${NC}"
    echo -e "${YELLOW}This may indicate firewall issues or incorrect SMTP host/port${NC}"
fi

echo ""

# Send test email
if [ -n "$TEST_EMAIL" ]; then
    echo -e "${BLUE}Sending test email to $TEST_EMAIL...${NC}"

    # Get SUPABASE_ANON_KEY from environment
    if [ -z "${SUPABASE_ANON_KEY:-}" ] && [ -z "${ANON_KEY:-}" ]; then
        echo -e "${RED}✗ SUPABASE_ANON_KEY or ANON_KEY not set${NC}"
        exit 1
    fi

    ANON_KEY="${SUPABASE_ANON_KEY:-$ANON_KEY}"

    # Trigger password recovery email
    HTTP_CODE=$(curl -s -o /tmp/smtp-test-response.json -w "%{http_code}" \
        -X POST "http://localhost:8000/auth/v1/recover" \
        -H "apikey: $ANON_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$TEST_EMAIL\"}")

    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ Test email triggered successfully${NC}"
        echo ""
        echo "Response:"
        cat /tmp/smtp-test-response.json | jq '.' 2>/dev/null || cat /tmp/smtp-test-response.json
        echo ""
        echo -e "${YELLOW}Check the inbox for $TEST_EMAIL (including spam folder)${NC}"
    else
        echo -e "${RED}✗ Failed to trigger test email (HTTP $HTTP_CODE)${NC}"
        echo ""
        echo "Response:"
        cat /tmp/smtp-test-response.json
        echo ""
    fi

    rm -f /tmp/smtp-test-response.json
else
    echo -e "${YELLOW}No test email address provided. Skipping email send test.${NC}"
    echo "Run with --email to send a test email:"
    echo "  $0 --email admin@yourdomain.com"
fi

echo ""

# Check auth service logs for SMTP errors
echo -e "${BLUE}Checking recent auth logs for SMTP errors...${NC}"

SMTP_LOGS=$(docker compose logs auth --tail=50 2>&1 | grep -i "smtp\|mail" || true)

if [ -n "$SMTP_LOGS" ]; then
    echo "Recent SMTP-related log entries:"
    echo "$SMTP_LOGS" | tail -10
else
    echo -e "${GREEN}No SMTP errors found in recent logs${NC}"
fi

echo ""

# Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
echo ""
echo "SMTP Configuration:"
echo "  Host: $SMTP_HOST"
echo "  Port: $SMTP_PORT"
echo "  From: $SMTP_ADMIN_EMAIL"
echo ""

if [ $SMTP_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ SMTP configuration appears valid${NC}"
else
    echo -e "${RED}✗ SMTP configuration has issues${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Check email delivery in inbox (and spam folder)"
echo "  2. Verify email links work correctly"
echo "  3. Monitor auth logs: docker compose logs auth -f"
echo "  4. Check provider dashboard for delivery status"
echo ""
echo "Troubleshooting resources:"
echo "  - SMTP Setup Guide: ./SMTP_SETUP_GUIDE.md"
echo "  - Auth service logs: docker compose logs auth"
echo "  - Environment config: cat .env | grep SMTP"

exit 0
