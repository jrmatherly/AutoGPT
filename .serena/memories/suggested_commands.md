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
