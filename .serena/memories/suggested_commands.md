# Suggested Commands

## Serena Configuration (Updated 2026-01-29)

The project is configured as a **multi-language monorepo** with:
- **TypeScript**: Frontend (Next.js/React) in `autogpt_platform/frontend/`
- **Python**: Backend (FastAPI) in `autogpt_platform/backend/` and libs in `autogpt_platform/autogpt_libs/`

**To apply language server changes**: Restart Claude Code or the Serena MCP server.

--- for AutoGPT Development

## Quick Reference

| Task | Command |
|------|---------|
| Start infrastructure | `cd autogpt_platform && make start-core` |
| Backend dev server | `cd autogpt_platform && make run-backend` |
| Frontend dev server | `cd autogpt_platform && make run-frontend` |
| Format all code | `cd autogpt_platform && make format` |
| Run migrations | `cd autogpt_platform && make migrate` |
| Generate API client | `cd autogpt_platform/frontend && pnpm generate:api` |

## Makefile Commands (autogpt_platform/)

Run from `autogpt_platform/` directory:

```bash
make help                    # List all available make targets

# Core Services (Supabase + Redis + RabbitMQ)
make start-core              # Start core services: docker compose up -d deps
make stop-core               # Stop all services: docker compose stop
make logs-core               # Tail logs: docker compose logs -f deps

# Development Servers
make run-backend             # Run FastAPI server: cd backend && poetry run app
make run-frontend            # Run Next.js dev: cd frontend && pnpm dev

# Code Quality
make format                  # Format & lint backend AND frontend code

# Database
make migrate                 # Run Prisma migrations + generate client + gen-prisma-stub
make reset-db                # Stop db, delete volume, run migrations

# Environment Setup
make init-env                # Copy .env.default to .env for all services (platform, backend, frontend)

# Test Data
make test-data               # Run test data creator script
make load-store-agents       # Load store agents from agents/ folder

# Drift - Codebase Pattern Analysis
# ⚠️  IMPORTANT: Multi-project commands run sequentially for backend, frontend, AND libs

# Multi-Project Commands (executes for all 3 projects)
make drift-status            # Show drift status for all projects
make drift-scan              # Scan all projects for patterns
make drift-check             # Check for violations (CI-friendly)
make drift-approve           # Approve all discovered patterns (95%+ confidence)

# Single-Project Commands (executes for specific project only)
make drift-scan-backend      # Scan backend only (verbose)
make drift-scan-frontend     # Scan frontend only (verbose)
make drift-scan-libs         # Scan libs only (verbose)

# Advanced Analysis (executes for all 3 projects)
make drift-callgraph         # Build call graphs for all projects
make drift-analyze           # Run language-specific analysis (Python/TypeScript) for all
make drift-coupling          # Build module coupling graphs for all projects
make drift-coupling-cycles   # Find dependency cycles in all projects
make drift-coupling-hotspots # Find highly coupled modules in all projects
make drift-test-topology     # Build test topology for all projects
make drift-error-gaps        # Find error handling gaps in all projects

# Combined Workflows (executes for all 3 projects)
make drift-deep              # Run coupling + test-topology for all projects
make drift-full              # Full setup: scan, approve, callgraph, deep for all projects
```

## Backend Development (autogpt_platform/backend)

### Setup

```bash
cd autogpt_platform/backend
poetry install                    # Install dependencies
docker compose up -d              # Start services (db, redis, rabbitmq, clamav)
poetry run prisma migrate dev     # Run database migrations (dev mode)
poetry run prisma generate        # Generate Prisma client
poetry run gen-prisma-stub        # Generate Prisma type stubs
```

### Running Services

```bash
poetry run serve                  # Run all backend services
poetry run app                    # Run main app (used by make run-backend)
poetry run rest                   # Run REST server only
poetry run ws                     # Run WebSocket server only
poetry run scheduler              # Run scheduler service
poetry run executor               # Run executor service
```

### Testing

```bash
poetry run test                   # Run all tests
poetry run pytest path/to/test.py::test_function  # Specific test
poetry run pytest backend/blocks/test/test_block.py -xvs  # Test all blocks
poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[GetCurrentTimeBlock]' -xvs  # Specific block
poetry run pytest path/to/test.py --snapshot-update  # Update snapshots
```

### Linting & Formatting

```bash
poetry run format                 # Black + isort (auto-fix)
poetry run lint                   # Ruff linting
```

## Frontend Development (autogpt_platform/frontend)

### Setup

```bash
cd autogpt_platform/frontend
pnpm i                            # Install dependencies
pnpm generate:api                 # Generate API client from OpenAPI spec
```

### Running

```bash
pnpm dev                          # Start dev server (generates API first)
pnpm build                        # Production build
pnpm start                        # Start production server
pnpm storybook                    # Run Storybook for components
```

### Testing

```bash
pnpm test                         # Run Playwright E2E tests
pnpm test-ui                      # Playwright with UI
pnpm test:unit                    # Run Vitest unit tests
pnpm test:unit:watch              # Unit tests in watch mode
pnpm test-storybook               # Test Storybook stories
```

