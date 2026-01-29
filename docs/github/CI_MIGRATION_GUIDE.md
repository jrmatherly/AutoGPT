# CI Migration Guide: ci.yml → ci-mise.yml

## Overview

This guide explains the migration from the simple `ci.yml` to the comprehensive `ci-mise.yml` workflow, which provides:

- ✅ **Parallelization**: Lint and tests run simultaneously (2-3x faster)
- ✅ **Full Infrastructure**: All services (ClamAV, Redis, RabbitMQ, Supabase)
- ✅ **Mise Integration**: Proper mise-action@v3 configuration
- ✅ **Latest Actions**: Updated to v6/v5 versions (January 2026)
- ✅ **Test Matrix**: Python 3.11, 3.12, 3.13 coverage
- ✅ **Production Parity**: Matches proven platform-backend-ci.yml infrastructure

---

## Key Improvements

### 1. Action Version Updates

| Action | Old | New | Benefits |

|--------|-----|-----|----------|
| `actions/checkout` | v4 | **v6** | Node.js 24 runtime |
| `actions/setup-python` | v5 | **v6** | Python 3.13 support, free-threading |
| `actions/cache` | v4 | **v5** | Rewritten backend, better performance |
| `jdx/mise-action` | v2 | **v3** | Template cache keys, experimental flag |

### 2. Mise Configuration Enhancements

**Before (ci.yml)**:

```yaml
- uses: jdx/mise-action@v2
  with:
    version: 2026.1.0
```

**After (ci-mise.yml)**:

```yaml
- uses: jdx/mise-action@v3
  with:
    version: 2026.1.0
    experimental: true  # Matches mise.toml config
    cache: true
    cache_key: mise-lint-{{platform}}-{{file_hash}}  # Optimized caching
    github_token: ${{ secrets.GITHUB_TOKEN }}  # Prevents API rate limiting
    log_level: info
```

**Benefits:**

- ✅ Experimental features enabled (matches project config)
- ✅ Custom cache keys per job (faster cache hits)
- ✅ GitHub token prevents 60/hr API rate limit
- ✅ Lockfile-based cache invalidation

### 3. Parallelization Architecture

**Before**: Single sequential job (~15-20 min)

```markdown
[Checkout] → [Mise Setup] → [Install] → [Test] → [Format]
```

**After**: Three parallel jobs (~8-12 min)

```markdown
[Lint & Format Check] ─┐
                        ├─→ [CI Success Gate]
[Backend Tests x3]     ─┤
                        │
[Frontend Tests]       ─┘
```

**Time Savings:**

- Lint runs independently (3-5 min)
- Backend tests parallelized across Python versions
- Frontend tests run simultaneously
- **Est. 40-60% faster CI**

### 4. Complete Infrastructure Preservation

#### Services (from platform-backend-ci.yml)

```yaml
services:
  redis: ✅ Port 6379
  rabbitmq: ✅ Ports 5672, 15672
  clamav: ✅ Port 3310 with 180s health checks
```

#### Critical Steps Preserved

1. ✅ **ClamAV Wait Logic**: 60s timeout with health verification
2. ✅ **Prisma Generation**: `prisma generate && gen-prisma-stub`
3. ✅ **Supabase Setup**: Full initialization with output capture
4. ✅ **Poetry Version**: Extracted from lockfile with base branch comparison
5. ✅ **Environment Variables**: Complete set (13 vars) for tests

#### Test Matrix

```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12", "3.13"]
```

Tests run across all supported Python versions in parallel.

---

## Migration Process

### Phase 1: Testing (Week 1)

**IMPORTANT: Configure GitHub Secrets First**

Before testing the new workflow, configure required secrets:

```bash
# Minimum requirement
gh secret set OPENAI_API_KEY
# Paste your OpenAI API key when prompted

# Verify secrets are set
gh secret list
```

See [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md) for complete setup guide.

---

**Run both workflows in parallel** to validate ci-mise.yml:

1. **Keep `ci.yml` active** as the required check
2. **Add `ci-mise.yml`** as an optional check
3. **Monitor results** for 5-10 runs
4. **Compare:**
   - Execution times
   - Pass/fail rates
   - Cache hit rates

**Validation checklist:**

- [ ] All backend tests pass across Python 3.11, 3.12, 3.13
- [ ] ClamAV service starts reliably
- [ ] Formatting checks work correctly
- [ ] No cache-related failures
- [ ] Execution time < 15 minutes

### Phase 2: Cutover (Week 2)

Once ci-mise.yml is validated:

```bash
# 1. Update branch protection rules
# GitHub Settings → Branches → master/dev
# Replace required check: "CI / test" → "CI (Mise-Enhanced) / ci-success"

# 2. Rename files
git mv .github/workflows/ci.yml .github/workflows/ci-old.yml
git mv .github/workflows/ci-mise.yml .github/workflows/ci.yml

# 3. Update workflow name
sed -i '' 's/name: CI (Mise-Enhanced)/name: CI/' .github/workflows/ci.yml

# 4. Commit and push
git add .github/workflows/
git commit -m "ci: migrate to mise-enhanced parallel workflow

BREAKING CHANGE: CI workflow restructured for parallelization

- Run lint, backend, and frontend tests in parallel
- Update all actions to latest versions (Jan 2026)
- Add proper mise-action@v3 configuration
- Preserve all infrastructure from platform-backend-ci.yml
- Add Python version matrix (3.11, 3.12, 3.13)

Estimated CI time reduction: 40-60%
"
git push origin master
```

