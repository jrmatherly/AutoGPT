# Project Index: AutoGPT

> **Generated**: 2026-01-29 | **Backend**: v0.6.22 | **Frontend**: v0.3.4

A platform for building, deploying, and managing AI agents that automate complex workflows.

---

## 📁 Project Structure

```tree
AutoGPT/
├── autogpt_platform/           # Modern platform (Polyform Shield License)
│   ├── backend/                # FastAPI + Python backend
│   ├── frontend/               # Next.js 15 + React frontend
│   ├── autogpt_libs/           # Shared Python libraries
│   ├── db/                     # Database Docker configs
│   └── docker-compose.yml      # Dev stack
└── docs/                       # Documentation
```

---

## 🚀 Entry Points

| Component | Path | Mise Command | Alternative |
|-----------|------|--------------|-------------|
| **Backend Server** | `autogpt_platform/backend/backend/app.py` | `mise run backend` | `poetry run serve` |
| **Frontend Dev** | `autogpt_platform/frontend/` | `mise run frontend` | `pnpm dev` |
| **Infrastructure** | `autogpt_platform/docker-compose.yml` | `mise run docker:up` | `docker compose up -d` |
| **REST API** | `autogpt_platform/backend/backend/rest.py` | N/A | `poetry run rest` |
| **WebSocket** | `autogpt_platform/backend/backend/ws.py` | N/A | `poetry run ws` |
| **Executor** | `autogpt_platform/backend/backend/exec.py` | N/A | `poetry run executor` |
| **Scheduler** | `autogpt_platform/backend/backend/scheduler.py` | N/A | `poetry run scheduler` |
| **CLI** | `autogpt_platform/backend/backend/cli_main.py` | N/A | `poetry run cli` |

---

## 📦 Core Modules

### Backend (`autogpt_platform/backend/backend/`)

