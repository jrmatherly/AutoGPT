#!/bin/bash
# SSL/TLS Setup Automation Script
#
# This script automates the setup of SSL/TLS for Supabase using either Nginx or Caddy
#
# Usage:
#   ./setup-ssl.sh --proxy nginx|caddy --domain api.yourdomain.com [--email your@email.com]
#
# Arguments:
#   --proxy PROXY      Reverse proxy to use (nginx or caddy)
#   --domain DOMAIN    Your domain name
#   --email EMAIL      Email for Let's Encrypt (required for nginx)
#
# Example:
#   ./setup-ssl.sh --proxy nginx --domain api.example.com --email admin@example.com
#   ./setup-ssl.sh --proxy caddy --domain api.example.com

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
PROXY=""
DOMAIN=""
EMAIL=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --proxy)
            PROXY="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --email)
            EMAIL="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 --proxy nginx|caddy --domain DOMAIN [--email EMAIL]"
            echo ""
            echo "Options:"
            echo "  --proxy PROXY    Reverse proxy to use (nginx or caddy)"
            echo "  --domain DOMAIN  Your domain name"
            echo "  --email EMAIL    Email for Let's Encrypt notifications"
            echo ""
            echo "Examples:"
            echo "  $0 --proxy nginx --domain api.example.com --email admin@example.com"
            echo "  $0 --proxy caddy --domain api.example.com"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate arguments
if [ -z "$PROXY" ]; then
    echo -e "${RED}Error: --proxy is required${NC}"
    echo "Use --help for usage information"
    exit 1
fi

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: --domain is required${NC}"
    echo "Use --help for usage information"
    exit 1
fi

if [ "$PROXY" != "nginx" ] && [ "$PROXY" != "caddy" ]; then
    echo -e "${RED}Error: --proxy must be either 'nginx' or 'caddy'${NC}"
    exit 1
fi

if [ "$PROXY" = "nginx" ] && [ -z "$EMAIL" ]; then
    echo -e "${RED}Error: --email is required when using nginx${NC}"
    exit 1
fi

echo -e "${BLUE}=== Supabase SSL/TLS Setup ===${NC}"
echo "Proxy: $PROXY"
echo "Domain: $DOMAIN"
[ -n "$EMAIL" ] && echo "Email: $EMAIL"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Warning: This script should be run with sudo${NC}"
    echo -e "${YELLOW}Some operations may fail without root privileges${NC}"
    read -p "Continue anyway? (y/N): " continue
    if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
        exit 0
    fi
fi

# Check DNS resolution
echo -e "${BLUE}Checking DNS resolution for $DOMAIN...${NC}"
if ! host "$DOMAIN" > /dev/null 2>&1; then
    echo -e "${RED}✗ DNS lookup failed for $DOMAIN${NC}"
    echo -e "${YELLOW}Please ensure your domain's A record points to this server${NC}"
    read -p "Continue anyway? (y/N): " continue
    if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
        exit 0
    fi
else
    echo -e "${GREEN}✓ DNS resolution successful${NC}"
fi

# Check if Supabase is running
echo -e "${BLUE}Checking if Supabase is running...${NC}"
cd "$DOCKER_DIR"
if ! docker compose ps | grep -q "supabase-kong"; then
    echo -e "${RED}✗ Supabase Kong service is not running${NC}"
    echo "Please start Supabase first: docker compose up -d"
    exit 1
fi
echo -e "${GREEN}✓ Supabase is running${NC}"

# Check port 8000
if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Cannot reach Supabase on localhost:8000${NC}"
    read -p "Continue anyway? (y/N): " continue
    if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
        exit 0
    fi
fi

# Install and configure based on proxy choice
if [ "$PROXY" = "nginx" ]; then
    echo -e "${BLUE}Setting up Nginx...${NC}"

    # Install Nginx and Certbot
    echo "Installing Nginx and Certbot..."
    apt-get update
    apt-get install -y nginx certbot python3-certbot-nginx

    # Copy and configure
    echo "Configuring Nginx..."
    NGINX_CONF="$DOCKER_DIR/nginx/supabase.conf"

    if [ ! -f "$NGINX_CONF" ]; then
        echo -e "${RED}✗ Nginx configuration not found: $NGINX_CONF${NC}"
        exit 1
    fi

    # Replace domain in config
    sed "s/api.yourdomain.com/$DOMAIN/g" "$NGINX_CONF" > /tmp/supabase.conf

    # Install config
    cp /tmp/supabase.conf /etc/nginx/sites-available/supabase

    # Test configuration
    if ! nginx -t; then
        echo -e "${RED}✗ Nginx configuration test failed${NC}"
        exit 1
    fi

    # Enable site
    ln -sf /etc/nginx/sites-available/supabase /etc/nginx/sites-enabled/
    systemctl reload nginx

    echo -e "${GREEN}✓ Nginx configured${NC}"

    # Obtain SSL certificate
    echo -e "${BLUE}Obtaining SSL certificate...${NC}"
    if certbot --nginx -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive; then
        echo -e "${GREEN}✓ SSL certificate obtained${NC}"
    else
        echo -e "${RED}✗ Failed to obtain SSL certificate${NC}"
        echo "Please check DNS configuration and try again"
        exit 1
    fi

    # Enable auto-renewal
    systemctl enable certbot.timer
    systemctl start certbot.timer

    echo -e "${GREEN}✓ Certificate auto-renewal enabled${NC}"

