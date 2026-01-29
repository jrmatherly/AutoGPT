# GitHub Actions Upgrade Notes - January 2026

This document describes the breaking changes and migration notes for the GitHub Actions upgrades implemented in January 2026.

## Overview

All workflow files have been updated to use the latest stable versions of GitHub Actions as of January 2026:

| Action | Previous | Current | Breaking Changes |
|--------|----------|---------|------------------|
| actions/checkout | v4 | v6 | Minimal (credential storage) |
| actions/setup-python | v5 | v6 | **Yes** (runner requirement, cache keys) |
| actions/cache | v4 | v5 | No |
| actions/github-script | v7 | v8 | Minimal (Node 24) |
| peter-evans/repository-dispatch | v3 | v4 | No (improved defaults) |
| supabase/setup-cli | 1.178.1 | latest (2.72.8) | No |

## Critical Breaking Changes

### 1. actions/setup-python@v6

#### Runner Version Requirement

**Breaking Change:** Requires GitHub Actions runner v2.327.1 or later for Node 24 support.

**Impact:**

- ✅ **GitHub-hosted runners** (ubuntu-latest, windows-latest, macos-latest): Already updated, no action needed
- ⚠️ **Self-hosted runners**: Must be upgraded to v2.327.1+ before using setup-python@v6

**Affected Workflows:**

- All workflows in this repository use `ubuntu-latest` (GitHub-hosted), so this is **informational only**
- Note: `platform-frontend-ci.yml` has one job using `runs-on: big-boi` (self-hosted) - not in the scope of this upgrade but should be monitored

**How to verify runner version:**

```bash
# On self-hosted runner
./run.sh --version
```

**How to upgrade self-hosted runner:**

```bash
# Download latest runner
# https://github.com/actions/runner/releases/tag/v2.327.1
```

#### Cache Key Architecture Change

**Breaking Change:** Architecture (arch) was added to cache keys to prevent cross-architecture cache conflicts.

**Impact:**

- **All existing Poetry caches will be invalidated** on first workflow run after upgrade
- First run after upgrade will be **slower** (full dependency install)
- Subsequent runs will be **faster** (using new architecture-specific caches)
- No manual intervention required - caches rebuild automatically

**Cache Key Format:**

```bash
# Old format (v5)
poetry-Linux-<hash>

# New format (v6)
poetry-Linux-x64-<hash>
```

**Expected Behavior:**

1. **First workflow run**: Cache miss, full `poetry install` (2-5 minutes)
2. **Second workflow run**: Cache hit, instant dependency loading (10-30 seconds)

**Monitoring:**

- Check workflow run times after upgrade
- First run after merge should show "Cache miss" in setup-python step
- Second run should show "Cache hit"

### 2. Built-in Poetry Caching

**Optimization:** Replaced manual `actions/cache@v4` with built-in `cache: 'poetry'` parameter in setup-python@v6.

**Before:**

```yaml
- name: Set up Python dependency cache
  uses: actions/cache@v4
  with:
    path: ~/.cache/pypoetry
    key: poetry-${{ runner.os }}-${{ hashFiles('autogpt_platform/backend/poetry.lock') }}

- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.13"
```

**After:**

```yaml
- name: Set up Python
  uses: actions/setup-python@v6
  with:
    python-version: "3.13"
    cache: 'poetry'
```

**Benefits:**

- Automatic cache key generation (includes architecture)
- Better cache hit detection
- Reduces workflow complexity (1 step instead of 2)
- Follows GitHub Actions best practices

## Non-Breaking Updates

### actions/checkout@v6

**Changes:**

- Credential storage mechanism updated
- Git operations remain backward compatible via includeIf directives
- No workflow changes required

### actions/cache@v5 (Removed)

**Note:** Manual cache action was **removed** from `platform-backend-ci.yml` and replaced with built-in caching.

### actions/github-script@v8

**Changes:**

- Updated to Node 24 runtime
- No breaking changes in API or functionality
- All existing scripts continue to work

### peter-evans/repository-dispatch@v4

**Changes:**

- Now defaults to using `GITHUB_TOKEN` for same-repository dispatches
- Our workflows use `DEPLOY_TOKEN` for cross-repository dispatch (unchanged)
- No workflow changes required

### supabase/setup-cli

**Changes:**

- Updated from hardcoded version `1.178.1` to `latest`
- Now uses Supabase CLI 2.72.8 (latest as of Jan 2026)
- No breaking changes in CLI commands used

## New Features Added

### 1. Composite Action for Migrations

**Created:** `.github/actions/prisma-migrate/action.yml`

**Purpose:** Eliminates duplication between `platform-autogpt-deploy-dev.yaml` and `platform-autogpt-deploy-prod.yml`

