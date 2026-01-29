# AutoGPT Platform API Reference

> Complete API documentation for the AutoGPT Platform

## Overview

The AutoGPT Platform provides REST and WebSocket APIs for building, deploying, and managing AI agents.

**Base URLs:**
- Production: `https://api.example.com`
- Staging: `https://api-staging.example.com`
- Local: `http://localhost:8006`

**OpenAPI Specification:**
- Production: `https://api.example.com/openapi.json`
- Staging: `https://api-staging.example.com/openapi.json`

## Authentication

All API endpoints require authentication via JWT bearer tokens obtained through Supabase.

```http
Authorization: Bearer <jwt_token>
```

### API Key Authentication (External API)

For external API access, use API keys:

```http
X-API-Key: <your_api_key>
```

---

## Library API

Manage agents in your personal library.

### List Library Agents

```http
GET /api/v2/library/agents
```

**Query Parameters:**

| Parameter | Type | Default | Description |

|-----------|------|---------|-------------|
| `search_term` | string | - | Filter agents by name/description |
| `sort_by` | enum | `updated_at` | Sort by: `created_at`, `updated_at`, `name` |
| `page` | integer | 1 | Page number (≥1) |
| `page_size` | integer | 15 | Items per page (≥1) |

**Response:**

```json
{
  "agents": [
    {
      "id": "uuid",
      "name": "My Agent",
      "description": "Agent description",
      "is_favorite": false,
      "is_created_by_user": true,
      "is_latest_version": true,
      "agent_id": "graph-uuid",
      "agent_version": 1,
      "preset_id": null,
      "updated_at": "2024-01-15T10:30:00Z",
      "created_at": "2024-01-10T08:00:00Z"
    }
  ],
  "pagination": {
    "total": 42,
    "page": 1,
    "page_size": 15,
    "total_pages": 3
  }
}
```

### Get Library Agent

```http
GET /api/v2/library/agents/{library_agent_id}
```

### Get Agent by Graph ID

```http
GET /api/v2/library/agents/by-graph/{graph_id}
```

**Query Parameters:**

| Parameter | Type | Description |

|-----------|------|-------------|
| `version` | integer | Specific version (optional) |

### Add Agent to Library

```http
POST /api/v2/library/agents
```

**Request Body:**

```json
{
  "agent_id": "graph-uuid",
  "agent_version": 1
}
```

### Update Library Agent

```http
PUT /api/v2/library/agents/{library_agent_id}
```

**Request Body:**

```json
{
  "is_favorite": true,
  "is_archived": false
}
```

### Delete from Library

```http
DELETE /api/v2/library/agents/{library_agent_id}
```

---

## Builder API

Create and manage agent graphs.

### List Graphs

```http
GET /api/v2/builder/graphs
```

**Response:**

```json
{
  "graphs": [
    {
      "id": "uuid",
      "version": 1,
      "name": "My Workflow",
      "description": "Workflow description",
      "is_active": true,
      "created_at": "2024-01-10T08:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 10,
    "page": 1,
    "page_size": 20,
    "total_pages": 1
  }
}
```

### Get Graph

```http
GET /api/v2/builder/graphs/{graph_id}
```

**Query Parameters:**

| Parameter | Type | Description |

|-----------|------|-------------|
| `version` | integer | Specific version (optional, defaults to latest) |

**Response:**

```json
{
  "id": "uuid",
  "version": 1,
  "name": "My Workflow",
  "description": "Workflow description",
  "is_active": true,
  "nodes": [
    {
      "id": "node-uuid",
      "block_id": "block-uuid",
      "input_default": {
        "prompt": "Hello, world!"
      },
      "metadata": {
        "position": { "x": 100, "y": 200 }
      }
    }
  ],
  "links": [
    {
      "id": "link-uuid",
      "source_id": "node-1",
      "sink_id": "node-2",
      "source_name": "output",
      "sink_name": "input"
    }
  ],
  "input_schema": {
    "type": "object",
    "properties": {
      "user_input": { "type": "string" }
    }
  },
  "output_schema": {
    "type": "object",
    "properties": {
      "result": { "type": "string" }
    }
  }
}
```

