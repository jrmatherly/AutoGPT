# Release Task Analysis - AgentOS to AutoGPT

**Date:** 2026-01-29
**Source:** AgentOS agent-ui project
**Target:** AutoGPT Platform

---

## Executive Summary

The AgentOS project has a well-designed mise-based release automation system that can be adapted for AutoGPT. The system provides semantic versioning, automated tagging, GitHub releases, and Docker image builds. Adapting this to AutoGPT requires handling the monorepo structure and integrating with existing deployment workflows.

---

## AgentOS Release System Analysis

### Architecture Overview

```mermaid
Developer → mise release → release.sh → Git Tag → GitHub Release → Docker Builds
```

### Components

#### 1. **Mise Task Configuration** (`mise.toml`)

```toml
[tasks.release]
description = "Create a new release (tag + GitHub release)"
run = "./scripts/release.sh"
raw = true

[tasks."release:major"]
description = "Create a major release (vX.0.0)"
run = "./scripts/release.sh major --yes"

[tasks."release:minor"]
description = "Create a minor release (vX.Y.0)"
run = "./scripts/release.sh minor --yes"

[tasks."release:patch"]
description = "Create a patch release (vX.Y.Z)"
run = "./scripts/release.sh patch --yes"
```

**Features:**

- ✅ Semantic versioning shortcuts (major/minor/patch)
- ✅ Auto-confirm flag for CI/CD integration
- ✅ Raw mode for direct shell script execution

#### 2. **Release Script** (`scripts/release.sh`)

**Capabilities:**

- Auto-increment versioning (major/minor/patch)
- Manual version override support
- Interactive confirmation prompts
- Auto-confirm mode (`--yes` flag)
- Package.json version updating
- Git commit, tag, and push automation
- GitHub release creation via gh CLI
- Release notes from git log
- Comprehensive validation checks

**Validation Checks:**

```bash
✓ Git repository existence
✓ Working directory cleanliness
✓ gh CLI authentication
```

**Version Management:**

```bash
# Parse current version from git tags
latest_tag=$(git tag -l 'v*' --sort=-v:refname | head -n1)

# Increment based on type
increment_version() {
    case "$type" in
        major) major=$((major + 1)); minor=0; patch=0 ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        patch) patch=$((patch + 1)) ;;
    esac
}
```

**Package.json Update:**

```bash
# Preserves JSON formatting
node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.version = '$version';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
```

**Release Notes Generation:**

```bash
# Auto-generate from commits since last tag
git log "${last_tag}..HEAD" --pretty=format:"- %s" --no-merges
```

**GitHub Release:**

```bash
gh release create "$new_version" \
    --title "$new_version" \
    --notes "$release_notes" \
    --latest
```

#### 3. **Docker Image Workflow** (`docker-images.yml`)

**Trigger:**

```yaml
on:
  release:
    types: [published]
```

**Features:**

- ✅ Multi-platform builds (linux/amd64, linux/arm64)
- ✅ Digest-based building for efficiency
- ✅ Dual registry support (GHCR + DockerHub)
- ✅ Semantic version tagging (`{{version}}`, `{{major}}.{{minor}}`, `latest`)
- ✅ GitHub Actions caching
- ✅ Separate main app + db-init images

**Build Strategy:**

```yaml
strategy:
  fail-fast: false
  matrix:
    include:
      - platform: linux/amd64
        runner: ubuntu-latest
        artifact: amd64
      - platform: linux/arm64
        runner: ubuntu-24.04-arm
        artifact: arm64
```

**Tag Generation:**

```yaml
tags: |
  type=semver,pattern={{version}}
  type=semver,pattern={{major}}.{{minor}}
  type=raw,value=latest,enable={{is_default_branch}}
```

---

## AutoGPT Current State Analysis

### Project Structure

**Monorepo Layout:**

```tree
AutoGPT/
├── autogpt_platform/
│   ├── frontend/         # Node.js/Next.js (package.json v0.3.4)
│   ├── backend/          # Python/FastAPI (pyproject.toml)
│   └── autogpt_libs/     # Python libraries (pyproject.toml)
└── .github/workflows/
    └── platform-autogpt-deploy-prod.yml
```

### Existing Release Workflow

**Current Process:**

```mermaid
GitHub Release (manual) → platform-autogpt-deploy-prod.yml
  ↓
Run Prisma migrations
  ↓
Trigger AutoGPT_cloud_infrastructure deployment
```

