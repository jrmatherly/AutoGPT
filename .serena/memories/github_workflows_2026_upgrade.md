# GitHub Workflows - January 2026 Updates

## Latest: Workflow Consolidation (2026-01-29) ✅ COMPLETE

### Summary

Completed comprehensive workflow consolidation eliminating duplicate CI execution and implementing path-based conditional testing.

### Changes Implemented

**Phase 1 - Consolidation:**
- ✅ Deleted `ci.yml` (31 lines - basic version)
- ✅ Deleted `ci.enhanced.yml` (49 lines - enhanced version)
- ✅ Deleted `claude-dependabot.yml` (300+ lines - deprecated)
- ✅ Renamed `ci-mise.yml` → `ci.yml` (comprehensive 382-line version)
- ✅ Standardized mise version to 2026.1.9 across all workflows

**Phase 2 - Path-Based Conditionals:**
- ✅ Added path detection using `dorny/paths-filter@v3`
- ✅ Backend tests conditional on `backend/**` or `autogpt_libs/**` changes
- ✅ Frontend tests conditional on `frontend/**` changes
- ✅ Updated CI success gate to handle skipped jobs

### Impact Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Duplicate CI workflows | 3 | 1 | -66% |
| CI runs per PR | 3-6 | 1-2 | -50-66% |
| Duplicate code | ~600 lines | ~200 lines | -67% |
| Mise versions | 2 different | 1 unified | Standardized ✅ |

### Behavior Changes

**Before:** Every PR triggered 3 identical CI workflows (ci.yml, ci.enhanced.yml, ci-mise.yml)

**After:** 
- Backend-only PR: Runs lint + backend tests (frontend skipped)
- Frontend-only PR: Runs lint + frontend tests (backend skipped)
- Docs-only PR: Runs lint only (both tests skipped)
- Full-stack PR: Runs all jobs

### Documentation Created

All documentation properly located in `docs/github/workflows/`:
- `DUPLICATION_ANALYSIS_2026.md` - Comprehensive validation report
- `CLEANUP_PLAN_2026.md` - Implementation plan
- `VALIDATION_SUMMARY_2026.md` - Quick reference
- `IMPLEMENTATION_COMPLETE.md` - Full implementation record
- `PRE_IMPLEMENTATION_VALIDATION.md` - Pre-flight checks

### Testing Recommendations

Before merging to master:
1. Test backend-only PR (verify frontend tests skip)
2. Test frontend-only PR (verify backend tests skip)
3. Test docs-only PR (verify all tests skip except lint)
4. Test full-stack PR (verify all jobs run)

### Decision: Preserved platform-fullstack-ci.yml

**Kept separate** (not consolidated into frontend-ci) because:
- Provides unique API schema validation
- Spins up full docker stack to validate backend/frontend integration
- Detects when API schema changes without frontend updates
- Complementary to frontend-ci, not duplicative

---

## Previous: Action Version Upgrades (2026-01-29)

### Action Version Updates

| Action | Old | New | Status |
|--------|-----|-----|--------|\n| actions/checkout | v4 | v6 | ✅ Updated (6 files) |
| actions/setup-python | v5 | v6 | ✅ Updated (3 files) |
| actions/setup-node | v4 | v6 | ✅ Updated (2 files) |
| actions/cache | v4 | v5 | ✅ Updated (2 files) |
| actions/github-script | v7 | v8 | ✅ Updated (1 file) |
| peter-evans/repository-dispatch | v3 | v4 | ✅ Updated (3 files) |
| supabase/setup-cli | 1.178.1 | latest | ✅ Updated (1 file) |

### Files Modified

**Target Workflows:**
1. `.github/workflows/platform-autogpt-deploy-dev.yaml`
2. `.github/workflows/platform-autogpt-deploy-prod.yml`
3. `.github/workflows/platform-backend-ci.yml`
4. `.github/workflows/platform-dev-deploy-event-dispatcher.yml`
5. `.github/workflows/platform-frontend-ci.yml`
6. `.github/workflows/platform-fullstack-ci.yml`

### New Files Created
1. `.github/actions/prisma-migrate/action.yml` - Composite action for migrations
2. `docs/github/workflows/UPGRADE_NOTES_2026.md` - Complete upgrade documentation

### Key Improvements

1. **Eliminated Duplication** - Composite action for Prisma migrations
2. **Built-in Caching** - setup-python@v6 automatic caching
3. **Python 3.13** - Updated to project standard
4. **Security** - Concurrency controls and job-level permissions
5. **Supabase CLI** - Updated to latest version

### Breaking Changes

**actions/setup-python@v6:**
- Requires runner v2.327.1+ for Node 24 support
- Cache key format changed (architecture added)
- First run will rebuild caches (2-5 min), subsequent runs fast (10-30s)

### Composite Action

**Location:** `.github/actions/prisma-migrate/action.yml`

**Usage:**
```yaml
- name: Run Prisma migrations
  uses: ./.github/actions/prisma-migrate
  with:
    python-version: "3.13"
    database-url: ${{ secrets.BACKEND_DATABASE_URL }}
    git-ref: ${{ github.ref_name }}
```

---

## Root mise.toml Compatibility

The project has a workspace root `/mise.toml` that:
- Defines the same tools (python 3.13, node 22, pnpm 10.28.2)
- Delegates all tasks to `autogpt_platform/mise.toml`
- Allows running mise tasks from workspace root

**GitHub Workflows Compatibility:** ✅ All workflows remain fully compatible

**Current Pattern:**
```yaml
- name: Setup mise
  uses: jdx/mise-action@v3
  with:
    working_directory: autogpt_platform  # ✅ Still works
```

---

## References

- **Consolidation Report:** `docs/github/workflows/IMPLEMENTATION_COMPLETE.md`
- **Upgrade Documentation:** `docs/github/workflows/UPGRADE_NOTES_2026.md`
- **Workflow Guide:** `docs/github/workflows/WORKFLOWS.md`
- **Project Python Version:** `mise.toml` (python = "3.13")
- **Composite Action:** `.github/actions/prisma-migrate/action.yml`

## Lessons Learned

1. **Validation First:** Comprehensive pre-implementation validation prevents issues
2. **Path-Based Filtering:** `dorny/paths-filter` works excellently for conditional jobs
3. **Preserve Unique Value:** Don't consolidate workflows with unique functionality (API schema validation)
4. **Documentation Location:** GitHub workflow docs belong in `docs/github/workflows/`, not `.github/workflows/`
5. **Git Operations:** Use regular `rm`/`mv` commands, not `git rm`/`git mv`, when working with workflow files
6. **Success Gates:** When adding conditional jobs, success gates must handle skipped jobs properly

## Status

✅ **Workflow Consolidation: COMPLETE (2026-01-29)**
✅ **Action Upgrades: COMPLETE (2026-01-29)**
✅ **Documentation: Properly organized in docs/github/workflows/**
✅ **Ready for testing and deployment**
