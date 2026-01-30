# Supabase Security Hardening

**Full documentation:** [docs/platform/SUPABASE_SECURITY.md](../../docs/platform/SUPABASE_SECURITY.md)

**Implementation location:** `autogpt_platform/db/docker/`

## Security Scripts

| Script | Purpose |
|--------|---------|
| `generate-secrets.sh` | Production secret generation |
| `rotate-secrets.sh` | Zero-downtime rotation |
| `validate-config.sh` | Pre-deployment validation (25+ checks) |

## Secret Rotation Schedule

- JWT_SECRET: 12 months
- POSTGRES_PASSWORD: 6-12 months
- Encryption Key: 12 months

## Quick Commands

```bash
./scripts/generate-secrets.sh   # Generate secrets
./scripts/validate-config.sh    # Validate before deploy
./scripts/rotate-secrets.sh     # Rotate secrets
```
