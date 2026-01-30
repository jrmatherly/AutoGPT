# Frontend Design Patterns

**Full documentation:** [docs/development/FRONTEND_PATTERNS.md](../../docs/development/FRONTEND_PATTERNS.md)

## Quick Reference

| Pattern | Description |
|---------|-------------|
| Component | Separate `.tsx` (render) + `use*.ts` (logic) + `helpers.ts` |
| Data Fetching | Generated React Query hooks from `@/app/api/__generated__/` |
| State | React Query (server), useState (local), Zustand (complex flows) |
| Error Handling | ErrorCard (render), Toast (mutations), Sentry (exceptions) |

## Key Anti-Patterns

- Using `BackendAPI` or `autogpt-server-api` (deprecated)
- Using `__legacy__` components
- Using icons other than Phosphor
- Arrow functions for components
- Barrel files / index.ts re-exports

## Related Docs

- [frontend/CONTRIBUTING.md](../../autogpt_platform/frontend/CONTRIBUTING.md) - Complete frontend guide
- [frontend/.cursorrules](../../autogpt_platform/frontend/.cursorrules) - IDE conventions
