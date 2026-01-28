# Suggested Commands for AutoGPT Development

## System Commands (macOS/Darwin)
```bash
# Standard Unix utilities work on Darwin
git, ls, cd, grep, find, cat, etc.

# Homebrew for package management
brew install <package>
```

## Backend Development (autogpt_platform/backend)

### Setup
```bash
cd autogpt_platform/backend
poetry install                    # Install dependencies

# Start all services (database, redis, rabbitmq, clamav)
docker compose up -d

# Run database migrations
poetry run prisma migrate dev
poetry run prisma generate        # Generate Prisma client
```

### Running Services
```bash
poetry run serve                  # Run the backend server (all services)
poetry run app                    # Run main app
poetry run rest                   # Run REST server
poetry run ws                     # Run WebSocket server
poetry run scheduler              # Run scheduler
poetry run executor               # Run executor
```

### Testing
```bash
poetry run test                   # Run all tests
poetry run pytest path/to/test.py::test_function  # Run specific test
poetry run pytest backend/blocks/test/test_block.py -xvs  # Test blocks
poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[GetCurrentTimeBlock]' -xvs  # Test specific block
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

## Classic AutoGPT (classic/)

### Setup & Run
```bash
./run setup                       # Install dependencies
./run agent start <agent>         # Start an agent
./run benchmark                   # Run benchmarks
```

### Individual Projects
```bash
cd classic/original_autogpt && poetry install
cd classic/forge && poetry install
cd classic/benchmark && poetry install
```

## Docker Commands

### Platform Stack
```bash
cd autogpt_platform
docker compose up -d              # Start all services
docker compose down               # Stop all services
docker compose logs -f <service>  # View logs
```

## Git Workflow
```bash
git checkout dev                  # Work from dev branch
git checkout -b feature/name      # Create feature branch
# Use conventional commits: feat(scope): message
```

## Pre-commit Hooks
```bash
pre-commit install                # Install hooks
pre-commit run --all-files        # Run all hooks manually
```

## Quick Reference

| Task | Command |
|------|---------|
| Backend tests | `cd autogpt_platform/backend && poetry run test` |
| Frontend dev | `cd autogpt_platform/frontend && pnpm dev` |
| Format backend | `poetry run format` |
| Format frontend | `pnpm format` |
| Type check frontend | `pnpm types` |
| Generate API client | `pnpm generate:api` |
| Start Docker services | `docker compose up -d` |
