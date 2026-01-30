# GitHub Workflows Duplication Analysis & Cleanup Plan

**Date**: 2026-01-29
**Scope**: All workflows in `.github/workflows/`
**Total Workflows**: 20 files

---

## Executive Summary

Identified **5 major duplication patterns** across 20 workflow files with cleanup opportunities that could:
- Reduce ~250-350 lines of duplicated YAML code
- Improve maintainability by centralizing common patterns
- Standardize action versions across all workflows
- Create reusable composite actions for common setups

**Priority Actions**:
1. ✅ **HIGH**: Standardize action versions (7 workflows using outdated versions)
2. 🟡 **MEDIUM**: Create composite action for Python/Poetry setup (4 workflows, ~100 lines duplication)
3. 🟡 **MEDIUM**: Consolidate or remove obsolete CI workflows (ci.yml overlap)
4. 🟢 **LOW**: Consider mise-action migration for documentation workflows

---

## Duplication Pattern Analysis

### 1. Action Version Inconsistencies ⚠️ HIGH PRIORITY

**Issue**: Mixed action versions across workflows create maintenance burden and security risks.

#### actions/checkout Versions

| Version | Count | Workflows |
|---------|-------|-----------|
| **@v6** (latest) | 13 uses | platform-*, ci.yml, codeql.yml, claude-dependabot.simplified.yml |
| **@v4** (outdated) | 7 uses | copilot-setup-steps, docs-*, claude-*, repo-workflow-checker |

**Recommendation**: Update all 7 outdated workflows to `@v6`.

#### actions/setup-python Versions

| Version | Count | Workflows |
|---------|-------|-----------|
| **@v6** (latest) | 5 uses | copilot-setup-steps, docs-* workflows, ci.yml |
| **@v5** (outdated) | 1 use | repo-workflow-checker.yml |

**Recommendation**: Update `repo-workflow-checker.yml` to `@v6`.

#### actions/setup-node Versions

| Version | Count | Workflows |
|---------|-------|-----------|
| **@v6** (latest) | 1 use | copilot-setup-steps.yml |
| **@v4** (outdated) | 1 use | ci.yml |

**Recommendation**: Update `ci.yml` to `@v6`.

---

### 2. Python/Poetry Setup Duplication 🟡 MEDIUM PRIORITY

**Pattern Identified**: 4 workflows duplicate ~25 lines of Python/Poetry installation code.

#### Affected Workflows

1. **copilot-setup-steps.yml** (lines 69-103)
2. **docs-block-sync.yml** (lines 29-44)
3. **docs-claude-review.yml** (lines 43-56)
4. **docs-enhance.yml** (lines 29-42)

#### Duplicated Pattern

```yaml
- name: Set up Python
  uses: actions/setup-python@v6
  with:
    python-version: "3.11"

- name: Cache Poetry
  uses: actions/cache@v5
  with:
    path: ~/.cache/pypoetry
    key: poetry-${{ runner.os }}-${{ hashFiles('autogpt_platform/backend/poetry.lock') }}

- name: Install Poetry
  run: |
    cd autogpt_platform/backend
    HEAD_POETRY_VERSION=$(python3 ../../.github/workflows/scripts/get_package_version_from_lockfile.py poetry)
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=$HEAD_POETRY_VERSION python3 -
    echo "$HOME/.local/bin" >> $GITHUB_PATH

- name: Install dependencies
  working-directory: autogpt_platform/backend
  run: |
    poetry install --only main
    poetry run prisma generate
```

**Lines of Duplication**: ~25 lines × 4 workflows = **~100 lines**

#### Cleanup Option A: Composite Action (Recommended)

Create `.github/actions/setup-python-poetry/action.yml`:

```yaml
name: Setup Python and Poetry
description: Sets up Python 3.11 with Poetry and backend dependencies

inputs:
  poetry-groups:
    description: 'Poetry install groups (default: --only main)'
    required: false
    default: '--only main'
  generate-prisma:
    description: 'Generate Prisma client (default: true)'
    required: false
    default: 'true'

runs:
  using: composite
  steps:
    - name: Set up Python
      uses: actions/setup-python@v6
      with:
        python-version: "3.11"

    - name: Cache Poetry
      uses: actions/cache@v5
      with:
        path: ~/.cache/pypoetry
        key: poetry-${{ runner.os }}-${{ hashFiles('autogpt_platform/backend/poetry.lock') }}

    - name: Install Poetry
      shell: bash
      run: |
        cd autogpt_platform/backend
        HEAD_POETRY_VERSION=$(python3 ../../.github/workflows/scripts/get_package_version_from_lockfile.py poetry)
        curl -sSL https://install.python-poetry.org | POETRY_VERSION=$HEAD_POETRY_VERSION python3 -
        echo "$HOME/.local/bin" >> $GITHUB_PATH

    - name: Install dependencies
      shell: bash
      working-directory: autogpt_platform/backend
      run: |
        poetry install ${{ inputs.poetry-groups }}
        if [ "${{ inputs.generate-prisma }}" = "true" ]; then
          poetry run prisma generate
        fi
```