**Current Workflow:**

```yaml
on:
  release:
    types: [published]
  workflow_dispatch:

jobs:
  migrate:
    - uses: ./.github/actions/prisma-migrate

  trigger:
    - uses: peter-evans/repository-dispatch@v4
      with:
        repository: Significant-Gravitas/AutoGPT_cloud_infrastructure
        event-type: build_deploy_prod
```

### Gaps

❌ No automated version bumping
❌ No automated git tagging
❌ No automated GitHub release creation
❌ Manual release process
❌ No monorepo version synchronization
❌ No Python package versioning automation

---

## Refactoring Plan

### Option A: Minimal Adaptation (Recommended)

**Approach:** Adapt AgentOS script to handle AutoGPT's monorepo structure

**Changes Required:**

#### 1. **Update Version Files**

Support multiple version sources:

```bash
# Update package.json (frontend)
update_package_json() {
    local version="${1#v}"
    node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('autogpt_platform/frontend/package.json', 'utf8'));
        pkg.version = '$version';
        fs.writeFileSync('autogpt_platform/frontend/package.json', JSON.stringify(pkg, null, 2) + '\n');
    "
}

# Update pyproject.toml (backend)
update_backend_version() {
    local version="${1#v}"
    sed -i.bak "s/^version = .*/version = \"$version\"/" autogpt_platform/backend/pyproject.toml
    rm autogpt_platform/backend/pyproject.toml.bak
}

# Update pyproject.toml (libs)
update_libs_version() {
    local version="${1#v}"
    sed -i.bak "s/^version = .*/version = \"$version\"/" autogpt_platform/autogpt_libs/pyproject.toml
    rm autogpt_platform/autogpt_libs/pyproject.toml.bak
}
```

#### 2. **Git Commit Strategy**

Commit all version files together:

```bash
git add \
    autogpt_platform/frontend/package.json \
    autogpt_platform/backend/pyproject.toml \
    autogpt_platform/autogpt_libs/pyproject.toml

git commit -m "chore(platform): bump version to $new_version"
```

#### 3. **Mise Task Integration**

Add to `/Users/jason/dev/AutoGPT/mise.toml`:

```toml
[tasks.release]
description = "Create a new release (tag + GitHub release)"
dir = "{{config_root}}"
run = "./scripts/release.sh"
raw = true

[tasks."release:major"]
description = "Create a major release (vX.0.0)"
dir = "{{config_root}}"
run = "./scripts/release.sh major --yes"

[tasks."release:minor"]
description = "Create a minor release (vX.Y.0)"
dir = "{{config_root}}"
run = "./scripts/release.sh minor --yes"

[tasks."release:patch"]
description = "Create a patch release (vX.Y.Z)"
dir = "{{config_root}}"
run = "./scripts/release.sh patch --yes"
```

#### 4. **Create Release Script**

Copy and adapt `scripts/release.sh` with monorepo support:

**Key Modifications:**

1. Update version file paths (3 files instead of 1)
2. Adjust working directory references
3. Add platform-specific release notes sections
4. Keep existing validation checks

#### 5. **Integration with Existing Workflow**

**No changes needed** to `platform-autogpt-deploy-prod.yml`:

- Already triggers on `release.published`
- Already handles migrations and deployment
- Works with new release system automatically

---

### Option B: Extended Automation

**Additional Features** (optional enhancements):

#### 1. **Docker Image Builds**

Add `platform-docker-images.yml` workflow similar to AgentOS:

**Considerations:**

- AutoGPT may already have Docker builds in infrastructure repo
- Evaluate if in-repo Docker builds are needed
- Consider multi-platform support requirements

#### 2. **Changelog Generation**

Enhanced release notes with categorization:

```bash
generate_release_notes() {
    local last_tag="$1"

    echo "## Backend Changes"
    git log "${last_tag}..HEAD" --pretty=format:"- %s" \
        --no-merges -- "autogpt_platform/backend/**" "autogpt_platform/autogpt_libs/**"

    echo ""
    echo "## Frontend Changes"
    git log "${last_tag}..HEAD" --pretty=format:"- %s" \
        --no-merges -- "autogpt_platform/frontend/**"
}
```

#### 3. **Version Validation**

Ensure version consistency:

```bash
validate_version_sync() {
    local fe_version=$(jq -r '.version' autogpt_platform/frontend/package.json)
    local be_version=$(grep '^version =' autogpt_platform/backend/pyproject.toml | cut -d'"' -f2)

    if [[ "$fe_version" != "$be_version" ]]; then
        echo "Warning: Frontend ($fe_version) and Backend ($be_version) versions differ"
    fi
}
```

---

## Implementation Steps

### Phase 1: Core Release Automation

1. **Create scripts directory**

   ```bash
   mkdir -p scripts
   ```

2. **Copy and adapt release.sh**
   - Copy from AgentOS
   - Update file paths for monorepo
   - Add multi-file version updates
   - Test locally

3. **Add mise tasks**
   - Update root mise.toml
   - Add release tasks with delegation
   - Test task execution

4. **Test release process**

   ```bash
   # Dry run (manual verification)
   mise run release

   # Test version increment
   mise run release:patch
   ```

### Phase 2: Validation & Documentation

1. **Add validation checks**
   - Verify all version files updated
   - Check git tag creation
   - Validate GitHub release

2. **Update documentation**
   - Add release process to CLAUDE.md
   - Document conventional commit usage
   - Create release checklist

3. **Team communication**
   - Announce new release process
   - Provide usage examples
   - Document rollback procedures

---

## File Locations

### New Files to Create

```tree
AutoGPT/
├── scripts/
│   └── release.sh                    # Adapted release script
├── mise.toml                          # Add release tasks (already exists)
└── docs/
    └── RELEASE_PROCESS.md            # Release documentation
```

### Files to Modify

```tree
autogpt_platform/
├── frontend/package.json             # Auto-updated by script
├── backend/pyproject.toml             # Auto-updated by script
└── autogpt_libs/pyproject.toml       # Auto-updated by script
```

---

## Usage Examples

### Creating a Patch Release

```bash
# Interactive mode
cd /Users/jason/dev/AutoGPT
mise run release

# Guided prompts:
# Current version: v0.3.4
# Next version: v0.3.5
# [Enter] Accept v0.3.5
# Release notes preview
# Confirm? [y/N] y
```

### Creating a Minor Release

```bash
# Auto-confirm mode
mise run release:minor

# Automatic:
# - Increment v0.3.4 → v0.4.0
# - Update package.json, pyproject.toml files
# - Commit changes
# - Create git tag v0.4.0
# - Push tag and commit
# - Create GitHub release
# - Trigger deploy workflow
```

### Creating a Major Release

```bash
# Interactive with specific version
mise run release

# Choose: major
# v0.3.4 → v1.0.0
```

---

## Integration with Existing Workflows

### Deployment Flow

```mermaid
Developer                    GitHub                      Infrastructure
    │                           │                             │
    │  mise run release:patch   │                             │
    ├──────────────────────────>│                             │
    │                           │                             │
    │  Git tag pushed            │                             │
    ├──────────────────────────>│                             │
    │                           │                             │
    │  GitHub release created   │                             │
    ├──────────────────────────>│                             │
    │                           │                             │
    │                           │  Trigger: release.published │
    │                           ├────────────────────────────>│
    │                           │                             │
    │                           │  Run Prisma migrations      │
    │                           ├────────────────────────────>│
    │                           │                             │
    │                           │  Dispatch to infra repo     │
    │                           ├────────────────────────────>│
    │                           │                             │
    │                           │  Infrastructure deployment  │
    │                           │                             ├──> Deploy
```

### No Breaking Changes

✅ Existing `platform-autogpt-deploy-prod.yml` works as-is
✅ Infrastructure repo integration preserved
✅ Migration workflow unchanged
✅ Only adds automation before the GitHub release

---

## Benefits

### Developer Experience

- ✅ **One command releases**: `mise run release:patch`
- ✅ **No manual tagging**: Automated git tag creation
- ✅ **Consistent versioning**: All files updated together
- ✅ **Auto-generated release notes**: From git commit history
- ✅ **Interactive or automated**: Flexible workflow support

### Process Improvements

- ✅ **Semantic versioning**: Clear version progression
- ✅ **Conventional commits**: Structured commit history
- ✅ **Atomic releases**: Single commit for all version changes
- ✅ **Rollback capability**: Git tags enable easy rollback
- ✅ **Audit trail**: GitHub releases provide historical record