**Before (45 lines duplicated):**

```yaml
# Repeated in both deploy-dev and deploy-prod
steps:
  - name: Checkout code
    uses: actions/checkout@v4
  - name: Set up Python
    uses: actions/setup-python@v5
  - name: Install dependencies
    run: ...
  - name: Run migrations
    run: ...
```

**After (1 line per workflow):**

```yaml
steps:
  - name: Run Prisma migrations
    uses: ./.github/actions/prisma-migrate
    with:
      python-version: "3.13"
      database-url: ${{ secrets.BACKEND_DATABASE_URL }}
```

**Benefits:**

- DRY principle (Don't Repeat Yourself)
- Single source of truth for migration logic
- Easier maintenance and updates
- Consistent behavior across environments

### 2. Concurrency Controls

**Added to:** `platform-autogpt-deploy-dev.yaml` and `platform-autogpt-deploy-prod.yml`

```yaml
concurrency:
  group: deploy-{env}-${{ github.ref }}
  cancel-in-progress: false
```

**Purpose:**

- Prevents concurrent deployments to same environment
- Prevents migration conflicts (critical for database safety)
- Ensures deployments run sequentially

**Behavior:**

- Dev deployment triggered → Blocks new dev deployments until complete
- Prod deployment triggered → Blocks new prod deployments until complete
- Dev and prod can run concurrently (different concurrency groups)

### 3. Job-Level Permissions

**Added to:** All workflow jobs

```yaml
jobs:
  migrate:
    permissions:
      contents: read
      id-token: write
```

**Purpose:**

- Principle of least privilege
- Explicit permission requirements per job
- Better security posture
- GitHub security best practice

## Rollback Procedure

If issues arise after merging these changes:

### Quick Rollback (via Git Revert)

```bash
# Revert the merge commit
git revert -m 1 <merge-commit-sha>
git push origin master
```

### Manual Rollback (edit workflows)

1. Change action versions back:
   - `actions/checkout@v6` → `actions/checkout@v4`
   - `actions/setup-python@v6` → `actions/setup-python@v5`
   - `actions/github-script@v8` → `actions/github-script@v7`
   - `peter-evans/repository-dispatch@v4` → `peter-evans/repository-dispatch@v3`

2. Restore manual caching in `platform-backend-ci.yml`:

```yaml
- name: Set up Python dependency cache
  uses: actions/cache@v4
  with:
    path: ~/.cache/pypoetry
    key: poetry-${{ runner.os }}-${{ hashFiles('autogpt_platform/backend/poetry.lock') }}
```

3. Optionally revert composite action usage to inline steps

## Testing Checklist

- [ ] Verify deploy-dev workflow runs successfully
- [ ] Verify deploy-prod workflow runs successfully
- [ ] Verify backend-ci workflow runs successfully
- [ ] Verify event-dispatcher workflow runs successfully
- [ ] Check that first run shows "Cache miss" for Poetry dependencies
- [ ] Check that second run shows "Cache hit" for Poetry dependencies
- [ ] Verify migrations run successfully in both dev and prod
- [ ] Verify concurrency controls prevent simultaneous deployments
- [ ] Monitor workflow run times (first run slower, subsequent runs faster)

## Monitoring

### First Week After Deployment

Monitor these metrics:

1. **Workflow Success Rate**
   - Baseline: Current success rate
   - Target: Maintain or improve success rate

2. **Workflow Duration**
   - First run: 2-5 minutes slower (cache rebuild)
   - Subsequent runs: 30-60 seconds faster (built-in caching)

3. **Cache Hit Rate**
   - Target: 90%+ cache hit rate after initial rebuild

4. **Deployment Frequency**
   - Verify concurrency controls don't block legitimate deployments
   - Check for deployment queue buildup

### Alerts to Watch For

- ❌ "Runner version too old" errors (self-hosted runners only)
- ⚠️ Persistent cache misses after first run
- ⚠️ Workflow timeout errors
- ⚠️ Migration failures

## References

- [actions/checkout v6 releases](https://github.com/actions/checkout/releases)
- [actions/setup-python v6 releases](https://github.com/actions/setup-python/releases)
- [GitHub Actions runner v2.327.1](https://github.com/actions/runner/releases/tag/v2.327.1)
- [Node 24 deprecation timeline](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [peter-evans/repository-dispatch v4](https://github.com/peter-evans/repository-dispatch/releases)

## Questions or Issues?

If you encounter problems with these updates:

1. Check this document for known issues and solutions
2. Review workflow run logs in GitHub Actions tab
3. Open an issue with:
   - Workflow name and run URL
   - Error message or unexpected behavior
   - Runner type (GitHub-hosted or self-hosted)
