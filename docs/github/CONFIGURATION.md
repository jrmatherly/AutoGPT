# GitHub Configuration Guide

**Last Updated:** 2026-01-29
**Status:** Current configurations validated, enhancements available

## Overview

This guide covers GitHub automation configuration including labeler.yml and dependabot.yml. The project uses modern practices with opportunities for enhancement.

**For detailed analysis**, see [.archive/github/workflows/analysis/config_analysis.md](../../.archive/github/workflows/analysis/config_analysis.md)

## Current Status

| Component | Version | Status | Notes |
|-----------|---------|--------|-------|
| **labeler.yml** | v6 | ✅ Current | Modern configuration format |
| **dependabot.yml** | v2 | ✅ Comprehensive | 7 ecosystems monitored |
| **Security** | - | ⚠️ Can enhance | Opportunities for hardening |

## Priority Recommendations

### 1. Enhanced Dependabot Configuration (HIGH)

**Add security-specific grouping:**

```yaml
groups:
  # Security updates - separate PRs for immediate attention
  security-updates:
    applies-to: security-updates
    patterns:
      - "*"

  # Production dependencies - grouped minor/patch
  production-dependencies:
    dependency-type: "production"
    update-types:
      - "minor"
      - "patch"

  # Development dependencies - grouped
  development-dependencies:
    dependency-type: "development"
    update-types:
      - "minor"
      - "patch"
```

**Add labels and specific scheduling:**

```yaml
labels:
  - "dependencies"
  - "python"
  - "backend"

schedule:
  interval: "weekly"
  day: "monday"
  time: "04:00"
  timezone: "UTC"
```

### 2. Enhanced Labeler Patterns (MEDIUM)

**Add branch-based and priority labels:**

```yaml
# Branch-based labels
feature:
  - head-branch: ['^feature/', 'feature']

bugfix:
  - head-branch: ['^bugfix/', '^fix/']

# Infrastructure labels
ci/cd:
  - changed-files:
      - any-glob-to-any-file:
        - '.github/workflows/**'
        - '.github/dependabot.yml'
        - '.github/labeler.yml'

mise/tooling:
  - changed-files:
      - any-glob-to-any-file:
        - 'mise.toml'
        - '**/mise.toml'
        - '.mise/**'

# Priority labels
breaking-change:
  - changed-files:
      - any-glob-to-any-file:
        - 'autogpt_platform/backend/backend/data/migrations/**'

security:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*auth*.py'
        - '**/*auth*.ts'
        - '**/*security*.py'
        - '**/supabase/**'
```

### 3. Security Enhancements (MEDIUM)

**Add dependency review workflow:**

```yaml
# .github/workflows/dependency-review.yml
name: Dependency Review

on:
  pull_request:
    branches: [master, dev]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: moderate
          comment-summary-in-pr: always
```

## Implementation Roadmap

### Phase 1: Immediate (Low Risk)
1. Update `dependabot.yml` with labels and security grouping
2. Enhance `labeler.yml` with branch and priority patterns
3. Add specific schedule times (Monday 4 AM UTC)

### Phase 2: Security (Medium Risk)
1. Add dependency review workflow
2. Consider OpenSSF Scorecard for security metrics
3. Pin critical actions to commit SHA

### Phase 3: Automation (Higher Risk)
1. Dependabot auto-merge for patch/minor updates
2. Label synchronization workflow
3. PR size labeling

## Testing

```bash
# Validate YAML syntax
yamllint .github/labeler.yml
yamllint .github/dependabot.yml

# Test on draft PR
gh pr create --draft --title "test: config validation"
```

## References

- **Detailed Analysis:** [.archive/github/workflows/analysis/config_analysis.md](../../.archive/github/workflows/analysis/config_analysis.md)
- **Implementation Steps:** Removed (consolidated into this guide)
- [GitHub Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [GitHub Actions Labeler](https://github.com/actions/labeler)

## Monitoring

After implementing changes, monitor:
- **Week 1:** Label application accuracy
- **Week 2:** Dependabot PR volume (expect 30-50% reduction)
- **Month 1:** Security scan findings

## Change Log

- **2026-01-29:** Consolidated configuration guide created
- Original analysis: 2026-01-29 (archived)
