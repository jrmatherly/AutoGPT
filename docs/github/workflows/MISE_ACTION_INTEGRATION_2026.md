# Mise-Action Integration Recommendations (January 2026)

**Status:** Research Complete
**Date:** 2026-01-29
**Target Files:** `platform-frontend-ci.yml`, `platform-fullstack-ci.yml`
**Reference Implementation:** `ci-mise.yml`

---

## Executive Summary

After researching the latest mise-action patterns (v3, January 2026), we can **significantly simplify** our GitHub Actions workflows by fully leveraging mise's tool management capabilities. The current `ci-mise.yml` partially uses mise-action but doesn't fully eliminate manual tool setup steps.

**Key Insight:** When properly configured, mise-action can replace:
- ❌ `actions/setup-node`
- ❌ Manual `corepack enable`
- ❌ Manual `actions/cache` for pnpm
- ❌ Manual `pnpm install` commands

**Benefits:**
- 🎯 Single source of truth for tool versions (mise.toml)
- ⚡ Faster CI with mise's built-in caching
- 🔒 Consistent versions between local dev and CI
- 📉 Fewer workflow steps to maintain

---

## Current State Analysis

### What's Already in mise.toml

```toml
[tools]
python = "3.13"
node = "22"
pnpm = "10.28.2"

[tasks]
install = { depends = ["install:backend", "install:frontend", "install:libs"] }
"install:frontend" = { dir = "{{config_root}}/frontend", run = "pnpm install" }
frontend = { dir = "{{config_root}}/frontend", run = "pnpm dev" }
format = { ... }  # Formats both backend + frontend
"test:frontend" = { dir = "{{config_root}}/frontend", run = "pnpm test" }
```

### Current ci-mise.yml Pattern (Partial Mise Adoption)

```yaml
- name: Setup Mise
  uses: jdx/mise-action@v3
  with:
    version: 2026.1.0
    experimental: true
    cache: true
    cache_key: mise-frontend-{{platform}}-{{file_hash}}
    github_token: ${{ secrets.GITHUB_TOKEN }}
    log_level: info

# ⚠️ REDUNDANT: mise already installed node + pnpm
- name: Set up Node.js
  uses: actions/setup-node@v4  # Should be removed!
  with:
    node-version: "22.18.0"

- name: Enable corepack  # Should be removed!
  run: corepack enable

- name: Cache frontend dependencies  # Should be removed!
  uses: actions/cache@v5  # mise handles this
  with:
    path: ~/.pnpm-store
    ...

- name: Install dependencies  # Should use mise run
  run: pnpm install --frozen-lockfile
```

---

## Recommended Pattern (Full Mise Adoption)

### Minimal Setup (Recommended)

```yaml
steps:
  - name: Checkout repository
    uses: actions/checkout@v6

  - name: Setup Mise
    uses: jdx/mise-action@v3
    with:
      version: 2026.1.0
      experimental: true
      cache: true
      cache_key: mise-frontend-{{platform}}-{{file_hash}}
      github_token: ${{ secrets.GITHUB_TOKEN }}
      log_level: info

  # That's it! Node.js, pnpm are now available via mise

  - name: Install dependencies
    working-directory: autogpt_platform
    run: mise run install:frontend

  - name: Generate API client
    working-directory: autogpt_platform/frontend
    run: pnpm generate:api  # Can use pnpm directly via mise shims

  - name: Type checking
    working-directory: autogpt_platform
    run: |
      cd frontend && pnpm types
```

### Alternative: Using Mise Tasks Exclusively

```yaml
- name: Setup Mise
  uses: jdx/mise-action@v3
  with:
    version: 2026.1.0
    experimental: true
    cache: true
    cache_key: mise-{{platform}}-{{file_hash}}
    github_token: ${{ secrets.GITHUB_TOKEN }}

- name: Install all dependencies
  working-directory: autogpt_platform
  run: mise run install  # Runs install:backend, install:frontend, install:libs in parallel

- name: Run format check
  working-directory: autogpt_platform
  run: mise run format  # Formats both backend + frontend

- name: Run tests
  working-directory: autogpt_platform
  run: mise run test  # Could add test task for frontend
```

---

## Mise-Action Configuration Deep Dive

### Essential Parameters