### Integration

- ✅ **Existing workflow compatible**: No changes to deploy-prod.yml
- ✅ **Infrastructure repo preserved**: Dispatch mechanism unchanged
- ✅ **CI/CD ready**: Auto-confirm mode for automation
- ✅ **Local and remote**: Works for manual and automated releases

---

## Risks & Mitigation

### Monorepo Complexity

**Risk:** Version files could get out of sync

**Mitigation:**

- Script updates all files atomically in single commit
- Add validation check to verify version consistency
- Include version comparison in release notes

### Git Conflicts

**Risk:** Concurrent releases could cause conflicts

**Mitigation:**

- Require clean working directory
- Use git hooks to prevent simultaneous releases
- Document single-release-at-a-time policy

### Breaking Changes

**Risk:** Script errors could create invalid releases

**Mitigation:**

- Comprehensive validation checks before push
- Test mode that skips git push
- Rollback procedure documentation
- Dry-run capability for testing

---

## Testing Strategy

### Pre-Implementation Testing

1. **Fork AgentOS script**: Test basic functionality
2. **Mock file updates**: Test version updates without git operations
3. **Test version parsing**: Validate semver logic
4. **Test release notes**: Generate notes from actual git log

### Implementation Testing

1. **Test on feature branch**: Create test releases without affecting master
2. **Verify all files updated**: Check package.json + pyproject.toml changes
3. **Validate git operations**: Confirm tag creation and push
4. **Test GitHub release**: Verify gh CLI integration
5. **Confirm workflow trigger**: Ensure deploy-prod.yml triggers

### Rollback Testing

1. **Delete tag locally and remotely**
2. **Revert version commit**
3. **Verify deployment doesn't trigger**

---

## Comparison: AgentOS vs AutoGPT

| Aspect | AgentOS | AutoGPT (Proposed) |

|--------|---------|---------------------|
| **Project Type** | Single Next.js app | Monorepo (FE + BE + Libs) |
| **Version Files** | 1 (package.json) | 3 (package.json + 2x pyproject.toml) |
| **Languages** | JavaScript/Node.js | JavaScript + Python |
| **Package Managers** | pnpm | pnpm (FE) + Poetry (BE) |
| **Docker Builds** | In-repo workflow | External infrastructure repo |
| **Deployment** | Direct Docker push | Repository dispatch to infra repo |
| **Release Notes** | Simple git log | Categorized by component |
| **Validation** | Basic checks | Extended monorepo checks |

---

## Recommended Approach

**Phase 1: Core Automation** (Recommended for immediate implementation)

- ✅ Adapt release.sh for monorepo
- ✅ Add mise tasks to root mise.toml
- ✅ Test with patch release
- ✅ Document process

**Phase 2: Enhanced Features** (Optional future work)

- ⏳ Categorized release notes
- ⏳ Version consistency validation
- ⏳ Docker image builds (evaluate need)
- ⏳ Changelog generation

---

## Next Steps

1. **Review and approve** this analysis
2. **Create scripts/release.sh** with monorepo adaptations
3. **Update root mise.toml** with release tasks
4. **Test on feature branch** with actual release
5. **Document process** in CLAUDE.md and Serena memories
6. **Communicate to team** about new release workflow

---

## References

**Source Files:**

- `/Users/jason/dev/MCP/AgentOS/agent-ui/mise.toml`
- `/Users/jason/dev/MCP/AgentOS/agent-ui/scripts/release.sh`
- `/Users/jason/dev/MCP/AgentOS/agent-ui/.github/workflows/docker-images.yml`

**Target Files:**

- `/Users/jason/dev/AutoGPT/mise.toml`
- `/Users/jason/dev/AutoGPT/.github/workflows/platform-autogpt-deploy-prod.yml`
- `/Users/jason/dev/AutoGPT/autogpt_platform/frontend/package.json`
- `/Users/jason/dev/AutoGPT/autogpt_platform/backend/pyproject.toml`
- `/Users/jason/dev/AutoGPT/autogpt_platform/autogpt_libs/pyproject.toml`

**Related Documentation:**

- `docs/github/workflows/MISE_ROOT_COMPATIBILITY_ANALYSIS.md`
- `.serena/memories/github_workflows_2026_upgrade.md`
- `.serena/memories/workflow_maintenance.md`
