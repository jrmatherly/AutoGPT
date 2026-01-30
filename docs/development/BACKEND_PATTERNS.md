# Backend Design Patterns

This document covers backend development patterns for the AutoGPT Platform.

## Block Architecture

Blocks are the core building units of agent workflows. Each block:

- Inherits from `Block` base class
- Has defined input/output schemas using `BlockSchema`
- Implements an async `run` method
- Has a unique UUID identifier
- Can use providers for authentication/configuration

```python
import uuid
from backend.data.block import Block, BlockSchema, SchemaField, BlockCategory

class MyBlock(Block):
    id = str(uuid.uuid4())  # Generate unique ID once

    class Input(BlockSchema):
        query: str = SchemaField(description="Input query")
        limit: int = SchemaField(default=10, description="Max results")

    class Output(BlockSchema):
        result: str = SchemaField(description="Output result")
        error: str = SchemaField(description="Error message if failed")

    def __init__(self):
        super().__init__(
            name="My Block",
            description="Does something useful",
            categories=[BlockCategory.TEXT],
        )

    async def run(self, input_data: Input, **kwargs) -> Output:
        try:
            result = await do_something(input_data.query)
            return Output(result=result, error="")
        except Exception as e:
            return Output(result="", error=str(e))
```

## SchemaField Options

```python
SchemaField(
    description="Field description",      # Required
    default=None,                         # Default value
    placeholder="Example value",          # UI placeholder
    secret=True,                          # Hide value in UI
    advanced=True,                        # Show in advanced settings
    title="Custom Title",                 # Override field name
)
```

## Provider Pattern

Use `ProviderBuilder` for blocks that need configuration:

```python
# my_service/_config.py
from backend.integrations.providers import ProviderBuilder

MY_SERVICE = (
    ProviderBuilder("my_service")
    .api_key_credential(
        id="my_service_api_key",
        name="My Service API Key",
        description="API key for My Service",
    )
    .build()
)
```

## Credentials Pattern

**API Key Authentication:**

```python
from backend.data.model import CredentialsField, CredentialsMetaInput

class MyAPIBlock(Block):
    class Input(BlockSchema):
        credentials: CredentialsMetaInput = CredentialsField(
            provider="my_service",
            required_scopes=set(),
            description="API credentials"
        )
        query: str = SchemaField(description="Query")

    async def run(self, input_data: Input, **kwargs) -> Output:
        api_key = input_data.credentials.api_key
        # Use API key...
```

**OAuth Authentication:**

```python
class GitHubBlock(Block):
    class Input(BlockSchema):
        credentials: CredentialsMetaInput = CredentialsField(
            provider="github",
            required_scopes={"repo", "user"},
            description="GitHub OAuth credentials"
        )

    async def run(self, input_data: Input, **kwargs) -> Output:
        token = input_data.credentials.access_token
        # Use OAuth token...
```

## Webhook Block Pattern

**Basic Webhook:**

```python
from backend.data.block import Block, BlockWebhookConfig, BlockType

class MyWebhookBlock(Block):
    block_type = BlockType.WEBHOOK

    webhook_config = BlockWebhookConfig(
        provider="my_service",
        event_type="event.created",
    )
```

**Manual Webhook:**

```python
from backend.data.block import BlockManualWebhookConfig

class ManualWebhookBlock(Block):
    block_type = BlockType.WEBHOOK_MANUAL

    webhook_config = BlockManualWebhookConfig(
        setup_instructions="Configure webhook in your service settings",
        webhook_url_template="https://api.example.com/webhook/{node_id}",
    )
```

## Multiple Outputs Pattern

For blocks that produce multiple results:

```python
from typing import AsyncGenerator

class IteratorBlock(Block):
    async def run(self, input_data: Input, **kwargs) -> AsyncGenerator[Output, None]:
        for item in input_data.items:
            yield Output(item=item)
```

## Block Testing Pattern

```python
class MyBlock(Block):
    test_input = {
        "text": "Hello, World!",
        "uppercase": True
    }

    test_output = [
        ("result", "HELLO, WORLD!"),
        ("length", 13),
    ]

    # For blocks requiring credentials
    test_credentials = {
        "provider": "my_service",
        "api_key": "test_key_123"
    }
```

## API Route Pattern

Routes are in `/backend/api/features/` with colocated Pydantic models and tests.

**Structure:**
```
api/features/
├── my_feature/
│   ├── routes.py          # FastAPI router
│   ├── models.py          # Pydantic request/response models
│   └── test_routes.py     # Tests colocated with routes
```

## Database Pattern

- Prisma ORM for all database operations
- Models defined in `schema.prisma`
- Use transactions for multi-step operations
- Always verify user ID checks in data layer

**Transaction Example:**
```python
async def create_with_related(user_id: str, data: dict):
    async with prisma.tx() as tx:
        item = await tx.item.create(data={"user_id": user_id, ...})
        await tx.related.create(data={"item_id": item.id, ...})
        return item
```

## Anti-Patterns to Avoid

- ❌ Synchronous I/O in async functions
- ❌ Raw SQL instead of Prisma ORM
- ❌ Skipping user ID validation in data layer
- ❌ Large monolithic functions (prefer small, focused functions)
- ❌ Not yielding for blocks that produce multiple outputs
- ❌ Hardcoded credentials or API keys
- ❌ Missing error handling in block run methods

## Testing Patterns

### Test Structure

- Colocate tests with source (`*_test.py`)
- Use pytest fixtures for common setup
- Snapshot testing for API responses
- Mock external services

**Example:**
```python
# test_my_block.py
import pytest
from backend.blocks.my_block import MyBlock

@pytest.fixture
def block():
    return MyBlock()

async def test_my_block_success(block):
    input_data = MyBlock.Input(query="test", limit=5)
    output = await block.run(input_data)
    assert output.result == "expected"
    assert output.error == ""

async def test_my_block_error(block):
    input_data = MyBlock.Input(query="invalid")
    output = await block.run(input_data)
    assert output.error != ""
```

## Security Patterns

### Cache Control

All endpoints have caching disabled by default via middleware. Only explicitly allowed paths can be cached:

- Static assets
- Public store pages
- Health checks
- Documentation

**Middleware location:** `backend/api/middleware/cache_protection.py`

### Authentication

- JWT-based via Supabase
- Always validate `user_id` from token
- Use `get_user_id()` helper for route protection

**Example:**
```python
from backend.util.auth import get_user_id

@router.get("/protected")
async def protected_route(user_id: str = Depends(get_user_id)):
    # user_id is validated and extracted from JWT
    return {"user_id": user_id}
```

### File Uploads

- ClamAV integration for virus scanning
- File type validation (whitelist approach)
- Size limits enforced
- Scan before processing or storage

**Location:** `backend/util/file_upload.py`

### User Data Access

**CRITICAL:** Always verify user ownership in data layer operations:

```python
# data/my_model.py
async def get_user_item(item_id: str, user_id: str):
    item = await prisma.item.find_first(
        where={"id": item_id, "user_id": user_id}  # ✅ User ID check
    )
    if not item:
        raise NotFoundException("Item not found")
    return item
```