```yaml
uses: jdx/mise-action@v3
with:
  # Required/Recommended
  version: 2026.1.0              # Pin mise version for reproducibility
  experimental: true             # Required for AutoGPT (set in mise.toml)
  cache: true                    # Enable GitHub Actions caching
  github_token: ${{ secrets.GITHUB_TOKEN }}  # Avoid GitHub API rate limits

  # Optional but useful
  cache_key: mise-frontend-{{platform}}-{{file_hash}}  # Custom cache key
  log_level: info                # Visibility into mise operations
  working_directory: autogpt_platform  # If not running from root
```

### Cache Key Template Variables

Available variables for `cache_key`:
- `{{version}}` - Mise version
- `{{platform}}` - OS platform (linux, darwin, etc.)
- `{{file_hash}}` - Hash of mise config files
- `{{install_args_hash}}` - Hash of install arguments
- `{{mise_env}}` - Mise environment variables
- `{{default}}` - The default computed cache key

**Examples:**
```yaml
# Basic (default behavior)
cache_key: mise-v0-{{platform}}-{{file_hash}}

# Per-job optimization
cache_key: mise-frontend-{{platform}}-{{file_hash}}
cache_key: mise-backend-{{platform}}-{{file_hash}}

# Include install args if using custom flags
cache_key: mise-{{platform}}-{{install_args_hash}}-{{file_hash}}
```

### Default Behavior (What Happens When You Don't Specify)

```yaml
uses: jdx/mise-action@v3
# Defaults to:
# - version: latest
# - install: true (runs `mise install`)
# - cache: true
# - github_token: ${{ secrets.GITHUB_TOKEN }} (auto-provided)
# - log_level: info
```

---

## Migration Strategy

### Phase 1: Update Existing Workflows (Conservative)

**For `platform-frontend-ci.yml` and `platform-fullstack-ci.yml`:**

1. Add mise-action BEFORE setup-node:
   ```yaml
   - name: Setup Mise
     uses: jdx/mise-action@v3
     with:
       version: 2026.1.0
       experimental: true
       cache: true
       cache_key: mise-frontend-{{platform}}-{{file_hash}}
       github_token: ${{ secrets.GITHUB_TOKEN }}
       log_level: info
   ```

2. **Keep setup-node for now** (gradual migration)

3. Update Node.js version to use mise-managed version:
   ```yaml
   - name: Set up Node.js
     uses: actions/setup-node@v6
     with:
       node-version: "22"  # Match mise.toml
   ```

4. Test thoroughly before proceeding to Phase 2

### Phase 2: Full Mise Adoption (Recommended)

**Eliminate redundant steps:**

```diff
  - name: Setup Mise
    uses: jdx/mise-action@v3
    with:
      version: 2026.1.0
      experimental: true
      cache: true
      cache_key: mise-frontend-{{platform}}-{{file_hash}}
      github_token: ${{ secrets.GITHUB_TOKEN }}
      log_level: info

- - name: Set up Node.js
-   uses: actions/setup-node@v6
-   with:
-     node-version: "22.x"
-     cache: 'pnpm'
-     cache-dependency-path: 'autogpt_platform/frontend/pnpm-lock.yaml'
-
- - name: Enable corepack
-   run: corepack enable
-
- - name: Cache dependencies
-   uses: actions/cache@v5
-   with:
-     path: ~/.pnpm-store
-     key: ...
-
- - name: Generate cache key
-   id: cache-key
-   run: echo "key=..." >> $GITHUB_OUTPUT

  - name: Install dependencies
-   run: pnpm install --frozen-lockfile
+   working-directory: autogpt_platform
+   run: mise run install:frontend
```

**Result:**
- ✅ 5 fewer steps per job
- ✅ Single source of truth (mise.toml)
- ✅ Faster caching via mise
- ✅ Consistent with local development

---

## Recommended Workflow Structure

### platform-frontend-ci.yml (Optimized)