### Linting & Formatting

```bash
pnpm lint                         # ESLint + Prettier check
pnpm format                       # Auto-fix formatting
pnpm types                        # TypeScript type checking
```

### API Client Generation

```bash
pnpm fetch:openapi                # Fetch OpenAPI spec from backend (port 8006)
pnpm generate:api-client          # Generate TypeScript client using Orval
pnpm generate:api                 # Run both fetch and generate in sequence
```

## Docker Commands

### Platform Stack

```bash
cd autogpt_platform
docker compose up -d              # Start all services
docker compose down               # Stop and remove containers
docker compose stop               # Stop without removing
docker compose logs -f <service>  # View logs for a service
docker compose ps                 # Check service status
docker compose build <service>    # Build specific service
docker compose up -d --scale executor=3  # Scale executor service
docker compose watch              # Watch for changes and auto-update
```

### Service-Specific Commands

```bash
# Rebuild and restart API server
docker compose build api_srv
docker compose up -d --no-deps api_srv

# View logs for multiple services
docker compose logs -f api_srv ws_srv

# Full system restart
docker compose stop
docker compose rm -f
docker compose pull
docker compose up -d
```

## Git Workflow

```bash
git checkout dev                  # Work from dev branch
git checkout -b feature/name      # Create feature branch

# Conventional commit format
git commit -m "feat(scope): description"
git commit -m "fix(backend): resolve authentication timeout"

# Pre-commit hooks
pre-commit install                # Install hooks
pre-commit run --all-files        # Run all hooks manually
```

## PR Review Commands

```bash
# Fetch PR reviews
gh api /repos/Significant-Gravitas/AutoGPT/pulls/{pr_number}/reviews

# Get review comments
gh api /repos/Significant-Gravitas/AutoGPT/pulls/{pr_number}/reviews/{review_id}/comments

# Get PR comments
gh api /repos/Significant-Gravitas/AutoGPT/issues/{pr_number}/comments
```

## Common Workflows

### Starting Development

```bash
cd autogpt_platform
make init-env                     # Copy environment files (first time only)
make start-core                   # Start Supabase + Redis + RabbitMQ
make migrate                      # Run migrations
make run-backend                  # In terminal 1
make run-frontend                 # In terminal 2
```

### Before Committing

```bash
cd autogpt_platform
make format                       # Format both backend and frontend

# Additional checks
cd backend && poetry run lint && poetry run test
cd frontend && pnpm types && pnpm test
```

### After Modifying Backend API

```bash
cd autogpt_platform/frontend
pnpm generate:api                 # Regenerate TypeScript client
```

### Using Drift for Code Intelligence

**Multi-Project Execution**: Drift commands run for all 3 projects (backend, frontend, libs) sequentially.

```bash
cd autogpt_platform

# Quick pattern check before committing (runs for all 3 projects)
make drift-check

# View codebase health and patterns (shows backend → frontend → libs)
make drift-status

# After adding new code, scan for new patterns
make drift-scan                  # For changes across projects (all 3)
make drift-scan-backend          # For backend changes only (single project)
make drift-scan-frontend         # For frontend changes only (single project)

# Deep analysis before major refactoring
make drift-coupling              # Check module dependencies
make drift-coupling-cycles       # Find circular dependencies
make drift-test-topology         # Understand test coverage

# Find areas needing improvement
make drift-error-gaps            # Identify missing error handling
make drift-coupling-hotspots     # Find tightly coupled modules

# Full analysis and approval workflow
make drift-full                  # Complete scan, approve, and analyze
```

### Drift Intelligence in Development

The drift analysis has discovered **805 approved patterns** across the codebase:

**Pattern Categories** (with coverage):
- `data-access` (88 patterns, 81% coverage) - Database queries, Prisma usage
- `components` (65 patterns, 78% coverage) - React component patterns
- `styling` (61 patterns, 82% coverage) - Tailwind/CSS conventions
- `testing` (60 patterns, 87% coverage) - Test structure and assertions
- `security` (59 patterns, 83% coverage) - Auth, validation, sanitization
- `errors` (58 patterns, 86% coverage) - Error handling patterns
- `types` (58 patterns, 84% coverage) - TypeScript type usage
- `performance` (52 patterns, 83% coverage) - Optimization patterns
- `api` (18 patterns, 100% coverage) - API route patterns

**Health Score**: 95/100 | **Violations**: 0

Use drift patterns to ensure new code follows established conventions.

#### How Multi-Project Commands Work

When you run a multi-project drift command, the Makefile executes it for each project sequentially:

```bash
# Example: make drift-status
cd autogpt_platform
make drift-status

# Executes:
# 1. cd backend && drift status --detailed
# 2. cd frontend && drift status --detailed  
# 3. cd autogpt_libs && drift status --detailed
```

**Project Structure:**
- **Backend**: `autogpt_platform/backend/` - Python/FastAPI
- **Frontend**: `autogpt_platform/frontend/` - TypeScript/Next.js
- **Libs**: `autogpt_platform/autogpt_libs/` - Python shared libraries

Each project has its own `.drift/` directory with isolated pattern analysis.
