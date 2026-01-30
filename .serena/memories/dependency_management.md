# Dependency Management

**Full reference:** See [autogpt_platform/CLAUDE.md](../../autogpt_platform/CLAUDE.md#dependency-management)

## Package Managers

| Project | Manager | Lock File |
|---------|---------|-----------|
| Frontend | pnpm | `pnpm-lock.yaml` |
| Backend | Poetry | `poetry.lock` |
| Libs | Poetry | `poetry.lock` |

## Safe Update Commands

All commands respect semver constraints (no breaking changes):

```bash
# Check outdated (read-only)
mise run deps:check

# Preview updates (dry-run)
mise run deps:preview

# Apply updates
mise run deps:update

# Verify
mise run test
```

## Recommended Workflow

1. `mise run deps:check` - See what's outdated
2. `mise run deps:preview` - Preview changes
3. `mise run deps:update` - Apply updates
4. `mise run test` - Verify everything works