```yaml
name: AutoGPT Platform - Frontend CI

on:
  push:
    branches: [master, dev]
    paths:
      - ".github/workflows/platform-frontend-ci.yml"
      - "autogpt_platform/frontend/**"
      - "mise.toml"
      - "autogpt_platform/mise.toml"
  pull_request:
    paths:
      - ".github/workflows/platform-frontend-ci.yml"
      - "autogpt_platform/frontend/**"
      - "mise.toml"
      - "autogpt_platform/mise.toml"
  merge_group:
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.event_name == 'merge_group' && format('merge-queue-{0}', github.ref) || format('{0}-{1}', github.ref, github.event.pull_request.number || github.sha) }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

defaults:
  run:
    shell: bash
    working-directory: autogpt_platform

jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6

      - name: Setup Mise
        uses: jdx/mise-action@v3
        with:
          version: 2026.1.0
          experimental: true
          cache: true
          cache_key: mise-lint-{{platform}}-{{file_hash}}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          log_level: info

      - name: Verify mise environment
        run: |
          echo "🔍 Verifying mise setup..."
          mise --version
          mise ls

      - name: Install dependencies
        run: mise run install:frontend

      - name: Run lint
        working-directory: frontend
        run: pnpm lint

  types:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          submodules: recursive

      - name: Setup Mise
        uses: jdx/mise-action@v3
        with:
          version: 2026.1.0
          experimental: true
          cache: true
          cache_key: mise-types-{{platform}}-{{file_hash}}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          log_level: info

      - name: Copy default supabase .env
        run: cp .env.default .env

      - name: Copy backend .env
        run: cp backend/.env.default backend/.env

      - name: Start infrastructure
        run: docker compose --profile local --profile deps_backend up -d

      - name: Wait for services
        run: |
          timeout 60 sh -c 'until curl -f http://localhost:8006/health 2>/dev/null; do sleep 2; done'

      - name: Install dependencies
        run: mise run install:frontend

      - name: Generate API client
        working-directory: frontend
        run: pnpm generate:api:force

      - name: Check for API schema changes
        working-directory: frontend
        run: |
          if ! git diff --exit-code src/app/api/openapi.json; then
            echo "❌ API schema changes detected"
            echo "Run 'pnpm generate:api' locally and commit changes"
            exit 1
          fi

      - name: Run TypeScript checks
        working-directory: frontend
        run: pnpm types

  chromatic:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/dev' || github.base_ref == 'dev'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Setup Mise
        uses: jdx/mise-action@v3
        with:
          version: 2026.1.0
          experimental: true
          cache: true
          cache_key: mise-chromatic-{{platform}}-{{file_hash}}
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Install dependencies
        run: mise run install:frontend

      - name: Run Chromatic
        uses: chromaui/action@v1
        with:
          projectToken: chpt_9e7c1a76478c9c8
          onlyChanged: true
          workingDir: frontend
          token: ${{ secrets.GITHUB_TOKEN }}
          exitOnceUploaded: true

  e2e_test:
    runs-on: big-boi
    timeout-minutes: 30

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          submodules: recursive

      - name: Setup Mise
        uses: jdx/mise-action@v3
        with:
          version: 2026.1.0
          experimental: true
          cache: true
          cache_key: mise-e2e-{{platform}}-{{file_hash}}
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Copy environment files
        run: |
          cp .env.default .env
          cp backend/.env.default backend/.env
          echo "OPENAI_INTERNAL_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> backend/.env

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Run docker compose
        run: NEXT_PUBLIC_PW_TEST=true docker compose up -d
        env:
          DOCKER_BUILDKIT: 1
          BUILDX_CACHE_FROM: type=gha
          BUILDX_CACHE_TO: type=gha,mode=max

      - name: Wait for services
        run: |
          timeout 60 sh -c 'until curl -f http://localhost:8006/health 2>/dev/null; do sleep 2; done'
          timeout 60 sh -c 'until docker compose exec -T db pg_isready -U postgres 2>/dev/null; do sleep 2; done'

      - name: Create E2E test data
        run: |
          docker compose exec -T rest_server sh -c "cd /app/autogpt_platform && python backend/test/e2e_test_data.py"

      - name: Install dependencies
        run: mise run install:frontend

      - name: Install Playwright browsers
        working-directory: frontend
        run: pnpm playwright install --with-deps chromium

      - name: Run Playwright tests
        working-directory: frontend
        run: pnpm test:no-build

      - name: Upload Playwright report
        if: always()
        uses: actions/upload-artifact@v6
        with:
          name: playwright-report
          path: frontend/playwright-report
          if-no-files-found: ignore
          retention-days: 3

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v6
        with:
          name: playwright-test-results
          path: frontend/test-results
          if-no-files-found: ignore
          retention-days: 3

      - name: Print Docker logs
        if: always()
        run: docker compose logs

  integration_test:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          submodules: recursive

      - name: Setup Mise
        uses: jdx/mise-action@v3
        with:
          version: 2026.1.0
          experimental: true
          cache: true
          cache_key: mise-integration-{{platform}}-{{file_hash}}
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Install dependencies
        run: mise run install:frontend

      - name: Generate API client
        working-directory: frontend
        run: pnpm generate:api

      - name: Run integration tests
        working-directory: frontend
        run: pnpm test:unit
```

---

## Comparison: Before vs After