**Usage in workflows**:

```yaml
- uses: ./.github/actions/setup-python-poetry
  with:
    poetry-groups: '--only main'
    generate-prisma: 'true'
```

**Benefits**:
- Reduces 100 lines to 4-6 lines per workflow
- Single source of truth for Python/Poetry setup
- Easier to update (e.g., Python version bump)
- Consistent caching across all workflows

#### Cleanup Option B: Migrate to mise-action

Convert documentation workflows to use `jdx/mise-action@v3` like platform workflows.

**Pros**:
- Dev/CI parity for all workflows
- Eliminates manual Poetry installation entirely
- Automatic caching via mise-action
- Consistent with platform workflow modernization

**Cons**:
- Requires adding mise.toml awareness to documentation workflows
- More significant refactoring effort
- May be overkill for simple documentation tasks

**Recommendation**: Option A (composite action) for documentation workflows, keep mise-action for platform workflows.

---

### 3. Workflow Complexity & Redundancy 🟡 MEDIUM PRIORITY

#### ci.yml (409 lines) - Potential Consolidation

**Current State**:
- Duplicates functionality from platform-* workflows
- Has `test-backend` and `test-frontend` jobs
- 409 lines (largest workflow file)

**Overlap Analysis**:

| Feature | ci.yml | platform-backend-ci.yml | platform-frontend-ci.yml |
|---------|--------|-------------------------|--------------------------|
| Backend tests | ✅ | ✅ | ❌ |
| Frontend tests | ✅ | ❌ | ✅ |
| Python matrix | ❌ | ✅ (3.11, 3.12, 3.13) | ❌ |
| mise-action | ✅ | ✅ | ✅ |
| Path filtering | ✅ | ❌ | ❌ |
| Chromatic | ❌ | ❌ | ✅ |
| E2E tests | ❌ | ❌ | ✅ |

**Observations**:
- `ci.yml` appears to be a unified CI workflow
- Platform-specific workflows provide more comprehensive testing
- Path filtering in `ci.yml` optimizes for monorepo

**Options**:

**Option A: Keep both** (Current approach)
- `ci.yml` for fast feedback on PRs (path-filtered)
- `platform-*-ci.yml` for comprehensive testing

**Option B: Consolidate**
- Merge `ci.yml` functionality into platform-* workflows
- Add path filtering to platform workflows
- Remove `ci.yml`
- **Risk**: Increases complexity of platform workflows

**Option C: Clarify roles**
- Document purpose of each workflow in README
- `ci.yml` = fast PR checks
- `platform-*-ci.yml` = comprehensive CI
- Keep current structure

**Recommendation**: **Option C** - Clarify roles and keep current structure. The redundancy serves different purposes (fast feedback vs comprehensive testing).

---

### 4. Documentation Workflow Patterns

#### 3 Similar Claude-powered Documentation Workflows

**Workflows**:
1. `docs-block-sync.yml` (83 lines) - Validates block docs match code
2. `docs-claude-review.yml` (99 lines) - AI-powered PR review
3. `docs-enhance.yml` (194 lines) - AI-powered doc enhancement

**Common Pattern**:
- All use `anthropics/claude-code-action@v1`
- All need Python/Poetry setup for block access
- All target block documentation

**Shared Setup** (duplicated across all 3):
```yaml
- uses: actions/checkout@v4  # Should be v6
- uses: actions/setup-python@v6
- Install Poetry
- Install dependencies
- Generate Prisma
```

