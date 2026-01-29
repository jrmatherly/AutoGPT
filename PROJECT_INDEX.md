# Project Index: AutoGPT

> **Generated**: 2026-01-28 | **Backend**: v0.6.22 | **Frontend**: v0.3.4

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

| Component | Path | Command |
|-----------|------|---------|
| **Backend Server** | `autogpt_platform/backend/backend/app.py` | `poetry run serve` |
| **REST API** | `autogpt_platform/backend/backend/rest.py` | `poetry run rest` |
| **WebSocket** | `autogpt_platform/backend/backend/ws.py` | `poetry run ws` |
| **Executor** | `autogpt_platform/backend/backend/exec.py` | `poetry run executor` |
| **Scheduler** | `autogpt_platform/backend/backend/scheduler.py` | `poetry run scheduler` |
| **Frontend Dev** | `autogpt_platform/frontend/` | `pnpm dev` |
| **CLI** | `autogpt_platform/backend/backend/cli_main.py` | `poetry run cli` |

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
| `autogpt_platform/docker-compose.yml` | Development stack (DB, Redis, RabbitMQ) |
| `autogpt_platform/backend/schema.prisma` | Database schema |
| `autogpt_platform/backend/pyproject.toml` | Backend dependencies |
| `autogpt_platform/frontend/package.json` | Frontend dependencies |
| `autogpt_platform/frontend/orval.config.ts` | API client generation |
| `.pre-commit-config.yaml` | Pre-commit hooks |
| `autogpt_platform/CLAUDE.md` | AI assistant guide |

---

## 🧪 Test Coverage

| Area | Files | Command |
|------|-------|---------|
| **Backend Unit** | 61 `*_test.py` files | `poetry run test` |
| **Block Tests** | `blocks/test/test_block.py` | `poetry run pytest backend/blocks/test/` |
| **Frontend E2E** | Playwright | `pnpm test` |
| **Storybook** | 57 `*.stories.tsx` files | `pnpm storybook` |

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

| Task | Command |
|------|---------|
| Add new block | Create in `backend/blocks/`, inherit `Block`, run tests |
| Add API endpoint | Create route in `api/features/`, add Pydantic models |
| Add frontend page | Create in `app/(platform)/`, add hooks |
| Regenerate API client | `pnpm generate:api` |
| Format code | Backend: `poetry run format` / Frontend: `pnpm format` |
| Run tests | Backend: `poetry run test` / Frontend: `pnpm test` |

---

## 📚 Documentation

| Doc | Path | Purpose |
|-----|------|---------|
| Main README | `README.md` | Project overview |
| Platform Guide | `autogpt_platform/CLAUDE.md` | Development guide |
| Frontend Contributing | `frontend/CONTRIBUTING.md` | Frontend patterns |
| Agents Guide | `AGENTS.md` | Platform contribution |
| Block SDK | `docs/content/platform/block-sdk-guide.md` | Creating blocks |

---

*Index size: ~4KB | Full codebase: ~60KB tokens | Savings: 94%*