### Create Graph

```http
POST /api/v2/builder/graphs
```

**Request Body:**

```json
{
  "name": "New Workflow",
  "description": "Workflow description",
  "nodes": [],
  "links": []
}
```

### Update Graph

```http
PUT /api/v2/builder/graphs/{graph_id}
```

Creates a new version of the graph.

**Request Body:**

```json
{
  "name": "Updated Workflow",
  "description": "Updated description",
  "nodes": [...],
  "links": [...]
}
```

### Delete Graph

```http
DELETE /api/v2/builder/graphs/{graph_id}
```

### Execute Graph

```http
POST /api/v2/builder/graphs/{graph_id}/execute
```

**Request Body:**

```json
{
  "input_data": {
    "user_input": "Hello!"
  },
  "version": 1
}
```

**Response:**

```json
{
  "execution_id": "exec-uuid"
}
```

### List Available Blocks

```http
GET /api/v2/builder/blocks
```

**Response:**

```json
{
  "blocks": [
    {
      "id": "block-uuid",
      "name": "LLM Call",
      "description": "Make a call to an LLM provider",
      "categories": ["AI", "LLM"],
      "input_schema": {...},
      "output_schema": {...}
    }
  ]
}
```

---

## Executions API

Monitor and manage workflow executions.

### List Executions

```http
GET /api/v2/executions
```

**Query Parameters:**

| Parameter | Type | Description |

|-----------|------|-------------|
| `graph_id` | string | Filter by graph ID |
| `status` | enum | Filter by status: `QUEUED`, `RUNNING`, `COMPLETED`, `FAILED`, `TERMINATED` |
| `page` | integer | Page number |
| `page_size` | integer | Items per page |

**Response:**

```json
{
  "executions": [
    {
      "id": "exec-uuid",
      "graph_id": "graph-uuid",
      "graph_version": 1,
      "status": "COMPLETED",
      "started_at": "2024-01-15T10:30:00Z",
      "ended_at": "2024-01-15T10:30:45Z",
      "stats": {
        "total_nodes": 5,
        "completed_nodes": 5,
        "failed_nodes": 0,
        "total_run_time": 45.2
      }
    }
  ],
  "pagination": {...}
}
```

### Get Execution Details

```http
GET /api/v2/executions/{execution_id}
```

**Response:**

```json
{
  "id": "exec-uuid",
  "graph_id": "graph-uuid",
  "graph_version": 1,
  "status": "COMPLETED",
  "started_at": "2024-01-15T10:30:00Z",
  "ended_at": "2024-01-15T10:30:45Z",
  "node_executions": [
    {
      "node_id": "node-uuid",
      "status": "COMPLETED",
      "input_data": {...},
      "output_data": {...},
      "started_at": "...",
      "ended_at": "..."
    }
  ]
}
```

### Stop Execution

```http
POST /api/v2/executions/{execution_id}/stop
```

---

## Store API

Browse and publish agents in the marketplace.

### List Store Agents

```http
GET /api/v2/store/agents
```

**Query Parameters:**

| Parameter | Type | Description |

|-----------|------|-------------|
| `search` | string | Search term |
| `category` | string | Filter by category |
| `featured` | boolean | Featured agents only |
| `sorted_by` | enum | Sort by: `runs`, `rating`, `newest` |
| `page` | integer | Page number |
| `page_size` | integer | Items per page |

### Get Store Agent

```http
GET /api/v2/store/agents/{agent_id}
```

### Submit Agent to Store

```http
POST /api/v2/store/submissions
```

**Request Body:**

```json
{
  "graph_id": "graph-uuid",
  "graph_version": 1,
  "name": "My Agent",
  "description": "Agent description",
  "categories": ["Productivity"],
  "image_urls": ["https://..."]
}
```

### List Creators

```http
GET /api/v2/store/creators
```

---

## Integrations API

Manage OAuth connections and API credentials.

### List Integrations

```http
GET /api/v2/integrations
```

**Response:**

```json
{
  "integrations": [
    {
      "id": "int-uuid",
      "provider": "github",
      "scopes": ["repo", "user"],
      "created_at": "2024-01-10T08:00:00Z"
    }
  ]
}
```

