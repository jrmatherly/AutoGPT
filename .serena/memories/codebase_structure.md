# AutoGPT Codebase Structure

## Root Directory
```
AutoGPT/
├── autogpt_platform/     # Modern platform (Polyform Shield License)
├── classic/              # Legacy components (MIT License)
├── docs/                 # Documentation
├── assets/               # Project assets
├── .github/              # GitHub workflows and templates
├── .claude/              # Claude Code configuration
├── .serena/              # Serena configuration
├── README.md             # Main project README
├── AGENTS.md             # AI agent contribution guide
├── CONTRIBUTING.md       # Contribution guidelines
└── .pre-commit-config.yaml  # Pre-commit hooks configuration
```

## AutoGPT Platform (`autogpt_platform/`)

### Backend (`backend/`)
```
backend/
├── backend/
│   ├── api/              # API features and routes
│   ├── blocks/           # Reusable workflow blocks
│   ├── cli/              # CLI tools
│   ├── data/             # Data layer and models
│   ├── executor/         # Workflow execution engine
│   ├── integrations/     # OAuth and third-party integrations
│   ├── monitoring/       # Prometheus metrics
│   ├── notifications/    # Notification system
│   ├── sdk/              # SDK utilities
│   ├── usecases/         # Business logic
│   ├── util/             # Utilities
│   ├── app.py            # Main application entry
│   ├── rest.py           # REST server entry
│   ├── ws.py             # WebSocket server entry
│   ├── scheduler.py      # Scheduler service
│   ├── exec.py           # Executor service
│   └── db.py             # Database utilities
├── test/                 # Test files
├── schema.prisma         # Prisma database schema
├── pyproject.toml        # Poetry configuration
└── .env.default          # Default environment variables
```

### Frontend (`frontend/`)
```
frontend/
├── src/
│   ├── app/
│   │   ├── (platform)/   # Protected platform routes
│   │   │   ├── library/  # Agent library
│   │   │   ├── marketplace/  # Store/marketplace
│   │   │   ├── build/    # Agent builder
│   │   │   └── ...
│   │   ├── api/          # API routes
│   │   │   └── __generated__/  # Orval-generated hooks
│   │   └── ...
│   ├── components/
│   │   ├── atoms/        # Basic UI components
│   │   ├── molecules/    # Composite components
│   │   ├── organisms/    # Complex components
│   │   └── __legacy__/   # Deprecated (do not use)
│   ├── lib/              # Utilities and configurations
│   └── services/         # Business services
├── public/               # Static assets
├── tests/                # Playwright tests
├── .storybook/           # Storybook configuration
├── package.json          # npm/pnpm configuration
├── orval.config.ts       # API generation config
├── tailwind.config.ts    # Tailwind configuration
└── CONTRIBUTING.md       # Frontend contribution guide
```

### Shared Libraries (`autogpt_libs/`)
```
autogpt_libs/
├── autogpt_libs/
│   ├── auth/             # Authentication utilities
│   ├── utils/            # Common utilities
│   └── ...
└── pyproject.toml
```

### Database (`db/`)
```
db/
└── docker/               # Docker configuration for database
```

## Classic AutoGPT (`classic/`)

### Original AutoGPT (`original_autogpt/`)
```
original_autogpt/
├── autogpt/              # Core AutoGPT agent
│   ├── agents/           # Agent implementations
│   ├── commands/         # Agent commands
│   └── ...
├── scripts/              # Utility scripts
├── tests/                # Test files
└── pyproject.toml
```

### Forge (`forge/`)
```
forge/
├── forge/
│   ├── components/       # Reusable agent components
│   ├── llm/              # LLM provider integrations
│   └── ...
├── tutorials/            # Getting started guides
└── pyproject.toml
```

### Benchmark (`benchmark/`)
```
benchmark/
├── agbenchmark/
│   ├── challenges/       # Test challenges
│   └── ...
├── frontend/             # Benchmark UI
└── pyproject.toml
```

## Key Files

| File | Purpose |
|------|---------|
| `autogpt_platform/CLAUDE.md` | AI assistant development guide |
| `autogpt_platform/docker-compose.yml` | Development stack |
| `autogpt_platform/backend/schema.prisma` | Database schema |
| `autogpt_platform/frontend/orval.config.ts` | API client generation |
| `.pre-commit-config.yaml` | Pre-commit hooks |
| `AGENTS.md` | Platform contribution guide for AI agents |

## Environment Files

- `autogpt_platform/.env.default` - Platform defaults (Supabase)
- `autogpt_platform/backend/.env.default` - Backend defaults
- `autogpt_platform/frontend/.env.default` - Frontend defaults
- `.env` files (gitignored) - User-specific overrides
