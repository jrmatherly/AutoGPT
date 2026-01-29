# API Reference Quick Guide

## Documentation Location

**Complete API documentation:** [docs/API_REFERENCE.md](../../docs/API_REFERENCE.md)

## API Structure

The platform exposes APIs through:
- **REST API** (`backend/rest.py`) - Main HTTP endpoints at `/api/v2/`
- **WebSocket API** (`backend/ws.py`) - Real-time updates at `/ws`
- **External API** (`backend/api/external/v1/`) - Public API v1

## Key Route Groups

| Group | Path | Purpose |
|-------|------|---------|
| Library | `/api/v2/library/*` | User's agent CRUD |
| Builder | `/api/v2/builder/*` | Graph building & execution |
| Store | `/api/v2/store/*` | Marketplace agents |
| Executions | `/api/v2/executions/*` | Execution management |
| Integrations | `/api/v2/integrations/*` | OAuth & credentials |
| Admin | `/api/v2/admin/*` | Analytics & administration |

## Authentication

- **JWT**: Bearer token in `Authorization` header (Supabase)
- **API Key**: `X-API-Key` header for external API

## OpenAPI Spec

```bash
# Local development
http://localhost:8006/openapi.json

# Generate TypeScript client
cd autogpt_platform/frontend && pnpm generate:api
```

## Quick Examples

**Frontend (Generated Hooks):**
```typescript
import { useGetV2ListLibraryAgents } from "@/app/api/__generated__/endpoints/library/library";

const { data, isLoading } = useGetV2ListLibraryAgents();
```

**Python:**
```python
import requests

headers = {"Authorization": f"Bearer {token}"}
response = requests.get("http://localhost:8000/api/v2/library/agents", headers=headers)
```

**Full details:** See [docs/API_REFERENCE.md](../../docs/API_REFERENCE.md) for complete endpoint listings, request/response schemas, error codes, and examples.
