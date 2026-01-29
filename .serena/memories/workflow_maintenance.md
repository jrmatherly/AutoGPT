# GitHub Actions Workflow Maintenance

## Last Updated
- **Date**: January 29, 2026
- **Commit**: PENDING - ci(workflows): migrate to mise-action for unified tool management
- **Updated Files**: 3 platform workflows + 5 documentation workflows (8 total in `.github/workflows/`)

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
- **platform-backend-ci.yml** - ✅ Using jdx/mise-action@v3 with mise 2026.1.9
- **platform-frontend-ci.yml** - ✅ Using jdx/mise-action@v3 with mise 2026.1.9
- **platform-fullstack-ci.yml** - ✅ Using jdx/mise-action@v3 with mise 2026.1.9

**Migration Benefits**:
- Dev/CI parity: Same tool versions defined in `autogpt_platform/mise.toml`
- Code reduction: ~85% fewer lines (390 → 60 lines of setup code)
- Eliminated manual Poetry installation script
- Automatic caching via mise-action
- Security: Pinned chromaui/action to v11

**Details**: See `.github/workflows/MISE_MIGRATION_COMPLETE.md`

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
