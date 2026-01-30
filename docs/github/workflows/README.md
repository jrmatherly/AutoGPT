# GitHub Workflows Documentation

This directory contains documentation for GitHub Actions workflows, upgrades, and optimization.

## Quick Navigation

| Document | Purpose | When to Use |

|----------|---------|-------------|
| **[WORKFLOWS.md](WORKFLOWS.md)** | Workflow analysis and upgrades | Understanding workflow structure and updates |
| **[DUPLICATION_ANALYSIS_2026.md](DUPLICATION_ANALYSIS_2026.md)** | Duplication analysis & validation | Understanding workflow cleanup rationale (Jan 2026) |
| **[CLEANUP_PLAN_2026.md](CLEANUP_PLAN_2026.md)** | Actionable cleanup plan | Executing workflow consolidation (Jan 2026) |
| **[UPGRADE_NOTES_2026.md](UPGRADE_NOTES_2026.md)** | January 2026 action upgrades | Reference for 2026 workflow updates |
| **[WORKFLOW_SCRIPTS_ANALYSIS_2026.md](WORKFLOW_SCRIPTS_ANALYSIS_2026.md)** | Workflow script analysis | Understanding workflow helper scripts |

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

**January 2026 Workflow Analysis & Cleanup:**
- 🔍 **NEW:** Comprehensive duplication analysis completed ([DUPLICATION_ANALYSIS_2026.md](DUPLICATION_ANALYSIS_2026.md))
- 📋 **NEW:** Actionable cleanup plan created ([CLEANUP_PLAN_2026.md](CLEANUP_PLAN_2026.md))
- ⚠️ **Finding:** 3 duplicate CI workflows causing 66% waste in execution
- ⚠️ **Finding:** Service definitions duplicated across 6 workflows
- ✅ **Status:** Validated and ready for implementation

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
