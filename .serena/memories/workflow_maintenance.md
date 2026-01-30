# GitHub Actions Workflow Maintenance

## Last Updated
- **Date**: January 29, 2026
- **Commit**: e37cbd7a6 - docs(workflows): create comprehensive workflow guide for contributor onboarding
- **Updated Files**: Created WORKFLOW_GUIDE.md (881 lines) - complete workflow reference documentation

## Current Action Versions (January 2026)

### Core Actions
| Action | Current Version | Last Updated | Notes |
|--------|----------------|--------------|-------|
| **actions/checkout** | v6 | Jan 2026 | Latest stable |
| **actions/setup-python** | v6 | Jan 2026 | ⚠️ Replaced by mise-action in platform workflows |
| **actions/setup-node** | v6 | Jan 2026 | ⚠️ Replaced by mise-action in platform workflows |
| **actions/cache** | v5 | Jan 2026 | New cache service (Feb 2025), requires runner v2.327.1+ |
| **github/codeql-action** | v4 | Jan 2026 | Uses Node.js 24, v3 deprecates Dec 2026 |
| **docker/setup-buildx-action** | v3 | Current | v3.12.0 latest |
| **anthropics/claude-code-action** | v1 | Current | v1 GA (General Availability) |
| **jdx/mise-action** | v3 | Jan 2026 | **NEW**: Unified tool management for platform workflows |
| **chromaui/action** | v11 | Jan 2026 | **UPDATED**: Pinned from @latest for security |

### Runner Requirements
- All current actions require GitHub Actions runner **v2.327.1+**
- GitHub-hosted runners (ubuntu-latest, macos-latest) automatically support this
- No self-hosted runners in use for this project

## Workflow Files in AutoGPT

### Documentation Workflows (5 files updated Jan 2026)
1. **codeql.yml** - CodeQL security scanning
   - Runs on: push to master/dev, PRs, weekly schedule
   - Language: TypeScript, Python
   - Critical: Uses CodeQL v4 (v3 deprecates Dec 2026)

2. **copilot-setup-steps.yml** - GitHub Copilot environment setup
   - Sets up: Python/Poetry, Node/pnpm, Docker, Supabase
   - Most complex setup (Docker caching, multi-language)

3. **docs-block-sync.yml** - Block documentation sync validation
   - Validates: Block docs match code
   - Runs: On push/PR to master/dev when blocks or docs change

4. **docs-claude-review.yml** - Claude Code PR review for docs
   - Reviews: Block documentation PRs
   - Uses: anthropics/claude-code-action@v1
   - Only runs for: OWNER, MEMBER, COLLABORATOR authors

5. **docs-enhance.yml** - LLM-powered documentation enhancement
   - Manual trigger: workflow_dispatch
   - Uses: anthropics/claude-code-action@v1
   - Enhances: Block documentation with AI

### Platform Workflows (Migrated to mise-action Jan 2026)
- **platform-backend-ci.yml** - ✅ Using jdx/mise-action@v3 with mise 2026.1.9 + LiteLLM Proxy support
- **platform-frontend-ci.yml** - ✅ Using jdx/mise-action@v3 with mise 2026.1.9 + LiteLLM Proxy support
- **platform-fullstack-ci.yml** - ✅ Using jdx/mise-action@v3 with mise 2026.1.9

**Migration Benefits**:
- Dev/CI parity: Same tool versions defined in `autogpt_platform/mise.toml`
- Code reduction: ~85% fewer lines (390 → 60 lines of setup code)
- Eliminated manual Poetry installation script
- Automatic caching via mise-action
- Security: Pinned chromaui/action to v11

**LiteLLM Proxy Integration** (Jan 2026):
- Optional `LITELLM_PROXY_URL` secret support in E2E workflows
- Routes OpenAI API calls through self-hosted LiteLLM Proxy
- Backend supports `OPENAI_BASE_URL` and `OPENAI_INTERNAL_BASE_URL` configuration
- Full backward compatibility maintained