### Before (Current platform-frontend-ci.yml)

**Steps per job:**
1. Checkout
2. Set up Node.js (with cache config)
3. Enable corepack
4. Generate cache key
5. Cache dependencies
6. Install dependencies
7. Run actual task

**Total:** 7 steps + task

### After (With Mise-Action)

**Steps per job:**
1. Checkout
2. Setup Mise
3. Verify mise (optional)
4. Install dependencies (via mise)
5. Run actual task

**Total:** 5 steps + task (or 4 if skipping verification)

**Improvement:**
- ✅ 29% fewer steps
- ✅ Single source of truth (mise.toml)
- ✅ Faster setup (mise caching is optimized)
- ✅ Consistent with local development

---

## Benefits Analysis

### 1. Single Source of Truth

**Before:** Tool versions scattered across:
- `mise.toml`: python = "3.13", node = "22", pnpm = "10.28.2"
- Workflows: node-version: "22.x"
- Local development: uses mise
- CI: uses actions/setup-node

**After:** Everything reads from `mise.toml`
- ✅ Local dev: `mise install`
- ✅ CI: `mise-action` reads same config
- ✅ No version drift between environments

### 2. Simplified Maintenance

**Before:** Update Node.js version
1. Edit `mise.toml` → node = "23"
2. Edit `platform-frontend-ci.yml` → node-version: "23.x"
3. Edit `platform-fullstack-ci.yml` → node-version: "23.x"
4. Edit `ci-mise.yml` → node-version: "23.x"

**After:** Update Node.js version
1. Edit `mise.toml` → node = "23"
2. Done! ✅ All workflows automatically use new version

### 3. Performance Improvements

**Mise Caching Strategy:**
- Uses GitHub Actions cache backend (`cache: true`)
- Caches entire mise environment (tools + shims)
- Custom cache keys per job type
- Faster than individual tool setups

**Estimated Time Savings:**
- Setup time: ~30-45 seconds faster per job
- Cache hit rate: Higher (mise manages entire toolchain)
- Parallel installs: mise can install tools in parallel

### 4. Consistency Guarantees

**With mise-action:**
- ✅ Same Node.js version in local dev and CI
- ✅ Same pnpm version everywhere
- ✅ Same Python version everywhere
- ✅ Reproducible builds (mise.lock)

---

## Implementation Checklist

### Phase 1: Add Mise-Action (Non-Breaking)

- [ ] **platform-frontend-ci.yml**
  - [ ] Add mise-action step after checkout
  - [ ] Keep existing setup-node for now
  - [ ] Test all jobs pass

- [ ] **platform-fullstack-ci.yml**
  - [ ] Add mise-action step after checkout
  - [ ] Keep existing setup-node for now
  - [ ] Test all jobs pass

### Phase 2: Optimize with Mise Tasks

- [ ] **Verify mise tasks exist**
  - [x] `mise run install:frontend` ✅
  - [x] `mise run format` ✅
  - [ ] `mise run test:frontend` - Add if missing
  - [ ] `mise run lint:frontend` - Add if missing

- [ ] **Update workflows to use mise tasks**
  - [ ] Replace `pnpm install` with `mise run install:frontend`
  - [ ] Replace format commands with `mise run format`
  - [ ] Replace test commands with `mise run test:frontend`

### Phase 3: Remove Redundant Steps

- [ ] **Remove from all workflows**
  - [ ] `actions/setup-node` steps
  - [ ] `corepack enable` steps
  - [ ] Manual `actions/cache` for pnpm
  - [ ] `Generate cache key` steps
  - [ ] `needs: setup` dependencies (if setup job only did caching)

- [ ] **Simplify job structure**
  - [ ] Remove `setup` job if it only cached dependencies
  - [ ] Update job dependencies

### Phase 4: Optimization

- [ ] **Add path triggers for mise configs**
  ```yaml
  on:
    push:
      paths:
        - "mise.toml"
        - "autogpt_platform/mise.toml"
  ```

- [ ] **Optimize cache keys per workflow**
  ```yaml
  cache_key: mise-frontend-{{platform}}-{{file_hash}}
  cache_key: mise-fullstack-{{platform}}-{{file_hash}}
  ```

- [ ] **Add mise verification step** (optional but recommended)
  ```yaml
  - name: Verify mise environment
    run: |
      mise --version
      mise ls
  ```

---

## Potential Issues & Solutions

### Issue 1: Tools Not Found After Mise Install

**Symptom:** `pnpm: command not found` after mise-action