| Module | Path | Purpose |
|--------|------|---------|
| **blocks/** | 224 files, 32 integrations | Workflow building blocks |
| **api/** | `api/features/` | REST endpoints (9 feature groups) |
| **data/** | `data/` | Data models, Prisma ORM |
| **executor/** | `executor/` | Workflow execution engine |
| **integrations/** | `integrations/` | OAuth, webhooks, credentials |
| **util/** | `util/` | Utilities, settings, caching |

### Frontend (`autogpt_platform/frontend/src/`)

| Module | Path | Purpose |
|--------|------|---------|
| **app/(platform)/** | 44 pages | Platform routes (build, library, marketplace) |
| **components/** | atoms/molecules/organisms | Design system components |
| **api/**generated**/** | Generated hooks | Type-safe API client (Orval) |
| **lib/** | Utilities | Helpers, configurations |
| **services/** | Business logic | Feature flags, etc. |

---

## 🔌 API Features

| Feature | Path | Description |
|---------|------|-------------|
| **library** | `api/features/library/` | Agent CRUD, presets |
| **builder** | `api/features/builder/` | Graph creation, execution |
| **store** | `api/features/store/` | Marketplace, submissions |
| **executions** | `api/features/executions/` | Run history, human review |
| **integrations** | `api/features/integrations/` | OAuth connections |
| **chat** | `api/features/chat/` | AI copilot |
| **admin** | `api/features/admin/` | Analytics, credits |
| **otto** | `api/features/otto/` | AI assistant |
| **postmark** | `api/features/postmark/` | Email notifications |

---

## 🧩 Block Integrations (32 Categories)

| Category | Blocks | Examples |
|----------|--------|----------|
| **Social Media** | Twitter, Discord, Reddit, Ayrshare | Tweets, DMs, multi-platform posting |
| **Productivity** | Google, Notion, Airtable, Todoist, Linear | Sheets, pages, tasks, issues |
| **AI/LLM** | OpenAI, Anthropic, Groq, Ollama, Perplexity | Chat, images, code |
| **Developer** | GitHub, Firecrawl, Exa | PRs, web scraping, search |
| **Media** | Replicate, Fal, Bannerbear | Video, images, audio |
| **Sales/CRM** | HubSpot, Apollo, Smartlead | Contacts, campaigns |
| **Core** | HTTP, Basic, Text, Iteration, Branching | Control flow, data ops |

---

## 🔧 Configuration

| File | Purpose |
|------|---------|
| `mise.lock` | Tool version pinning (Python 3.13.1, Node 22.22.0, pnpm 10.28.2) |
| `mise.toml` | Development environment configuration |
| `autogpt_platform/docker-compose.yml` | Development stack (DB, Redis, RabbitMQ, ClamAV) |
| `autogpt_platform/backend/schema.prisma` | Database schema |
| `autogpt_platform/backend/pyproject.toml` | Backend dependencies |
| `autogpt_platform/frontend/package.json` | Frontend dependencies |
| `autogpt_platform/frontend/orval.config.ts` | API client generation |
| `.pre-commit-config.yaml` | Pre-commit hooks |
| `autogpt_platform/CLAUDE.md` | AI assistant guide |
| `scripts/release.sh` | Release automation script (production-hardened) |
| `docs/processes/RELEASE_PROCESS.md` | Release process documentation |

---

## 🧪 Test Coverage

| Area | Files | Mise Command | Alternative |
|------|-------|--------------|-------------|
| **All Tests** | Backend + Frontend | `mise run test` | See below |
| **Backend Unit** | 61 `*_test.py` files | `mise run test:backend` | `poetry run test` |
| **Block Tests** | `blocks/test/test_block.py` | N/A | `poetry run pytest backend/blocks/test/` |
| **Frontend E2E** | Playwright | `mise run test:frontend` | `pnpm test` |
| **Storybook** | 57 `*.stories.tsx` files | N/A | `pnpm storybook` |

---

## 🔗 Key Dependencies

### Backend

| Package | Purpose |
|---------|---------|
| fastapi | Web framework |
| prisma | Database ORM |
| pika/aio-pika | RabbitMQ client |
| anthropic, openai, groq | LLM providers |
| supabase | Authentication |

### Frontend

| Package | Purpose |
|---------|---------|
| next (15.x) | React framework |
| @tanstack/react-query | Server state |
| @xyflow/react | Workflow editor |
| tailwindcss + shadcn/ui | Styling |
| orval | API client generation |

---

## 📝 Quick Start

### Using Mise (Recommended)

```bash
# 1. Install mise (one-time setup)
curl https://mise.run | sh
eval "$(mise activate bash)"  # Add to ~/.bashrc or ~/.zshrc

# 2. Setup project
cd autogpt_platform
mise trust && mise run setup

# 3. Daily development
mise run docker:up      # Start infrastructure (Supabase, Redis, RabbitMQ)
mise run backend        # Terminal 1: Start backend server
mise run frontend       # Terminal 2: Start frontend dev server

# Common tasks
mise tasks              # List all available tasks
mise run format         # Format and lint all code (backend + frontend)
mise run test           # Run all tests
mise run db:migrate     # Run database migrations
```

### Using Direct Commands (Alternative)

```bash
# 1. Start infrastructure
cd autogpt_platform && docker compose up -d

# 2. Backend setup
cd backend && poetry install
poetry run prisma migrate dev
poetry run serve

# 3. Frontend setup (new terminal)
cd frontend && pnpm i
pnpm generate:api
pnpm dev
```

**URLs**:

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- OpenAPI docs: http://localhost:8000/docs

---

## 🎯 Common Tasks

| Task | Mise Command | Alternative |
|------|--------------|-------------|
| **Start infrastructure** | `mise run docker:up` | `docker compose up -d` |
| **Format and lint all code** | `mise run format` | Backend: `poetry run format` / Frontend: `pnpm format` |
| **Run all tests** | `mise run test` | Backend: `poetry run test` / Frontend: `pnpm test` |
| **Database migrations** | `mise run db:migrate` | `poetry run prisma migrate dev` |
| **Reset database** | `mise run db:reset` | Stop DB, delete volume, re-run migrations |
| **Regenerate API client** | `cd frontend && pnpm generate:api` | Same |
| **Environment check** | `mise run doctor` | N/A |
| **List all tasks** | `mise tasks` | N/A |
| **Check dependencies** | `mise run deps:check` | Check for outdated dependencies |
| **Create release** | `mise run release` | Interactive release (creates tag, GitHub release) |
| **Patch release** | `mise run release:patch` | Auto-confirm patch version bump |
| **Add new block** | Create in `backend/blocks/`, inherit `Block`, test with `mise run test:backend` |
| **Add API endpoint** | Create route in `api/features/`, add Pydantic models, regenerate API client |
| **Add frontend page** | Create in `app/(platform)/`, add hooks, use generated API client |

---

## 📚 Documentation

| Doc | Path | Purpose |
|-----|------|---------|
| Main README | `README.md` | Project overview |
| Platform Guide | `autogpt_platform/CLAUDE.md` | Development guide |
| Frontend Contributing | `frontend/CONTRIBUTING.md` | Frontend patterns |
| Agents Guide | `AGENTS.md` | Platform contribution |
| Block SDK | `docs/content/platform/block-sdk-guide.md` | Creating blocks |
| Release Process | `docs/processes/RELEASE_PROCESS.md` | Release automation guide |

---

## 🔌 MCP Server Integration

| MCP Server | Documentation | Purpose |
|-----------|---------------|---------|
| **microsoft-learn** | `.serena/memories/mcp_microsoft_learn_integration.md` | Official Microsoft docs (TypeScript, Playwright, GitHub Actions) |

**Available Tools**:
- `microsoft_docs_search`: Quick documentation lookups (up to 10 content chunks)
- `microsoft_code_sample_search`: Code examples (up to 20 samples, language filter available)
- `microsoft_docs_fetch`: Full documentation pages in markdown format

**Covered Technologies**:
- ✅ TypeScript (official language docs)
- ✅ Playwright (Microsoft-maintained testing framework)
- ✅ GitHub Actions (Microsoft-owned CI/CD platform)
- ⚠️ React/Next.js (partial coverage, use official docs as primary)
- ✅ VS Code (editor configuration)

See `.serena/memories/mcp_microsoft_learn_integration.md` for complete integration guide.

---

*Index size: ~5KB | Full codebase: ~60KB tokens | Savings: 92%*