elif [ "$PROXY" = "caddy" ]; then
    echo -e "${BLUE}Setting up Caddy...${NC}"

    # Install Caddy
    echo "Installing Caddy..."
    apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | \
        gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | \
        tee /etc/apt/sources.list.d/caddy-stable.list
    apt update
    apt install -y caddy

    # Configure Caddy
    echo "Configuring Caddy..."
    CADDY_CONF="$DOCKER_DIR/caddy/Caddyfile"

    if [ ! -f "$CADDY_CONF" ]; then
        echo -e "${RED}✗ Caddy configuration not found: $CADDY_CONF${NC}"
        exit 1
    fi

    # Replace domain in config
    sed "s/api.yourdomain.com/$DOMAIN/g" "$CADDY_CONF" > /tmp/Caddyfile

    # Backup existing config
    [ -f /etc/caddy/Caddyfile ] && cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup

    # Install config
    cp /tmp/Caddyfile /etc/caddy/Caddyfile

    # Validate configuration
    if ! caddy validate --config /etc/caddy/Caddyfile; then
        echo -e "${RED}✗ Caddy configuration validation failed${NC}"
        exit 1
    fi

    # Start Caddy
    systemctl enable caddy
    systemctl restart caddy

    # Wait for Caddy to obtain certificate
    echo "Waiting for Caddy to obtain SSL certificate..."
    sleep 10

    if systemctl is-active --quiet caddy; then
        echo -e "${GREEN}✓ Caddy is running${NC}"
    else
        echo -e "${RED}✗ Caddy failed to start${NC}"
        journalctl -u caddy --no-pager | tail -20
        exit 1
    fi

    echo -e "${GREEN}✓ Caddy configured (certificates managed automatically)${NC}"
fi

# Update environment variables
echo -e "${BLUE}Updating Supabase environment configuration...${NC}"

ENV_FILE="$DOCKER_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Warning: .env file not found, creating from .env.default${NC}"
    cp "$DOCKER_DIR/.env.default" "$ENV_FILE"
fi

# Backup .env
cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Update or add HTTPS URLs
if grep -q "^SUPABASE_PUBLIC_URL=" "$ENV_FILE"; then
    sed -i "s|^SUPABASE_PUBLIC_URL=.*|SUPABASE_PUBLIC_URL=https://$DOMAIN|" "$ENV_FILE"
else
    echo "SUPABASE_PUBLIC_URL=https://$DOMAIN" >> "$ENV_FILE"
fi

if grep -q "^API_EXTERNAL_URL=" "$ENV_FILE"; then
    sed -i "s|^API_EXTERNAL_URL=.*|API_EXTERNAL_URL=https://$DOMAIN|" "$ENV_FILE"
else
    echo "API_EXTERNAL_URL=https://$DOMAIN" >> "$ENV_FILE"
fi

echo -e "${GREEN}✓ Environment configuration updated${NC}"

# Restart Supabase
echo -e "${BLUE}Restarting Supabase services...${NC}"
docker compose restart
sleep 5

echo ""
echo -e "${GREEN}=== SSL/TLS Setup Complete ===${NC}"
echo ""
echo "Configuration summary:"
echo "  - Reverse proxy: $PROXY"
echo "  - Domain: $DOMAIN"
echo "  - HTTPS URL: https://$DOMAIN"
echo ""
echo "Next steps:"
echo "  1. Test HTTPS access: curl -I https://$DOMAIN/health"
echo "  2. Update OAuth redirect URIs to use https://$DOMAIN"
echo "  3. Configure production SMTP (see ENHANCEMENT_OPPORTUNITIES.md)"
echo "  4. Review SSL configuration: https://www.ssllabs.com/ssltest/"
echo ""
echo -e "${YELLOW}Important: Update your client applications to use https://$DOMAIN${NC}"

exit 0
