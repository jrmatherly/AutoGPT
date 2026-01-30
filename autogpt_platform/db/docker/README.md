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

| Document | Purpose |
|----------|---------|
| [SECURITY_HARDENING.md](SECURITY_HARDENING.md) | Complete security hardening guide |
| [KONG_UPGRADE.md](KONG_UPGRADE.md) | Kong Gateway 2.8.1 → 3.4 LTS upgrade |
| [ENHANCEMENT_OPPORTUNITIES.md](ENHANCEMENT_OPPORTUNITIES.md) | Production readiness and optimization recommendations |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Implementation overview and validation |
| [scripts/README.md](scripts/README.md) | Security scripts documentation |

## Security Scripts

Located in `scripts/`:

- `generate-secrets.sh` - Generate production secrets
- `rotate-secrets.sh` - Zero-downtime secret rotation
- `validate-config.sh` - Pre-deployment validation

See [scripts/README.md](scripts/README.md) for detailed usage.

## Additional Resources

- **Official Guide**: https://supabase.com/docs/guides/hosting/docker
- **Production Checklist**: https://supabase.com/docs/guides/deployment/going-into-prod
- **Security Best Practices**: https://supabase.com/docs/guides/security/product-security

---

**Last Updated:** January 2026
**Status:** Production Ready with Security Hardening