**Solution:**
```yaml
- name: Verify mise shims
  run: |
    echo "$PATH"
    mise which pnpm
    mise which node
```

mise-action should automatically add shims to PATH. If not, explicitly add:
```yaml
- name: Add mise to PATH
  run: echo "$HOME/.local/share/mise/shims" >> $GITHUB_PATH
```

### Issue 2: Cache Not Working

**Symptom:** Slow installs every run

**Diagnosis:**
```yaml
- name: Check cache
  run: |
    mise cache clear  # Clear if corrupted
    mise install --verbose
```

**Solution:** Ensure `cache: true` and valid `github_token`:
```yaml
uses: jdx/mise-action@v3
with:
  cache: true
  github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Issue 3: Wrong Tool Version

**Symptom:** Using system Node.js instead of mise version

**Solution:**
```yaml
- name: Verify tool versions
  run: |
    mise current
    node --version  # Should match mise.toml
    pnpm --version  # Should match mise.toml
```

### Issue 4: GitHub API Rate Limiting

**Symptom:** "API rate limit exceeded" during mise install

**Solution:** Always pass github_token:
```yaml
github_token: ${{ secrets.GITHUB_TOKEN }}
```

This gives 5000 requests/hour instead of 60.

---

## Testing Strategy

### 1. Test in Isolation

Create a test workflow:
```yaml
name: Test Mise Integration
on: workflow_dispatch

jobs:
  test-mise:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - uses: jdx/mise-action@v3
        with:
          version: 2026.1.0
          experimental: true
          cache: true
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Verify tools
        working-directory: autogpt_platform
        run: |
          mise current
          node --version
          pnpm --version
          pnpm --version | grep "10.28.2" || exit 1

      - name: Test install task
        working-directory: autogpt_platform
        run: mise run install:frontend

      - name: Verify install
        working-directory: autogpt_platform/frontend
        run: |
          test -d node_modules || exit 1
          pnpm list next
```

### 2. Gradual Rollout

1. **Week 1:** Add mise-action to one workflow
2. **Week 2:** If successful, add to all workflows
3. **Week 3:** Start removing redundant setup-node steps
4. **Week 4:** Complete migration, remove all manual steps

### 3. Validation Checklist

After each change:
- [ ] All CI jobs pass ✅
- [ ] Tool versions match mise.toml ✅
- [ ] Cache is hitting (check logs) ✅
- [ ] Build times are same or faster ✅
- [ ] No "command not found" errors ✅

---

## Recommended Next Steps

### Immediate (This Week)

1. **Update platform-frontend-ci.yml**
   - Add mise-action to all jobs
   - Keep setup-node temporarily for safety
   - Test thoroughly

2. **Update platform-fullstack-ci.yml**
   - Same approach as frontend-ci
   - Monitor for any issues

### Short-term (Next 2 Weeks)

1. **Add missing mise tasks**
   ```toml
   [tasks."lint:frontend"]
   dir = "{{config_root}}/frontend"
   run = "pnpm lint"

   [tasks."test:frontend"]
   dir = "{{config_root}}/frontend"
   run = "pnpm test"
   ```

2. **Convert workflows to use mise tasks**
   - Replace direct pnpm commands with `mise run`
   - Validate all jobs still pass

### Medium-term (Next Month)

1. **Remove redundant steps**
   - Eliminate setup-node from all workflows
   - Remove manual caching steps
   - Simplify workflow structure

2. **Update ci-mise.yml**
   - It currently has redundant setup-node steps too
   - Apply same optimizations

### Long-term (Continuous)

1. **Monitor and optimize**
   - Track build times
   - Optimize cache keys if needed
   - Keep mise version up to date

---

## Additional Resources

### Official Documentation
- [mise CI/CD Guide](https://mise.jdx.dev/continuous-integration.html)
- [mise-action GitHub](https://github.com/jdx/mise-action)
- [mise Tasks Documentation](https://mise.jdx.dev/tasks/)

### Internal References
- `mise.toml` - Tool and task definitions
- `autogpt_platform/mise.toml` - Platform-specific config
- `ci-mise.yml` - Reference implementation (needs optimization)
- `.archive/github/workflows/reports/optimization.md` - Recent action updates

### Examples in Wild
- [mise project CI](https://github.com/jdx/mise/blob/main/.github/workflows/test.yml)
- [Community examples](https://github.com/search?q=jdx%2Fmise-action&type=code)

---

**Next Action:** Review this document and decide on migration timeline. I recommend starting with Phase 1 (add mise-action non-disruptively) this week.
