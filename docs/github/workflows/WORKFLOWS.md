# GitHub Workflows Guide

**Last Updated:** 2026-01-30
**Status:** Recently upgraded (January 2026)

## Overview

This guide covers GitHub Actions workflows for the AutoGPT platform. All workflows have been upgraded to latest action versions (January 2026) with optimization and security enhancements.

**For detailed analysis**, see [../../../.archive/github/workflows/analysis/workflows_analysis.md](../../../.archive/github/workflows/analysis/workflows_analysis.md)

## Current Workflow Architecture

### CI/CD Workflows

| Workflow | Purpose | Trigger | Key Actions |

|----------|---------|---------|-------------|
| **platform-backend-ci.yml** | Backend tests & linting | PR, push to dev/master | setup-python@v6, Poetry, Prisma |
| **platform-frontend-ci.yml** | Frontend tests & linting | PR, push to dev/master | setup-node@v6, pnpm, Playwright |
| **platform-fullstack-ci.yml** | Full integration tests | PR, push to dev/master | Both backend + frontend |
| **ci-mise.yml** | Mise-integrated CI | PR, push | mise tasks |

### Deployment Workflows

| Workflow | Purpose | Environment | Special Features |

|----------|---------|-------------|------------------|
| **platform-autogpt-deploy-dev.yml** | Dev deployment | dev | Auto-deploy on merge |
| **platform-autogpt-deploy-prod.yml** | Prod deployment | prod | Manual approval required |

### Repository Automation

| Workflow | Purpose | Trigger |

|----------|---------|---------|
| **repo-pr-label.yml** | Auto-label PRs | PR open/sync |
| **repo-pr-size.yml** | Label PR size | PR open/sync |

## Recent Upgrades (January 2026)

### Action Version Updates

| Action | Old | New | Breaking Changes |

|--------|-----|-----|------------------|
| actions/checkout | v4 | v6 | Node 24 required |
| actions/setup-python | v5 | v6 | Cache key format changed |
| actions/setup-node | v4 | v6 | Node 24 required |
| actions/cache | v4 | v5 | None |
| actions/github-script | v7 | v8 | None |
| peter-evans/repository-dispatch | v3 | v4 | None |

**Complete upgrade details:** See [UPGRADE_NOTES_2026.md](UPGRADE_NOTES_2026.md)

### Key Improvements

1. **Eliminated Duplication** - Created `prisma-migrate` composite action
2. **Built-in Caching** - Migrated to setup-python@v6 automatic caching
3. **Python 3.13** - Updated from 3.11 to project standard 3.13
4. **Security** - Added concurrency controls and job-level permissions
5. **Supabase CLI** - Updated from pinned 1.178.1 to `latest`

## Composite Actions

### Prisma Migrate Action

**Location:** `.github/actions/prisma-migrate/action.yml`

**Purpose:** Reusable migration workflow using mise-action for dev/CI parity

**Updated:** 2026-01-30 - Migrated to `jdx/mise-action@v3`

**Usage:**
```yaml
- name: Run Prisma migrations
  uses: ./.github/actions/prisma-migrate
  with:
    database-url: ${{ secrets.BACKEND_DATABASE_URL }}
    git-ref: ${{ github.ref_name }}
    # Optional: Override Python version (uses mise.toml default if omitted)
    # python-version: "3.13"
    # Optional: Skip client generation
    # generate-client: "false"
```

**Inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `database-url` | Yes | - | Database connection string |
| `git-ref` | No | `github.ref_name` | Git ref to checkout |
| `python-version` | No | `""` (uses mise.toml) | Override Python version |
| `mise-version` | No | `2026.1.10` | Mise version to use |
| `generate-client` | No | `true` | Run `prisma generate` after migrations |

**Features:**
- Uses `jdx/mise-action@v3` for dev/CI parity
- Installs dependencies via Poetry (respects lock file)
- Runs both `prisma migrate deploy` and `prisma generate`
- Automatic caching via mise (cache_key_prefix: `mise-prisma`)
- Configurable Python version override for matrix testing

**Benefits:**
- Single source of truth for migrations
- Consistent with all other platform workflows
- Uses Poetry lock file for reproducible builds
- Proper Prisma client generation included

