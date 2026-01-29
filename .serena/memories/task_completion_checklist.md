# Task Completion Checklist

## Before Committing

### Quick Check (Mise)
- [ ] Run `mise run format` (formats both backend + frontend)
- [ ] Run `mise run lint` (lints both backend + frontend)
- [ ] Run `mise run test` (tests both backend + frontend)

### Backend Changes (Detailed)
- [ ] Format: `poetry run format` or `mise run format`
- [ ] Lint: `poetry run lint` or `mise run lint`
- [ ] Test: `poetry run test` or `mise run test:backend`
- [ ] Update snapshots if needed: `poetry run pytest --snapshot-update`
- [ ] Verify Prisma schema if database changes: `poetry run prisma generate`

### Frontend Changes (Detailed)
- [ ] Format: `pnpm format` or `mise run format`
- [ ] Lint: `pnpm lint` or `mise run lint`
- [ ] Type check: `pnpm types`
- [ ] Test: `pnpm test` or `mise run test:frontend`
- [ ] Regenerate API client if backend API changed: `pnpm generate:api`
- [ ] Verify in Storybook if UI changed: `pnpm storybook`

### General
- [ ] Pre-commit hooks pass: `pre-commit run --all-files`
- [ ] No secrets or sensitive data in code
- [ ] No hardcoded values that should be configurable
- [ ] Environment check: `mise run doctor` (optional but helpful)

## Code Quality Checks

### Backend
- ✅ Type hints present and correct
- ✅ Async/await used appropriately
- ✅ Error handling is meaningful
- ✅ Tests cover new functionality
- ✅ No new `any` types or unsafe casts
- ✅ User ID validation in data layer operations
- ✅ Prisma ORM used (no raw SQL)

### Frontend
- ✅ Function declarations for components (not arrow functions)
- ✅ Logic separated into hooks (`use*.ts`) and helpers
- ✅ Using design system components (not `__legacy__`)
- ✅ Using generated API hooks (not `BackendAPI`)
- ✅ Using Phosphor Icons only
- ✅ Tailwind CSS with design tokens
- ✅ No `useCallback`/`useMemo` unless strictly needed
- ✅ No barrel files or index.ts re-exports
- ✅ Props interfaces not exported unless needed externally

## Pull Request Checklist

- [ ] Branch created from `dev`
- [ ] Descriptive branch name (e.g., `feature/add-new-block`)
- [ ] Conventional commit format: `type(scope): description`
- [ ] PR template filled out completely
- [ ] Out-of-scope changes under 20%
- [ ] Tests added/updated for new functionality
- [ ] Documentation updated if API changed

## Adding New Blocks (Backend)

1. [ ] Create file in `backend/backend/blocks/`
2. [ ] Configure provider using `ProviderBuilder` in `_config.py` (if needed)
3. [ ] Inherit from `Block` base class
4. [ ] Define input/output schemas using `BlockSchema`
5. [ ] Implement async `run` method
6. [ ] Generate unique block ID: `id = str(uuid.uuid4())`
7. [ ] Add test data: `test_input`, `test_output`, `test_credentials`
8. [ ] Test: `poetry run pytest backend/blocks/test/test_block.py -xvs`
9. [ ] Verify block works in graph editor UI

**Reference:** See `backend_patterns` memory for detailed block patterns.

## Modifying API

1. [ ] Update route in `backend/api/features/`
2. [ ] Add/update Pydantic request/response models
3. [ ] Write tests colocated with route file
4. [ ] Run backend tests: `poetry run test` or `mise run test:backend`
5. [ ] Regenerate frontend API client: `cd frontend && pnpm generate:api`
6. [ ] Verify frontend uses new/updated API correctly

## Database Changes

1. [ ] Update `schema.prisma` with new models/fields
2. [ ] Create migration: `poetry run prisma migrate dev --name descriptive_name`
3. [ ] Generate Prisma client: `poetry run prisma generate`
4. [ ] Generate type stubs: `poetry run gen-prisma-stub`
5. [ ] Update data layer operations in `backend/data/`
6. [ ] Verify user ID checks in new data operations
7. [ ] Test migrations: `mise run db:reset` (resets and re-runs all migrations)

## Security Considerations

- [ ] No sensitive data cached (middleware handles caching)
- [ ] User ID checks in place for all `data/*.py` operations
- [ ] Protected routes updated in `frontend/lib/supabase/middleware.ts`
- [ ] File uploads use ClamAV virus scanning
- [ ] No hardcoded API keys or credentials
- [ ] OAuth scopes properly defined for integration blocks
- [ ] Input validation for all API endpoints

## Documentation

- [ ] Update `docs/` if architecture changed
- [ ] Update `CLAUDE.md` if development patterns changed
- [ ] Update `README.md` if setup instructions changed
- [ ] Add Storybook stories for new UI components
- [ ] Update block documentation in `docs/integrations/` if applicable

## Mise-Specific Checks

**Development environment:**
- [ ] Tool versions match `mise.lock`: `mise ls`
- [ ] Environment healthy: `mise run doctor`

**After major changes:**
- [ ] Drift pattern check: `mise run drift:check`
- [ ] Drift scan for new patterns: `mise run drift:scan`
