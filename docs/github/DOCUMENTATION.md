# GitHub Documentation Files Guide

**Last Updated:** 2026-01-29
**Status:** Critical updates needed for mise alignment

## Overview

This guide covers `.github/` documentation files including `copilot-instructions.md` and `PULL_REQUEST_TEMPLATE.md`. These files guide developers and GitHub Copilot in following project conventions.

**For detailed analysis**, see [.archive/github/workflows/analysis/docs_analysis.md](../../.archive/github/workflows/analysis/docs_analysis.md)

## Current Status

| File | Status | Priority | Issue |
|------|--------|----------|-------|
| **copilot-instructions.md** | ❌ Out of sync | **CRITICAL** | No mise references, outdated commands |
| **PULL_REQUEST_TEMPLATE.md** | ✅ Adequate | LOW | Minor enhancements available |

## Critical Issue: Copilot Instructions

### Problem

The `copilot-instructions.md` file contains **no references to mise** and uses outdated Makefile-based commands. This causes GitHub Copilot to suggest deprecated workflows to developers.

### Impact

- Copilot users follow outdated patterns
- New contributors get incorrect guidance
- Inconsistent development practices

### Solution

Update `.github/copilot-instructions.md` to prioritize mise-based workflow while maintaining backwards compatibility.

## Recommended Updates

### 1. Add Development Tool Management Section

```markdown
## Development Tool Management

This project uses **[mise](https://mise.jdx.dev)** for unified tool management (Python, Node.js, pnpm, Poetry).

**Quick Start:**
```bash
# First time setup
cd autogpt_platform
mise trust && mise run setup

# Daily development
mise run docker:up      # Start infrastructure
mise run backend        # Terminal 1
mise run frontend       # Terminal 2
```

**For full command reference:** See [CLAUDE.md](../autogpt_platform/CLAUDE.md)
```

### 2. Update Build Instructions (Mise-First Approach)

```markdown
## Build Instructions

### Backend (Python FastAPI)

**Recommended (mise):**
```bash
cd autogpt_platform
mise run backend        # Runs all backend services
```

**Alternative (direct):**
```bash
cd autogpt_platform/backend
poetry install
docker compose up -d
poetry run app
```

### Frontend (Next.js)

**Recommended (mise):**
```bash
cd autogpt_platform
mise run frontend       # Runs dev server
```

**Alternative (direct):**
```bash
cd autogpt_platform/frontend
pnpm install
pnpm dev
```
```

### 3. Update CI/CD References

```markdown
## CI/CD

The project uses GitHub Actions with mise integration:
- **Main CI:** `.github/workflows/ci-mise.yml`
- **Deployments:** `.github/workflows/platform-*-deploy-*.yml`

**Testing locally with mise:**
```bash
mise run format         # Format all code
mise run lint           # Lint all code
mise run test           # Run all tests
```
```

### 4. Add Drift Pattern Analysis

```markdown
## Code Quality

The project uses [Drift](https://drift.sh) for pattern analysis:

```bash
mise run drift:status   # View codebase health
mise run drift:check    # Check for violations
mise run drift:approve  # Approve new patterns
```

See [docs/github/CONFIGURATION.md](../docs/github/CONFIGURATION.md) for details.
```

## PR Template Enhancements (Optional)

### Add Mise Checklist Item

```markdown
## Pre-Submission Checklist

- [ ] Code formatted: `mise run format`
- [ ] Linting passed: `mise run lint`
- [ ] Tests passed: `mise run test`
- [ ] Drift check passed: `mise run drift:check` (if applicable)
- [ ] API client regenerated: `cd frontend && pnpm generate:api` (if backend API changed)
```

## Implementation Plan

### Phase 1: Critical Update (IMMEDIATE)

1. **Update copilot-instructions.md**
   - Add Development Tool Management section (mise-first)
   - Update all command examples to show mise commands
   - Maintain backwards compatibility with direct commands
   - Add references to CLAUDE.md and CONTRIBUTING.md

2. **Test with GitHub Copilot**
   - Verify Copilot suggests mise commands
   - Check command accuracy in suggestions
   - Validate backwards compatibility

### Phase 2: PR Template Enhancement (OPTIONAL)

1. **Add mise checklist items**
2. **Add drift check reminder**
3. **Test with draft PR**

## Testing

### Copilot Instructions

```bash
# 1. Update the file
# 2. Create a test file and ask Copilot for setup commands
# 3. Verify it suggests mise commands first

# Example test:
# In a new Python file, type: "# Setup backend development environment"
# Expected: Copilot suggests "mise run backend" not "poetry run app"
```

### PR Template

```bash
# Create draft PR and verify checklist renders correctly
gh pr create --draft --title "test: PR template validation"
```

## Alignment with Other Docs

Ensure consistency across:
- `autogpt_platform/CLAUDE.md` ✅ (primary mise reference)
- `autogpt_platform/frontend/CONTRIBUTING.md` ✅ (frontend-specific)
- `docs/MISE_MIGRATION.md` ✅ (migration guide)
- `.github/copilot-instructions.md` ❌ (needs update)

## References

- **Detailed Analysis:** [.archive/github/workflows/analysis/docs_analysis.md](../../.archive/github/workflows/analysis/docs_analysis.md)
- **Enhanced Template:** See archived analysis for full enhanced version
- **Mise Documentation:** [mise.jdx.dev](https://mise.jdx.dev)
- **Project Mise Guide:** [docs/MISE_MIGRATION.md](../MISE_MIGRATION.md)

## Change Log

- **2026-01-29:** Consolidated documentation guide created
- Original analysis: 2026-01-29 (archived)
