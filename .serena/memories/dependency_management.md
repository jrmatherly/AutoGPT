# Dependency Management for AutoGPT Platform

## Overview
The AutoGPT platform uses a monorepo structure with different package managers:
- **Frontend**: pnpm (Node.js/TypeScript)
- **Backend**: Poetry (Python)
- **Libs**: Poetry (Python)

## Safe Dependency Updates

All dependency update tasks respect semver constraints to prevent breaking changes:
- **pnpm**: Respects semver ranges in `package.json`
- **Poetry**: Respects caret (^) and tilde (~) constraints in `pyproject.toml`

## Available Mise Tasks

### Check for Outdated Dependencies (Read-Only, Always Safe)

```bash
# Check all projects
mise run deps:check

# Check specific project
mise run deps:check:frontend   # Frontend only
mise run deps:check:backend    # Backend only
mise run deps:check:libs       # Libs only
```

These commands show which dependencies have updates available that are compatible with your current semver constraints.

### Preview Updates (Dry-Run, 100% Safe)

```bash
# Preview updates for all projects
mise run deps:preview

# Preview specific project
mise run deps:preview:frontend   # Frontend only
mise run deps:preview:backend    # Backend only
mise run deps:preview:libs       # Libs only
```

These commands show what would be updated WITHOUT making any changes.

### Apply Updates (Safe, Respects Semver)

```bash
# Update all projects (interactive)
mise run deps:update

# Update specific project
mise run deps:update:frontend   # Interactive pnpm update
mise run deps:update:backend    # Poetry update
mise run deps:update:libs       # Poetry update (remember to rebuild backend)
```

**Safety Guarantees:**
- Frontend: `pnpm update --interactive` allows you to review each update
- Backend/Libs: `poetry update` respects ^ and ~ constraints (no major version jumps)
- No breaking changes unless you explicitly modify version constraints

## Workflow Recommendations

### Regular Maintenance (Weekly/Monthly)
```bash
# 1. Check what's outdated
mise run deps:check

# 2. Preview the changes
mise run deps:preview

# 3. Apply updates
mise run deps:update

# 4. Verify everything works
mise run test
```

### Before Major Features
```bash
# Check for security updates
mise run deps:check

# Apply critical updates
mise run deps:update

# Verify
mise run test
```

### Per-Project Updates
```bash
# Frontend development
mise run deps:check:frontend
mise run deps:update:frontend
mise run test:frontend

# Backend development
mise run deps:check:backend
mise run deps:update:backend
mise run test:backend
```

## Understanding Semver Constraints

### Frontend (package.json)
Most dependencies use exact versions (e.g., `"10.0.0"`), which means:
- `pnpm update` will NOT change them unless you manually edit package.json
- Very safe but requires manual updates

### Backend/Libs (pyproject.toml)
Dependencies use caret (^) constraints (e.g., `"^0.59.0"`), which allows:
- Patch updates: 0.59.0 → 0.59.1 ✅
- Minor updates: 0.59.0 → 0.60.0 ✅
- Major updates: 0.59.0 → 1.0.0 ❌ (blocked)

## Special Cases

### Poetry Version Pin
The backend has a special comment:
```toml
poetry = "2.1.1" # CHECK DEPENDABOT SUPPORT BEFORE UPGRADING
```

This dependency should NOT be updated automatically. Always check Dependabot compatibility first.

### After Updating Libs
When you update `autogpt_libs`, you must rebuild the backend:
```bash
mise run deps:update:libs
cd backend && poetry install
```

## Troubleshooting

### pnpm update shows no updates
- Check `package.json` - you may have exact version pins
- Use `pnpm outdated --long` to see ALL available versions
- Manually edit `package.json` to use semver ranges if desired

### Poetry update fails
- Check `poetry.lock` is committed
- Try `poetry lock --no-update` to refresh lock file
- Check for dependency conflicts with `poetry show --tree`

### Tests fail after updates
- Review the changes: `git diff package.json pyproject.toml poetry.lock`
- Rollback if needed: `git restore package.json pyproject.toml poetry.lock`
- Update one project at a time to isolate issues

## CI/CD Integration

These tasks can be used in CI/CD pipelines:
```bash
# Check for outdated dependencies in CI
mise run deps:check > deps-report.txt

# Preview updates without applying
mise run deps:preview
```

## Best Practices

1. **Check First**: Always run `deps:check` before `deps:update`
2. **Preview Changes**: Use `deps:preview` to understand impact
3. **Test After Updates**: Run `mise run test` after any dependency changes
4. **Update Regularly**: Weekly checks prevent large update backlogs
5. **One Project at a Time**: Update frontend/backend/libs separately for easier debugging
6. **Commit Lock Files**: Always commit `pnpm-lock.yaml` and `poetry.lock`
7. **Review Breaking Changes**: Check changelogs for major updates before applying