### Get Available Providers

```http
GET /api/v2/integrations/providers
```

**Response:**

```json
{
  "providers": [
    {
      "name": "github",
      "display_name": "GitHub",
      "oauth_url": "/api/v2/integrations/oauth/github/authorize"
    },
    {
      "name": "google",
      "display_name": "Google",
      "oauth_url": "/api/v2/integrations/oauth/google/authorize"
    }
  ]
}
```

### OAuth Authorization

```http
GET /api/v2/integrations/oauth/{provider}/authorize
```

Redirects to the OAuth provider's authorization page.

### OAuth Callback

```http
GET /api/v2/integrations/oauth/{provider}/callback
```

Handles the OAuth callback and stores credentials.

### Delete Integration

```http
DELETE /api/v2/integrations/{integration_id}
```

---

## WebSocket API

Real-time updates for execution monitoring.

### Connection

```
ws://localhost:8001/ws?user_id={user_id}
```

### Subscribe to Execution

```json
{
  "type": "subscribe",
  "execution_id": "exec-uuid"
}
```

### Unsubscribe from Execution

```json
{
  "type": "unsubscribe",
  "execution_id": "exec-uuid"
}
```

### Server Events

**Execution Started:**
```json
{
  "type": "execution.started",
  "execution_id": "exec-uuid",
  "graph_id": "graph-uuid",
  "started_at": "2024-01-15T10:30:00Z"
}
```

**Node Progress:**
```json
{
  "type": "node.output",
  "execution_id": "exec-uuid",
  "node_id": "node-uuid",
  "output_name": "result",
  "output_data": {...}
}
```

**Execution Completed:**
```json
{
  "type": "execution.completed",
  "execution_id": "exec-uuid",
  "status": "COMPLETED",
  "ended_at": "2024-01-15T10:30:45Z"
}
```

**Execution Failed:**
```json
{
  "type": "execution.failed",
  "execution_id": "exec-uuid",
  "error": {
    "message": "Error message",
    "node_id": "node-uuid"
  }
}
```

---

## Error Responses

All errors follow a consistent format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### Error Codes

| Code | HTTP Status | Description |

|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Missing or invalid authentication |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 422 | Invalid request data |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

---

## Rate Limits

| Endpoint | Limit |

|----------|-------|
| General API | 100 requests/minute |
| Execution | 20 executions/minute |
| External API | 60 requests/minute |

Rate limit headers are included in responses:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705320000
```

---

## Code Examples

### Python

```python
import requests

API_URL = "http://localhost:8006"
TOKEN = "your_jwt_token"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

# List library agents
response = requests.get(
    f"{API_URL}/api/v2/library/agents",
    headers=headers
)
agents = response.json()

# Execute a graph
response = requests.post(
    f"{API_URL}/api/v2/builder/graphs/{graph_id}/execute",
    headers=headers,
    json={"input_data": {"prompt": "Hello!"}}
)
execution = response.json()
```

### JavaScript/TypeScript

```typescript
const API_URL = "http://localhost:8006";
const token = "your_jwt_token";

// List library agents
const response = await fetch(`${API_URL}/api/v2/library/agents`, {
  headers: {
    Authorization: `Bearer ${token}`,
  },
});
const agents = await response.json();

// Execute a graph
const execResponse = await fetch(
  `${API_URL}/api/v2/builder/graphs/${graphId}/execute`,
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ input_data: { prompt: "Hello!" } }),
  }
);
const execution = await execResponse.json();
```

### cURL

```bash
# List library agents
curl -X GET "http://localhost:8006/api/v2/library/agents" \
  -H "Authorization: Bearer $TOKEN"

# Execute a graph
curl -X POST "http://localhost:8006/api/v2/builder/graphs/$GRAPH_ID/execute" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"input_data": {"prompt": "Hello!"}}'
```

---

## Changelog

### v2 (Current)

- Pagination standardized across all list endpoints
- New library agent management endpoints
- Enhanced execution monitoring
- WebSocket API for real-time updates

### v1 (Deprecated)

- Legacy endpoints still available at `/api/v1/*`
- Will be removed in future release