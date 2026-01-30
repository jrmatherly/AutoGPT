# Kong Gateway Upgrade Guide: 2.8.1 → 3.4 LTS

## Overview

This guide walks through upgrading Kong Gateway from version 2.8.1 to 3.4 LTS (Long-Term Support) in your self-hosted Supabase deployment.

**Benefits of Kong 3.4 LTS:**

- FIPS 140-2 compliance for government/finance sectors
- Enhanced secrets management (AWS Secrets Manager, HashiCorp Vault)
- Improved OAuth/OIDC security (JWT-secured authorization, DPoP)
- Reduced container attack surface (debian-slim base)
- Full support until August 2026

**Timeline:** 30-60 minutes (including testing)

---

## Pre-Upgrade Checklist

- [ ] **Backup current configuration**

  ```bash
  cd autogpt_platform/db/docker
  cp docker-compose.yml docker-compose.yml.backup
  cp volumes/api/kong.yml volumes/api/kong.yml.backup
  ```

- [ ] **Backup database**

  ```bash
  docker exec supabase-db pg_dump -U postgres -d postgres > backup_$(date +%Y%m%d).sql
  ```

- [ ] **Document current API endpoints**

  ```bash
  curl http://localhost:8000/ | jq > api-endpoints-before.json
  ```

- [ ] **Review Kong 3.x breaking changes**
  - Read: https://docs.konghq.com/gateway/latest/upgrade/
  - Config format version changes: `2.1` → `3.0`
  - Plugin compatibility updates
  - Deprecated features removal

- [ ] **Test in staging environment** (recommended)

---

## Step 1: Update Kong Service in docker-compose.yml

**File:** `autogpt_platform/db/docker/docker-compose.yml`

### Current Configuration (Lines 65-87)

```yaml
  kong:
    container_name: supabase-kong
    image: kong:2.8.1
    restart: unless-stopped
    ports:
      - 8000:8000/tcp
      - 8443:8443/tcp
    volumes:
      - ./volumes/api/kong.yml:/home/kong/temp.yml:ro
    <<: *supabase-env-files
    environment:
      <<: *supabase-env
      KONG_DATABASE: "off"
      KONG_DECLARATIVE_CONFIG: /home/kong/kong.yml
      KONG_DNS_ORDER: LAST,A,CNAME
      KONG_PLUGINS: request-transformer,cors,key-auth,acl,basic-auth
      KONG_NGINX_PROXY_PROXY_BUFFER_SIZE: 160k
      KONG_NGINX_PROXY_PROXY_BUFFERS: 64 160k
    entrypoint: bash -c 'eval "echo \"$$(cat ~/temp.yml)\"" > ~/kong.yml && /docker-entrypoint.sh kong docker-start'
```

### Updated Configuration (Kong 3.4)

```yaml
  kong:
    container_name: supabase-kong
    image: kong:3.4  # Updated version
    restart: unless-stopped
    ports:
      - 8000:8000/tcp
      - 8443:8443/tcp
    volumes:
      - ./volumes/api/kong.yml:/home/kong/temp.yml:ro
    <<: *supabase-env-files
    environment:
      <<: *supabase-env
      KONG_DATABASE: "off"
      KONG_DECLARATIVE_CONFIG: /home/kong/kong.yml
      KONG_DNS_ORDER: LAST,A,CNAME
      KONG_PLUGINS: request-transformer,cors,key-auth,acl,basic-auth
      KONG_NGINX_PROXY_PROXY_BUFFER_SIZE: 160k
      KONG_NGINX_PROXY_PROXY_BUFFERS: 64 160k
      # Kong 3.x: Disable deprecated legacy router (use expressions router)
      KONG_ROUTER_FLAVOR: expressions
    entrypoint: bash -c 'eval "echo \"$$(cat ~/temp.yml)\"" > ~/kong.yml && /docker-entrypoint.sh kong docker-start'
```

**Changes:**

1. Image: `kong:2.8.1` → `kong:3.4`
2. Added: `KONG_ROUTER_FLAVOR: expressions` (Kong 3.x default)

---

## Step 2: Update Kong Configuration Format

**File:** `autogpt_platform/db/docker/volumes/api/kong.yml`

### Update Format Version (Line 1)

**Before:**

```yaml
_format_version: '2.1'
```

**After:**

