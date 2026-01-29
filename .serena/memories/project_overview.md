# AutoGPT Project Overview

## Purpose

AutoGPT is a powerful platform for building, deploying, and managing continuous AI agents that automate complex workflows. It enables users to create custom AI-powered automation through a visual graph-based editor.

## Project Structure

The repository is a **monorepo** containing:

```
AutoGPT/
├── autogpt_platform/          # Modern platform (main development)
│   ├── backend/               # Python FastAPI server
│   ├── frontend/              # Next.js 15 React app
│   ├── autogpt_libs/          # Shared Python libraries
│   ├── graph_templates/       # Pre-built workflow templates
│   └── db/                    # Database Docker configuration
└── docs/                      # Project documentation
```

Licensed under **Polyform Shield License** (commercial restrictions apply).

## Tech Stack

### Backend (Python)

| Component | Technology |
|-----------|------------|
| **Framework** | FastAPI with async support |
| **Language** | Python 3.10+ |
| **Database** | PostgreSQL with Prisma ORM (includes pgvector for embeddings) |
| **Queue** | RabbitMQ for async task processing |
| **Cache** | Redis |
| **Auth** | JWT-based with Supabase integration |
| **Package Manager** | Poetry |
| **Testing** | pytest with snapshot testing |
| **Formatting** | Black + isort |
| **Linting** | Ruff |

### Frontend (TypeScript)

| Component | Technology |
|-----------|------------|
| **Framework** | Next.js 15 with App Router (client-first approach) |
| **Language** | TypeScript (strict mode) |
| **Data Fetching** | Orval-generated React Query hooks from OpenAPI spec |
| **State** | React Query (server state), Zustand (complex local state) |
| **Styling** | Tailwind CSS + shadcn/ui (Radix primitives) |
| **Components** | Design system with atoms, molecules, organisms |
| **Workflow Editor** | @xyflow/react |
| **Icons** | Phosphor Icons (only - no other icon libraries) |
| **Feature Flags** | LaunchDarkly |
| **Testing** | Playwright (E2E), Storybook (components), Vitest (units) |
| **Package Manager** | pnpm (v10.20.0+) |
| **Node** | 22.x |

## Key Concepts

1. **Agent Graphs**: Workflow definitions stored as JSON, executed by the backend. Contains nodes (blocks) and links (connections).

2. **Blocks**: Reusable components in `/backend/blocks/` that perform specific tasks (224+ available). Each block has input/output schemas and an async `run` method.

3. **Integrations**: OAuth and API connections stored per user for third-party services (Google, GitHub, Discord, Twitter, etc.).

4. **Store/Marketplace**: Platform for sharing and discovering agent templates.

5. **Execution Engine**: Separate executor service processes agent workflows asynchronously via RabbitMQ queue.

## Architecture Highlights

### Services

| Service | Purpose |
|---------|---------|
| **REST API** (`rest.py`) | Main HTTP endpoints |
| **WebSocket** (`ws.py`) | Real-time execution updates |
| **Executor** (`exec.py`) | Workflow execution engine |
| **Scheduler** (`scheduler.py`) | Task scheduling |
| **Notification** (`notification.py`) | User notifications |

### Security

- **Cache Protection Middleware**: Disables caching for all endpoints by default; only explicitly allowed paths can be cached
- **ClamAV**: Virus scanning for file uploads
- **User ID Validation**: All data layer operations verify user ownership

### Monitoring

- **Sentry**: Error tracking and exception monitoring
- **Prometheus**: Metrics collection
- **Structured Logging**: JSON logs for observability

## Development Workflow

### Quick Start

```bash
# Start infrastructure
cd autogpt_platform && docker compose up -d

# Backend
cd backend && poetry install && poetry run serve

# Frontend
cd frontend && pnpm i && pnpm dev
```

### Key Commands

| Task | Command |
|------|---------|
| Format backend | `poetry run format` |
| Test backend | `poetry run test` |
| Format frontend | `pnpm format` |
| Type check frontend | `pnpm types` |
| Generate API client | `pnpm generate:api` |

## Contributing

- Create PRs against the `dev` branch
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `ci`, `docs`, `dx`
- Scopes: `platform`, `frontend`, `backend`, `blocks`, `infra`
