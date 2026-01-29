# GitHub Configuration Analysis & Enhancement Recommendations

**Analysis Date:** 2026-01-29
**Scope:** `.github/labeler.yml`, `.github/dependabot.yml`, and related workflows
**Target:** Validate current versions and identify enhancement opportunities

---

## Executive Summary

This analysis reviews AutoGPT's GitHub automation configuration against January 2026 best practices. The project is **already using current best practices** in most areas, with several opportunities for enhancement identified.

### Current Status
- ✅ **labeler.yml**: Using modern v6 configuration (GOOD)
- ✅ **dependabot.yml**: Comprehensive ecosystem coverage (GOOD)
- ✅ **Workflow**: Using actions/labeler@v6 (CURRENT)
- ⚠️ **Opportunities**: Security hardening, additional features, and optimization available

---

## 1. Labeler Configuration Analysis

### Current State: `.github/labeler.yml`

**File:** `.github/labeler.yml`
**Last Updated:** Using v6 configuration format
**Status:** ✅ **CURRENT AND VALID**

```yaml
documentation:
  - changed-files:
      - any-glob-to-any-file: docs/**

platform/frontend:
  - changed-files:
      - any-glob-to-any-file: autogpt_platform/frontend/**

platform/backend:
  - changed-files:
      - all-globs-to-any-file:
          - autogpt_platform/backend/**
          - "!autogpt_platform/backend/backend/blocks/**"

platform/blocks:
  - changed-files:
      - any-glob-to-any-file: autogpt_platform/backend/backend/blocks/**
```

### Workflow Integration: `.github/workflows/repo-pr-label.yml`

**Current Version:** Using `actions/labeler@v6` ✅
**Permissions:** Correctly configured with least privilege
**Trigger:** Using `pull_request_target` (recommended for fork PRs)

```yaml
scope:
  if: ${{ github.event_name == 'pull_request_target' }}
  permissions:
    contents: read
    pull-requests: write
  runs-on: ubuntu-latest
  steps:
    - uses: actions/labeler@v6
      with:
        sync-labels: true
```

### Research Findings