**Recommendation**:
1. Update `actions/checkout` to `@v6` (standardization)
2. Use composite action for Python/Poetry setup (see Pattern #2)
3. Consider combining workflows with workflow_dispatch inputs if logic overlap increases

---

### 5. Obsolete/Deprecated Patterns

#### Obsolete Script Reference

**Script**: `.github/workflows/scripts/get_package_version_from_lockfile.py`

**Status**: Still in use by 4 workflows (copilot-setup-steps, docs-*)

**Context**: Platform workflows migrated to mise-action, which eliminates need for this script.

**Action**: Keep script until documentation workflows are either:
- Migrated to mise-action, OR
- Refactored to use composite action (which would still need this script)

**Recommendation**: No immediate action. Mark as deprecated in documentation.

---

## Priority Cleanup Roadmap

### Phase 1: Quick Wins (Immediate) ✅ HIGH PRIORITY

**Standardize Action Versions** (~30 minutes)

Update outdated action versions in 8 workflows:

| Workflow | Current | Target | Change |
|----------|---------|--------|--------|
| copilot-setup-steps.yml | checkout@v4 | @v6 | +2 versions |
| docs-block-sync.yml | checkout@v4 | @v6 | +2 versions |
| docs-claude-review.yml | checkout@v4 | @v6 | +2 versions |
| docs-enhance.yml | checkout@v4 | @v6 | +2 versions |
| claude-ci-failure-auto-fix.yml | checkout@v4 | @v6 | +2 versions |
| claude-code-review.yml | checkout@v4 | @v6 | +2 versions |
| claude.yml | checkout@v4 | @v6 | +2 versions |
| repo-workflow-checker.yml | setup-python@v5 | @v6 | +1 version |
| ci.yml | setup-node@v4 | @v6 | +2 versions |

**Impact**:
- Security improvements (latest patches)
- Consistency across all workflows
- Single maintenance version

**Effort**: Low (find/replace in 8 files)
**Risk**: Very low (major version upgrades are backward compatible)

### Phase 2: Reduce Duplication (Short-term) 🟡 MEDIUM PRIORITY

**Create Composite Action for Python/Poetry Setup** (~2 hours)

1. Create `.github/actions/setup-python-poetry/action.yml`
2. Update 4 workflows to use composite action:
   - copilot-setup-steps.yml
   - docs-block-sync.yml
   - docs-claude-review.yml
   - docs-enhance.yml

**Impact**:
- Reduces ~100 lines of duplicated YAML
- Single source of truth for Python/Poetry setup
- Easier Python version updates (1 file vs 4 files)

**Effort**: Medium (create composite action + test across workflows)
**Risk**: Low (well-defined pattern, backwards compatible)

### Phase 3: Documentation & Maintenance (Ongoing) 🟢 LOW PRIORITY

**Update Workflow Documentation** (~1 hour)

1. Create `docs/github/workflows/README.md` (if not exists)
2. Document purpose of each workflow category:
   - **Platform CI** (`platform-*-ci.yml`) - Comprehensive testing
   - **Unified CI** (`ci.yml`) - Fast PR feedback with path filtering
   - **Documentation** (`docs-*.yml`) - Block documentation automation
   - **Claude Automation** (`claude-*.yml`) - AI-powered development assistance
   - **Repository** (`repo-*.yml`) - Repository maintenance

**Impact**:
- Clarifies workflow purposes
- Prevents future duplication
- Onboarding documentation for contributors

**Effort**: Low (documentation only)
**Risk**: None

---

## Cleanup Implementation Guide

### Phase 1: Action Version Standardization

#### Step 1: Update to actions/checkout@v6

```bash
# Workflows to update
workflows=(
  "copilot-setup-steps.yml"
  "docs-block-sync.yml"
  "docs-claude-review.yml"
  "docs-enhance.yml"
  "claude-ci-failure-auto-fix.yml"
  "claude-code-review.yml"
  "claude.yml"
)

# Update in-place
for workflow in "${workflows[@]}"; do
  sed -i 's/actions\/checkout@v4/actions\/checkout@v6/g' ".github/workflows/$workflow"
done
```

#### Step 2: Update to actions/setup-python@v6

```bash
sed -i 's/actions\/setup-python@v5/actions\/setup-python@v6/g' .github/workflows/repo-workflow-checker.yml
```

#### Step 3: Update to actions/setup-node@v6

```bash
sed -i 's/actions\/setup-node@v4/actions\/setup-node@v6/g' .github/workflows/ci.yml
```

#### Step 4: Verify Changes

```bash
# Verify no outdated versions remain
grep -r "actions/checkout@v4" .github/workflows/ || echo "✅ All checkout actions updated"
grep -r "actions/setup-python@v5" .github/workflows/ || echo "✅ All Python actions updated"
grep -r "actions/setup-node@v4" .github/workflows/ || echo "✅ All Node actions updated"
```

#### Step 5: Commit Changes

```bash
git add .github/workflows/
git commit -m "ci(workflows): standardize GitHub Actions to latest versions

Updated action versions for consistency and security:
- actions/checkout@v4 → @v6 (7 workflows)
- actions/setup-python@v5 → @v6 (1 workflow)
- actions/setup-node@v4 → @v6 (1 workflow)

All workflows now use latest stable action versions as of January 2026.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Phase 2: Composite Action Creation

#### Step 1: Create Composite Action

Create `.github/actions/setup-python-poetry/action.yml` (see detailed example in Pattern #2 above).

#### Step 2: Update Workflow Files

Before:
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

- name: Install dependencies
  working-directory: autogpt_platform/backend
  run: |
    poetry install --only main
    poetry run prisma generate
```

After:
```yaml
- uses: ./.github/actions/setup-python-poetry
  with:
    poetry-groups: '--only main'
    generate-prisma: 'true'
```

#### Step 3: Test Each Workflow

```bash
# Trigger workflow manually to verify
gh workflow run docs-block-sync.yml
gh workflow run docs-claude-review.yml
gh workflow run docs-enhance.yml
gh workflow run copilot-setup-steps.yml

# Monitor runs
gh run list --workflow=docs-block-sync.yml
```

#### Step 4: Commit Changes

```bash
git add .github/actions/setup-python-poetry/ .github/workflows/
git commit -m "ci(workflows): create composite action for Python/Poetry setup

Created reusable composite action to eliminate duplication:
- .github/actions/setup-python-poetry/action.yml

Updated 4 workflows to use composite action:
- copilot-setup-steps.yml
- docs-block-sync.yml
- docs-claude-review.yml
- docs-enhance.yml

Benefits:
- Reduces ~100 lines of duplicated YAML code
- Single source of truth for Python/Poetry configuration
- Easier maintenance and version updates

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Metrics & Impact

### Current State

| Metric | Value |
|--------|-------|
| Total Workflows | 20 |
| Total Lines | 2,514 |
| Workflows with Python/Poetry setup | 4 |
| Lines of Python/Poetry duplication | ~100 |
| Workflows with outdated actions | 8 |
| Action versions in use | 3 (v4, v5, v6) |

### After Phase 1 (Action Standardization)

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Action versions in use | 3 | 1 | 67% reduction |
| Workflows using latest actions | 12/20 | 20/20 | 100% coverage |
| Maintenance burden | High | Low | Simplified updates |

### After Phase 2 (Composite Action)

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Lines of duplicated setup | ~100 | ~20 | 80% reduction |
| Files to update for Python version | 4 | 1 | 75% reduction |
| Workflows using composite action | 0 | 4 | Consistency ✅ |

### Total Impact (Both Phases)

- **~100 lines** of YAML code reduction
- **1 version** of each action (down from 3)
- **1 file** to update Python/Poetry setup (down from 4)
- **Improved** maintainability and consistency

---

## Risk Assessment

### Phase 1: Action Version Updates

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking changes in actions | Very Low | Medium | All are major version upgrades (backward compatible) |
| Workflow failures | Low | Medium | Test each workflow after update |
| Unexpected behavior | Very Low | Low | Monitor first workflow runs after update |

**Overall Risk**: ✅ Very Low

### Phase 2: Composite Action

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Composite action bugs | Medium | High | Thorough testing in non-critical workflow first |
| Input parameter issues | Low | Medium | Well-defined inputs with defaults |
| Working directory confusion | Low | Medium | Explicit working-directory in composite steps |

**Overall Risk**: 🟡 Low to Medium (requires testing)

---

## Alternative Approaches Considered

### Alternative 1: Migrate All to mise-action

**Approach**: Convert all workflows (including documentation) to use `jdx/mise-action@v3`.

**Pros**:
- Ultimate dev/CI parity across all workflows
- Eliminates Python/Poetry installation entirely
- Leverages mise.toml for all version management

**Cons**:
- Significant refactoring effort (all 4+ workflows)
- Adds mise.toml dependency to simple workflows
- May be overkill for documentation automation
- Requires autogpt_platform working directory awareness

**Decision**: ❌ **Rejected** - Composite action is simpler and sufficient for documentation workflows.

### Alternative 2: Do Nothing

**Approach**: Accept duplication as acceptable trade-off for simplicity.

**Pros**:
- Zero effort required
- No risk of introducing bugs

**Cons**:
- Continued maintenance burden (4× updates for Python version)
- Inconsistency risk (forgetting to update all workflows)
- Code smell (100 lines of duplicated YAML)

**Decision**: ❌ **Rejected** - Duplication is addressable with low-effort composite action.

### Alternative 3: Workflow Templates

**Approach**: Use workflow templates instead of composite actions.

**Pros**:
- GitHub native feature
- Full workflow reuse

**Cons**:
- Less flexible than composite actions
- Requires matrix jobs for variations
- Harder to customize per-workflow

**Decision**: ❌ **Rejected** - Composite actions provide better granularity.

---

## Recommendations Summary

### Immediate Actions (Phase 1)

✅ **DO NOW** - Standardize action versions:
- Update 7 workflows to `actions/checkout@v6`
- Update 1 workflow to `actions/setup-python@v6`
- Update 1 workflow to `actions/setup-node@v6`
- **Effort**: 30 minutes
- **Risk**: Very low
- **Impact**: Security + consistency

### Short-term Actions (Phase 2)

🟡 **DO NEXT** - Create composite action:
- Build `.github/actions/setup-python-poetry/action.yml`
- Refactor 4 documentation workflows
- Test thoroughly before rollout
- **Effort**: 2 hours
- **Risk**: Low (with testing)
- **Impact**: 80% code reduction for setup

### Long-term Maintenance (Phase 3)

🟢 **DOCUMENT** - Workflow organization:
- Update `docs/github/workflows/README.md`
- Clarify purpose of each workflow type
- Prevent future duplication
- **Effort**: 1 hour
- **Risk**: None
- **Impact**: Better contributor onboarding

---

## Success Criteria

### Phase 1 Success Metrics

- ✅ All workflows use `actions/checkout@v6`
- ✅ All workflows use latest action versions
- ✅ Zero workflow failures after update
- ✅ Action version consistency across all 20 workflows

### Phase 2 Success Metrics

- ✅ Composite action created and tested
- ✅ 4 workflows successfully refactored
- ✅ All refactored workflows pass CI
- ✅ ~100 lines of YAML code reduction
- ✅ Single source of truth for Python/Poetry setup

### Phase 3 Success Metrics

- ✅ Workflow documentation created
- ✅ Purpose of each workflow category documented
- ✅ Contributor onboarding guide updated

---

## References

- **Existing Analysis**: `docs/github/workflows/DUPLICATION_ANALYSIS_2026.md`
- **Workflow Maintenance**: `.serena/memories/workflow_maintenance.md`
- **Migration Report**: `docs/github/workflows/MISE_MIGRATION_COMPLETE.md`
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Composite Actions Guide**: https://docs.github.com/en/actions/creating-actions/creating-a-composite-action

---

## Appendix: Workflow Inventory

| Workflow | Lines | Purpose | Last Updated | Duplication Risk |
|----------|-------|---------|--------------|------------------|
| ci.yml | 409 | Unified CI with path filtering | Jan 2026 | Medium (overlaps platform-*) |
| copilot-setup-steps.yml | 312 | Copilot environment setup | - | High (Python/Poetry dup) |
| platform-frontend-ci.yml | 249 | Frontend comprehensive CI | Jan 2026 | Low (mise-action) |
| platform-backend-ci.yml | 204 | Backend comprehensive CI | Jan 2026 | Low (mise-action) |
| platform-dev-deploy-event-dispatcher.yml | 198 | Deployment dispatcher | - | Low |
| docs-enhance.yml | 194 | AI doc enhancement | - | High (Python/Poetry dup) |
| platform-fullstack-ci.yml | 130 | Fullstack type checking | Jan 2026 | Low (mise-action) |
| claude-ci-failure-auto-fix.yml | 118 | Auto-fix CI failures | - | Low |
| claude-dependabot.simplified.yml | 117 | Dependabot automation | - | Low |
| docs-claude-review.yml | 99 | AI doc review | - | High (Python/Poetry dup) |
| docs-block-sync.yml | 83 | Block doc validation | - | High (Python/Poetry dup) |
| **Others** (8 workflows) | <80 each | Various | - | Very Low |

---

**Generated**: 2026-01-29
**Analyst**: Claude Sonnet 4.5 via /sc:analyze
**Review Status**: Ready for implementation
