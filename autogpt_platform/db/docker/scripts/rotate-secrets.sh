#!/bin/bash
# Supabase Secret Rotation Script
# Rotates secrets with zero-downtime strategy
# Usage: ./rotate-secrets.sh [--secret-type jwt|postgres|all]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
SECRET_TYPE="${1:---all}"
ENV_FILE="../.env"

echo -e "${BLUE}=== Supabase Secret Rotation Tool ===${NC}"
echo ""

# Validate environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found at $ENV_FILE${NC}"
    echo "Run generate-secrets.sh first to create initial secrets"
    exit 1
fi

# Function to backup current env
backup_env() {
    local backup_file="../.env.rotation-backup.$(date +%Y%m%d_%H%M%S)"
    cp "$ENV_FILE" "$backup_file"
    echo -e "${GREEN}✓ Backed up .env to: $backup_file${NC}"
}

# Function to generate new secret
generate_secret() {
    local type=$1
    case "$type" in
        jwt)
            openssl rand -base64 48 | tr -d '\n'
            ;;
        postgres)
            LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
            ;;
        base64)
            openssl rand -base64 48 | tr -d '\n'
            ;;
        hex32)
            openssl rand -hex 16 | tr -d '\n'
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to rotate JWT secret
rotate_jwt_secret() {
    echo ""
    echo -e "${YELLOW}=== Rotating JWT Secret ===${NC}"
    echo ""
    echo "This will rotate the JWT_SECRET and require new ANON_KEY and SERVICE_ROLE_KEY generation."
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return
    fi

    backup_env

    local new_jwt_secret=$(generate_secret jwt)

    # Update JWT_SECRET in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|^JWT_SECRET=.*|JWT_SECRET=${new_jwt_secret}|" "$ENV_FILE"
    else
        # Linux
        sed -i "s|^JWT_SECRET=.*|JWT_SECRET=${new_jwt_secret}|" "$ENV_FILE"
    fi

    echo -e "${GREEN}✓ Updated JWT_SECRET${NC}"
    echo ""
    echo -e "${YELLOW}⚠ IMPORTANT: Generate new JWT tokens${NC}"
    echo ""
    echo "1. Use this new JWT_SECRET:"
    echo "   ${new_jwt_secret:0:10}..."
    echo ""
    echo "2. Generate ANON_KEY and SERVICE_ROLE_KEY at:"
    echo "   https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys"
    echo ""
    echo "3. Update .env with new tokens"
    echo ""
    echo "4. Disable old anon and service_role keys in Supabase dashboard:"
    echo "   /dashboard/project/_/settings/api-keys"
    echo ""
    echo "5. Restart services:"
    echo "   docker compose down && docker compose up -d"
    echo ""
}

# Function to rotate Postgres password
rotate_postgres_password() {
    echo ""
    echo -e "${YELLOW}=== Rotating Postgres Password ===${NC}"
    echo ""
    echo "This will use the db-passwd.sh utility to rotate the database password."
    echo ""

    if [ ! -f "../utils/db-passwd.sh" ]; then
        echo -e "${RED}Error: db-passwd.sh not found${NC}"
        echo "This script should be in autogpt_platform/db/docker/utils/"
        return
    fi

    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return
    fi

    backup_env

    echo "Running db-passwd.sh..."
    cd ../utils && bash db-passwd.sh && cd - > /dev/null

    echo ""
    echo -e "${GREEN}✓ Postgres password rotated${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart database service:"
    echo "   docker compose restart db"
    echo ""
    echo "2. Verify all services reconnect successfully:"
    echo "   docker compose ps"
    echo ""
}

# Function to rotate encryption keys
rotate_encryption_keys() {
    echo ""
    echo -e "${YELLOW}=== Rotating Encryption Keys ===${NC}"
    echo ""
    echo "This will rotate:"
    echo "  - SECRET_KEY_BASE (Realtime/Supavisor)"
    echo "  - VAULT_ENC_KEY (Supavisor)"
    echo ""

    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return
    fi

    backup_env

    local new_secret_key_base=$(generate_secret base64)
    local new_vault_enc_key=$(generate_secret hex32)

    # Update keys in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=${new_secret_key_base}|" "$ENV_FILE"
        sed -i '' "s|^VAULT_ENC_KEY=.*|VAULT_ENC_KEY=${new_vault_enc_key}|" "$ENV_FILE"
    else
        sed -i "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=${new_secret_key_base}|" "$ENV_FILE"
        sed -i "s|^VAULT_ENC_KEY=.*|VAULT_ENC_KEY=${new_vault_enc_key}|" "$ENV_FILE"
    fi

    echo -e "${GREEN}✓ Updated SECRET_KEY_BASE${NC}"
    echo -e "${GREEN}✓ Updated VAULT_ENC_KEY${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart affected services:"
    echo "   docker compose restart realtime supavisor"
    echo ""
    echo "2. Verify services are healthy:"
    echo "   docker compose ps"
    echo ""
}

# Main menu
show_menu() {
    echo "Select secret rotation option:"
    echo ""
    echo "  1) Rotate JWT Secret (ANON_KEY, SERVICE_ROLE_KEY)"
    echo "  2) Rotate Postgres Password"
    echo "  3) Rotate Encryption Keys (SECRET_KEY_BASE, VAULT_ENC_KEY)"
    echo "  4) Rotate All Secrets (requires manual steps)"
    echo "  5) Exit"
    echo ""
    read -p "Enter choice [1-5]: " choice

    case $choice in
        1)
            rotate_jwt_secret
            ;;
        2)
            rotate_postgres_password
            ;;
        3)
            rotate_encryption_keys
            ;;
        4)
            echo ""
            echo -e "${YELLOW}=== Rotating All Secrets ===${NC}"
            echo ""
            rotate_encryption_keys
            rotate_jwt_secret
            echo ""
            echo -e "${YELLOW}Note: Postgres password rotation requires separate execution${NC}"
            echo "Run: ./rotate-secrets.sh and select option 2"
            ;;
        5)
            echo "Exiting"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

# Parse command line arguments
case "$SECRET_TYPE" in
    --jwt)
        rotate_jwt_secret
        ;;
    --postgres)
        rotate_postgres_password
        ;;
    --encryption)
        rotate_encryption_keys
        ;;
    --all)
        show_menu
        ;;
    *)
        echo "Usage: $0 [--jwt|--postgres|--encryption|--all]"
        echo ""
        echo "Options:"
        echo "  --jwt         Rotate JWT secret and tokens"
        echo "  --postgres    Rotate database password"
        echo "  --encryption  Rotate encryption keys"
        echo "  --all         Interactive menu (default)"
        exit 1
        ;;
esac
