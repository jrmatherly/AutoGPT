# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Context Loading

For efficient context, read these files first:

- **[PROJECT_INDEX.json](PROJECT_INDEX.json)** - Machine-readable project structure (94% token reduction vs exploring)

## Repository Structure

AutoGPT is a monorepo:

```tree
AutoGPT/
├── autogpt_platform/          # Modern platform (main development)
│   ├── backend/               # Python FastAPI server
│   ├── frontend/              # Next.js 15 React app
│   └── autogpt_libs/          # Shared Python libraries
└── docs/                      # Project documentation
```

## Platform-Specific Guidance

For platform development, see **[autogpt_platform/CLAUDE.md](autogpt_platform/CLAUDE.md)** which covers:

- Backend/Frontend commands
- Architecture overview
- Block development
- API modification
- PR guidelines

## Documentation

| Document | Purpose |
|----------|---------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture with Mermaid diagrams |
| [docs/API_REFERENCE.md](docs/API_REFERENCE.md) | Complete REST/WebSocket API documentation |
| [docs/BLOCK_SDK.md](docs/BLOCK_SDK.md) | Comprehensive block creation guide |
| [docs/CLAUDE.md](docs/CLAUDE.md) | Documentation writing guidelines |
| [docs/processes/RELEASE_PROCESS.md](docs/processes/RELEASE_PROCESS.md) | Release automation and versioning guide |

## Key Technologies

### Backend (Python)

- **Framework**: FastAPI with async support
- **ORM**: Prisma (PostgreSQL with pgvector)
- **Queue**: RabbitMQ for async task processing
- **Cache**: Redis
- **Auth**: JWT + Supabase

### Frontend (TypeScript)

- **Framework**: Next.js 15 App Router
- **Data Fetching**: Orval-generated hooks + React Query
- **Styling**: Tailwind CSS + shadcn/ui
- **Workflow Editor**: @xyflow/react
- **Icons**: Phosphor Icons only

## Development Tool Management

**The project uses [mise](https://mise.jdx.dev)** for unified development tool management.

### Common Commands (Mise - Recommended)

```bash
# First time setup
cd autogpt_platform
mise trust && mise run setup

# Daily development
mise run docker:up      # Start infrastructure (Supabase, Redis, RabbitMQ)
mise run backend        # Start backend server
mise run frontend       # Start frontend dev server

# Code quality
mise run format         # Format both backend + frontend
mise run lint           # Lint both backend + frontend
mise run test           # Run all tests

# Database
mise run db:migrate     # Run Prisma migrations
mise run db:reset       # Reset database

# Release management
mise run release        # Interactive release (creates git tag, GitHub release)
mise run release:patch  # Auto-confirm patch release (vX.Y.Z → vX.Y.Z+1)
mise run release:minor  # Auto-confirm minor release (vX.Y.Z → vX.Y+1.0)
mise run release:major  # Auto-confirm major release (vX.Y.Z → vX+1.0.0)

# List all available tasks
mise tasks
```

### Alternative Commands (Direct)

If you prefer not to use mise:

```bash
# Backend
cd autogpt_platform/backend
poetry install
poetry run prisma migrate dev
poetry run app
poetry run test

# Frontend
cd autogpt_platform/frontend
pnpm i
pnpm generate:api
pnpm dev
pnpm test
```

**For migration from Makefile:** See [docs/development/MISE_MIGRATION.md](docs/development/MISE_MIGRATION.md)

## Licensing

- **autogpt_platform/**: Polyform Shield License (commercial restrictions)

## Contributing

- Create PRs against the `master` branch
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `ci`, `docs`, `dx`
- Scopes: `platform`, `frontend`, `backend`, `blocks`, `infra`
