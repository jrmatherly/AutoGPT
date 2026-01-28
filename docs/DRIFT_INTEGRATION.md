# Drift Integration Guide for AutoGPT

> **Drift** — Codebase Intelligence for AI Agents
> 
> Drift scans your codebase, learns YOUR patterns, and provides AI agents with deep understanding of your conventions.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Workflow](#core-workflow)
3. [MCP Tools Reference](#mcp-tools-reference)
4. [Skills System](#skills-system)
5. [Quality Gates & CI Integration](#quality-gates--ci-integration)
6. [Watch Mode](#watch-mode)
7. [Security Analysis](#security-analysis)
8. [Impact Analysis](#impact-analysis)
9. [Git Hooks Setup](#git-hooks-setup)
10. [Configuration Reference](#configuration-reference)
11. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Installation

```bash
# CLI (provides the 'drift' command)
npm install -g driftdetect

# MCP server (for AI agent integration)
npm install -g driftdetect-mcp

# Verify installation
drift --version
```

### Initialize and Scan

```bash
cd /path/to/AutoGPT
drift init
```

> [!IMPORTANT]
> **AutoGPT-Specific: Scanning the Monorepo**
> 
> Running `drift scan` at the project root will NOT automatically recurse into `autogpt_platform/`. You must scan each package explicitly:

```bash
# Scan all three packages (recommended)
drift scan autogpt_platform/frontend/src --verbose
drift scan autogpt_platform/backend/backend --verbose
drift scan autogpt_platform/autogpt_libs --verbose

# Or scan all at once (slower but complete)
drift scan autogpt_platform --verbose
```

| Package | Path | Language | Files |

|---------|------|----------|-------|
| **Frontend** | `autogpt_platform/frontend/src` | TypeScript/React | ~850 |
| **Backend** | `autogpt_platform/backend/backend` | Python | ~200 |
| **Shared Libs** | `autogpt_platform/autogpt_libs` | Python | ~30 |

### Check Status

```bash
drift status --detailed
```

---

## Core Workflow

```
drift init → drift scan → drift status → drift approve → drift gate
```

### 1. Scanning

| Command | Purpose |

|---------|---------|
| `drift scan` | Full scan (first time) |
| `drift scan --incremental` | Fast incremental scan (daily use) |
| `drift scan --project @autogpt/backend` | Scan specific monorepo package |
| `drift scan --boundaries --contracts` | Include security boundaries and API contracts |

### 2. Reviewing Patterns

```bash
# Overview
drift status --detailed

# List patterns by category
drift where --category api
drift where --category auth

# See patterns in specific files
drift files src/api/
```

### 3. Approving Patterns

```bash
# Approve specific pattern
drift approve api-rest-controller

# Approve all in category
drift approve --category api

# Approve high-confidence patterns
drift approve --min-confidence 0.9

# Ignore a pattern (e.g., legacy code)
drift ignore legacy-pattern --reason "Legacy code"
```

### 4. Continuous Validation

```bash
# Check staged files before commit
drift check --staged

# Run quality gates
drift gate --fail-on warning

# CI-mode with GitHub annotations
drift gate --ci --format github
```

---

## MCP Tools Reference

### Layer 1: Orchestration (Start Here)

> [!TIP]
> **Always start with `drift_context`** — It synthesizes patterns, examples, files, and warnings into one response.

| Tool | Purpose | Example |

|------|---------|---------|
| `drift_context` | ⭐ **Recommended starting point** | `{ intent: "add_feature", focus: "auth" }` |
| `drift_package_context` | Monorepo-scoped context | `{ package: "@autogpt/backend" }` |

```javascript
// Best Practice: Always start any code generation task with this
drift_context({
  intent: "add_feature",  // add_feature, fix_bug, refactor, security_audit, understand_code, add_test
  focus: "user authentication",
  question: "How should I implement OAuth?"
})
```

### Layer 2: Discovery

| Tool | Purpose |

|------|---------|
| `drift_status` | Codebase health snapshot |
| `drift_capabilities` | Decision tree for tool selection |
| `drift_projects` | List/switch registered projects |

### Layer 3: Surgical Tools (Minimal Token Usage)

| Tool | Use Case |

|------|----------|
| `drift_signature` | Get function signature without reading entire files |
| `drift_callers` | "Who calls this function?" |
| `drift_imports` | Resolve correct import statements |
| `drift_prevalidate` | Quick code validation before writing |
| `drift_similar` | Find semantically similar code |
| `drift_type` | Expand type definitions |
| `drift_recent` | Recent changes in an area |
| `drift_test_template` | Generate test scaffold matching conventions |
| `drift_dependencies` | Package lookup (verify imports) |
| `drift_middleware` | Find middleware patterns |
| `drift_hooks` | React/Vue hook discovery |
| `drift_errors` | Error types and handling gaps |

### Layer 4-7: Advanced Tools

| Layer | Tools |

|-------|-------|
| **Exploration** | `drift_patterns_list`, `drift_security_summary`, `drift_contracts_list`, `drift_trends`, `drift_env` |
| **Detail** | `drift_pattern_get`, `drift_code_examples`, `drift_impact_analysis`, `drift_reachability`, `drift_dna_profile` |
| **Analysis** | `drift_test_topology`, `drift_coupling`, `drift_error_handling`, `drift_constraints`, `drift_simulate` |
| **Generation** | `drift_suggest_changes`, `drift_validate_change`, `drift_explain` |

---

## Skills System

Drift includes **71 production-ready implementation guides** that AI agents can use as context when implementing common patterns.

### Available Skills

| Category | Skills (Examples) |

|----------|-------------------|
| **Resilience** | `circuit-breaker`, `retry-fallback`, `graceful-shutdown`, `backpressure` |
| **API & Integration** | `api-client`, `rate-limiting`, `pagination`, `webhook-security` |
| **Authentication** | `jwt-auth`, `oauth-social-login`, `middleware-protection`, `row-level-security` |
| **Workers & Jobs** | `background-jobs`, `dead-letter-queue`, `job-state-machine` |
| **Data Pipeline** | `batch-processing`, `checkpoint-resume`, `deduplication` |
| **AI & ML** | `ai-coaching`, `ai-generation-client`, `prompt-engine` |

### Using Skills

```bash
# List all available skills
drift skills list

# Search for specific skills
drift skills search "authentication"

# View skill details
drift skills info circuit-breaker

# Install skills to .github/skills/
drift skills install circuit-breaker retry-fallback graceful-shutdown
```

### Creating Custom Skills

Create team-specific patterns in `.github/skills/custom-skill/SKILL.md`:

```markdown
---
name: custom-skill
description: Your team's custom pattern
license: MIT
compatibility: TypeScript/JavaScript, Python
metadata:
  category: custom
  time: 2h
---

# Custom Skill

[Your implementation guide here]
```

---

## Quality Gates & CI Integration

### The Six Gates

| Gate | What It Checks |

|------|----------------|
| **Pattern Compliance** | Do changed files follow established patterns? |
| **Constraint Verification** | Does code satisfy architectural invariants? |
| **Regression Detection** | Did this change make pattern health worse? |
| **Impact Simulation** | What's the blast radius of this change? |
| **Security Boundary** | Does this respect data access boundaries? |
| **Custom Rules** | User-defined rules for your codebase |

### CLI Usage

```bash
# Run all gates with default policy
drift gate

# Run specific gates
drift gate --gates pattern-compliance,security-boundary

# Use different policies
drift gate --policy strict    # Release branches
drift gate --policy relaxed   # Feature branches
drift gate --policy ci-fast   # Fast CI feedback
```

### GitHub Actions Integration

```yaml
name: Drift Quality Gate

on: [push, pull_request]

jobs:
  drift-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Cache Drift data
        uses: actions/cache@v4
        with:
          path: .drift
          key: drift-${{ runner.os }}-${{ hashFiles('**/*.ts', '**/*.py') }}
          restore-keys: drift-${{ runner.os }}-
      
      - name: Install Drift
        run: npm install -g driftdetect
      
      - name: Initialize Drift
        run: drift init --yes
      
      - name: Run Incremental Scan
        run: drift scan --incremental
      
      - name: Quality Gate
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            drift gate --policy strict --ci --format github
          else
            drift gate --policy default --ci --format github
          fi
```

### Custom Policy

Create `.drift/quality-gates/policies/custom.json`:

```json
{
  "id": "autogpt-policy",
  "name": "AutoGPT Quality Standards",
  "gates": {
    "pattern-compliance": {
      "enabled": true,
      "blocking": true,
      "minComplianceRate": 85,
      "categories": ["api", "auth", "errors"]
    },
    "security-boundary": {
      "enabled": true,
      "blocking": true,
      "protectedTables": ["users", "credentials", "api_keys"]
    }
  }
}
```

---

## Watch Mode

Real-time pattern detection as you edit files.

```bash
# Start watching
drift watch

# With verbose output
drift watch --verbose

# Filter categories
drift watch --categories api,auth,errors

# Auto-update AI context file
drift watch --context .drift/CONTEXT.md
```

### Output

```
🔍 Drift Watch Mode

  Watching: /Users/dev/AutoGPT
  Categories: api, auth, errors
  Persistence: enabled

[10:24:12] ✓ src/api/users.ts (3 patterns)
[10:24:18] ✗ src/services/payment.ts - 1 error, 2 warnings
    ● Line 45: Missing error handling for external API call
    ● Line 67: Bare catch clause
```

---

## Security Analysis

### Security Summary

```bash
drift boundaries overview
```

### Data Flow Tracing

```javascript
// Forward: "What sensitive data can this code access?"
drift_reachability({ 
  location: "src/api/users.ts:42", 
  direction: "forward" 
})

// Inverse: "Who can access this sensitive data?"
drift_reachability({ 
  target: "users.password_hash", 
  direction: "inverse" 
})
```

### CLI Commands

```bash
# Find sensitive data access
drift boundaries sensitive

# Check for violations
drift boundaries check

# Trace data flow
drift callgraph reach src/auth/login.ts:42
drift callgraph inverse users.password_hash
```

---

## Impact Analysis

Before refactoring, understand the blast radius:

```bash
drift callgraph impact src/auth/validateToken.ts
```

### MCP Tool

```javascript
drift_impact_analysis({
  target: "src/auth/validateToken.ts",
  maxDepth: 10,
  limit: 10
})
```

Returns:
- **Direct Callers** — Functions that call this code
- **Entry Points** — Public interfaces (routes, handlers) that reach it
- **Sensitive Data Paths** — What data flows through
- **Affected Tests** — Tests that cover this code
- **Risk Assessment** — Calculated risk level

---

## Git Hooks Setup

### Using Husky

```bash
# Install Husky
npm install -D husky
npx husky init

# Pre-commit: Check staged files
echo 'drift check --staged --fail-on error' > .husky/pre-commit

# Pre-push: Full quality gate
echo 'drift gate --fail-on warning' > .husky/pre-push
```

### Pre-commit Hook (Detailed)

```bash
#!/bin/sh
# .husky/pre-commit

# Skip if running in CI
if [ -n "$CI" ]; then
  exit 0
fi

# Skip if no staged files
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx|py)$')
if [ -z "$STAGED" ]; then
  exit 0
fi

# Run Drift check
drift check --staged --fail-on error
```

### Using Lefthook

```yaml
# lefthook.yml
pre-commit:
  commands:
    drift-check:
      glob: "*.{ts,tsx,js,jsx,py}"
      run: drift check --staged --fail-on error

pre-push:
  commands:
    drift-gate:
      run: |
        drift scan --incremental
        drift gate --fail-on warning
```

---

## Configuration Reference

### .drift/config.json

```json
{
  "version": "2.0.0",
  "project": {
    "name": "AutoGPT"
  },
  "defaultSeverity": "warning",
  "ignore": [
    "**/node_modules/**",
    "**/dist/**",
    "**/__pycache__/**"
  ],
  "learning": {
    "autoApproveThreshold": 0.95,
    "minOccurrences": 3,
    "semanticLearning": true
  },
  "performance": {
    "maxWorkers": 4,
    "cacheEnabled": true,
    "incrementalAnalysis": true
  },
  "features": {
    "callGraph": true,
    "boundaries": true,
    "dna": true,
    "contracts": true
  }
}
```

### .driftignore

```gitignore
# Dependencies
node_modules/
vendor/
__pycache__/

# Build outputs
dist/
build/
*.pyc

# Test fixtures and data
**/fixtures/**
**/test-data/**

# Generated code
*.generated.ts
*.g.cs

# Documentation
docs/
*.md
```

### .gitignore (Drift-specific)

```gitignore
# Drift: ignore caches and temporary data
.drift/lake/
.drift/cache/
.drift/history/
.drift/call-graph/
.drift/patterns/discovered/
.drift/patterns/ignored/
.drift/patterns/variants/
.drift/constraints/discovered/
.drift/constraints/ignored/
.drift/contracts/discovered/
.drift/contracts/ignored/
.drift/contracts/mismatch/
.drift/**/.backups/
```

**Commit these for team sharing:**
- `.drift/config.json`
- `.drift/patterns/approved/`
- `.drift/boundaries/`
- `.drift/constraints/approved/`
- `.drift/contracts/verified/`

---

## Troubleshooting

### Installation Issues

| Problem | Solution |

|---------|----------|
| npm install fails (Tree-sitter) | Install build tools: `xcode-select --install` (macOS) |
| npx hangs | Use global install: `npm install -g driftdetect` |

### Scanning Issues

| Problem | Solution |

|---------|----------|
| Scan too slow | Add to `.driftignore`, use `--incremental` |
| No patterns found | Check language support: `drift parser --test` |
| Scan fails | Run with `--verbose` for details |

### MCP Issues

| Problem | Solution |

|---------|----------|
| MCP not connecting | Restart AI client after config changes |
| "Scan required" errors | Run `drift init && drift scan` first |
| Slow MCP responses | Pre-build call graph: `drift callgraph build` |

### Common Commands for Debugging

```bash
# Check Drift version
drift --version

# Test parser installation
drift parser --test

# View current status
drift status --detailed

# Check what's being ignored
cat .driftignore

# Verbose scan for debugging
drift scan --verbose
```

---

## Quick Decision Tree

```
What are you doing?
│
├─ Adding a feature?
│  └─ drift_context → drift_code_examples → drift_validate_change
│
├─ Fixing a bug?
│  └─ drift_context → drift_callers → drift_error_handling
│
├─ Refactoring?
│  └─ drift_impact_analysis → drift_coupling → drift_test_topology
│
├─ Security review?
│  └─ drift_security_summary → drift_reachability → drift_env
│
├─ Understanding code?
│  └─ drift_explain → drift_callers → drift_file_patterns
│
└─ Adding tests?
   └─ drift_test_topology → drift_test_template
```

---

## Reports & Export

### Generate Reports

```bash
# Text report
drift report

# GitHub Actions format
drift report --format github

# GitLab CI format
drift report --format gitlab
```

### Export for AI Context

```bash
# AI-optimized context
drift export --format ai-context --output .drift/CONTEXT.md

# Token-limited for smaller context windows
drift export --format ai-context --max-tokens 8000

# Include code snippets
drift export --format ai-context --snippets
```

### Documentation Export

```bash
# Markdown documentation
drift export --format markdown --output docs/PATTERNS.md
```

---

## Additional Resources

- [Full Drift Documentation](/Users/jason/dev/AutoGPT/.archive/drift-docs/)
- [MCP Tools Reference](/.archive/drift-docs/MCP-Tools-Reference.md)
- [CLI Reference](/.archive/drift-docs/CLI-Reference.md)
- [Pattern Categories](/.archive/drift-docs/Pattern-Categories.md)
- [Security Analysis](/.archive/drift-docs/Security-Analysis.md)
