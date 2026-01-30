# Supabase Docker - Self-Hosted Configuration

This is a production-ready Docker Compose setup for self-hosting Supabase with comprehensive security hardening.

## Quick Start

### New Production Deployment

```bash
# 1. Generate production secrets
cd scripts
./generate-secrets.sh

# 2. Generate JWT tokens (follow script output instructions)
# 3. Update production.env with URLs and SMTP
# 4. Validate configuration
./validate-config.sh

# 5. Deploy
cd ..
cp production.env .env
chmod 600 .env
docker compose up -d
```

**Estimated time:** 30-45 minutes

### Existing Deployment (Upgrade/Hardening)

```bash
# Security hardening
cat SECURITY_HARDENING.md

# Kong Gateway upgrade
cat KONG_UPGRADE.md
```

## Documentation

### Core Documentation

| Document | Purpose |
|----------|---------|
| [SECURITY_HARDENING.md](SECURITY_HARDENING.md) | Complete security hardening guide |
| [KONG_UPGRADE.md](KONG_UPGRADE.md) | Kong Gateway 2.8.1 → 3.4 LTS upgrade |
| [ENHANCEMENT_OPPORTUNITIES.md](ENHANCEMENT_OPPORTUNITIES.md) | Production readiness research and recommendations |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Enhancement implementation summary and validation |

### Production Setup Guides

| Guide | Purpose |
|-------|---------|
| [SSL_SETUP_GUIDE.md](SSL_SETUP_GUIDE.md) | SSL/TLS configuration with Nginx or Caddy |
| [SMTP_SETUP_GUIDE.md](SMTP_SETUP_GUIDE.md) | Production SMTP configuration and testing |
| [HEALTH_CHECK_OPTIMIZATION.md](HEALTH_CHECK_OPTIMIZATION.md) | Docker health check optimization guide |
| [LOG_AGGREGATION_GUIDE.md](LOG_AGGREGATION_GUIDE.md) | Centralized logging with Loki + Promtail |

### Scripts Documentation

| Script | Purpose |
|--------|---------|
| [scripts/README.md](scripts/README.md) | Security scripts overview |
| `scripts/generate-secrets.sh` | Generate production secrets |
| `scripts/rotate-secrets.sh` | Zero-downtime secret rotation |
| `scripts/validate-config.sh` | Pre-deployment validation |
| `scripts/setup-ssl.sh` | Automated SSL/TLS setup |
| `scripts/test-smtp.sh` | SMTP configuration testing |
| `scripts/backup-database.sh` | Automated database backups |
| `scripts/restore-database.sh` | Disaster recovery |
| `scripts/verify-health.sh` | Health status monitoring |

## Additional Resources

- **Official Guide**: https://supabase.com/docs/guides/hosting/docker
- **Production Checklist**: https://supabase.com/docs/guides/deployment/going-into-prod
- **Security Best Practices**: https://supabase.com/docs/guides/security/product-security

---

**Last Updated:** January 2026
**Status:** Production Ready with Security Hardening
