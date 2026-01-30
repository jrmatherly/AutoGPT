# Suggested Commands

## Serena Configuration (Updated 2026-01-29)

The project is configured as a **multi-language monorepo** with:
- **TypeScript**: Frontend (Next.js/React) in `autogpt_platform/frontend/`
- **Python**: Backend (FastAPI) in `autogpt_platform/backend/` and libs in `autogpt_platform/autogpt_libs/`

**Development Tools**: Managed by [mise](https://mise.jdx.dev) - Python 3.13.1, Node 22.22.0, pnpm 10.28.2, Poetry 2.3.1

**To apply language server changes**: Restart Claude Code or the Serena MCP server.

--- for AutoGPT Development

## Quick Reference

**Development uses [mise](https://mise.jdx.dev)** - See [docs/MISE_MIGRATION.md](../../docs/development/MISE_MIGRATION.md) for migration from Makefile.

| Task | Command |
|------|---------|
| Setup project (first time) | `mise trust && mise run setup` |
| Start infrastructure | `mise run docker:up` |
| Backend dev server | `mise run backend` |
| Frontend dev server | `mise run frontend` |
| Format all code | `mise run format` |
| Run migrations | `mise run db:migrate` |
| Generate API client | `cd autogpt_platform/frontend && pnpm generate:api` |
| List all tasks | `mise tasks` |

## Mise Task Commands

Run from project root or `autogpt_platform/` directory (mise auto-detects context):

```bash
mise tasks                   # List all available tasks

# Core Services (Supabase + Redis + RabbitMQ)
mise run docker:up           # Start core services
mise run docker:down         # Stop all services
mise run docker:logs         # Tail logs

# Development Servers
mise run backend             # Run FastAPI server
mise run frontend            # Run Next.js dev server

# Code Quality
mise run format              # Format & lint backend AND frontend code
mise run lint                # Lint backend AND frontend code

# Database
mise run db:migrate          # Run Prisma migrations + generate client + stub
mise run db:reset            # Stop db, delete volume, run migrations
mise run db:rls-apply        # Apply RLS policies
mise run db:rls-verify       # Verify RLS policies

# Test Data
mise run test:data           # Run test data creator script
mise run store:load          # Load store agents from agents/ folder

# Testing
mise run test                # Run all tests (backend + frontend)
mise run test:backend        # Backend tests only
mise run test:frontend       # Frontend E2E tests only

# Drift - Codebase Pattern Analysis
# ⚠️ Multi-project commands run sequentially for backend, frontend, AND libs

mise run drift:status        # Show drift status for all projects
mise run drift:scan          # Scan all projects for patterns
mise run drift:check         # Check for violations (CI-friendly)
mise run drift:approve       # Approve discovered patterns (95%+ confidence)
mise run drift:approve:auto  # Auto-approve high-confidence patterns (≥90%)
mise run drift:audit         # Run audit review for all projects

# Advanced Analysis
mise run drift:coupling      # Build module coupling graphs
mise run drift:full          # Full analysis: scan, approve, callgraph, deep

# Setup & Diagnostics
mise run setup               # Complete project setup (first time)
mise run doctor              # Verify development environment
```

**Note:** Makefile still works but is deprecated. See [docs/MISE_MIGRATION.md](../../docs/development/MISE_MIGRATION.md).

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

# First time setup
mise trust                        # Trust mise configuration
mise run setup                    # Complete setup (installs tools, deps, runs migrations)

# Daily development
mise run docker:up                # Start Supabase + Redis + RabbitMQ
mise run backend                  # In terminal 1
mise run frontend                 # In terminal 2
```

### Before Committing

```bash
cd autogpt_platform
mise run format                   # Format both backend and frontend
mise run lint                     # Lint both backend and frontend
mise run test                     # Run all tests

# Or check individually
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
mise run drift:check

# View codebase health and patterns (shows backend → frontend → libs)
mise run drift:status

# After adding new code, scan for new patterns
mise run drift:scan              # For changes across all projects

# Deep analysis before major refactoring
mise run drift:coupling          # Check module dependencies

# Full analysis and approval workflow
mise run drift:full              # Complete scan, approve, and analyze

# Per-project audit commands
mise run drift:audit:backend     # Audit backend only
mise run drift:audit:frontend    # Audit frontend only
mise run drift:audit:libs        # Audit libs only
```

### Drift Intelligence

Drift analyzes the codebase for established patterns and conventions. Use drift commands to ensure new code follows project standards.

**Multi-project setup:** Each project (backend, frontend, libs) has its own `.drift/` directory with isolated pattern analysis.

**Run drift analysis:**
- `mise run drift:status` - View current drift status
- `mise run drift:scan` - Discover new patterns
- `mise run drift:check` - Check for violations (CI-friendly)
- `mise run drift:approve` - Approve discovered patterns (95%+ confidence)
- `mise run drift:approve:auto` - Auto-approve high-confidence patterns (≥90%)
- `mise run drift:audit` - Run audit review with recommendations
