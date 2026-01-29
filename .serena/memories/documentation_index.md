# AutoGPT Documentation Index

## Primary Documentation Files

### Root Level

| Document | Path | Purpose |
|----------|------|---------|
| **CLAUDE.md** | `CLAUDE.md` | AI assistant development guide (root) |
| **AGENTS.md** | `AGENTS.md` | Platform contribution guide for AI agents |
| **CONTRIBUTING.md** | `CONTRIBUTING.md` | General contribution guidelines |
| **PROJECT_INDEX.md** | `PROJECT_INDEX.md` | Quick reference (~3KB vs 58KB full read) |
| **PROJECT_INDEX.json** | `PROJECT_INDEX.json` | Machine-readable project index |

### Platform Level

| Document | Path | Purpose |
|----------|------|---------|
| **Platform CLAUDE.md** | `autogpt_platform/CLAUDE.md` | Detailed AI development guide for platform |
| **Platform README** | `autogpt_platform/README.md` | Getting started, Docker commands |
| **Platform Makefile** | `autogpt_platform/Makefile` | Development make targets |
| **Frontend CONTRIBUTING** | `autogpt_platform/frontend/CONTRIBUTING.md` | Frontend patterns, component structure |

### Generated Documentation (`docs/`)

| Document | Path | Purpose |
|----------|------|---------|
| **ARCHITECTURE.md** | `docs/ARCHITECTURE.md` | System architecture, Mermaid diagrams |
| **API_REFERENCE.md** | `docs/API_REFERENCE.md` | Complete REST/WebSocket API documentation |
| **BLOCK_SDK.md** | `docs/BLOCK_SDK.md` | Comprehensive block creation guide |
| **DRIFT_INTEGRATION.md** | `docs/DRIFT_INTEGRATION.md` | Drift codebase intelligence guide (846 lines) |
| **CLAUDE.md (docs)** | `docs/CLAUDE.md` | Documentation writing guidelines |

## Serena Memory Files

| Memory | Content |
|--------|---------|
| `project_overview.md` | Purpose, tech stack, key concepts, architecture |
| `project_index.md` | Navigation, module structure, quick integrations |
| `api_reference.md` | API endpoints, data models, error codes |
| `blocks_catalog.md` | 224+ blocks organized by category |
| `codebase_structure.md` | Directory layout, key files |
| `code_style_conventions.md` | Python/TypeScript style guides, commit format |
| `design_patterns_guidelines.md` | Block patterns, component patterns, testing |
| `suggested_commands.md` | Development commands, Makefile targets |
| `task_completion_checklist.md` | Pre-commit checks, PR checklist |
| `documentation_index.md` | This file - documentation navigation |

## Token Efficiency

| Resource | Tokens |
|----------|--------|
| PROJECT_INDEX.md | ~3,000 |
| Full codebase read | ~58,000 |
| **Savings** | **94%** |

## Quick Access Commands

```bash
# Read project index for quick context
cat PROJECT_INDEX.md

# Read architecture for system overview
cat docs/ARCHITECTURE.md

# Read API reference for endpoint details
cat docs/API_REFERENCE.md

# Read block SDK for creating blocks
cat docs/BLOCK_SDK.md

# Read platform development guide
cat autogpt_platform/CLAUDE.md

# Read frontend contribution guide
cat autogpt_platform/frontend/CONTRIBUTING.md
```

## Documentation Hierarchy

```
Root Level
├── CLAUDE.md              # Primary AI guidance
├── AGENTS.md              # AI contribution guide
├── CONTRIBUTING.md        # General contribution
├── PROJECT_INDEX.md       # Quick reference
└── PROJECT_INDEX.json     # Machine-readable

Platform Level
├── autogpt_platform/
│   ├── CLAUDE.md          # Detailed platform guidance
│   ├── README.md          # Getting started
│   ├── Makefile           # Make targets
│   └── frontend/
│       └── CONTRIBUTING.md  # Frontend patterns

Generated Docs
└── docs/
    ├── ARCHITECTURE.md    # System architecture
    ├── API_REFERENCE.md   # API documentation
    ├── BLOCK_SDK.md       # Block creation guide
    └── CLAUDE.md          # Doc writing guidelines

Serena Memories
└── .serena/memories/
    ├── project_overview.md
    ├── project_index.md
    ├── api_reference.md
    ├── blocks_catalog.md
    ├── codebase_structure.md
    ├── code_style_conventions.md
    ├── design_patterns_guidelines.md
    ├── suggested_commands.md
    ├── task_completion_checklist.md
    └── documentation_index.md
```

## When to Use Which Document

| Task | Primary Document |
|------|------------------|
| Quick context loading | `PROJECT_INDEX.md` or `PROJECT_INDEX.json` |
| Understanding architecture | `docs/ARCHITECTURE.md` |
| Creating new blocks | `docs/BLOCK_SDK.md` |
| API endpoint details | `docs/API_REFERENCE.md` |
| Backend development | `autogpt_platform/CLAUDE.md` |
| Frontend development | `autogpt_platform/frontend/CONTRIBUTING.md` |
| Code style questions | `.serena/memories/code_style_conventions.md` |
| Available commands | `.serena/memories/suggested_commands.md` |
| Pre-commit checklist | `.serena/memories/task_completion_checklist.md` |