### Phase 3: Cleanup (Week 3)

After 1 week of successful runs:

```bash
# Remove old workflow
git rm .github/workflows/ci-old.yml
git commit -m "ci: remove deprecated ci-old.yml workflow"
```

---

## Rollback Procedure

If issues are discovered after cutover:

```bash
# Quick rollback (emergency)
git mv .github/workflows/ci.yml .github/workflows/ci-mise.yml
git mv .github/workflows/ci-old.yml .github/workflows/ci.yml
git add .github/workflows/
git commit -m "ci: rollback to previous workflow due to [issue]"
git push origin master

# Update branch protection to use "CI / test" again
```

---

## Troubleshooting

### ClamAV Service Fails to Start

**Symptom**: "ClamAV failed to start after 300 seconds"

**Solutions:**

1. Check runner resources: `docker system df`
2. Increase health check timeout: `--health-start-period 300s`
3. Add explicit image pull: `docker pull clamav/clamav-debian:latest`

### Cache Misses

**Symptom**: Dependencies reinstalled on every run

**Diagnosis:**

```yaml
# Check cache key in workflow logs
# Look for: "Cache Key: mise-backend-py3.13-linux-x64-..."
```

**Solutions:**

1. Verify mise.lock hasn't changed unexpectedly
2. Check cache_key template variables render correctly
3. Ensure `experimental: true` is set (required for {{file_hash}})

### Python Version Matrix Timeout

**Symptom**: Backend test job exceeds 30min timeout

**Solutions:**

1. Reduce matrix to `["3.12", "3.13"]` temporarily
2. Increase timeout: `timeout-minutes: 45`
3. Check for hung ClamAV or Supabase processes

### Mise Tool Installation Fails

**Symptom**: "Tool X not found in lockfile"

**Solutions:**

1. Verify mise.lock is committed and up-to-date
2. Check `experimental: true` is set in mise-action
3. Run locally: `mise ls --locked` to validate lockfile

---

## Performance Benchmarks

### Expected Execution Times

| Job | Duration | Notes |

|-----|----------|-------|
| Lint & Format | 3-5 min | Parallel, no services needed |
| Backend Tests (each) | 10-15 min | 3 parallel jobs (Py 3.11, 3.12, 3.13) |
| Frontend Tests | 5-8 min | Parallel, lightweight |
| **Total (wall time)** | **10-15 min** | Down from 18-25 min |

### Cache Hit Rates

With proper caching:

- **Mise tools**: ~95% hit rate (lockfile-based)
- **Poetry deps**: ~90% hit rate (lock hash-based)
- **pnpm deps**: ~95% hit rate (lock hash-based)

---

## Comparison Table

| Feature | ci.yml (Old) | ci-mise.yml (New) |

|---------|-------------|-------------------|
| **Parallelization** | ❌ Sequential | ✅ 3 parallel jobs |
| **mise-action** | v2 | v3 with full config |
| **Python versions** | Single | Matrix: 3.11, 3.12, 3.13 |
| **ClamAV** | ❌ Missing | ✅ Full setup |
| **Prisma** | ❌ Missing | ✅ Generated |
| **Env vars** | ❌ Incomplete | ✅ Complete (13 vars) |
| **Cache strategy** | Default | Optimized per-job |
| **GitHub token** | ❌ Missing | ✅ Rate limit protection |
| **Experimental** | ❌ Missing | ✅ Matches project |
| **Est. runtime** | 18-25 min | 10-15 min |

---

## FAQ

### Q: Why keep both workflows during migration?

A: Running both in parallel allows validation without risk. If ci-mise.yml has issues, ci.yml continues to protect the main branch.

### Q: Can I use ci-mise.yml for feature branches immediately?

A: Yes! The workflow triggers on all PR branches. Only branch protection rules determine required checks.

### Q: What if a Python version test fails?

A: The matrix uses `fail-fast: false`, so all versions run even if one fails. Check logs for the specific Python version that failed.

### Q: How do I debug cache issues?

A: Enable debug logging:

```yaml
- name: Setup Mise
  uses: jdx/mise-action@v3
  with:
    log_level: debug  # Was: info
```

### Q: Why is frontend testing so minimal?

A: Frontend E2E tests are heavy (Playwright + Docker). This CI focuses on fast type/lint checks. Full E2E runs in platform-frontend-ci.yml on platform file changes.

---

## GitHub Secrets Setup

**Before running workflows, configure required secrets.**

See **[GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md)** for:
- Required vs optional secrets
- How to obtain and configure each secret
- Security best practices
- Troubleshooting common issues

**Minimum requirement for forks:**
```bash
gh secret set OPENAI_API_KEY
# Paste your OpenAI API key when prompted
```

## Additional Resources

- [GitHub Secrets Setup Guide](./GITHUB_SECRETS_SETUP.md) - **Configure secrets first**
- [mise-action@v3 Documentation](https://github.com/jdx/mise-action)
- [Mise CI Best Practices](https://mise.jdx.dev/continuous-integration.html)
- [GitHub Actions Cache Documentation](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [Python Version Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)

---

## Changelog

### 2026-01-29: Initial ci-mise.yml Creation

- Comprehensive Option 2.5 workflow created
- Merges proven platform-backend-ci.yml infrastructure
- Adds mise-action@v3 integration
- Implements 3-job parallelization
- Updates all actions to latest versions
- Preserves complete test environment