```yaml
_format_version: '3.0'
```

### Configuration Validation

Kong 3.0 introduced stricter validation. Verify your configuration:

1. **Consumer credentials** (Lines 8-14) - No changes needed
2. **ACLs** (Lines 19-24) - No changes needed
3. **Basic auth** (Lines 28-32) - No changes needed
4. **Services and routes** (Lines 36-242) - Review plugin configurations

### Plugin Compatibility

All plugins in your current configuration are compatible with Kong 3.4:

- ✅ `cors`
- ✅ `key-auth`
- ✅ `acl`
- ✅ `request-transformer`
- ✅ `basic-auth`
- ✅ `request-termination`
- ✅ `ip-restriction`

---

## Step 3: Enhanced Security Configuration (Optional)

Add rate limiting to protect against abuse:

**Add to kong.yml after line 46 (auth-v1-open-callback service):**

```yaml
  - name: auth-v1-open-callback
    url: http://auth:9999/callback
    routes:
      - name: auth-v1-open-callback
        strip_path: true
        paths:
          - /auth/v1/callback
    plugins:
      - name: cors
      # NEW: Add rate limiting
      - name: rate-limiting
        config:
          minute: 60
          hour: 1000
          policy: local
```

**Add rate limiting to sensitive endpoints:**

```yaml
  # Add to auth-v1 service (around line 76)
  - name: rate-limiting
    config:
      minute: 100
      hour: 5000
      policy: local

  # Add to rest-v1 service (around line 97)
  - name: rate-limiting
    config:
      minute: 200
      hour: 10000
      policy: local
```

---

## Step 4: Upgrade Execution

### 4.1 Pull New Kong Image

```bash
cd autogpt_platform/db/docker
docker compose pull kong
```

Expected output:

```docker
[+] Pulling 1/1
 ✔ kong Pulled
```

### 4.2 Stop Current Services

```bash
docker compose down
```

### 4.3 Validate Configuration

Before starting, validate the updated kong.yml:

```bash
docker run --rm -v $(pwd)/volumes/api/kong.yml:/kong.yml kong:3.4 \
  kong config parse /kong.yml
```

Expected output:

```bash
parse successful
```

### 4.4 Start with New Kong Version

```bash
docker compose up -d
```

### 4.5 Monitor Startup

```bash
# Watch Kong logs
docker compose logs -f kong

# Check health status
docker compose ps
```

Wait for Kong to show status: `Up (healthy)`

---

## Step 5: Post-Upgrade Validation

### 5.1 Verify Kong Version

```bash
docker exec supabase-kong kong version
```

Expected output:

```bash
Kong 3.4.x
```

### 5.2 Test API Endpoints

**Test anonymous access (should work):**

```bash
curl http://localhost:8000/auth/v1/health
```

**Test authenticated endpoint:**

```bash
# Replace with your ANON_KEY
curl -H "apikey: YOUR_ANON_KEY" http://localhost:8000/rest/v1/
```

**Test Studio access:**

```bash
# Should prompt for basic auth
curl -I http://localhost:8000/
```

### 5.3 Verify All Services

```bash
docker compose ps
```

All services should show `Up (healthy)`:

- ✅ supabase-studio
- ✅ supabase-kong
- ✅ supabase-auth
- ✅ supabase-rest
- ✅ supabase-realtime
- ✅ supabase-storage
- ✅ supabase-db
- ✅ supabase-pooler
- ✅ (other services)

### 5.4 Compare API Response

```bash
curl http://localhost:8000/ | jq > api-endpoints-after.json
diff api-endpoints-before.json api-endpoints-after.json
```

Should show no differences in API structure.

---

## Step 6: Testing Checklist

- [ ] **Studio Dashboard** - Access http://localhost:8000/ with basic auth
- [ ] **Authentication**
  - [ ] Sign up new user
  - [ ] Sign in existing user
  - [ ] Password reset flow
- [ ] **Database API (PostgREST)**
  - [ ] SELECT queries
  - [ ] INSERT operations
  - [ ] UPDATE operations
  - [ ] DELETE operations
- [ ] **Realtime**
  - [ ] WebSocket connections
  - [ ] Database changes broadcast
- [ ] **Storage**
  - [ ] File upload
  - [ ] File download
  - [ ] Pre-signed URLs
- [ ] **Edge Functions**
  - [ ] Function invocation
  - [ ] Function response

