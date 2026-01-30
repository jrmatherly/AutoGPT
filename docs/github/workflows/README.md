# GitHub Workflows Documentation

This directory contains documentation for GitHub Actions workflows, upgrades, and optimization.

## Quick Navigation

| Document | Purpose | When to Use |

|----------|---------|-------------|
| **[WORKFLOWS.md](WORKFLOWS.md)** | Workflow analysis and upgrades | Understanding workflow structure and updates |
| **[DUPLICATION_ANALYSIS_2026.md](DUPLICATION_ANALYSIS_2026.md)** | Duplication analysis & validation | Understanding workflow cleanup rationale (Jan 2026) |
| **[CLEANUP_PLAN_2026.md](CLEANUP_PLAN_2026.md)** | Actionable cleanup plan | Executing workflow consolidation (Jan 2026) |
| **[VALIDATION_SUMMARY_2026.md](VALIDATION_SUMMARY_2026.md)** | Validation summary | Quick reference for cleanup validation |
| **[IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)** | Implementation report | Complete record of workflow consolidation (Jan 2026) |
| **[PRE_IMPLEMENTATION_VALIDATION.md](PRE_IMPLEMENTATION_VALIDATION.md)** | Pre-flight validation | Pre-implementation checks and validation |
| **[UPGRADE_NOTES_2026.md](UPGRADE_NOTES_2026.md)** | January 2026 action upgrades | Reference for 2026 workflow updates |
| **[WORKFLOW_SCRIPTS_ANALYSIS_2026.md](WORKFLOW_SCRIPTS_ANALYSIS_2026.md)** | Workflow script analysis | Understanding workflow helper scripts |
| **[scripts/](scripts/)** | Workflow helper scripts | Analysis and documentation for workflow scripts |

## Archive

Detailed analysis and reports are preserved in **[../../../.archive/github/workflows/](../../../.archive/github/workflows/)**:

- **analysis/** - Full workflow analysis documents
  - `workflows_analysis.md` - Comprehensive workflow analysis
  - `config_analysis.md` - GitHub config analysis
  - `docs_analysis.md` - GitHub docs analysis

- **reports/** - Status and validation reports
  - `status.md` - Workflow status snapshot
  - `validation.md` - Validation report
  - `optimization.md` - Optimization summary

## Recent Updates

**January 2026 Workflow Consolidation - COMPLETED:**
- ✅ **COMPLETE:** Workflow cleanup and consolidation ([IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md))
- ✅ **Impact:** 66% reduction in duplicate CI runs (3 workflows → 1)
- ✅ **Enhancement:** Path-based conditional execution implemented
- ✅ **Standardization:** Mise version unified to 2026.1.9 across all workflows
- 🔍 **Analysis:** Comprehensive duplication analysis ([DUPLICATION_ANALYSIS_2026.md](DUPLICATION_ANALYSIS_2026.md))
- 📋 **Plan:** Detailed cleanup plan ([CLEANUP_PLAN_2026.md](CLEANUP_PLAN_2026.md))
- ✅ **Validation:** Pre-flight and final validation reports available

**January 2026 Workflow Upgrades:**
- ✅ Updated all GitHub Actions to latest versions (v4→v6, etc.)
- ✅ Created composite action for Prisma migrations (eliminated duplication)
- ✅ Updated Python version to 3.13 (project standard)
- ✅ Migrated to setup-python@v6 built-in caching
- ✅ Added security enhancements (concurrency, permissions)

See **[UPGRADE_NOTES_2026.md](UPGRADE_NOTES_2026.md)** for upgrade details.

## Workflow Structure

```
.github/workflows/
├── platform-*-ci.yml         # CI workflows (mise-integrated)
├── platform-*-deploy-*.yml   # Deployment workflows
└── repo-*.yml                # Repository automation

.github/actions/
└── prisma-migrate/          # Composite actions
    └── action.yml
```

## Contributing

When modifying workflows:
1. Review **[WORKFLOWS.md](WORKFLOWS.md)** for current architecture
2. Test changes in draft PR
3. Update **[UPGRADE_NOTES_2026.md](UPGRADE_NOTES_2026.md)** if action versions change
4. Run `yamllint .github/workflows/*.yml` before committing
