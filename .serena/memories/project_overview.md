# AutoGPT Project Overview

## Purpose

AutoGPT is a powerful platform for building, deploying, and managing continuous AI agents that automate complex workflows. It enables users to create custom AI-powered automation through a visual graph-based editor.

**For detailed project structure:** See [PROJECT_INDEX.md](../../PROJECT_INDEX.md) or [PROJECT_INDEX.json](../../PROJECT_INDEX.json)

---

## Key Concepts

### 1. Agent Graphs
Workflow definitions stored as JSON and executed by the backend. A graph contains:
- **Nodes**: Individual blocks that perform specific tasks
- **Links**: Connections between blocks that define data flow
- **Execution**: Asynchronous processing via the execution engine

### 2. Blocks
Reusable components that perform specific tasks (224+ available). Each block:
- Has defined input/output schemas
- Implements async execution logic
- Can integrate with external services via OAuth or API keys
- Located in `/backend/blocks/`

**Categories:** AI/LLM, Social Media, Productivity, Developer Tools, Data Flow, I/O, Storage, AI Services

### 3. Integrations
OAuth and API connections stored per user for third-party services:
- Google (Sheets, Docs, Calendar, Gmail)
- GitHub (Issues, PRs, CI/CD)
- Twitter/X (Tweets, DMs, Lists)
- Discord, Reddit, Notion, Airtable, Linear, HubSpot
- 32+ service integrations

### 4. Store/Marketplace
Platform for sharing and discovering agent templates:
- Public agent library
- Creator profiles
- Agent submissions and reviews
- Featured agents and categories

### 5. Execution Engine
Separate executor service that processes agent workflows asynchronously:
- Task queue via RabbitMQ
- Real-time updates via WebSocket
- Execution history and logs
- Human-in-the-loop support for approvals

---

## Architecture Highlights

### Services

| Service | File | Purpose |
|---------|------|---------|
| **REST API** | `backend/rest.py` | Main HTTP endpoints |
| **WebSocket** | `backend/ws.py` | Real-time execution updates |
| **Executor** | `backend/exec.py` | Workflow execution engine |
| **Scheduler** | `backend/scheduler.py` | Scheduled task execution |
| **Notification** | `backend/notification.py` | User notifications |

### Security

**Cache Protection**
- All endpoints have caching disabled by default via middleware
- Only explicitly allowed paths can be cached (static assets, public pages, health checks)
- Prevents sensitive data leakage through caching

**Authentication**
- JWT-based authentication via Supabase
- User ID validation in all data layer operations
- Protected routes in frontend `(platform)` route group

**File Uploads**
- ClamAV integration for virus scanning
- File type validation (whitelist approach)
- Size limits enforced

### Monitoring

- **Sentry**: Error tracking and exception monitoring
- **Prometheus**: Metrics collection and monitoring
- **Structured Logging**: JSON logs for observability
- **Health Checks**: Service health endpoints

---

## Technology Stack

**Backend:** Python 3.13.1, FastAPI, Prisma (PostgreSQL + pgvector), RabbitMQ, Redis  
**Frontend:** Node 22.22.0, Next.js 15, React, Tailwind CSS, shadcn/ui  
**Infrastructure:** Docker Compose, Supabase Auth, ClamAV  
**Development:** Mise (tool management), Poetry (Python), pnpm (Node)

**For detailed tech stack:** See [PROJECT_INDEX.md](../../PROJECT_INDEX.md)

---

## Development Quick Start

**For comprehensive development guide:** See [suggested_commands](suggested_commands.md)

```bash
# First time setup
cd autogpt_platform
mise trust && mise run setup

# Daily development
mise run docker:up      # Start infrastructure
mise run backend        # Terminal 1
mise run frontend       # Terminal 2
```

---

## Contributing

**For detailed guidelines:** See [task_completion_checklist](task_completion_checklist.md)

- Create PRs against `dev` branch
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `ci`, `docs`, `dx`
- Scopes: `platform`, `frontend`, `backend`, `blocks`, `infra`

**License:** Polyform Shield License (commercial restrictions apply)
