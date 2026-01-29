# GitHub Actions Workflow Maintenance

## Last Updated
- **Date**: January 29, 2026
- **Commit**: f2c8f623d - ci(workflows): update GitHub Actions to latest versions
- **Updated Files**: 5 workflow files in `.github/workflows/`

## Current Action Versions (January 2026)

### Core Actions
| Action | Current Version | Last Updated | Notes |
|--------|----------------|--------------|-------|
| **actions/checkout** | v6 | Jan 2026 | Latest stable |
| **actions/setup-python** | v6 | Jan 2026 | Enhanced caching support |
| **actions/setup-node** | v6 | Jan 2026 | Auto-caching with packageManager field |
| **actions/cache** | v5 | Jan 2026 | New cache service (Feb 2025), requires runner v2.327.1+ |
| **github/codeql-action** | v4 | Jan 2026 | Uses Node.js 24, v3 deprecates Dec 2026 |
| **docker/setup-buildx-action** | v3 | Current | v3.12.0 latest |
| **anthropics/claude-code-action** | v1 | Current | v1 GA (General Availability) |

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

### Other Workflows (Not Updated Jan 2026)
- platform-backend-ci.yml
- platform-frontend-ci.yml
- platform-fullstack-ci.yml
- platform-autogpt-deploy-prod.yml
- claude-ci-failure-auto-fix.yml
- claude-dependabot.yml
- claude-code-review.yml
- claude.yml
- ci.yml, ci-mise.yml, ci.enhanced.yml
- repo-* workflows (labels, stats, stale issues, etc.)

**Note**: These workflows may also benefit from action updates in future maintenance.

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
