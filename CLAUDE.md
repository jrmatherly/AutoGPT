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

## Common Commands

```bash
# Start infrastructure
cd autogpt_platform && docker compose up -d

# Backend
cd autogpt_platform/backend
poetry install
poetry run prisma migrate dev
poetry run serve
poetry run test

# Frontend
cd autogpt_platform/frontend
pnpm i
pnpm generate:api
pnpm dev
pnpm test
```

## Licensing

- **autogpt_platform/**: Polyform Shield License (commercial restrictions)

## Contributing

- Create PRs against the `dev` branch
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `ci`, `docs`, `dx`
- Scopes: `platform`, `frontend`, `backend`, `blocks`, `infra`
