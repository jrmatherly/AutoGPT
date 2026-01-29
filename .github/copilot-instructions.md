<!--
  GitHub Copilot Instructions for AutoGPT
  Version: 2.0
  Last Updated: 2026-01-29
  This is a living document - update as the project evolves
-->

# GitHub Copilot Instructions for AutoGPT

This file provides comprehensive onboarding information for GitHub Copilot coding agent to work efficiently with the AutoGPT repository.

## Repository Overview

**AutoGPT** is a powerful platform for creating, deploying, and managing continuous AI agents that automate complex workflows. This is a large monorepo (~150MB) containing multiple components:

- **AutoGPT Platform** (`autogpt_platform/`) - Main focus: Modern AI agent platform (Polyform Shield License)
- **Documentation** (`docs/`) - MkDocs-based documentation site
- **Infrastructure** - Docker configurations, CI/CD, and development tools

**Primary Languages & Frameworks:**

- **Backend**: Python 3.10-3.13, FastAPI, Prisma ORM, PostgreSQL, RabbitMQ
- **Frontend**: TypeScript, Next.js 15, React, Tailwind CSS, Radix UI
- **Development**: Docker, Poetry, pnpm, Playwright, Storybook

## Development Tool Management

**The project uses [mise](https://mise.jdx.dev)** for unified development tool management. Mise automatically installs and manages Python, Node.js, Poetry, and pnpm at the correct versions.

### Quick Setup with Mise (Recommended)

```bash
# Install mise (one-time)
curl https://mise.run | sh
eval "$(mise activate bash)"  # Add to ~/.bashrc or ~/.zshrc

# Setup project (replaces manual steps below)
cd autogpt_platform
mise trust                    # Trust the mise configuration
mise run setup                # Install everything automatically
```

**📖 Complete Setup Guide:** See [CONTRIBUTING.md](../CONTRIBUTING.md) for full installation and troubleshooting.

**Alternative:** You can still use Poetry and pnpm directly if you prefer manual management. The commands below show both approaches.

---

## Build and Validation Instructions

### Recommended: Automated Setup with Mise

**If you have mise installed** (recommended for new contributors):

```bash
# Clone and enter repository
git clone <repo> && cd AutoGPT

# Complete setup (handles all dependencies, services, and migrations)
cd autogpt_platform
mise trust && mise run setup

# Verify environment
mise run doctor
```

**That's it!** Mise handles all of the following automatically:
- Installing Python, Node.js, Poetry, pnpm at correct versions
- Starting Docker services (Supabase, Redis, RabbitMQ, ClamAV)
- Installing backend and frontend dependencies
- Running database migrations

### Alternative: Manual Setup (Without Mise)

**If you prefer manual setup** or don't have mise installed:

1. **Initial Setup** (required once):

   ```bash
   # Clone and enter repository
   git clone <repo> && cd AutoGPT

   # Start all services (database, redis, rabbitmq, clamav)
   cd autogpt_platform && docker compose --profile local up deps --build --detach
   ```

2. **Backend Setup** (always run before backend development):

   ```bash
   cd autogpt_platform/backend
   poetry install                    # Install dependencies
   poetry run prisma migrate dev     # Run database migrations
   poetry run prisma generate        # Generate Prisma client
   ```

3. **Frontend Setup** (always run before frontend development):
   ```bash
   cd autogpt_platform/frontend
   pnpm install                      # Install dependencies
   ```

### Runtime Requirements

**Critical:** Always ensure Docker services are running before starting development.

**With mise:**
```bash
cd autogpt_platform && mise run docker:up
```

**Without mise:**
```bash
cd autogpt_platform && docker compose --profile local up deps --build --detach
```

**Python Version:** Python 3.11 (required; managed automatically by mise or Poetry via pyproject.toml)
**Node.js Version:** Node.js 21+ with pnpm (managed automatically by mise or manually)

### Development Commands

**Backend Development:**

Recommended (with mise):
```bash
cd autogpt_platform
mise run backend                     # Start development server (port 8000)
mise run test:backend                # Run all backend tests
mise run format                      # Format all code (backend + frontend)
mise run db:migrate                  # Run database migrations
```

Alternative (direct tools):
```bash
cd autogpt_platform/backend
poetry run serve                     # Start development server (port 8000)
poetry run test                      # Run all tests (requires ~5 minutes)
poetry run pytest path/to/test.py    # Run specific test
poetry run format                    # Format code (Black + isort) - always run first
poetry run lint                      # Lint code (ruff) - run after format
```

**Frontend Development:**

Recommended (with mise):
```bash
cd autogpt_platform
mise run frontend                    # Start development server (port 3000)
mise run test:frontend               # Run Playwright E2E tests
mise run format                      # Format all code (backend + frontend)
```

Alternative (direct tools):
```bash
cd autogpt_platform/frontend
pnpm dev                            # Start development server (port 3000) - use for active development
pnpm build                          # Build for production (only needed for E2E tests or deployment)
pnpm test                           # Run Playwright E2E tests (requires build first)
pnpm test-ui                        # Run tests with UI
pnpm format                         # Format and lint code
pnpm storybook                      # Start component development server
```

**All Tasks:**

View all available mise tasks:
```bash
cd autogpt_platform && mise tasks
```

### Testing Strategy

**Backend Tests:**

- **Block Tests**: `poetry run pytest backend/blocks/test/test_block.py -xvs` (validates all blocks)
- **Specific Block**: `poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[BlockName]' -xvs`
- **Snapshot Tests**: Use `--snapshot-update` when output changes, always review with `git diff`

**Frontend Tests:**

- **E2E Tests**: Always run `pnpm dev` before `pnpm test` (Playwright requires running instance)
- **Component Tests**: Use Storybook for isolated component development

### Critical Validation Steps

**Before committing changes:**

With mise (recommended):
```bash
cd autogpt_platform
mise run format                      # Format all code
mise run test                        # Run all tests
mise run doctor                      # Verify environment
```

Without mise:
```bash
# Backend
cd autogpt_platform/backend && poetry run format && poetry run test

# Frontend
cd autogpt_platform/frontend && pnpm format && pnpm test
```

**Common Issues & Workarounds:**

- **Prisma issues**: Run `poetry run prisma generate` (or `mise run db:migrate`)
- **Permission errors**: Ensure Docker has proper permissions
- **Port conflicts**: Check the `docker-compose.yml` file for the current list of exposed ports
- **Test timeouts**: Backend tests can take 5+ minutes, use `-x` flag to stop on first failure
- **Environment issues**: Run `mise run doctor` to diagnose problems

## Project Layout & Architecture

### Core Architecture

**AutoGPT Platform** (`autogpt_platform/`):

- `backend/` - FastAPI server with async support
  - `backend/backend/` - Core API logic
  - `backend/blocks/` - Agent execution blocks
  - `backend/data/` - Database models and schemas
  - `schema.prisma` - Database schema definition
- `frontend/` - Next.js application
  - `src/app/` - App Router pages and layouts
  - `src/components/` - Reusable React components
  - `src/lib/` - Utilities and configurations
- `autogpt_libs/` - Shared Python utilities
- `docker-compose.yml` - Development stack orchestration

**Key Configuration Files:**

- `pyproject.toml` - Python dependencies and tooling
- `package.json` - Node.js dependencies and scripts
- `schema.prisma` - Database schema and migrations
- `next.config.mjs` - Next.js configuration
- `tailwind.config.ts` - Styling configuration

### Security & Middleware

**Cache Protection**: Backend includes middleware preventing sensitive data caching in browsers/proxies
**Authentication**: JWT-based with Supabase integration
**User ID Validation**: All data access requires user ID checks - verify this for any `data/*.py` changes

### Development Workflow

**GitHub Actions**: Multiple CI/CD workflows in `.github/workflows/`

- `ci-mise.yml` - Comprehensive mise-based CI (recommended for new workflows)
- `platform-backend-ci.yml` - Backend testing and validation
- `platform-frontend-ci.yml` - Frontend testing and validation
- `platform-fullstack-ci.yml` - End-to-end integration tests

**Pre-commit Hooks**: Run linting and formatting checks
**Conventional Commits**: Use format `type(scope): description` (e.g., `feat(backend): add API`)
**Development Tool**: [mise](https://mise.jdx.dev) for unified environment management

### Key Source Files

**Backend Entry Points:**

- `backend/backend/server/server.py` - FastAPI application setup
- `backend/backend/data/` - Database models and user management
- `backend/blocks/` - Agent execution blocks and logic

**Frontend Entry Points:**

- `frontend/src/app/layout.tsx` - Root application layout
- `frontend/src/app/page.tsx` - Home page
- `frontend/src/lib/supabase/` - Authentication and database client

**Protected Routes**: Update `frontend/lib/supabase/middleware.ts` when adding protected routes

### Agent Block System

Agents are built using a visual block-based system where each block performs a single action. Blocks are defined in `backend/blocks/` and must include:

- Block definition with input/output schemas
- Execution logic with proper error handling
- Tests validating functionality

### Database & ORM

**Prisma ORM** with PostgreSQL backend including pgvector for embeddings:

- Schema in `schema.prisma`
- Migrations in `backend/migrations/`
- Always run `prisma migrate dev` and `prisma generate` after schema changes

## Environment Configuration

### Configuration Files Priority Order

1. **Backend**: `/backend/.env.default` → `/backend/.env` (user overrides)
2. **Frontend**: `/frontend/.env.default` → `/frontend/.env` (user overrides)
3. **Platform**: `/.env.default` (Supabase/shared) → `/.env` (user overrides)
4. Docker Compose `environment:` sections override file-based config
5. Shell environment variables have highest precedence

### Docker Environment Setup

- All services use hardcoded defaults (no `${VARIABLE}` substitutions)
- The `env_file` directive loads variables INTO containers at runtime
- Backend/Frontend services use YAML anchors for consistent configuration
- Copy `.env.default` files to `.env` for local development customization

## Advanced Development Patterns

### Adding New Blocks

1. Create file in `/backend/backend/blocks/`
2. Inherit from `Block` base class with input/output schemas
3. Implement `run` method with proper error handling
4. Generate block UUID using `uuid.uuid4()`
5. Register in block registry
6. Write tests alongside block implementation
7. Consider how inputs/outputs connect with other blocks in graph editor

### API Development

1. Update routes in `/backend/backend/server/routers/`
2. Add/update Pydantic models in same directory
3. Write tests alongside route files
4. For `data/*.py` changes, validate user ID checks
5. Run `poetry run test` (or `mise run test:backend`) to verify changes

### Frontend Development

**📖 Complete Frontend Guide**: See `autogpt_platform/frontend/CONTRIBUTING.md` and `autogpt_platform/frontend/.cursorrules` for comprehensive patterns and conventions.

**Quick Reference:**

**Component Structure:**

- Separate render logic from data/behavior
- Structure: `ComponentName/ComponentName.tsx` + `useComponentName.ts` + `helpers.ts`
- Exception: Small components (3-4 lines of logic) can be inline
- Render-only components can be direct files without folders

**Data Fetching:**

- Use generated API hooks from `@/app/api/__generated__/endpoints/`
- Generated via Orval from backend OpenAPI spec
- Pattern: `use{Method}{Version}{OperationName}`
- Example: `useGetV2ListLibraryAgents`
- Regenerate with: `pnpm generate:api` (or `mise run frontend` does this automatically)
- **Never** use deprecated `BackendAPI` or `src/lib/autogpt-server-api/*`

**Code Conventions:**

- Use function declarations for components and handlers (not arrow functions)
- Only arrow functions for small inline lambdas (map, filter, etc.)
- Components: `PascalCase`, Hooks: `camelCase` with `use` prefix
- No barrel files or `index.ts` re-exports
- Minimal comments (code should be self-documenting)

**Styling:**

- Use Tailwind CSS utilities only
- Use design system components from `src/components/` (atoms, molecules, organisms)
- Never use `src/components/__legacy__/*`
- Only use Phosphor Icons (`@phosphor-icons/react`)
- Prefer design tokens over hardcoded values

**Error Handling:**

- Render errors: Use `<ErrorCard />` component
- Mutation errors: Display with toast notifications
- Manual exceptions: Use `Sentry.captureException()`
- Global error boundaries already configured

**Testing:**

- Add/update Storybook stories for UI components (`pnpm storybook`)
- Run Playwright E2E tests with `pnpm test`
- Verify in Chromatic after PR

**Architecture:**

- Default to client components ("use client")
- Server components only for SEO or extreme TTFB needs
- Use React Query for server state (via generated hooks)
- Co-locate UI state in components/hooks

### Security Guidelines

**Cache Protection Middleware** (`/backend/backend/server/middleware/security.py`):

- Default: Disables caching for ALL endpoints with `Cache-Control: no-store, no-cache, must-revalidate, private`
- Uses allow list approach for cacheable paths (static assets, health checks, public pages)
- Prevents sensitive data caching in browsers/proxies
- Add new cacheable endpoints to `CACHEABLE_PATHS`

### CI/CD Alignment

The repository has comprehensive CI workflows that test:

- **Backend**: Python 3.11-3.13, services (Redis/RabbitMQ/ClamAV), Prisma migrations, Poetry lock validation
- **Frontend**: Node.js 21, pnpm, Playwright with Docker Compose stack, API schema validation
- **Integration**: Full-stack type checking and E2E testing
- **Mise-based**: `ci-mise.yml` provides comprehensive mise-based CI pipeline

Match these patterns when developing locally - the copilot setup environment mirrors these CI configurations.

## Collaboration with Other AI Assistants

This repository is actively developed with assistance from Claude (via CLAUDE.md files). When working on this codebase:

- Check for existing CLAUDE.md files that provide additional context
- Follow established patterns and conventions already in the codebase
- Maintain consistency with existing code style and architecture
- Consider that changes may be reviewed and extended by both human developers and AI assistants

## Trust These Instructions

These instructions are comprehensive and tested. Only perform additional searches if:

1. Information here is incomplete for your specific task
2. You encounter errors not covered by the workarounds
3. You need to understand implementation details not covered above

For detailed platform development patterns, refer to `autogpt_platform/CLAUDE.md` and `AGENTS.md` in the repository root.

---

**Note:** This is a living document that evolves with the project. For the most up-to-date setup instructions, always refer to [CONTRIBUTING.md](../CONTRIBUTING.md).
