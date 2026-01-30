# Supabase Security Hardening

## Overview

Comprehensive security hardening for self-hosted Supabase deployment including automated secret generation, validation, rotation, and Kong Gateway upgrade path.

**Location:** `autogpt_platform/db/docker/`

## Security Scripts

| Script | Purpose |
|--------|---------|
| `scripts/generate-secrets.sh` | Generate JWT_SECRET, POSTGRES_PASSWORD, encryption keys |
| `scripts/rotate-secrets.sh` | Zero-downtime secret rotation (interactive + CLI modes) |
| `scripts/validate-config.sh` | Pre-deployment validation (25+ security checks) |

## Secret Rotation Schedule

| Secret | Recommended Interval |
|--------|---------------------|
| JWT_SECRET | 12 months |
| POSTGRES_PASSWORD | 6-12 months |
| Encryption Key | 12 months |

## Quick Reference

### Generate Production Secrets
```bash
cd autogpt_platform/db/docker
./scripts/generate-secrets.sh
```

### Validate Configuration
```bash
./scripts/validate-config.sh
# Exit 0 = ready, Exit 1 = errors found
```

### Rotate Secrets
```bash
./scripts/rotate-secrets.sh --secret jwt      # Rotate JWT
./scripts/rotate-secrets.sh --secret postgres # Rotate DB password
```

## Documentation

- `autogpt_platform/db/docker/SECURITY_HARDENING.md` - Complete production deployment workflow
- `autogpt_platform/db/docker/KONG_UPGRADE.md` - Kong Gateway migration guide
- `autogpt_platform/db/docker/scripts/README.md` - Script documentation

## Kong Gateway

Current: Kong 2.8.1 → Upgrade path to Kong 3.4 LTS documented in `KONG_UPGRADE.md`.

Key changes:
- Configuration format: `_format_version: 2.1` → `3.0`
- See upgrade guide for step-by-step migration
