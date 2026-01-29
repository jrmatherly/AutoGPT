# GitHub Actions Workflow Scripts

This directory contains shell scripts used by GitHub Actions workflows in this repository.

## Scripts

### docker-build-summary-unified.sh (Recommended)

**Status:** ✅ Production-ready, consolidated replacement

Unified script that generates detailed Markdown summaries of Docker builds for both CI and release workflows.

**Features:**
- Comprehensive error handling with strict mode
- Input validation for all required variables
- Dependency checking (docker, jq, etc.)
- ShellCheck compliant (with configuration)
- Debug and dry-run modes
- Modular function design
- Complete documentation

**Usage:**
```bash
# CI mode
docker-build-summary-unified.sh ci

# Release mode
docker-build-summary-unified.sh release

# Debug mode
DEBUG=true docker-build-summary-unified.sh ci

# Dry run (validate only)
DRY_RUN=true docker-build-summary-unified.sh release

# Help
docker-build-summary-unified.sh --help
```

**Required Environment Variables:**

Common (all modes):
- `IMAGE_NAME` - Docker image name with tag
- `current_ref` - Current git ref (branch/tag)
- `commit_hash` - Full commit SHA
- `repository` - Repository name
- `source_url` - URL to source commit
- `github_context_json` - GitHub context JSON
- `vars_json` - Workflow vars context
- `job_env_json` - Job environment JSON

CI mode additional:
- `base_branch` - Base branch name
- `build_type` - Build type label
- `compare_url_template` - URL template for comparisons
- `event_name` - GitHub event name
- `event_ref` - Event ref
- `new_commits_json` - JSON array of new commits
- `push_forced_label` - (optional) Forced push indicator

Release mode additional:
- `ref_type` - Ref type (tag/branch)
- `event_name` - GitHub event name
- `inputs_no_cache` - No-cache build parameter

**Exit Codes:**
- `0` - Success
- `1` - General error
- `2` - Missing dependency
- `3` - Invalid arguments or missing required variables
- `4` - Docker command failed

### docker-ci-summary.sh (Legacy)

**Status:** ⚠️ Legacy, consider migrating to unified script

Original CI build summary generator. Works but lacks error handling and modern best practices.

**Issues:**
- No error handling (no `set -euo pipefail`)
- Multiple ShellCheck violations (unquoted variables, legacy syntax)
- No input validation
- No dependency checking
- High code duplication with docker-release-summary.sh

**Recommendation:** Migrate to `docker-build-summary-unified.sh`

### docker-release-summary.sh (Legacy)

**Status:** ⚠️ Legacy, consider migrating to unified script

Original release build summary generator. Works but lacks error handling and modern best practices.

**Issues:**
- Same issues as docker-ci-summary.sh
- 85% code duplication with docker-ci-summary.sh

**Recommendation:** Migrate to `docker-build-summary-unified.sh`

## Development

### Testing

Run ShellCheck on all scripts:
```bash
shellcheck *.sh
```

The unified script includes comprehensive validation:
```bash
# Validate environment without generating output
DRY_RUN=true ./docker-build-summary-unified.sh ci
```

### ShellCheck Configuration

The `.shellcheckrc` file configures ShellCheck for GitHub Actions environment:
- Disables SC2154 (external variables) since variables come from workflow env
- Enables all other checks
- Sets severity to "style" for comprehensive checking

### Code Quality Standards

All new scripts should:
- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -Eeuo pipefail`
- Quote all variable expansions
- Validate inputs and dependencies
- Include comprehensive documentation
- Pass ShellCheck without warnings
- Include error handling with traps
- Support `--help` and `--version` flags

### Migration Guide

To migrate from legacy scripts to unified script:

1. **Update workflow file:**
   ```yaml
   # Old
   - name: Generate summary
     run: ./.github/workflows/scripts/docker-ci-summary.sh
     env:
       IMAGE_NAME: ${{ env.IMAGE_NAME }}
       # ... other vars ...

   # New
   - name: Generate summary
     run: ./.github/workflows/scripts/docker-build-summary-unified.sh ci
     env:
       IMAGE_NAME: ${{ env.IMAGE_NAME }}
       # ... other vars ...
   ```

2. **Test in non-production workflow first**

3. **Verify output format matches expectations**

4. **Remove old script once migration confirmed**

## Analysis

See [ANALYSIS.md](ANALYSIS.md) for detailed analysis of:
- Code quality issues
- Security considerations
- Performance optimization opportunities
- Consolidation recommendations
- Modern Bash best practices

## Contributing

When adding new workflow scripts:

1. Start from the unified script as a template
2. Follow the code quality standards above
3. Document all required environment variables
4. Add usage examples
5. Include error handling
6. Run ShellCheck before committing
7. Consider adding test cases

## License

These scripts are part of the Auto-GPT project and subject to the Polyform Shield License.