# Documentation Quick Reference

## When to Use Which Document

| Task | Primary Document |
|------|------------------|
| **Quick context loading** | [PROJECT_INDEX.md](../../PROJECT_INDEX.md) or [PROJECT_INDEX.json](../../PROJECT_INDEX.json) |
| **Project concepts & purpose** | [project_overview](project_overview.md) (Serena memory) |
| **System architecture** | [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md) |
| **Creating new blocks** | [docs/BLOCK_SDK.md](../../docs/BLOCK_SDK.md) |
| **API endpoint details** | [docs/API_REFERENCE.md](../../docs/API_REFERENCE.md) |
| **Backend development** | [autogpt_platform/CLAUDE.md](../../autogpt_platform/CLAUDE.md) |
| **Frontend development** | [autogpt_platform/frontend/CONTRIBUTING.md](../../autogpt_platform/frontend/CONTRIBUTING.md) |
| **Backend patterns & examples** | [backend_patterns](backend_patterns.md) (Serena memory) |
| **Frontend patterns & examples** | [frontend_patterns](frontend_patterns.md) (Serena memory) |
| **Code style questions** | [code_style_conventions](code_style_conventions.md) (Serena memory) |
| **Available commands** | [suggested_commands](suggested_commands.md) (Serena memory) |
| **Pre-commit checklist** | [task_completion_checklist](task_completion_checklist.md) (Serena memory) |
| **API quick reference** | [api_reference](api_reference.md) (Serena memory) |
| **Blocks catalog** | [blocks_catalog](blocks_catalog.md) (Serena memory) |
| **Microsoft Learn MCP integration** | [mcp_microsoft_learn_integration](mcp_microsoft_learn_integration.md) (Serena memory) |
| **Dependency management** | [dependency_management](dependency_management.md) (Serena memory) |
| **Unit testing patterns** | [unit_testing_patterns](unit_testing_patterns.md) (Serena memory) |
| **Workflow maintenance** | [workflow_maintenance](workflow_maintenance.md) (Serena memory) |
| **LiteLLM Proxy configuration** | [litellm_proxy_configuration](litellm_proxy_configuration.md) (Serena memory) |

---

## Documentation Organization Structure

### Where to Place Documentation

**CRITICAL**: Always create documentation in the `docs/` directory, organized by category.

| Category | Location | Purpose | Examples |
|----------|----------|---------|----------|
| **GitHub Actions** | `docs/github/workflows/` | Workflow analysis, CI/CD migration docs | MISE_MIGRATION_COMPLETE.md, WORKFLOWS.md |
| **Processes** | `docs/processes/` | Release process, deployment procedures | RELEASE_PROCESS.md, RELEASE_TASK_ANALYSIS.md |
| **Development** | `docs/development/` | Tool setup, development environment | MISE_MIGRATION.md, DRIFT_INTEGRATION.md |
| **Platform** | `docs/platform/` | Integration guides, OAuth flows | oauth-guide.md, api-guide.md |
| **Architecture** | `docs/` (root level) | System design, API reference | ARCHITECTURE.md, API_REFERENCE.md |

### Documentation Anti-Patterns

**Never create documentation in these locations:**

❌ `.github/workflows/` - Reserved for YAML workflow files only
❌ `autogpt_platform/backend/` - Source code directory
❌ `autogpt_platform/frontend/` - Source code directory  
❌ Root directory - Except root-level docs (CLAUDE.md, README.md)

### When Creating New Documentation

1. **Determine the category**: GitHub workflows, processes, development tooling, platform integration, or architecture
2. **Choose the correct `docs/` subdirectory** based on the table above
3. **Use descriptive filenames** in SCREAMING_SNAKE_CASE for analysis/reports, kebab-case for guides
4. **Update this index** if creating a new frequently-referenced document

### Enforcement

This structure is enforced through:
- CLAUDE.md documentation placement rules
- Serena memory (this file) for cross-session consistency
- Code review to catch misplaced documentation

---

## Quick Access

**For efficient context loading** (94% token reduction vs full codebase exploration):
```bash
# Read project index
cat PROJECT_INDEX.md

# Or use machine-readable format
cat PROJECT_INDEX.json
```

**For detailed documentation:**
- Architecture: `docs/ARCHITECTURE.md`
- API Reference: `docs/API_REFERENCE.md`
- Block SDK: `docs/BLOCK_SDK.md`
- Platform Guide: `autogpt_platform/CLAUDE.md`
- GitHub Workflows: `docs/github/workflows/WORKFLOWS.md`
- Release Process: `docs/processes/RELEASE_PROCESS.md`
