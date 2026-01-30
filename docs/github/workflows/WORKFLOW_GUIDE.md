# GitHub Actions Workflow Guide

Complete reference for all GitHub Actions workflows in the AutoGPT repository.

## Table of Contents

- [Quick Reference](#quick-reference)
- [Workflow Categories](#workflow-categories)
  - [Platform CI/CD](#platform-cicd)
  - [Documentation Workflows](#documentation-workflows)
  - [Code Quality](#code-quality)
  - [Automation](#automation)
  - [Repository Management](#repository-management)
  - [Development Environment](#development-environment)
- [Tool Management: mise-action](#tool-management-mise-action)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Reference

| Category | Workflows | Purpose |
|----------|-----------|---------|
| **Platform CI/CD** | platform-backend-ci, platform-frontend-ci, platform-fullstack-ci, platform-autogpt-deploy-prod | Test, validate, and deploy the AutoGPT Platform |
| **Documentation** | docs-block-sync, docs-claude-review, docs-enhance | Maintain and enhance block documentation |
| **Code Quality** | codeql, claude-code-review, ci | Security scanning and code review |
| **Automation** | claude-ci-failure-auto-fix, claude-dependabot, claude | Automated fixes and maintenance |
| **Repository** | repo-* (6 workflows) | Issue management, labeling, stats |
| **Development** | copilot-setup-steps | Development environment setup |

**Total Workflows**: 20 files in `.github/workflows/`

## Workflow Categories

### Platform CI/CD

#### platform-backend-ci.yml
```yaml
Triggers: PR/push to master/dev (backend paths)
Runtime: ~5-10 minutes per Python version
```

**Purpose**: Comprehensive backend testing with Python version matrix

**Key Features**:
- Python version matrix: 3.11, 3.12, 3.13
- mise-action for unified tool management
- Poetry dependency installation with caching
- Prisma client generation
- pytest with coverage reporting
- Lint (ruff) and type checking (mypy)
- Optional LiteLLM Proxy integration for E2E tests

**Path Filters**:
```
autogpt_platform/backend/**
autogpt_platform/autogpt_libs/**
pyproject.toml
poetry.lock
```

**Special Configuration**:
```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12", "3.13"]

steps:
  - uses: jdx/mise-action@v3
    with:
      version: 2026.1.9
      install: true
      cache: true
      working_directory: autogpt_platform
      install_args: python@${{ matrix.python-version }}
```

---

#### platform-frontend-ci.yml
```yaml
Triggers: PR/push to master/dev (frontend paths)
Runtime: ~3-5 minutes
```

**Purpose**: Frontend testing, linting, and type checking

**Key Features**:
- mise-action for Node.js/pnpm setup
- Next.js build validation
- ESLint and TypeScript type checking
- Playwright E2E tests
- Optional LiteLLM Proxy integration

**Path Filters**:
```
autogpt_platform/frontend/**
package.json
pnpm-lock.yaml
```

---

#### platform-fullstack-ci.yml
```yaml
Triggers: PR/push to master/dev (fullstack paths)
Runtime: ~2-4 minutes
```

**Purpose**: Full-stack type checking and API contract validation

**Key Features**:
- mise-action for unified tool management
- Backend and frontend type checking in parallel
- API schema validation
- Ensures backend/frontend type compatibility

**Path Filters**:
```
autogpt_platform/backend/**
autogpt_platform/frontend/**
```

---

#### platform-autogpt-deploy-prod.yml
```yaml
Triggers: Git tags matching v* (e.g., v1.2.3)
Runtime: ~10-15 minutes
```

**Purpose**: Production deployment automation

**Key Features**:
- Triggered by release tags from `mise run release`
- Version validation
- Production deployment
- Artifact creation

**Related Documentation**: [Release Process](../../processes/RELEASE_PROCESS.md)

**Release Commands**:
```bash
# Interactive release
mise run release

# Auto-confirm releases
mise run release:patch  # vX.Y.Z → vX.Y.Z+1
mise run release:minor  # vX.Y.Z → vX.Y+1.0
mise run release:major  # vX.Y.Z → vX+1.0.0
```

### Documentation Workflows

#### docs-block-sync.yml
```yaml
Triggers: Push/PR to master/dev (blocks or docs paths)
Runtime: ~2-3 minutes
```

**Purpose**: Validates block documentation is in sync with code

**Key Features**:
- Uses mise-action for Python/Poetry setup
- Runs `generate_block_docs.py --check`
- Shows diff if out of sync
- Fails CI if regeneration needed

**Fix Command**:
```bash
cd autogpt_platform/backend
poetry run python scripts/generate_block_docs.py
git add ../../docs/integrations/
git commit -m "docs: regenerate block documentation"
```

**Path Filters**:
```
autogpt_platform/backend/backend/blocks/**
docs/integrations/**
autogpt_platform/backend/scripts/generate_block_docs.py
```

---

#### docs-claude-review.yml
```yaml
Triggers: PR opened/synchronized (docs or blocks paths)
Runtime: ~3-5 minutes
```

**Purpose**: AI-powered documentation review

**Key Features**:
- Uses anthropics/claude-code-action@v1
- Reviews block documentation accuracy
- Validates manual sections quality
- Checks template compliance
- Only runs for OWNER/MEMBER/COLLABORATOR authors

**Review Focus**:
1. Documentation accuracy (inputs/outputs match schemas)
2. Manual content quality ("How it works", "Possible use case")
3. Template compliance
4. Cross-references and links

**Permissions**:
```yaml
permissions:
  contents: read
  pull-requests: write
  id-token: write
```

---

#### docs-enhance.yml
```yaml
Triggers: Manual workflow_dispatch
Runtime: ~15-45 minutes (depends on max_blocks)
```

**Purpose**: LLM-powered documentation enhancement

**Key Features**:
- Uses anthropics/claude-code-action@v1
- Improves manual sections by reading block implementations
- Supports dry-run mode
- Pattern matching for specific blocks
- Creates PR with enhancements

**Parameters**:
| Parameter | Description | Default |
|-----------|-------------|---------|
| `block_pattern` | File pattern (e.g., `google/*.md`, `*`) | `*` |
| `dry_run` | Show changes without committing | `true` |
| `max_blocks` | Maximum blocks to process | `10` |

**Usage Example**:
```yaml
# Via GitHub UI: Actions → Enhance Block Documentation → Run workflow
# Set block_pattern: google/*.md
# Set dry_run: false
# Set max_blocks: 5
```

**Enhancement Target Sections**:
- `<!-- MANUAL: how_it_works -->` - Technical explanations
- `<!-- MANUAL: use_case -->` - Practical examples

### Code Quality

#### codeql.yml
```yaml
Triggers: Push to master/dev, PR, weekly schedule (Mon 6am)
Runtime: ~10-15 minutes
```

**Purpose**: Security vulnerability scanning

**Key Features**:
- CodeQL analysis for TypeScript and Python
- Automated security scanning
- Weekly scheduled scans
- Uses github/codeql-action@v4 (Node.js 24)

**Languages Analyzed**:
- TypeScript/JavaScript
- Python

**Schedule**: Every Monday at 6:00 AM UTC

---

#### claude-code-review.yml
```yaml
Triggers: PR opened/synchronized
Runtime: ~5-10 minutes
```

**Purpose**: AI-powered code review

**Key Features**:
- Uses anthropics/claude-code-action@v1
- Comprehensive code quality analysis
- Security vulnerability detection
- Best practices enforcement

---

#### ci.yml
```yaml
Triggers: PR to master/dev with path filtering
Runtime: Varies based on changed paths
```

**Purpose**: Unified CI workflow with intelligent path-based execution

**Key Features**:
- Path filtering for backend, frontend, docs
- Delegates to platform-specific workflows
- Reduces unnecessary workflow runs

**Note**: This workflow has some overlap with platform-* workflows. See [Duplication Cleanup Analysis](DUPLICATION_CLEANUP_ANALYSIS.md) for details.

### Automation

#### claude-ci-failure-auto-fix.yml
```yaml
Triggers: workflow_run (when other workflows fail)
Runtime: ~10-20 minutes
```

**Purpose**: Automated CI failure investigation and fixes

**Key Features**:
- Uses anthropics/claude-code-action@v1
- Analyzes failed workflow logs
- Proposes fixes via PR
- Only runs on master/dev branches

**Trigger Conditions**:
- Another workflow completes with status: failure
- Branch is master or dev
- Creates investigation PR with proposed fixes

---

#### claude-dependabot.simplified.yml
```yaml
Triggers: Dependabot PRs
Runtime: ~3-5 minutes
```

**Purpose**: Automated dependency update review

**Key Features**:
- Reviews Dependabot PRs automatically
- Validates dependency changes
- Auto-approves low-risk updates

---

#### claude.yml
```yaml
Triggers: Issue comments with /claude command
Runtime: Varies by task
```

**Purpose**: General-purpose Claude Code automation

**Key Features**:
- Responds to issue comments
- Natural language task automation
- Flexible command handling

**Usage**: Comment `/claude [task description]` on any issue

### Repository Management

#### repo-close-stale-issues.yml
```yaml
Triggers: Daily schedule (midnight UTC)
Runtime: ~1-2 minutes
```

**Purpose**: Close stale issues after inactivity period

---

#### repo-pr-enforce-base-branch.yml
```yaml
Triggers: PR opened/synchronized
Runtime: <1 minute
```

**Purpose**: Enforce PRs target master/dev branches

**Validation**: Ensures PRs don't target feature branches

---

#### repo-pr-label.yml
```yaml
Triggers: PR opened/synchronized
Runtime: <1 minute
```

**Purpose**: Automated PR labeling based on changed paths

**Labels Applied**:
- `backend` - Changes to backend code
- `frontend` - Changes to frontend code
- `docs` - Documentation changes
- `ci` - CI/CD changes

---

#### repo-stats.yml
```yaml
Triggers: Weekly schedule (Sundays)
Runtime: ~5-10 minutes
```

**Purpose**: Generate repository statistics

---

#### repo-workflow-checker.yml
```yaml
Triggers: PR opened/synchronized/reopened, merge_group
Runtime: ~1-2 minutes
```

**Purpose**: Check PR status and required workflows

**Script**: `.github/workflows/scripts/check_actions_status.py`

### Development Environment

#### copilot-setup-steps.yml
```yaml
Triggers: Manual dispatch, push/PR affecting this file
Runtime: ~10-15 min (first), ~5-8 min (cached)
```

**Purpose**: GitHub Copilot development environment setup

**Key Features**:
- Uses mise-action for all tool management
- Docker image caching for faster setup
- Builds migrate service with cache
- Starts Supabase and dependencies
- Validates installations
- Free disk space optimization

**Important**: Job name MUST be `copilot-setup-steps` for GitHub Copilot integration

**Setup Stages**:
1. Checkout code with submodules
2. Setup mise (Python, Poetry, Node.js, pnpm)
3. Install dependencies (Poetry + pnpm)
4. Generate Prisma client
5. Docker image caching
6. Build migrate image with cache
7. Start Docker services
8. Wait for migrations
9. Verify installations

**Docker Services Started**:
- PostgreSQL (Supabase)
- Redis
- RabbitMQ
- ClamAV
- Kong gateway
- Supabase services (GoTrue, Studio, etc.)

## Tool Management: mise-action

All platform and documentation workflows use **[mise-action](https://github.com/jdx/mise-action)** for unified tool management.

### Why mise-action?

- **Dev/CI Parity**: Identical tool versions in local development and CI
- **Single Source of Truth**: `autogpt_platform/mise.toml` defines all tools
- **Automatic Caching**: Built-in GitHub Actions cache integration
- **Simplified Workflows**: No manual Python/Poetry/Node.js setup needed
- **Task Integration**: Can run `mise run` tasks directly in CI

### Standard Configuration

```yaml
- name: Setup mise
  uses: jdx/mise-action@v3
  with:
    version: 2026.1.9  # Latest as of January 2026
    install: true      # Automatically run `mise install`
    cache: true        # Enable GitHub Actions caching
    working_directory: autogpt_platform
```

### Python Version Matrix

Backend CI supports Python version matrix testing:

```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12", "3.13"]

steps:
  - uses: jdx/mise-action@v3
    with:
      version: 2026.1.9
      install: true
      cache: true
      working_directory: autogpt_platform
      install_args: python@${{ matrix.python-version }}
```

### Caching Behavior

mise-action automatically caches tools with key format:
```
mise-v0-<platform>-<mise.toml hash>-<tools hash>
```

**Cache invalidation triggers**:
- mise.toml changes → cache refresh
- Platform changes (Linux/macOS) → separate caches
- Tool version changes → automatic refresh

### Migration History

| Date | Workflows Migrated | Lines Eliminated | Impact |
|------|-------------------|------------------|--------|
| **Jan 2026** | Platform workflows (3) | ~90 lines | Initial migration |
| **Jan 2026** | Documentation workflows (4) | ~120 lines | Phase 2 completion |
| **Total** | 7 workflows | ~210 lines | Dev/CI parity achieved |

**Documentation**: [Migration Complete](MISE_MIGRATION_COMPLETE.md)

### Obsolete Scripts

After mise-action migration, these scripts are **no longer needed**:
- `.github/workflows/scripts/get_package_version_from_lockfile.py` (Poetry version now from mise.toml)

## Best Practices

### Duplication Prevention

**CRITICAL**: Avoid duplicating workflow logic. Use these strategies:

#### 1. Use mise-action for Tool Setup

**✅ CORRECT**:
```yaml
- name: Setup mise
  uses: jdx/mise-action@v3
  with:
    version: 2026.1.9
    install: true
    cache: true
    working_directory: autogpt_platform
```

**❌ INCORRECT** (Don't do this):
```yaml
- uses: actions/setup-python@v6
  with:
    python-version: "3.11"
- name: Install Poetry
  run: curl -sSL https://install.python-poetry.org | python3 -
```

**Why**: mise-action provides dev/CI parity and eliminates duplication.

#### 2. Leverage Composite Actions

For complex multi-step operations repeated across workflows:

**Create**: `.github/actions/action-name/action.yml`

**Example Use Case**: Database setup, complex build steps, custom validation

**Documentation**: [GitHub Composite Actions Guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)

#### 3. Use Workflow Reuse

For entire workflow patterns in multiple contexts:

**Documentation**: [GitHub Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)

#### 4. Centralize Scripts

Place reusable scripts in `.github/workflows/scripts/`:
- `check_actions_status.py` - PR status checking
- Future scripts should follow this pattern

### Version Management

**Current action versions (January 2026)**:

| Action | Version | Notes |
|--------|---------|-------|
| **actions/checkout** | v6 | Latest stable |
| **actions/setup-python** | v6 | ⚠️ Use mise-action instead |
| **actions/setup-node** | v6 | ⚠️ Use mise-action instead |
| **actions/cache** | v5 | New cache service (Feb 2025) |
| **github/codeql-action** | v4 | Node.js 24, v3 deprecates Dec 2026 |
| **docker/setup-buildx-action** | v3 | Current stable |
| **anthropics/claude-code-action** | v1 | GA release |
| **jdx/mise-action** | v3 | Latest (mise 2026.1.9) |

### Security Guidelines

#### 1. Never Use Untrusted Input Directly

**❌ UNSAFE**:
```yaml
run: echo "${{ github.event.issue.title }}"
```

**✅ SAFE**:
```yaml
env:
  TITLE: ${{ github.event.issue.title }}
run: echo "$TITLE"
```

**Risky Context Variables**:
- `github.event.issue.*`
- `github.event.pull_request.*`
- `github.event.comment.*`
- `github.event.commits.*.message`
- `github.head_ref`

**Reference**: [GitHub Actions Security Guide](https://github.blog/security/vulnerability-research/how-to-catch-github-actions-workflow-injections-before-attackers-do/)

#### 2. Minimize Permissions

Use least-privilege `permissions:` blocks:

```yaml
permissions:
  contents: read      # Read repository
  pull-requests: write # Comment on PRs
  # Don't grant unnecessary permissions
```

#### 3. Pin Action Versions

**Current Strategy**: Major version tags (@v6)
- Automatic patch updates
- Security fixes included

**Alternative**: Pin to SHA (@sha256:abc...)
- Maximum security
- No automatic updates

**Trade-off**: Major tags balance security with maintainability

#### 4. Review External Actions

- Use official GitHub or verified publisher actions only
- Review permissions before adding third-party actions
- All current workflows use trusted actions

### Maintenance Schedule

| Frequency | Action | Resources |
|-----------|--------|-----------|
| **Quarterly** | Check for action updates | [GitHub Changelog](https://github.blog/changelog/label/actions/) |
| **Immediate** | Security vulnerabilities | [Security Advisories](https://github.com/advisories) |
| **Immediate** | Deprecation notices | Workflow run warnings |

### Contributing Guidelines

#### 1. Follow Naming Conventions

| Prefix | Purpose | Examples |
|--------|---------|----------|
| `platform-*` | Platform CI/CD | platform-backend-ci.yml |
| `docs-*` | Documentation | docs-block-sync.yml |
| `claude-*` | Automation | claude-code-review.yml |
| `repo-*` | Repository | repo-pr-label.yml |
| `codeql` | Code quality | codeql.yml |

#### 2. Use Conventional Commits

```bash
ci(workflows): update action versions to latest

- actions/checkout: v4 → v6
- actions/setup-python: v5 → v6
- Improves security and compatibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types**: `ci`, `feat`, `fix`, `refactor`, `docs`, `dx`
**Scope**: `workflows`, `backend`, `frontend`, `platform`

#### 3. Test Workflows

**Before Merging**:
1. Add `workflow_dispatch` trigger for manual testing
2. Test on feature branch
3. Validate all jobs pass
4. Check for deprecation warnings

**Example**:
```yaml
on:
  workflow_dispatch:  # Enable manual testing
  pull_request:
    branches: [master, dev]
```

#### 4. Update Documentation

When adding/modifying workflows:
- [ ] Update this guide (WORKFLOW_GUIDE.md)
- [ ] Document purpose and triggers
- [ ] Add runtime expectations
- [ ] Update troubleshooting section if needed

#### 5. Avoid Duplication

**Before Creating New Workflow**:
1. Check existing workflows for similar functionality
2. Consider extending existing workflow with path filters
3. Use composite actions for shared logic
4. Consult [Duplication Cleanup Analysis](DUPLICATION_CLEANUP_ANALYSIS.md)

## Troubleshooting

### Common Issues

#### Workflow Not Triggering

**Symptoms**: Workflow doesn't run on PR/push

**Checks**:
1. Verify path filters match changed files
2. Check branch matches trigger conditions
3. Review workflow permissions
4. Confirm workflow is enabled in Actions tab

**Debug**:
```yaml
on:
  pull_request:
    branches: [master, dev]
    paths:
      - 'autogpt_platform/backend/**'  # Check this matches your changes
```

---

#### Cache Restoration Failures

**Error**:
```
Warning: Cache restore failed
```

**Cause**: actions/cache@v5 uses new cache service (Feb 2025)

**Solution**:
- Clear old cache keys (Settings → Actions → Caches)
- Wait for natural cache expiration
- No action needed if workflow continues successfully

---

#### mise-action Installation Failures

**Error**:
```
Error: mise install failed for tool X
```

**Debugging Steps**:
1. Check `mise.toml` syntax in `autogpt_platform/`
2. Verify `working_directory: autogpt_platform` parameter
3. Review mise-action logs for specific tool errors
4. Test locally: `cd autogpt_platform && mise install`

**Common Issues**:
- Tool version not available
- Network timeout downloading tools
- Incorrect mise.toml configuration

---

#### CodeQL Analysis Failures

**Error**:
```
Error: CodeQL Action v3 is deprecated
```

**Solution**: Already resolved - all workflows use v4 (Jan 2026 update)

**If Still Seeing**: Update workflow to `github/codeql-action@v4`

---

#### Python/Poetry Version Mismatches

**Error**:
```
Error: Poetry lock file is not compatible with this version
```

**Solution with mise-action**:
1. Check mise.toml defines correct Poetry version
2. Run locally: `mise install && poetry lock`
3. Commit updated poetry.lock

**Old Solution** (pre-mise):
Check `.github/workflows/scripts/get_package_version_from_lockfile.py`
(Note: This script is obsolete after mise-action migration)

---

#### Prisma Generate Failures

**Error**:
```
Error: Prisma schema file not found
```

**Solution**:
```yaml
- name: Install dependencies and generate Prisma
  working-directory: autogpt_platform/backend
  run: |
    poetry install --only main
    poetry run prisma generate
```

**Check**:
- Prisma schema exists at `autogpt_platform/backend/backend/data/db.prisma`
- Dependencies installed before running prisma generate

---

#### Docker Build Failures in copilot-setup-steps

**Error**:
```
Error: failed to solve: executor failed running [...]
```

**Common Causes**:
1. Disk space (workflow includes cleanup step)
2. Cache corruption
3. Network issues

**Solution**:
```yaml
# Already included in workflow:
- name: Free up disk space
  run: |
    sudo rm -rf /usr/share/dotnet
    sudo rm -rf /usr/local/lib/android
    sudo docker system prune -af
```

**Manual Fix**: Re-run workflow (cache issues often resolve)

### Getting Help

1. **Check Workflow Logs**: GitHub Actions tab → Failed workflow → Expand failed step
2. **Review Documentation**:
   - This guide (WORKFLOW_GUIDE.md)
   - [Duplication Analysis](DUPLICATION_CLEANUP_ANALYSIS.md)
   - [GitHub Actions Docs](https://docs.github.com/en/actions)
3. **Search Issues**: Check repository issues for similar problems
4. **Ask for Help**: Create issue with workflow logs and error details

## Related Documentation

| Document | Purpose |
|----------|---------|
| **[DUPLICATION_CLEANUP_ANALYSIS.md](DUPLICATION_CLEANUP_ANALYSIS.md)** | Comprehensive 693-line analysis of workflow duplication patterns |
| **[MISE_MIGRATION_COMPLETE.md](MISE_MIGRATION_COMPLETE.md)** | Platform workflow migration to mise-action |
| **[Release Process](../../processes/RELEASE_PROCESS.md)** | Release automation via mise tasks |
| **[GitHub Actions Documentation](https://docs.github.com/en/actions)** | Official GitHub Actions reference |
| **[mise Documentation](https://mise.jdx.dev)** | mise tool version manager |
| **[Serena Workflow Maintenance](.serena/memories/workflow_maintenance.md)** | Workflow maintenance memory |

---

**Last Updated**: January 29, 2026
**Version**: 1.0.0
**Maintainer**: AutoGPT Team

**Generated**: Via Claude Code `/sc:implement` with Phase 3 cleanup roadmap
**Phase**: 3 of 3 (Documentation & Guidelines - COMPLETE)
