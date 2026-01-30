# SSL/TLS Setup Guide for Supabase Self-Hosted

This guide provides step-by-step instructions for enabling HTTPS on your self-hosted Supabase deployment using either Nginx or Caddy as a reverse proxy.

## Prerequisites

- Domain name pointing to your server's IP address
- Root/sudo access to the server
- Supabase running on localhost:8000
- Ports 80 and 443 available

## Table of Contents

1. [Option A: Nginx (Recommended)](#option-a-nginx-recommended)
2. [Option B: Caddy (Simpler)](#option-b-caddy-simpler)
3. [Post-Installation Configuration](#post-installation-configuration)
4. [Testing](#testing)
5. [Troubleshooting](#troubleshooting)

---

## Option A: Nginx (Recommended)

Nginx is the recommended choice for production deployments due to its maturity, extensive documentation, and widespread adoption.

### Step 1: Install Nginx and Certbot

```bash
# Update package list
sudo apt-get update

# Install Nginx and Certbot
sudo apt-get install -y nginx certbot python3-certbot-nginx

# Verify installation
nginx -v
certbot --version
```

### Step 2: Configure Nginx

```bash
# Copy the configuration file
sudo cp nginx/supabase.conf /etc/nginx/sites-available/supabase

# Edit the configuration to use your domain
sudo nano /etc/nginx/sites-available/supabase
# Replace 'api.yourdomain.com' with your actual domain (3 occurrences)
```

### Step 3: Obtain SSL Certificate

```bash
# Obtain and install Let's Encrypt certificate
sudo certbot --nginx -d api.yourdomain.com

# Follow the prompts:
# - Enter email address
# - Agree to Terms of Service
# - Choose whether to share email with EFF
# - Certbot will automatically configure SSL in your Nginx config
```

### Step 4: Enable the Site

```bash
# Create symbolic link to enable site
sudo ln -s /etc/nginx/sites-available/supabase /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# If test passes, reload Nginx
sudo systemctl reload nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx
```

### Step 5: Verify Auto-Renewal

```bash
# Test certificate auto-renewal (dry run)
sudo certbot renew --dry-run

# If successful, the certificate will automatically renew before expiration
```

**Certificate Renewal:** Certbot installs a systemd timer that automatically renews certificates. Check status with:

```bash
sudo systemctl status certbot.timer
```

---

## Option B: Caddy (Simpler)

Caddy automatically obtains and renews SSL certificates, making it the simplest option.

### Step 1: Install Caddy

```bash
# Add Caddy repository
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | \
    sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | \
    sudo tee /etc/apt/sources.list.d/caddy-stable.list

# Update and install
sudo apt update
sudo apt install caddy

# Verify installation
caddy version
```

### Step 2: Configure Caddy

```bash
# Backup default configuration
sudo mv /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup

# Copy Supabase configuration
sudo cp caddy/Caddyfile /etc/caddy/Caddyfile

# Edit the configuration to use your domain
sudo nano /etc/caddy/Caddyfile
# Replace 'api.yourdomain.com' with your actual domain
```

### Step 3: Start Caddy

```bash
# Start Caddy service
sudo systemctl start caddy

# Enable Caddy to start on boot
sudo systemctl enable caddy

# Check status
sudo systemctl status caddy
```

**That's it!** Caddy automatically obtains the SSL certificate and handles renewals.

---

## Post-Installation Configuration

After setting up SSL/TLS with either Nginx or Caddy, update your Supabase environment configuration.

### Update Environment Variables

Edit your environment file:

```bash
cd /path/to/autogpt_platform/db/docker
nano .env
```

Update the following variables:

```bash
# Public API URL (used by clients)
SUPABASE_PUBLIC_URL=https://api.yourdomain.com
API_EXTERNAL_URL=https://api.yourdomain.com

# Site URL (used for redirects after authentication)
SITE_URL=https://app.yourdomain.com

# Update JWT settings if needed
JWT_SECRET=<your-existing-jwt-secret>
```

### Restart Supabase Services

```bash
# Restart all services to pick up new environment variables
docker compose restart

# Verify services are running
docker compose ps
```

### Update OAuth Redirect URIs

If you're using OAuth providers (Google, GitHub, etc.), update redirect URIs in provider settings:

**Old (development):**

```url
http://localhost:8000/auth/v1/callback
```

**New (production):**

```url
https://api.yourdomain.com/auth/v1/callback
```

---

## Testing

### Test HTTPS Connection

```bash
# Test SSL certificate
curl -I https://api.yourdomain.com/health

# Should return 200 OK with security headers
```

### Test HTTP Redirect

```bash
# Test HTTP to HTTPS redirect
curl -I http://api.yourdomain.com

# Should return 301 redirect to HTTPS
```

### Test WebSocket Connection

```bash
# Install wscat if needed
npm install -g wscat

# Test Realtime WebSocket connection
wscat -c "wss://api.yourdomain.com/realtime/v1/websocket?apikey=YOUR_ANON_KEY"
```

### SSL Labs Test

For a comprehensive SSL/TLS security assessment:

1. Visit: https://www.ssllabs.com/ssltest/
2. Enter your domain: `api.yourdomain.com`
3. Wait for scan to complete (2-3 minutes)
4. Aim for an **A** or **A+** rating

---

## Troubleshooting

### Certificate Issuance Fails

**Problem:** Certbot cannot obtain certificate

**Solutions:**

1. Verify DNS records:

   ```bash
   dig api.yourdomain.com
   ```

2. Check port 80 is accessible:

   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

3. Check Nginx is not blocking Let's Encrypt:

   ```bash
   sudo nginx -t
   tail -f /var/log/nginx/error.log
   ```

### 502 Bad Gateway

**Problem:** Nginx shows 502 Bad Gateway error

**Solutions:**

1. Verify Supabase is running:

   ```bash
   docker compose ps
   curl http://localhost:8000/health
   ```

2. Check Nginx logs:

   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

3. Verify proxy_pass configuration:

   ```bash
   sudo cat /etc/nginx/sites-enabled/supabase | grep proxy_pass
   ```

### WebSocket Connection Fails

**Problem:** Realtime subscriptions not working

**Solutions:**

1. Verify WebSocket headers in Nginx config:

   ```nginx
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade";
   ```

2. Check browser console for errors

3. Test with wscat (see Testing section)

### Caddy Not Starting

**Problem:** Caddy service fails to start

**Solutions:**

1. Check Caddy logs:

   ```bash
   sudo journalctl -u caddy --no-pager | tail -20
   ```

2. Validate Caddyfile syntax:

   ```bash
   caddy validate --config /etc/caddy/Caddyfile
   ```

3. Check port availability:

   ```bash
   sudo lsof -i :80
   sudo lsof -i :443
   ```

---

## Security Best Practices

### Regular Updates

```bash
# Update Nginx
sudo apt-get update && sudo apt-get upgrade nginx

# Update Caddy
sudo apt-get update && sudo apt-get upgrade caddy

# Update Certbot
sudo apt-get update && sudo apt-get upgrade certbot
```

### Monitor Certificate Expiration

Nginx/Certbot:

```bash
# Check certificate expiration
sudo certbot certificates

# Manual renewal (if needed)
sudo certbot renew
```

Caddy automatically renews certificates - no action needed.

### Firewall Configuration

```bash
# Allow only necessary ports
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Disable Direct Access to Port 8000

Update `docker-compose.yml` to bind Kong to localhost only:

```yaml
services:
  kong:
    ports:
      - "127.0.0.1:8000:8000"  # Only accessible from localhost
```

This ensures all traffic goes through the reverse proxy.

---

## Additional Resources

- [Supabase Self-Hosting Docker Guide](https://supabase.com/docs/guides/self-hosting/docker)
- [Nginx SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [SSL Labs Best Practices](https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)

---

## Summary

You have now configured SSL/TLS for your self-hosted Supabase deployment. Key outcomes:

✅ HTTPS enabled with automatic certificate management
✅ HTTP to HTTPS redirect configured
✅ WebSocket support for Realtime
✅ Security headers configured
✅ Production-ready SSL/TLS configuration

**Next Steps:**

1. Configure production SMTP (see `ENHANCEMENT_OPPORTUNITIES.md` section 2)
2. Verify monitoring is operational
3. Test authentication flows with HTTPS URLs
4. Update any client applications to use HTTPS endpoints