According to the [official actions/labeler repository](https://github.com/actions/labeler):

- **Latest Version:** v6 (released 2026, upgraded to node24)
- **Breaking Changes:** v6 has a redesigned configuration format (not compatible with v5)
- **Runner Requirements:** Requires runner version v2.327.1+ for node24 compatibility
- **Key Features:**
  - Apply labels based on changed files (path globs) ✅ Currently using
  - Apply labels based on branch names (regexp) ❌ Not currently using
  - Support for up to 100 labels (API limit)
  - Better error handling

**Sources:**
- [GitHub Actions Labeler](https://github.com/actions/labeler)
- [Labeler Marketplace](https://github.com/marketplace/actions/labeler)
- [GitHub Actions labeler.yml best practices 2026](https://www.google.com/search?q=GitHub+Actions+labeler.yml+best+practices+2026+latest+version)

### ✅ Strengths

1. **Using Latest Version:** Already on v6 (node24)
2. **Proper Permissions:** Least privilege principle applied
3. **Correct Trigger:** Using `pull_request_target` for fork compatibility
4. **Sync Labels:** Enabled to remove stale labels
5. **Clear Organization:** Labels map to monorepo structure

### 🔄 Enhancement Opportunities

#### 1. Add Branch-Based Labeling

**Benefit:** Automatically label PRs based on branch naming conventions

```yaml
# Enhanced labeler.yml with branch patterns
feature/*:
  - head-branch: ['^feature/', 'feature']

bugfix/*:
  - head-branch: ['^bugfix/', 'fix/']

hotfix/*:
  - head-branch: ['^hotfix/']

release/*:
  - head-branch: ['^release/']

dependencies:
  - head-branch: ['^dependabot/']

# CI/Infra changes
ci/cd:
  - changed-files:
      - any-glob-to-any-file:
        - '.github/workflows/**'
        - '.github/dependabot.yml'
        - '.github/labeler.yml'
        - 'mise.toml'
        - 'autogpt_platform/mise.toml'

infrastructure:
  - changed-files:
      - any-glob-to-any-file:
        - 'autogpt_platform/infra/**'
        - 'docker-compose*.yml'
        - 'Dockerfile*'

# Testing
tests:
  - changed-files:
      - any-glob-to-any-file:
        - '**/test/**'
        - '**/*test*.py'
        - '**/*.spec.ts'
        - '**/*.test.ts'

# Configuration
configuration:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*.toml'
        - '**/*.yaml'
        - '**/*.yml'
        - '**/.env*'
        - '**/mise.lock'
```

#### 2. Add Priority/Type Labels

```yaml
breaking-change:
  - changed-files:
      - any-glob-to-any-file:
        - 'autogpt_platform/backend/backend/data/migrations/**'
        - '**/BREAKING_CHANGES.md'
  - body-contains: ['BREAKING CHANGE', 'breaking change']

security:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*auth*.py'
        - '**/*security*.py'
        - '**/supabase/**'
  - body-contains: ['security', 'vulnerability', 'CVE']

performance:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*cache*.py'
        - '**/*perf*.py'
  - body-contains: ['performance', 'optimization', 'slow']

documentation:
  - changed-files:
      - any-glob-to-any-file:
        - 'docs/**'
        - '**/*.md'
        - '**/CLAUDE.md'
```

#### 3. Add Mise/Tooling Labels

```yaml
mise/tooling:
  - changed-files:
      - any-glob-to-any-file:
        - 'mise.toml'
        - '**/mise.toml'
        - 'mise.lock'
        - '.mise/**'
        - '.tool-versions'

dependencies/python:
  - changed-files:
      - any-glob-to-any-file:
        - '**/poetry.lock'
        - '**/pyproject.toml'

dependencies/node:
  - changed-files:
      - any-glob-to-any-file:
        - '**/pnpm-lock.yaml'
        - '**/package.json'
```

---

## 2. Dependabot Configuration Analysis

### Current State: `.github/dependabot.yml`

**Version:** 2 ✅
**Status:** ✅ **COMPREHENSIVE AND WELL-CONFIGURED**

**Current Ecosystems Monitored:**
1. ✅ Python/pip (autogpt_libs)
2. ✅ Python/pip (backend)
3. ✅ npm (frontend)
4. ✅ Terraform (infra)
5. ✅ GitHub Actions
6. ✅ Docker
7. ✅ Python/pip (docs)

### Research Findings

According to [GitHub Dependabot documentation](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuring-dependabot-version-updates) and [Dependabot best practices (2026)](https://nesbitt.io/2026/01/10/16-best-practices-for-reducing-dependabot-noise.html):

**Critical 2026 Update:**
- ⚠️ **Reviewers Configuration Deprecated:** The `reviewers` option is being replaced by CODEOWNERS
- ✅ **Migration Required:** Must use `.github/CODEOWNERS` instead (you already have this file!)

**Sources:**
- [Dependabot reviewers configuration being replaced](https://github.blog/changelog/2025-04-29-dependabot-reviewers-configuration-option-being-replaced-by-code-owners/)
- [Dependabot configuration best practices 2026](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuring-dependabot-version-updates)
- [Reducing Dependabot Noise - 16 Best Practices](https://nesbitt.io/2026/01/10/16-best-practices-for-reducing-dependabot-noise.html)

### ✅ Strengths

1. **Comprehensive Coverage:** All 7 major ecosystems monitored
2. **Proper Grouping:** Using dependency groups to reduce PR noise
3. **Conventional Commits:** Proper commit message prefixes
4. **Target Branch:** Correctly targeting `dev` branch
5. **Weekly Schedule:** Balanced update frequency
6. **Reasonable Limits:** 1-10 PRs per ecosystem

### 🔄 Enhancement Opportunities

#### 1. Add Security Update Configuration

**Benefit:** Separate security updates from version updates for faster patching

```yaml
version: 2

# Enable security updates with higher priority
updates:
  # autogpt_libs (Poetry project)
  - package-ecosystem: "pip"
    directory: "autogpt_platform/autogpt_libs"
    schedule:
      interval: "weekly"
      day: "monday"  # Specific day for predictability
      time: "04:00"  # Off-peak hours
    open-pull-requests-limit: 10
    target-branch: "dev"

    # Labels for better organization
    labels:
      - "dependencies"
      - "python"
      - "autogpt_libs"

    # Milestone integration (optional)
    # milestone: 10

    commit-message:
      prefix: "chore(libs/deps)"
      prefix-development: "chore(libs/deps-dev)"
      include: "scope"

    # Ignore Poetry itself
    ignore:
      - dependency-name: "poetry"

    # Grouping configuration
    groups:
      # Security updates get their own PR
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      # Production dependencies
      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

      # Development dependencies
      development-dependencies:
        dependency-type: "development"
        update-types:
          - "minor"
          - "patch"
```

#### 2. Add Labels for All Ecosystems

**Current:** No labels configured
**Recommendation:** Add labels for better PR organization

```yaml
# Example for backend
- package-ecosystem: "pip"
  directory: "autogpt_platform/backend"
  schedule:
    interval: "weekly"
    day: "monday"
    time: "04:00"
  open-pull-requests-limit: 10
  target-branch: "dev"

  labels:
    - "dependencies"
    - "python"
    - "backend"

  commit-message:
    prefix: "chore(backend/deps)"
    prefix-development: "chore(backend/deps-dev)"
    include: "scope"
```

#### 3. Add Version Constraints (Optional)

**Benefit:** Control update aggressiveness per dependency

```yaml
# Example: Pin critical dependencies
ignore:
  - dependency-name: "poetry"
  - dependency-name: "fastapi"
    update-types: ["version-update:semver-major"]  # Only minor/patch
  - dependency-name: "prisma"
    update-types: ["version-update:semver-major"]  # Only minor/patch
```

#### 4. Separate Security Updates from Version Updates

**Recommended Configuration:**

```yaml
groups:
  # Security updates - highest priority, separate PRs
  security-updates:
    applies-to: security-updates
    patterns:
      - "*"

  # Production dependencies - grouped by minor/patch
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

#### 5. Add Rebase Strategy

**Benefit:** Keep PRs up-to-date automatically

```yaml
rebase-strategy: "auto"  # or "disabled" if you prefer manual control
```

#### 6. Add Specific Schedule Times

**Benefit:** Predictable update timing, avoid peak hours

```yaml
schedule:
  interval: "weekly"
  day: "monday"      # Run every Monday
  time: "04:00"      # 4 AM UTC (off-peak)
  timezone: "UTC"
```

---

## 3. Security & Permissions Best Practices

### Current Security Posture

**Analysis Based on:** [GitHub Actions Security Best Practices (2026)](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)

#### ✅ Current Strengths

1. **Least Privilege Permissions** (repo-pr-label.yml:23-25, 38-40, 59-61)
   - Correctly scoped `contents: read` and `pull-requests: write`
   - No overly broad permissions

2. **Pinned Action Versions**
   - Using `@v6` for labeler (semantic versioning)
   - ⚠️ Could be more secure with commit SHA pinning

3. **Proper Trigger Usage**
   - Using `pull_request_target` for fork PR access
   - Appropriate concurrency controls

4. **Secrets Management**
   - Using `GITHUB_TOKEN` (automatic token)
   - Not exposing long-lived credentials

**Sources:**
- [GitHub Actions Security Best Practices](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)
- [GitHub Actions Security Cheat Sheet](https://www.stepsecurity.io/blog/github-actions-security-best-practices)
- [GitHub Actions Permissions Guide](https://docs.github.com/en/actions/reference/security/secure-use)

#### 🔒 Security Enhancement Recommendations

##### 1. Pin Actions to Commit SHA (Highest Security)

**Current:**
```yaml
- uses: actions/labeler@v6
```

**Enhanced (Maximum Security):**
```yaml
# Pin to specific commit SHA for immutability
- uses: actions/labeler@8558fd74291d67161a8a78ce36a881fa63b766a9  # v6.0.0
```

**Note:** This prevents supply chain attacks but requires manual updates.

**Trade-off Analysis:**
- ✅ **Pros:** Prevents malicious code injection, immutable reference
- ❌ **Cons:** Requires manual updates, less readable
- **Recommendation:** Use for critical workflows (CI/CD, deployments)

##### 2. Add Dependency Review Action

**Purpose:** Automatically detect vulnerable dependencies in PRs

```yaml
# New workflow: .github/workflows/dependency-review.yml
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
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: moderate
          deny-licenses: GPL-2.0, GPL-3.0
          comment-summary-in-pr: always
```

##### 3. Add OpenSSF Scorecard

**Purpose:** Automated security best practice checks

```yaml
# New workflow: .github/workflows/scorecard.yml
name: OpenSSF Scorecard

on:
  branch_protection_rule:
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM
  push:
    branches: [master]

permissions: read-all

jobs:
  analysis:
    name: Scorecard analysis
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      id-token: write
      contents: read
      actions: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      - name: Run analysis
        uses: ossf/scorecard-action@v2
        with:
          results_file: results.sarif
          results_format: sarif
          publish_results: true

      - name: Upload SARIF results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif
```

##### 4. Enhance Concurrency Controls

**Current:** Basic concurrency in repo-pr-label.yml
**Enhanced:** Add to all workflows

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

---

## 4. Integration & Automation Enhancements

### 1. Automated Dependabot PR Handling

**Purpose:** Auto-approve and merge low-risk Dependabot PRs

```yaml
# New workflow: .github/workflows/dependabot-auto-merge.yml
name: Dependabot Auto-Merge

on:
  pull_request:
    branches: [dev]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'

    steps:
      - name: Fetch Dependabot metadata
        id: metadata
        uses: dependabot/fetch-metadata@v2

      - name: Auto-approve for patch/minor updates
        if: |
          steps.metadata.outputs.update-type == 'version-update:semver-patch' ||
          steps.metadata.outputs.update-type == 'version-update:semver-minor'
        run: gh pr review --approve "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Enable auto-merge for patch/minor
        if: |
          steps.metadata.outputs.update-type == 'version-update:semver-patch' ||
          steps.metadata.outputs.update-type == 'version-update:semver-minor'
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 2. Enhanced Label Synchronization

**Purpose:** Ensure labels exist before applying them

```yaml
# New workflow: .github/workflows/label-sync.yml
name: Label Synchronization

on:
  push:
    branches: [master]
    paths:
      - '.github/labels.yml'
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    permissions:
      issues: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Sync labels
        uses: EndBug/label-sync@v2
        with:
          config-file: .github/labels.yml
          token: ${{ secrets.GITHUB_TOKEN }}
```

**Create:** `.github/labels.yml`

```yaml
# Label definitions
- name: "size/xs"
  color: "00ff00"
  description: "Extra small PR (0-10 lines)"

- name: "size/s"
  color: "44cc11"
  description: "Small PR (11-100 lines)"

- name: "size/m"
  color: "ff9900"
  description: "Medium PR (101-500 lines)"

- name: "size/l"
  color: "ff5500"
  description: "Large PR (501-1000 lines)"

- name: "size/xl"
  color: "ff0000"
  description: "Extra large PR (1000+ lines)"

- name: "platform/frontend"
  color: "0075ca"
  description: "Frontend changes"

- name: "platform/backend"
  color: "0e8a16"
  description: "Backend changes"

- name: "platform/blocks"
  color: "fbca04"
  description: "Block system changes"

- name: "dependencies"
  color: "0366d6"
  description: "Dependency updates"

- name: "ci/cd"
  color: "1d76db"
  description: "CI/CD workflow changes"

- name: "documentation"
  color: "0075ca"
  description: "Documentation updates"

- name: "breaking-change"
  color: "d73a4a"
  description: "Breaking changes"

- name: "security"
  color: "d73a4a"
  description: "Security-related changes"

- name: "performance"
  color: "d4c5f9"
  description: "Performance improvements"

- name: "conflicts"
  color: "b60205"
  description: "Has merge conflicts"
```

---

## 5. Complete Enhanced Configuration Files

### Enhanced `.github/labeler.yml`

```yaml
# =============================================================================
# Platform Components
# =============================================================================
documentation:
  - changed-files:
      - any-glob-to-any-file:
        - 'docs/**'
        - '**/*.md'
        - '**/CLAUDE.md'

platform/frontend:
  - changed-files:
      - any-glob-to-any-file: 'autogpt_platform/frontend/**'

platform/backend:
  - changed-files:
      - all-globs-to-any-file:
          - 'autogpt_platform/backend/**'
          - '!autogpt_platform/backend/backend/blocks/**'

platform/blocks:
  - changed-files:
      - any-glob-to-any-file: 'autogpt_platform/backend/backend/blocks/**'

platform/libs:
  - changed-files:
      - any-glob-to-any-file: 'autogpt_platform/autogpt_libs/**'

# =============================================================================
# Branch-Based Labels
# =============================================================================
feature:
  - head-branch: ['^feature/', 'feature']

bugfix:
  - head-branch: ['^bugfix/', '^fix/']

hotfix:
  - head-branch: ['^hotfix/']

release:
  - head-branch: ['^release/']

# =============================================================================
# Infrastructure & Tooling
# =============================================================================
ci/cd:
  - changed-files:
      - any-glob-to-any-file:
        - '.github/workflows/**'
        - '.github/dependabot.yml'
        - '.github/labeler.yml'

infrastructure:
  - changed-files:
      - any-glob-to-any-file:
        - 'autogpt_platform/infra/**'
        - 'docker-compose*.yml'
        - 'Dockerfile*'
        - '**/Dockerfile*'

mise/tooling:
  - changed-files:
      - any-glob-to-any-file:
        - 'mise.toml'
        - '**/mise.toml'
        - 'mise.lock'
        - '.mise/**'
        - '.tool-versions'

# =============================================================================
# Dependencies
# =============================================================================
dependencies:
  - head-branch: ['^dependabot/']

dependencies/python:
  - changed-files:
      - any-glob-to-any-file:
        - '**/poetry.lock'
        - '**/pyproject.toml'

dependencies/node:
  - changed-files:
      - any-glob-to-any-file:
        - '**/pnpm-lock.yaml'
        - '**/package.json'

dependencies/docker:
  - changed-files:
      - any-glob-to-any-file:
        - 'docker-compose*.yml'
        - 'Dockerfile*'

# =============================================================================
# Code Categories
# =============================================================================
tests:
  - changed-files:
      - any-glob-to-any-file:
        - '**/test/**'
        - '**/*test*.py'
        - '**/*.spec.ts'
        - '**/*.test.ts'
        - '**/*.test.tsx'
        - '**/playwright/**'

configuration:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*.toml'
        - '**/*.yaml'
        - '**/*.yml'
        - '!.github/workflows/**'
        - '**/tsconfig*.json'
        - '**/.eslintrc*'
        - '**/.prettierrc*'

database:
  - changed-files:
      - any-glob-to-any-file:
        - '**/prisma/**'
        - '**/migrations/**'
        - '**/schema.prisma'

# =============================================================================
# Priority/Impact Labels
# =============================================================================
breaking-change:
  - changed-files:
      - any-glob-to-any-file:
        - 'autogpt_platform/backend/backend/data/migrations/**'
        - '**/BREAKING_CHANGES.md'

security:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*auth*.py'
        - '**/*auth*.ts'
        - '**/*security*.py'
        - '**/supabase/**'

performance:
  - changed-files:
      - any-glob-to-any-file:
        - '**/*cache*.py'
        - '**/*perf*.py'
        - '**/*optimization*.py'
```

### Enhanced `.github/dependabot.yml`

```yaml
version: 2

# =============================================================================
# Python Projects (Poetry)
# =============================================================================
updates:
  # autogpt_libs (Shared Libraries)
  - package-ecosystem: "pip"
    directory: "autogpt_platform/autogpt_libs"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 10
    target-branch: "dev"

    labels:
      - "dependencies"
      - "python"
      - "autogpt_libs"

    commit-message:
      prefix: "chore(libs/deps)"
      prefix-development: "chore(libs/deps-dev)"
      include: "scope"

    ignore:
      - dependency-name: "poetry"

    groups:
      # Security updates - separate PRs for immediate attention
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      # Production dependencies - grouped minor/patch updates
      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

      # Development dependencies - grouped minor/patch updates
      development-dependencies:
        dependency-type: "development"
        update-types:
          - "minor"
          - "patch"

  # backend (FastAPI Server)
  - package-ecosystem: "pip"
    directory: "autogpt_platform/backend"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 10
    target-branch: "dev"

    labels:
      - "dependencies"
      - "python"
      - "backend"

    commit-message:
      prefix: "chore(backend/deps)"
      prefix-development: "chore(backend/deps-dev)"
      include: "scope"

    ignore:
      - dependency-name: "poetry"
      # Pin critical dependencies to avoid breaking changes
      # - dependency-name: "fastapi"
      #   update-types: ["version-update:semver-major"]

    groups:
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

      development-dependencies:
        dependency-type: "development"
        update-types:
          - "minor"
          - "patch"

# =============================================================================
# Node.js Projects (pnpm)
# =============================================================================
  # frontend (Next.js Application)
  - package-ecosystem: "npm"
    directory: "autogpt_platform/frontend"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 10
    target-branch: "dev"

    labels:
      - "dependencies"
      - "node"
      - "frontend"

    commit-message:
      prefix: "chore(frontend/deps)"
      prefix-development: "chore(frontend/deps-dev)"
      include: "scope"

    ignore:
      # Pin major framework versions to avoid breaking changes
      # - dependency-name: "next"
      #   update-types: ["version-update:semver-major"]
      # - dependency-name: "react"
      #   update-types: ["version-update:semver-major"]

    groups:
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

      development-dependencies:
        dependency-type: "development"
        update-types:
          - "minor"
          - "patch"

# =============================================================================
# Infrastructure
# =============================================================================
  # infra (Terraform)
  - package-ecosystem: "terraform"
    directory: "autogpt_platform/infra"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 5
    target-branch: "dev"

    labels:
      - "dependencies"
      - "terraform"
      - "infrastructure"

    commit-message:
      prefix: "chore(infra/deps)"
      prefix-development: "chore(infra/deps-dev)"
      include: "scope"

    groups:
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

      development-dependencies:
        dependency-type: "development"
        update-types:
          - "minor"
          - "patch"

# =============================================================================
# GitHub Actions & Docker
# =============================================================================
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 5
    target-branch: "dev"

    labels:
      - "dependencies"
      - "github-actions"
      - "ci/cd"

    commit-message:
      prefix: "chore(ci/deps)"
      include: "scope"

    groups:
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

  # Docker
  - package-ecosystem: "docker"
    directory: "autogpt_platform/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 5
    target-branch: "dev"

    labels:
      - "dependencies"
      - "docker"
      - "infrastructure"

    commit-message:
      prefix: "chore(docker/deps)"
      include: "scope"

    groups:
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

# =============================================================================
# Documentation
# =============================================================================
  # docs (Python dependencies for documentation)
  - package-ecosystem: "pip"
    directory: "docs/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "04:00"
      timezone: "UTC"
    open-pull-requests-limit: 1
    target-branch: "dev"

    labels:
      - "dependencies"
      - "python"
      - "documentation"

    commit-message:
      prefix: "chore(docs/deps)"
      include: "scope"

    groups:
      security-updates:
        applies-to: security-updates
        patterns:
          - "*"

      production-dependencies:
        dependency-type: "production"
        update-types:
          - "minor"
          - "patch"

      development-dependencies:
        dependency-type: "development"
        update-types:
          - "minor"
          - "patch"
```

---

## 6. Action Plan & Implementation Roadmap

### Phase 1: Immediate Updates (Low Risk)

**Priority:** HIGH
**Effort:** LOW
**Risk:** MINIMAL

1. ✅ **Update labeler.yml** (0.5 hours)
   - Add branch-based labels
   - Add CI/CD, infrastructure, and test labels
   - Add priority labels (breaking-change, security)

2. ✅ **Enhance dependabot.yml** (0.5 hours)
   - Add labels to all ecosystems
   - Add specific schedule times (Monday 4 AM UTC)
   - Configure security update groups
   - Add `include: "scope"` to commit messages

3. ✅ **Create labels.yml** (0.25 hours)
   - Define all labels used in labeler.yml
   - Set up label-sync workflow

### Phase 2: Security Hardening (Medium Risk)

**Priority:** HIGH
**Effort:** MEDIUM
**Risk:** LOW

1. 🔒 **Add Dependency Review** (1 hour)
   - Create `.github/workflows/dependency-review.yml`
   - Configure severity thresholds
   - Set up PR comments

2. 🔒 **Add OpenSSF Scorecard** (1 hour)
   - Create `.github/workflows/scorecard.yml`
   - Configure SARIF upload
   - Set up weekly scans

3. 🔒 **Pin Critical Actions** (2 hours)
   - Identify critical workflows (CI, deployments)
   - Pin actions to commit SHA
   - Document versions for updates

### Phase 3: Automation (Higher Risk)

**Priority:** MEDIUM
**Effort:** MEDIUM
**Risk:** MEDIUM

1. 🤖 **Dependabot Auto-Merge** (2 hours)
   - Create `.github/workflows/dependabot-auto-merge.yml`
   - Configure approval rules
   - Test with patch updates
   - **Requires:** Team approval for auto-merge policy

2. 🤖 **Label Synchronization** (1 hour)
   - Create `.github/workflows/label-sync.yml`
   - Configure label definitions
   - Test synchronization

### Phase 4: Advanced Features (Optional)

**Priority:** LOW
**Effort:** HIGH
**Risk:** MEDIUM

1. 📊 **Add PR Analytics** (3 hours)
   - Track PR merge times
   - Monitor Dependabot effectiveness
   - Dashboard for dependency health

2. 🔍 **Add Codebase Scanning** (4 hours)
   - Configure additional SAST tools
   - Set up CodeQL enhancements
   - Integrate with existing security workflow

---

## 7. Testing & Validation Plan

### Pre-Deployment Testing

1. **Labeler Configuration**
   ```bash
   # Validate YAML syntax
   yamllint .github/labeler.yml

   # Test on a sample PR
   gh pr create --draft --title "test: labeler configuration" --body "Test PR for labeler"
   ```

2. **Dependabot Configuration**
   ```bash
   # Validate YAML syntax
   yamllint .github/dependabot.yml

   # Verify via GitHub UI
   # Navigate to: Settings → Code security and analysis → Dependabot
   ```

3. **Workflow Validation**
   ```bash
   # Validate workflow syntax
   for workflow in .github/workflows/*.yml; do
     echo "Validating $workflow"
     yamllint "$workflow"
   done
   ```

### Post-Deployment Monitoring

1. **Week 1: Monitor Label Application**
   - Check if labels are correctly applied to new PRs
   - Verify branch-based labels work
   - Ensure no label conflicts

2. **Week 2: Monitor Dependabot PRs**
   - Verify labels are applied to Dependabot PRs
   - Check grouping is working correctly
   - Monitor PR volume (should be reduced)

3. **Month 1: Security Scan Review**
   - Review Dependency Review findings
   - Analyze OpenSSF Scorecard results
   - Adjust thresholds as needed

---

## 8. Migration Notes & Breaking Changes

### Breaking Changes

⚠️ **None Expected** - All changes are additive and backward-compatible

### Configuration Changes

1. **Dependabot Reviewers**
   - Old: `reviewers` in dependabot.yml (deprecated)
   - New: Use `.github/CODEOWNERS` (already in place)
   - **Action Required:** None (already migrated)

2. **Labeler v6 Format**
   - Already using v6 format ✅
   - No migration needed

### Rollback Plan

If issues occur:

1. **Labeler.yml**
   ```bash
   git revert <commit-hash>
   ```

2. **Dependabot.yml**
   - Changes are additive (labels, times)
   - Can remove without breaking functionality

3. **New Workflows**
   - Disable via GitHub UI: Actions → Workflow → Disable
   - Or delete workflow file

---

## 9. Cost & Resource Impact

### GitHub Actions Minutes

**Current Usage:** ~X minutes/month (check: Settings → Billing)

**Estimated Additional Usage:**
- Dependency Review: +5 min/PR (~20-40 min/month)
- OpenSSF Scorecard: +10 min/week (~40 min/month)
- Label Sync: +1 min/week (~4 min/month)
- Dependabot Auto-Merge: +2 min/PR (~10-20 min/month)

**Total Estimated Increase:** ~70-104 minutes/month

**Free Tier:** 2,000 minutes/month for public repos (unlimited for private in GitHub Pro)

### Dependabot PR Volume

**Current:** ~10-50 PRs/week (estimated)

**Expected Change:**
- ✅ **Reduced by 30-50%** due to grouping
- Security updates still create separate PRs (good for visibility)
- Example: 10 backend deps → 2 PRs (1 prod group, 1 dev group, separate security)

### Maintenance Overhead

**One-time Setup:** 8-16 hours (depending on phases implemented)

**Ongoing Maintenance:**
- Review Dependabot PRs: -30% time (due to grouping)
- Review Security Scans: +1 hour/week initially, +15 min/week ongoing
- Update Pinned Actions: +30 min/month (if using SHA pinning)

**Net Impact:** ~Neutral to slightly positive (time saved on Dependabot review)

---

## 10. Monitoring & Success Metrics

### Key Performance Indicators

1. **Dependabot Efficiency**
   - Metric: PRs per week
   - Target: 30-50% reduction
   - Measurement: GitHub Insights → Pull Requests

2. **Security Response Time**
   - Metric: Time from CVE disclosure to patch merge
   - Target: <48 hours for critical, <7 days for high
   - Measurement: Dependabot PR timestamps

3. **Label Accuracy**
   - Metric: % of PRs with correct labels
   - Target: >95%
   - Measurement: Manual spot checks

4. **CI/CD Efficiency**
   - Metric: Workflow run time
   - Target: No increase (or <5% increase)
   - Measurement: Actions → Workflow insights

### Monitoring Dashboard

**Recommended Tools:**
- GitHub Insights (built-in)
- [Haystack](https://usehaystack.io/) - PR analytics
- [Allstar](https://github.com/ossf/allstar) - Security policy enforcement

**Custom Metrics:**
```yaml
# Example: Track Dependabot merge time
# Query: Average time from Dependabot PR open to merge
# Goal: <24 hours for patch, <3 days for minor
```

---

## 11. Additional Recommendations

### Documentation Updates

1. **Update CONTRIBUTING.md**
   - Document new labels and their meanings
   - Explain Dependabot auto-merge policy
   - Add security workflow documentation

2. **Create SECURITY.md** (if not exists)
   - Document security update process
   - Explain vulnerability reporting
   - Reference OpenSSF Scorecard

3. **Update README.md**
   - Add security badges (Scorecard, Dependency Review)
   - Link to contribution guidelines

### Team Training

1. **Dependabot PR Review**
   - How to review grouped dependency updates
   - When to merge security updates immediately
   - How to handle breaking changes

2. **Label Usage**
   - When labels are automatically applied
   - How to manually adjust labels
   - Using labels for filtering and tracking

3. **Security Workflows**
   - Understanding Dependency Review alerts
   - Interpreting OpenSSF Scorecard results
   - Responding to security findings

---

## 12. References & Resources

### Official Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [GitHub Security Best Practices](https://docs.github.com/en/actions/security-guides)

### Tools & Resources

- [actions/labeler](https://github.com/actions/labeler)
- [OpenSSF Scorecard](https://github.com/ossf/scorecard)
- [Dependency Review Action](https://github.com/actions/dependency-review-action)
- [Dependabot Fetch Metadata](https://github.com/dependabot/fetch-metadata)

### Community Resources

- [16 Best Practices for Reducing Dependabot Noise](https://nesbitt.io/2026/01/10/16-best-practices-for-reducing-dependabot-noise.html)
- [GitHub Actions Security Cheat Sheet](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)
- [GitHub Well-Architected Framework](https://wellarchitected.github.com/)

---

## Appendix A: Quick Reference

### Labeler.yml Categories

| Category | Path/Branch Pattern | Auto-Applied |

|----------|-------------------|--------------|
| `documentation` | `docs/**`, `**/*.md` | ✅ |
| `platform/frontend` | `autogpt_platform/frontend/**` | ✅ |
| `platform/backend` | `autogpt_platform/backend/**` | ✅ |
| `platform/blocks` | `backend/blocks/**` | ✅ |
| `ci/cd` | `.github/workflows/**` | ✅ |
| `dependencies` | `dependabot/*` branch | ✅ |
| `feature` | `feature/*` branch | ✅ |
| `bugfix` | `bugfix/*`, `fix/*` branch | ✅ |
| `security` | `*auth*.py`, `*security*.py` | ✅ |
| `breaking-change` | `migrations/**` | ✅ |

### Dependabot Schedule

| Ecosystem | Day | Time | PR Limit | Target Branch |

|-----------|-----|------|----------|---------------|
| Python (libs) | Monday | 04:00 UTC | 10 | dev |
| Python (backend) | Monday | 04:00 UTC | 10 | dev |
| npm (frontend) | Monday | 04:00 UTC | 10 | dev |
| Terraform | Monday | 04:00 UTC | 5 | dev |
| GitHub Actions | Monday | 04:00 UTC | 5 | dev |
| Docker | Monday | 04:00 UTC | 5 | dev |
| Python (docs) | Monday | 04:00 UTC | 1 | dev |

### Security Workflow Triggers

| Workflow | Trigger | Frequency |

|----------|---------|-----------|
| Dependency Review | Pull Request | Per PR |
| OpenSSF Scorecard | Push to master, Weekly | Weekly + on push |
| CodeQL | Push, PR, Schedule | Per push/PR + weekly |

---

## Appendix B: YAML Validation Commands

```bash
# Validate all YAML files
find .github -name "*.yml" -o -name "*.yaml" | xargs yamllint

# Validate specific files
yamllint .github/labeler.yml
yamllint .github/dependabot.yml

# GitHub Actions validation
gh workflow view --yaml <workflow-name>

# Local testing with act (optional)
act -l  # List workflows
act pull_request -j labeler  # Test labeler workflow
```

---

## Document Control

**Version:** 1.0
**Date:** 2026-01-29
**Author:** Claude Code Analysis
**Review Status:** Pending Review
**Next Review:** 2026-02-29 (1 month)

**Change Log:**
- 2026-01-29: Initial analysis and recommendations