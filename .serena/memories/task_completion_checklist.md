# Task Completion Checklist

## Before Committing

### Backend Changes
- [ ] Run `poetry run format` (Black + isort)
- [ ] Run `poetry run lint` (Ruff)
- [ ] Run `poetry run test` or relevant test subset
- [ ] Update snapshots if needed: `poetry run pytest --snapshot-update`
- [ ] Verify Prisma schema if database changes: `poetry run prisma generate`

### Frontend Changes
- [ ] Run `pnpm format` (Prettier + ESLint fix)
- [ ] Run `pnpm lint` (ESLint check)
- [ ] Run `pnpm types` (TypeScript check)
- [ ] Run `pnpm test` (Playwright E2E) or `pnpm test:unit`
- [ ] Regenerate API client if backend API changed: `pnpm generate:api`
- [ ] Verify in Storybook if UI changed: `pnpm storybook`

### Both
- [ ] Pre-commit hooks pass: `pre-commit run --all-files`
- [ ] No secrets or sensitive data in code
- [ ] No hardcoded values that should be configurable

## Code Quality Checks

### Backend
- Type hints present and correct
- Async/await used appropriately
- Error handling is meaningful
- Tests cover new functionality
- No new `any` types or unsafe casts

### Frontend
- Function declarations for components (not arrow functions)
- Logic separated into hooks (`use*.ts`) and helpers
- Using design system components (not `__legacy__`)
- Using generated API hooks (not `BackendAPI`)
- Using Phosphor Icons only
- Tailwind CSS with design tokens
- No `useCallback`/`useMemo` unless strictly needed
- No barrel files or index.ts re-exports

## Pull Request Checklist

- [ ] Branch created from `dev`
- [ ] Descriptive branch name (e.g., `feature/add-new-block`)
- [ ] Conventional commit message format
- [ ] PR template filled out completely
- [ ] Out-of-scope changes under 20%
- [ ] Tests added/updated for new functionality
- [ ] Documentation updated if API changed

## Adding New Blocks (Backend)

1. [ ] Create file in `/backend/backend/blocks/`
2. [ ] Configure provider using `ProviderBuilder` in `_config.py`
3. [ ] Inherit from `Block` base class
4. [ ] Define input/output schemas using `BlockSchema`
5. [ ] Implement async `run` method
6. [ ] Generate unique block ID using `uuid.uuid4()`
7. [ ] Test: `poetry run pytest backend/blocks/test/test_block.py`
8. [ ] Verify block interfaces connect well in graph editor

## Modifying API

1. [ ] Update route in `/backend/backend/server/routers/`
2. [ ] Add/update Pydantic models
3. [ ] Write tests alongside route file
4. [ ] Run `poetry run test`
5. [ ] Frontend: regenerate API client with `pnpm generate:api`

## Security Considerations

- [ ] No sensitive data cached (middleware handles this)
- [ ] User ID checks in place for `data/*.py` changes
- [ ] Protected routes updated in `frontend/lib/supabase/middleware.ts`
- [ ] File uploads validated (ClamAV integration)

## Documentation

- [ ] AGENTS.md updated if agent instructions changed
- [ ] CLAUDE.md updated if development patterns changed
- [ ] README updated if setup instructions changed
- [ ] Storybook stories added for new UI components