---

## Rollback Procedure

If issues occur during upgrade:

### 1. Stop Services

```bash
docker compose down
```

### 2. Restore Configuration

```bash
cp docker-compose.yml.backup docker-compose.yml
cp volumes/api/kong.yml.backup volumes/api/kong.yml
```

### 3. Pull Original Kong Image

```bash
docker compose pull kong
```

### 4. Restart Services

```bash
docker compose up -d
```

### 5. Verify Rollback

```bash
docker exec supabase-kong kong version
# Should show Kong 2.8.1

docker compose ps
# All services should be healthy
```

---

## Common Issues & Solutions

### Issue: Kong fails to start with "invalid config"

**Symptom:**

```bash
Error: /kong.yml:1: unknown field '_format_version' (strict mode)
```

**Solution:**
Ensure `_format_version: '3.0'` is properly formatted with quotes.

---

### Issue: Plugins not loading

**Symptom:**

```bash
Error: plugin 'rate-limiting' not enabled
```

**Solution:**
Add plugin to `KONG_PLUGINS` environment variable in docker-compose.yml:

```yaml
KONG_PLUGINS: request-transformer,cors,key-auth,acl,basic-auth,rate-limiting
```

---

### Issue: Routes not matching

**Symptom:**

```bash
HTTP 404 - no Route matched with those values
```

**Solution:**
Kong 3.x uses expressions router by default. If using traditional routes, ensure paths are properly defined:

```yaml
routes:
  - name: my-route
    paths:
      - /exact/path  # Exact match
```

---

### Issue: Container keeps restarting

**Symptom:**

```bash
docker compose ps
# Shows: Restarting (1)
```

**Solution:**

```bash
# Check logs for specific error
docker compose logs kong

# Validate configuration
docker run --rm -v $(pwd)/volumes/api/kong.yml:/kong.yml kong:3.4 \
  kong config parse /kong.yml
```

---

## Performance Tuning (Optional)

Kong 3.4 includes performance improvements. Consider these optimizations:

### Enable DNS Caching

**Add to docker-compose.yml kong environment:**

```yaml
KONG_DNS_STALE_TTL: 3600  # Cache DNS for 1 hour
KONG_DNS_NOT_FOUND_TTL: 30  # Cache negative DNS responses
```

### Adjust Worker Processes

**For production:**

```yaml
KONG_NGINX_WORKER_PROCESSES: auto  # Match CPU cores
```

### Enable Prometheus Metrics (for monitoring)

**Add plugin to kong.yml:**

```yaml
plugins:
  - name: prometheus
    config:
      per_consumer: true
      status_code_metrics: true
      latency_metrics: true
```

**Expose metrics port:**

```yaml
# docker-compose.yml
ports:
  - 8000:8000/tcp
  - 8443:8443/tcp
  - 8001:8001/tcp  # Admin API
```

---

## Additional Resources

- **Kong 3.4 Release Notes**: https://konghq.com/blog/product-releases/gateway-3-4-enterprise-and-konnect
- **Kong Upgrade Guide**: https://docs.konghq.com/gateway/latest/upgrade/
- **Kong 3.x Configuration Reference**: https://docs.konghq.com/gateway/latest/reference/configuration/
- **Kong Support Policy**: https://docs.konghq.com/gateway/latest/support-policy/
- **Supabase Self-Hosting**: https://supabase.com/docs/guides/self-hosting/docker

---

## Success Criteria

✅ Upgrade is successful when:

1. Kong version shows `3.4.x`
2. All services are healthy (`docker compose ps`)
3. API endpoints respond correctly
4. Studio dashboard is accessible
5. Authentication flows work
6. Database operations succeed
7. No errors in Kong logs
8. Rate limiting works (if configured)

---

## Next Steps After Upgrade

1. **Monitor for 24-48 hours** - Watch logs and metrics
2. **Update documentation** - Record upgrade date and any issues
3. **Plan next upgrade** - Kong 3.4 LTS supported until August 2026
4. **Security hardening** - Implement rate limiting if not done
5. **Performance baseline** - Establish metrics for comparison

---

**Upgrade prepared by:** Supabase Configuration Analysis
**Date:** January 2026
**Kong Version:** 2.8.1 → 3.4 LTS
**Estimated Downtime:** 2-5 minutes