## CI Integration with Mise

The **ci-mise.yml** workflow demonstrates mise integration:

```yaml
- name: Install mise
  run: |
    curl https://mise.run | sh
    echo "$HOME/.local/bin" >> $GITHUB_PATH

- name: Setup project
  run: mise install

- name: Run tests
  run: mise run test
```

**Advantages:**
- Consistent with local development
- Automatic tool version management
- Single source of truth (mise.toml)

## Security Best Practices

### 1. Job-Level Permissions

All workflows use least-privilege permissions:

```yaml
permissions:
  contents: read
  pull-requests: write
```

### 2. Concurrency Controls

Deployment workflows prevent conflicts:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: false  # Don't cancel deployments
```

### 3. Secret Management

- Using `GITHUB_TOKEN` (automatic, limited scope)
- Deployment secrets scoped to environment
- No long-lived credentials in workflows

## Caching Strategy

### Python Dependencies (setup-python@v6)

**Automatic caching** based on:
- `poetry.lock` file hash
- Runner architecture
- Python version

**Performance:**
- First run: 2-5 minutes (cold cache)
- Subsequent runs: 10-30 seconds (cache hit)

### Node Dependencies (setup-node@v6)

**Automatic caching** based on:
- `pnpm-lock.yaml` file hash
- Node version

## Troubleshooting

### Cache Issues

**Symptom:** Cache miss on every run

**Solutions:**
1. Check runner version (must be v2.327.1+ for Node 24)
2. Verify lock files are committed
3. Check cache key in workflow logs

### Migration Failures

**Symptom:** Prisma migrations fail in CI

**Solutions:**
1. Verify `DATABASE_URL` secret is set
2. Check database is accessible from runner
3. Review migration files for syntax errors

### Action Version Errors

**Symptom:** "Unexpected value 'node24'" error

**Solution:** Runner needs upgrade to v2.327.1+
- GitHub-hosted runners: Already compatible ✅
- Self-hosted runners: Upgrade required

## Testing Workflows Locally

### Using act (GitHub Actions locally)

```bash
# Install act
brew install act  # macOS
# or: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# List workflows
act -l

# Run specific workflow
act pull_request -j backend-ci

# Run with secrets
act -s GITHUB_TOKEN=your_token
```

### Using mise

```bash
# Run the same commands locally
mise run format
mise run lint
mise run test
```

## Monitoring

**Workflow Insights:** Settings → Actions → [Workflow Name]

**Key Metrics:**
- Average run time
- Success rate
- Cache hit rate (check logs for "Cache hit")

**Expected Performance:**
- Backend CI: 5-10 minutes (cached)
- Frontend CI: 3-7 minutes (cached)
- Fullstack CI: 10-15 minutes (cached)

## Future Enhancements

### Phase 1: Security (Planned)
- [ ] Add dependency-review-action
- [ ] Pin critical actions to commit SHA
- [ ] Add OpenSSF Scorecard

### Phase 2: Optimization (Planned)
- [ ] Matrix strategy for multi-version testing
- [ ] Workflow reuse for common patterns
- [ ] Parallel job execution where possible

### Phase 3: Automation (Planned)
- [ ] Auto-merge Dependabot (patch/minor)
- [ ] Automated changelog generation
- [ ] Release automation

## References

- **Detailed Analysis:** [../../../.archive/github/workflows/analysis/workflows_analysis.md](../../../.archive/github/workflows/analysis/workflows_analysis.md)
- **Upgrade Notes:** [UPGRADE_NOTES_2026.md](UPGRADE_NOTES_2026.md)
- **Script Analysis:** [WORKFLOW_SCRIPTS_ANALYSIS_2026.md](WORKFLOW_SCRIPTS_ANALYSIS_2026.md)
- **Archived Reports:** [../../../.archive/github/workflows/reports/](../../../.archive/github/workflows/reports/)

## Change Log

- **2026-01-30:** Prisma-migrate action updated to use `jdx/mise-action@v3` for dev/CI parity
- **2026-01-29:** Consolidated workflows guide created
- **2026-01-29:** Action version upgrades completed (v4→v6)
- **2026-01-29:** Composite action created for Prisma migrations
- Original analysis: 2026-01-29 (archived)
