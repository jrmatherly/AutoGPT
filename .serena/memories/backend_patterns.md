# Backend Design Patterns

**Full documentation:** [docs/development/BACKEND_PATTERNS.md](../../docs/development/BACKEND_PATTERNS.md)

## Quick Reference

| Pattern | Description |
|---------|-------------|
| Block Architecture | `Block` base class, `BlockSchema`, async `run` method |
| Provider Pattern | `ProviderBuilder` for auth configuration |
| Credentials | `CredentialsField` for API keys and OAuth |
| Webhooks | `BlockWebhookConfig` / `BlockManualWebhookConfig` |
| Multiple Outputs | `AsyncGenerator` yield pattern |
| Database | Prisma ORM, transactions, user ID checks |

## Key Anti-Patterns

- ❌ Synchronous I/O in async functions
- ❌ Raw SQL instead of Prisma ORM
- ❌ Missing user ID validation in data layer
- ❌ Hardcoded credentials

## Related Docs

- [BLOCK_SDK.md](../../docs/BLOCK_SDK.md) - Complete block creation guide
- [API_REFERENCE.md](../../docs/API_REFERENCE.md) - API documentation
