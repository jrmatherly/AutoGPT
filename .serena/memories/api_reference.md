# AutoGPT Platform API Reference

## API Architecture

The platform exposes APIs through multiple servers:
- **REST API** (`rest.py`): Main HTTP endpoints
- **WebSocket API** (`ws.py`): Real-time communication
- **External API** (`api/external/`): Public API (v1)

## API Route Groups

### Authentication & Users (`api/features/`)

#### OAuth Routes (`oauth.py`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/oauth/{provider}/login` | GET | Initiate OAuth flow |
| `/oauth/{provider}/callback` | GET | OAuth callback handler |

#### Admin Routes (`admin/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/admin/analytics/*` | GET | Execution analytics |
| `/admin/store/*` | GET/POST | Store administration |
| `/admin/credits/*` | GET/POST | Credit management |

### Agent Library (`api/features/library/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /library/agents` | GET | List user's agents |
| `POST /library/agents` | POST | Create agent |
| `GET /library/agents/{id}` | GET | Get agent details |
| `PUT /library/agents/{id}` | PUT | Update agent |
| `DELETE /library/agents/{id}` | DELETE | Delete agent |
| `/library/presets/*` | * | Preset management |

### Agent Builder (`api/features/builder/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/builder/graphs` | GET/POST | Graph CRUD |
| `/builder/graphs/{id}` | GET/PUT/DELETE | Single graph ops |
| `/builder/graphs/{id}/execute` | POST | Execute graph |
| `/builder/blocks` | GET | List available blocks |

### Marketplace/Store (`api/features/store/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /store/agents` | GET | List store agents |
| `GET /store/agents/{id}` | GET | Get agent details |
| `POST /store/submissions` | POST | Submit agent |
| `GET /store/creators` | GET | List creators |
| `/store/media/*` | * | Media handling |

### Executions (`api/features/executions/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /executions` | GET | List executions |
| `GET /executions/{id}` | GET | Execution details |
| `POST /executions/{id}/stop` | POST | Stop execution |
| `/executions/review/*` | * | Human review flows |

### Integrations (`api/features/integrations/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /integrations` | GET | List user integrations |
| `POST /integrations` | POST | Add integration |
| `DELETE /integrations/{id}` | DELETE | Remove integration |
| `GET /integrations/providers` | GET | Available providers |

### Chat/Copilot (`api/features/chat/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `POST /chat/messages` | POST | Send chat message |
| `GET /chat/history` | GET | Get chat history |
| `POST /chat/sessions` | POST | Create session |

### Otto AI (`api/features/otto/`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `POST /otto/assist` | POST | Get AI assistance |

## External API (v1)

Located in `api/external/v1/`:

### Tools (`tools.py`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `POST /v1/tools/execute` | POST | Execute a tool/block |

### Integrations (`integrations.py`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /v1/integrations` | GET | List integrations |

### Main Routes (`routes.py`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /v1/graphs` | GET | List graphs |
| `POST /v1/graphs/{id}/execute` | POST | Execute graph |

## WebSocket API

### Connection
```
ws://host/ws?user_id={user_id}
```

### Events
| Event | Direction | Description |
|-------|-----------|-------------|
| `execution.started` | Server→Client | Execution began |
| `execution.progress` | Server→Client | Progress update |
| `execution.completed` | Server→Client | Execution finished |
| `execution.failed` | Server→Client | Execution error |
| `node.output` | Server→Client | Node produced output |

## Data Models

### Graph (Agent Workflow)
```python
class Graph:
    id: str
    name: str
    description: str
    nodes: List[Node]
    links: List[Link]
    version: int
    is_active: bool
    is_template: bool
```

### Node
```python
class Node:
    id: str
    block_id: str  # References Block
    input_default: Dict[str, Any]
    metadata: NodeMetadata
```

### Execution
```python
class Execution:
    id: str
    graph_id: str
    graph_version: int
    status: ExecutionStatus
    started_at: datetime
    ended_at: Optional[datetime]
    stats: ExecutionStats
```

### Block
```python
class Block:
    id: str  # UUID
    name: str
    description: str
    categories: List[BlockCategory]
    input_schema: BlockSchema
    output_schema: BlockSchema
    
    async def run(self, input_data: Input) -> Output:
        ...
```

## Authentication

### JWT Authentication
- Bearer token in `Authorization` header
- Supabase integration for user management

### API Key Authentication
- For external API access
- Header: `X-API-Key: {key}`

## Error Responses

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

### Common Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid/missing auth |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 422 | Invalid input |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

## Rate Limiting

- Default: 100 requests/minute per user
- External API: 60 requests/minute per API key
- Burst: 10 requests allowed

## OpenAPI Specification

- Production: https://backend.agpt.co/openapi.json
- Staging: https://dev-server.agpt.co/openapi.json

Generate client:
```bash
cd autogpt_platform/frontend
pnpm generate:api
```