**Details**: 
- Migration: `.github/workflows/MISE_MIGRATION_COMPLETE.md`
- LiteLLM Integration: `.serena/memories/litellm_proxy_configuration.md`
- Workflows Guide: `docs/github/workflows/WORKFLOWS.md`
- Configuration Guide: `docs/github/CONFIGURATION.md`
- Documentation Guide: `docs/github/DOCUMENTATION.md`

### Other Workflows (Not Updated)
- platform-autogpt-deploy-prod.yml
- claude-ci-failure-auto-fix.yml
- claude-dependabot.yml
- claude-code-review.yml
- claude.yml
- ci.yml, ci-mise.yml, ci.enhanced.yml
- repo-* workflows (labels, stats, stale issues, etc.)

**Note**: These workflows may also benefit from action updates in future maintenance.

## mise-action Configuration (Platform Workflows)

### What is mise?
[mise](https://mise.jdx.dev) is a polyglot tool version manager that replaces asdf, nvm, pyenv, rbenv, etc. It's the official development tool manager for the AutoGPT Platform, configured in `autogpt_platform/mise.toml`.

### Why mise-action?
- **Dev/CI Parity**: Identical tool versions between local development and CI
- **Single Source of Truth**: `mise.toml` defines all tool versions
- **Automatic Caching**: Built-in GitHub Actions cache integration
- **Simplified Workflows**: Eliminates manual setup scripts
- **Task Integration**: Can run `mise run` tasks directly in CI

### Current Configuration
All platform workflows use:
```yaml
- name: Setup mise
  uses: jdx/mise-action@v3
  with:
    version: 2026.1.9  # Latest stable release
    install: true      # Automatically run `mise install`
    cache: true        # Enable GitHub Actions caching
    working_directory: autogpt_platform
```

### Python Matrix Testing
Backend CI preserves Python version matrix testing:
```yaml
strategy:
  matrix:
    python-version: ["3.11", "3.12", "3.13"]

steps:
  - uses: jdx/mise-action@v3
    with:
      install_args: python@${{ matrix.python-version }}
```

### Caching Behavior
mise-action automatically caches tools with key format:
```
mise-v0-<platform>-<mise.toml hash>-<tools hash>
```

Cache invalidation:
- mise.toml changes → cache refresh
- Platform changes (Linux/macOS) → separate caches
- Tool version changes → automatic refresh

### Obsolete Scripts
After mise-action migration, the following script is **no longer needed**:
- `.github/workflows/scripts/get_package_version_from_lockfile.py`

Reason: Poetry version now managed by mise.toml instead of extracted from lockfile.

## Maintenance Schedule

### Quarterly Review (Every 3 Months)
- Check for new action versions
- Review deprecation notices from GitHub
- Update workflows proactively before deprecations

### Critical Updates (Immediate)
- Security vulnerabilities in actions
- Breaking changes announced by action maintainers
- Deprecation warnings in GitHub Actions runs

### Resources for Checking Updates
- [GitHub Actions Changelog](https://github.blog/changelog/label/actions/)
- [actions/checkout releases](https://github.com/actions/checkout/releases)
- [actions/setup-python releases](https://github.com/actions/setup-python/releases)
- [actions/setup-node releases](https://github.com/actions/setup-node/releases)
- [actions/cache releases](https://github.com/actions/cache/releases)
- [CodeQL Action releases](https://github.com/github/codeql-action/releases)
- [Claude Code Action docs](https://code.claude.com/docs/en/github-actions)

## Update Process

### Step 1: Research Latest Versions
```bash
# Use web search for latest versions
# Example queries:
# - "GitHub Actions latest versions 2026"
# - "CodeQL action latest version"
# - "actions/cache v5 changelog"
```

### Step 2: Validate Compatibility
- Check runner version requirements
- Review breaking changes in release notes
- Ensure no self-hosted runner compatibility issues

### Step 3: Update Workflow Files
```bash
# Edit workflow files directly
# Pattern: uses: action-name@vX → uses: action-name@vY
```

### Step 4: Commit with Conventional Format
```bash
git commit -m "ci(workflows): update GitHub Actions to latest versions

[Detailed description of updates]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Step 5: Test Workflows
- Monitor workflow runs after merge
- Check for deprecation warnings
- Verify all jobs complete successfully

## Duplication Cleanup Roadmap (January 2026)

**Comprehensive Analysis**: `docs/github/workflows/DUPLICATION_CLEANUP_ANALYSIS.md` (693 lines)

A systematic analysis of all 20 workflow files identified 5 major duplication patterns and created a 3-phase cleanup roadmap.

### Phase 1: Action Version Standardization (✅ COMPLETE)

**Status**: ✅ Complete (commit not tracked - completed earlier)

**Target**: Standardize all workflows to latest action versions

Updated actions:
- actions/checkout: @v4 → @v6 (9 workflows)
- actions/setup-python: @v5 → @v6 (1 workflow)
- actions/setup-node: @v4 → @v6 (1 workflow)

**Impact**: Security improvements, 100% version consistency
**Effort**: 30 minutes
**Risk**: Very low

### Phase 2: Migrate Documentation Workflows to mise-action (✅ COMPLETE)

**Status**: ✅ Complete (commit 0621d9822)

**Target**: Migrate 4 documentation workflows to use mise-action for dev/CI parity

Migrated workflows:
- docs-enhance.yml (~25 lines → mise-action)
- docs-block-sync.yml (~25 lines → mise-action)
- docs-claude-review.yml (~25 lines → mise-action)
- copilot-setup-steps.yml (~45 lines → mise-action)

**Pattern Used**:
```yaml
- name: Setup mise
  uses: jdx/mise-action@v3
  with:
    version: 2026.1.9  # Latest as of January 2026
    install: true
    cache: true
    working_directory: autogpt_platform
```

**Impact**: 
- ~120 lines of duplicated setup code eliminated
- Dev/CI parity achieved using same mise.toml configuration
- Automatic caching via mise-action
- Unified tool management (Python, Poetry, Node.js, pnpm)

**Note**: Initial approach attempted composite action, but pivoted to mise-action per project standards

### Phase 3: Documentation & Guidelines (✅ COMPLETE)

**Status**: ✅ Complete (commit e37cbd7a6)

**Target**: Create comprehensive workflow guide for contributor onboarding

**Deliverable**: `docs/github/workflows/WORKFLOW_GUIDE.md` (881 lines)

**Contents**:
- Complete reference for all 20 workflows
- Tool management guide (mise-action)
- Best practices (duplication prevention, security, version management)
- Troubleshooting guide for common issues
- Contributing guidelines with examples

**Impact**: 
- Improved contributor onboarding with comprehensive reference
- Duplication prevention guidelines documented
- Security best practices with code examples
- Troubleshooting reduces time-to-resolution

**Analysis Details**: See `docs/github/workflows/DUPLICATION_CLEANUP_ANALYSIS.md` for complete implementation guides, risk assessments, and success metrics.

## Common Duplication Patterns

### Python/Poetry Setup (4 workflows)
The following pattern appears in 4 workflows:
- copilot-setup-steps.yml
- docs-block-sync.yml
- docs-claude-review.yml
- docs-enhance.yml

**Pattern**:
```yaml
- uses: actions/setup-python@v6
  with:
    python-version: "3.11"

- uses: actions/cache@v5
  with:
    path: ~/.cache/pypoetry
    key: poetry-${{ runner.os }}-${{ hashFiles('autogpt_platform/backend/poetry.lock') }}

- name: Install Poetry
  run: |
    cd autogpt_platform/backend
    HEAD_POETRY_VERSION=$(python3 ../../.github/workflows/scripts/get_package_version_from_lockfile.py poetry)
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=$HEAD_POETRY_VERSION python3 -
    echo "$HOME/.local/bin" >> $GITHUB_PATH
```

**Future Optimization**: Consider creating a composite action at `.github/actions/setup-python-poetry/action.yml` to eliminate this duplication (~100 lines of YAML).

**Update (Jan 2026)**: Platform workflows now use mise-action instead of manual Python/Poetry setup, eliminating duplication there. Documentation workflows still use manual setup.

## Deprecation Timeline

### Upcoming Deprecations (As of Jan 2026)
- **CodeQL Action v3**: Deprecates December 2026
  - Reason: Node.js 20 EOL April 2026
  - Migration: Use v4 (already completed)
- **Node.js 20**: EOL April 30, 2026
  - Impact: Actions using Node 20 will need updates

### Completed Migrations
- ✅ CodeQL Action v2 → v3 (v2 deprecated Jan 2025)
- ✅ actions/cache v4 → v5 (new cache service Feb 2025)
- ✅ All actions to latest versions (Jan 2026)

## Troubleshooting

### Common Issues

**Runner Version Errors**
```
Error: This action requires a minimum Actions runner version of 2.327.1
```
Solution: GitHub-hosted runners automatically support this. If using self-hosted runners, upgrade runner version.

**Cache Restoration Failures**
```
Warning: Cache restore failed
```
Solution: Cache v5 uses new service. Clear old cache keys or let them expire naturally.

**CodeQL Analysis Failures**
```
Error: CodeQL Action v3 is deprecated
```
Solution: Update to v4 (already completed in Jan 2026 update).

## Security Considerations

### Action Version Pinning
- We use major version tags (@v4, @v6) for automatic patch updates
- Alternative: Pin to specific SHA for maximum security (e.g., @sha256:abc123...)
- Trade-off: Major version tags get security updates automatically

### Dependabot for Actions
- GitHub Dependabot can automatically create PRs for action updates
- Currently not enabled for this repository
- Consider enabling in repository settings if desired

### Action Security
- All actions used are official GitHub or Anthropic maintained
- No third-party untrusted actions in critical workflows
- Review action permissions regularly (see `permissions:` sections)

## Release Automation (Added January 2026)

### Release Process

The AutoGPT Platform uses automated release management via mise tasks:

**Script**: `scripts/release.sh` (executable bash script)
**Tasks**: Defined in root `mise.toml`

### Key Features

1. **Monorepo Version Synchronization**
   - Atomically updates 3 version files:
     * `autogpt_platform/frontend/package.json`
     * `autogpt_platform/backend/pyproject.toml`
     * `autogpt_platform/autogpt_libs/pyproject.toml`
   - Detects and resolves version mismatches on first run
   - Ensures all packages share same version number

2. **Semantic Versioning**
   - major: Breaking changes (v1.2.3 → v2.0.0)
   - minor: New features (v1.2.3 → v1.3.0)
   - patch: Bug fixes (v1.2.3 → v1.2.4)

3. **Automated Workflow**
   - Generates release notes from commit history
   - Creates git tags with annotations
   - Creates GitHub releases via `gh` CLI
   - Triggers `platform-autogpt-deploy-prod.yml` deployment

### Usage

```bash
# Interactive release (recommended)
mise run release

# Auto-confirm releases
mise run release:patch  # vX.Y.Z → vX.Y.Z+1
mise run release:minor  # vX.Y.Z → vX.Y+1.0
mise run release:major  # vX.Y.Z → vX+1.0.0

# Specific version
mise run release v1.2.3
```

### Prerequisites

- Clean working directory (no uncommitted changes)
- GitHub CLI authenticated (`gh auth login`)
- Run from workspace root (mise handles path resolution)

### Documentation

Complete release documentation: `docs/processes/RELEASE_PROCESS.md`

Includes:
- Version synchronization strategy
- Usage examples and troubleshooting
- Rollback procedures
- Best practices for conventional commits
- CI/CD integration details
