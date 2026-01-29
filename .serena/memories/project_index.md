# AutoGPT Project Index

## Quick Navigation

| Section | Path | Description |
|---------|------|-------------|
| [Platform Backend](#platform-backend) | `autogpt_platform/backend/` | FastAPI server, blocks, API |
| [Platform Frontend](#platform-frontend) | `autogpt_platform/frontend/` | Next.js React app |


---

## Platform Backend

### Core Entry Points
| File | Purpose |
|------|---------|
| `backend/app.py` | Main application entry |
| `backend/rest.py` | REST API server |
| `backend/ws.py` | WebSocket server |
| `backend/scheduler.py` | Task scheduler service |
| `backend/exec.py` | Workflow executor service |
| `backend/notification.py` | Notification service |
| `backend/db.py` | Database utilities |
| `backend/cli_main.py` | CLI commands |

### API Structure (`backend/api/`)
```
api/
├── features/           # Feature-specific APIs
│   ├── admin/         # Admin routes (analytics, credits, store)
│   ├── builder/       # Agent builder APIs
│   ├── chat/          # Chat/copilot APIs with tools
│   ├── executions/    # Execution management and review
│   ├── integrations/  # OAuth and integration APIs
│   ├── library/       # Agent library APIs
│   ├── otto/          # Otto AI assistant
│   ├── postmark/      # Email notifications
│   └── store/         # Marketplace/store APIs
├── external/          # External API (v1)
├── middleware/        # Security middleware
├── utils/             # CORS, auth utilities
├── rest_api.py        # Main REST API router
└── ws_api.py          # WebSocket API
```

### Blocks Registry (`backend/blocks/`)

#### AI/LLM Blocks
| Block | Description |
|-------|-------------|
| `llm.py` | Multi-provider LLM integration |
| `ai_condition.py` | AI-based conditional logic |
| `smart_decision_maker.py` | Intelligent decision making |
| `perplexity.py` | Perplexity AI search |
| `claude_code.py` | Claude Code integration |
| `codex.py` | Code generation |

#### Social Media Integrations
| Integration | Path | Capabilities |
|-------------|------|--------------|
| Twitter/X | `twitter/` | Tweets, DMs, lists, users, spaces |
| Discord | `discord/` | Bot and OAuth blocks |
| Reddit | `reddit.py` | Reddit API integration |
| Medium | `medium.py` | Article publishing |
| Ayrshare | `ayrshare/` | Multi-platform posting (Instagram, TikTok, LinkedIn, Facebook, etc.) |

#### Productivity Integrations
| Integration | Path | Capabilities |
|-------------|------|--------------|
| Google | `google/` | Sheets, Docs, Calendar, Gmail, Drive |
| Notion | `notion/` | Pages, databases, search |
| Airtable | `airtable/` | Records, bases, triggers |
| Todoist | `todoist/` | Tasks, projects, labels |
| Linear | `linear/` | Issues, projects, comments |
| HubSpot | `hubspot/` | Contacts, companies, engagements |
| WordPress | `wordpress/` | Blog posts |

#### Developer Integrations
| Integration | Path | Capabilities |
|-------------|------|--------------|
| GitHub | `github/` | Issues, PRs, CI, webhooks |
| Firecrawl | `firecrawl/` | Web scraping, crawling |
| Exa | `exa/` | Research, websets, search |

#### Media & Content
| Block | Description |
|-------|-------------|
| `ai_image_generator_block.py` | AI image generation |
| `ai_shortform_video_block.py` | Short-form video creation |
| `text_to_speech_block.py` | TTS conversion |
| `talking_head.py` | Talking head video |
| `youtube.py` | YouTube integration |
| `replicate/` | Replicate AI models |
| `fal/` | Fal AI video generation |

#### Data & Utilities
| Block | Description |
|-------|-------------|
| `basic.py` | Basic operations |
| `text.py` | Text manipulation |
| `data_manipulation.py` | Data transformations |
| `http.py` | HTTP requests |
| `iteration.py` | Loop/iteration logic |
| `branching.py` | Conditional branching |
| `persistence.py` | Data persistence |
| `time_blocks.py` | Time/date utilities |
| `spreadsheet.py` | Spreadsheet operations |

### Data Layer (`backend/data/`)
| File | Purpose |
|------|---------|
| `block.py` | Block definitions and schemas |
| `graph.py` | Agent graph/workflow models |
| `execution.py` | Execution tracking |
| `credit.py` | Credit system |
| `user.py` | User management |
| `notifications.py` | Notification models |
| `integrations.py` | Integration credentials |

### Executor (`backend/executor/`)
| File | Purpose |
|------|---------|
| `manager.py` | Execution manager |
| `scheduler.py` | Execution scheduling |
| `database.py` | Executor database ops |
| `automod/` | Auto-moderation |

### Integrations (`backend/integrations/`)
| Path | Purpose |
|------|---------|
| `oauth/` | OAuth providers (Google, GitHub, Discord, Twitter, etc.) |
| `webhooks/` | Webhook handlers (GitHub, Slant3D, Compass) |
| `credentials_store.py` | Credential management |
| `providers.py` | Provider configurations |

---

## Platform Frontend

### App Routes (`src/app/(platform)/`)
| Route | Description |
|-------|-------------|
| `/build` | Agent builder/editor |
| `/library` | Agent library |
| `/marketplace` | Agent marketplace/store |
| `/monitoring` | Execution monitoring |
| `/copilot` | AI copilot chat |
| `/profile` | User profile |
| `/admin` | Admin dashboard |
| `/auth`, `/login`, `/signup` | Authentication |

### Component Hierarchy (`src/components/`)
```
components/
├── atoms/             # Basic UI elements
├── molecules/         # Composite components
│   ├── Form/
│   ├── Dialog/
│   ├── Table/
│   ├── ErrorCard/
│   ├── Toast/
│   └── ...
├── organisms/         # Complex feature components
│   ├── PendingReviewsList/
│   ├── FloatingReviewsPanel/
│   └── ...
├── ui/                # shadcn/ui primitives
├── layout/            # Layout components
├── auth/              # Auth components
├── monitor/           # Monitoring components
├── renderers/         # Content renderers
├── tokens/            # Design tokens
└── __legacy__/        # Deprecated (do not use)
```

### Key Frontend Directories
| Path | Purpose |
|------|---------|
| `src/app/api/__generated__/` | Generated API hooks (Orval) |
| `src/lib/` | Utilities, hooks, configurations |
| `src/services/` | Business services (feature flags) |
| `tests/` | Playwright E2E tests |
| `.storybook/` | Storybook configuration |

---

## Key Configuration Files

| File | Purpose |
|------|---------|
| `autogpt_platform/docker-compose.yml` | Dev stack |
| `autogpt_platform/backend/schema.prisma` | Database schema |
| `autogpt_platform/backend/pyproject.toml` | Backend dependencies |
| `autogpt_platform/frontend/package.json` | Frontend dependencies |
| `autogpt_platform/frontend/orval.config.ts` | API generation |
| `.pre-commit-config.yaml` | Pre-commit hooks |

---

## Integration Quick Reference

### Adding a New Block
1. Create file in `backend/backend/blocks/`
2. Inherit from `Block` base class
3. Define `Input` and `Output` schemas with `BlockSchema`
4. Implement async `run` method
5. Generate UUID for block ID
6. Test: `poetry run pytest backend/blocks/test/test_block.py`

### Adding API Endpoint
1. Create/update route in `backend/api/features/`
2. Define Pydantic models
3. Add tests alongside route
4. Regenerate frontend client: `pnpm generate:api`

### Adding Frontend Page
1. Create page in `src/app/(platform)/feature-name/page.tsx`
2. Add `usePageName.ts` hook for logic
3. Create sub-components in `components/` folder
4. Use generated API hooks for data

---

## Testing Commands

```bash
# Backend
poetry run test                    # All tests
poetry run pytest path/to/test.py  # Specific test

# Frontend
pnpm test                          # Playwright E2E
pnpm test:unit                     # Vitest unit tests
pnpm storybook                     # Component development
```
