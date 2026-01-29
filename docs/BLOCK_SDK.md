# AutoGPT Block SDK Guide

> Complete guide for creating workflow blocks in the AutoGPT Platform

## Overview

Blocks are the fundamental building units of agent workflows. Each block performs a specific task and can be connected to other blocks in a visual graph editor.

## Quick Start

### 1. Create a Block File

Create a new Python file in `autogpt_platform/backend/backend/blocks/`:

```python
# my_block.py
import uuid
from backend.data.block import Block, BlockCategory, BlockSchema, SchemaField

class MyCustomBlock(Block):
    """A custom block that processes text."""

    id = str(uuid.uuid4())  # Generate unique ID once

    class Input(BlockSchema):
        text: str = SchemaField(description="Input text to process")
        uppercase: bool = SchemaField(default=False, description="Convert to uppercase")

    class Output(BlockSchema):
        result: str = SchemaField(description="Processed text")
        length: int = SchemaField(description="Length of processed text")
        error: str = SchemaField(description="Error message if failed")

    def __init__(self):
        super().__init__(
            name="My Custom Block",
            description="Processes text with optional transformations",
            categories=[BlockCategory.TEXT],
        )

    async def run(self, input_data: Input, **kwargs) -> Output:
        try:
            text = input_data.text
            if input_data.uppercase:
                text = text.upper()

            return Output(
                result=text,
                length=len(text),
                error=""
            )
        except Exception as e:
            return Output(
                result="",
                length=0,
                error=str(e)
            )
```

### 2. Test Your Block

```bash
cd autogpt_platform/backend

# Run all block tests
poetry run pytest backend/blocks/test/test_block.py -xvs

# Run test for your specific block
poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[MyCustomBlock]' -xvs
```

---

## Block Architecture

### Base Block Class

```python
class Block:
    id: str                          # Unique UUID for the block
    name: str                        # Display name
    description: str                 # Block description
    categories: list[BlockCategory]  # Block categories
    block_type: BlockType            # Block type (default: STANDARD)

    # Schemas
    input_schema: Type[BlockSchema]  # Input schema class
    output_schema: Type[BlockSchema] # Output schema class

    # Optional configurations
    test_input: dict                 # Test input data
    test_output: dict                # Expected test output
    test_credentials: dict           # Test credentials (if needed)
```

### BlockSchema

All input and output schemas must inherit from `BlockSchema`:

```python
from backend.data.block import BlockSchema, SchemaField

class Input(BlockSchema):
    # Required field
    query: str = SchemaField(description="Search query")

    # Optional field with default
    limit: int = SchemaField(default=10, description="Max results")

    # Boolean field (must have default)
    include_metadata: bool = SchemaField(default=False, description="Include metadata")

    # Complex types
    filters: dict[str, str] = SchemaField(
        default={},
        description="Filter criteria"
    )
```

### SchemaField Options

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

---

## Block Categories

```python
from backend.data.block import BlockCategory

class BlockCategory(Enum):
    AI = "AI"
    SOCIAL = "SOCIAL"
    DEVELOPER = "DEVELOPER"
    PRODUCTIVITY = "PRODUCTIVITY"
    COMMUNICATION = "COMMUNICATION"
    DATA = "DATA"
    TEXT = "TEXT"
    LOGIC = "LOGIC"
    INPUT = "INPUT"
    OUTPUT = "OUTPUT"
```

---

## Block Types

```python
from backend.data.block import BlockType

class BlockType(Enum):
    STANDARD = "standard"           # Regular block
    INPUT = "input"                 # Graph input block
    OUTPUT = "output"               # Graph output block
    WEBHOOK = "webhook"             # Webhook trigger
    WEBHOOK_MANUAL = "webhook_manual"  # Manual webhook
    HUMAN_IN_THE_LOOP = "hitl"      # Human review required
```

---

## Adding Credentials

### API Key Authentication

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
        # Access credentials
        api_key = input_data.credentials.api_key

        # Use the API key
        response = await self.call_api(api_key, input_data.query)
        return Output(result=response)
```

### OAuth Authentication

```python
from backend.data.model import CredentialsField, CredentialsMetaInput

class GitHubBlock(Block):
    class Input(BlockSchema):
        credentials: CredentialsMetaInput = CredentialsField(
            provider="github",
            required_scopes={"repo", "user"},
            description="GitHub OAuth credentials"
        )
        repo: str = SchemaField(description="Repository name")

    async def run(self, input_data: Input, **kwargs) -> Output:
        # Access OAuth token
        token = input_data.credentials.access_token

        # Use the token
        response = await self.github_api(token, input_data.repo)
        return Output(result=response)
```

### Provider Configuration

Create `_config.py` for provider settings:

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

---

## Webhook Blocks

### Basic Webhook

```python
from backend.data.block import Block, BlockWebhookConfig

class MyWebhookBlock(Block):
    block_type = BlockType.WEBHOOK

    webhook_config = BlockWebhookConfig(
        provider="my_service",
        event_type="event.created",
    )

    class Input(BlockSchema):
        credentials: CredentialsMetaInput = CredentialsField(...)

    class Output(BlockSchema):
        event_data: dict = SchemaField(description="Webhook event data")

    async def run(self, input_data: Input, **kwargs) -> Output:
        # input_data contains the webhook payload
        return Output(event_data=input_data.payload)
```

### Manual Webhook

```python
from backend.data.block import Block, BlockManualWebhookConfig

class ManualWebhookBlock(Block):
    block_type = BlockType.WEBHOOK_MANUAL

    webhook_config = BlockManualWebhookConfig(
        setup_instructions="Configure webhook in your service settings",
        webhook_url_template="https://api.example.com/webhook/{node_id}",
    )
```

---

## Advanced Patterns

### Multiple Outputs

```python
class MultiOutputBlock(Block):
    class Output(BlockSchema):
        success_result: str = SchemaField(description="Success output")
        error_result: str = SchemaField(description="Error output")
        error: str = SchemaField(description="Error message")

    async def run(self, input_data: Input, **kwargs) -> Output:
        try:
            result = await self.process(input_data)
            return Output(
                success_result=result,
                error_result="",
                error=""
            )
        except Exception as e:
            return Output(
                success_result="",
                error_result=str(e),
                error=str(e)
            )
```

### Yielding Multiple Results

For blocks that produce multiple outputs (e.g., iteration):

```python
from typing import AsyncGenerator

class IteratorBlock(Block):
    async def run(self, input_data: Input, **kwargs) -> AsyncGenerator[Output, None]:
        for item in input_data.items:
            yield Output(item=item, index=i)
```

### Human-in-the-Loop

```python
class ReviewBlock(Block):
    block_type = BlockType.HUMAN_IN_THE_LOOP

    class Input(BlockSchema):
        content: str = SchemaField(description="Content to review")
        review_prompt: str = SchemaField(
            default="Please review this content",
            description="Instructions for reviewer"
        )

    class Output(BlockSchema):
        approved: bool = SchemaField(description="Whether content was approved")
        feedback: str = SchemaField(description="Reviewer feedback")
```

---

## Testing Blocks

### Test Input/Output

Define test cases in your block:

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
```

### Test Credentials

For blocks requiring credentials:

```python
class MyAPIBlock(Block):
    test_credentials = {
        "provider": "my_service",
        "api_key": "test_key_123"
    }

    test_input = {
        "credentials": {},  # Will be filled with test_credentials
        "query": "test query"
    }
```

### Running Tests

```bash
# Test all blocks
poetry run pytest backend/blocks/test/test_block.py -xvs

# Test specific block
poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[MyBlock]' -xvs

# Test block validation only (no execution)
poetry run pytest 'backend/blocks/test/test_block.py::test_block_validation[MyBlock]' -xvs
```

---

## Block Organization

### File Structure

For simple blocks:
```
blocks/
└── my_block.py
```

For complex integrations:
```
blocks/
└── my_service/
    ├── __init__.py        # Exports all blocks
    ├── _config.py         # Provider configuration
    ├── _api.py            # API client
    ├── _auth.py           # Authentication helpers
    ├── read.py            # Read operations
    ├── write.py           # Write operations
    └── _test.py           # Integration tests
```

### Naming Conventions

- Block class: `PascalCaseBlock` (must end with "Block")
- File name: `snake_case.py`
- Block ID: Use `uuid.uuid4()` once, then hardcode

---

## Best Practices

### 1. Always Handle Errors

```python
async def run(self, input_data: Input, **kwargs) -> Output:
    try:
        result = await self.do_work(input_data)
        return Output(result=result, error="")
    except SpecificException as e:
        return Output(result="", error=f"Specific error: {e}")
    except Exception as e:
        return Output(result="", error=f"Unexpected error: {e}")
```

### 2. Validate Inputs

```python
async def run(self, input_data: Input, **kwargs) -> Output:
    if not input_data.url.startswith("https://"):
        return Output(error="URL must use HTTPS")

    # Continue with processing...
```

### 3. Use Async I/O

```python
import aiohttp

async def run(self, input_data: Input, **kwargs) -> Output:
    async with aiohttp.ClientSession() as session:
        async with session.get(input_data.url) as response:
            data = await response.json()
    return Output(data=data, error="")
```

### 4. Add Meaningful Descriptions

```python
class SearchBlock(Block):
    """Search for documents in a knowledge base.

    This block queries a vector database and returns the most
    relevant documents based on semantic similarity.
    """

    class Input(BlockSchema):
        query: str = SchemaField(
            description="Natural language search query",
            placeholder="What is the capital of France?"
        )
        top_k: int = SchemaField(
            default=5,
            description="Number of results to return (1-100)",
        )
```

### 5. Consider Graph Connectivity

When designing block interfaces, consider how they connect:

```python
# Good: Outputs match common input patterns
class APIBlock(Block):
    class Output(BlockSchema):
        data: dict = SchemaField(description="API response data")
        status_code: int = SchemaField(description="HTTP status code")
        error: str = SchemaField(description="Error message")

# This output can connect to blocks expecting:
# - dict input (for data processing)
# - int input (for status checking)
# - str input (for error handling)
```

---

## Common Patterns

### HTTP Request Block

```python
import aiohttp

class HTTPRequestBlock(Block):
    class Input(BlockSchema):
        url: str = SchemaField(description="Request URL")
        method: str = SchemaField(default="GET", description="HTTP method")
        headers: dict = SchemaField(default={}, description="Request headers")
        body: str = SchemaField(default="", description="Request body")

    class Output(BlockSchema):
        response: str = SchemaField(description="Response body")
        status_code: int = SchemaField(description="HTTP status code")
        headers: dict = SchemaField(description="Response headers")
        error: str = SchemaField(description="Error message")

    async def run(self, input_data: Input, **kwargs) -> Output:
        try:
            async with aiohttp.ClientSession() as session:
                async with session.request(
                    method=input_data.method,
                    url=input_data.url,
                    headers=input_data.headers,
                    data=input_data.body or None
                ) as response:
                    return Output(
                        response=await response.text(),
                        status_code=response.status,
                        headers=dict(response.headers),
                        error=""
                    )
        except Exception as e:
            return Output(
                response="",
                status_code=0,
                headers={},
                error=str(e)
            )
```

### LLM Integration Block

```python
from openai import AsyncOpenAI

class LLMBlock(Block):
    class Input(BlockSchema):
        credentials: CredentialsMetaInput = CredentialsField(
            provider="openai",
            description="OpenAI API credentials"
        )
        prompt: str = SchemaField(description="Prompt for the LLM")
        model: str = SchemaField(default="gpt-4", description="Model to use")
        temperature: float = SchemaField(default=0.7, description="Sampling temperature")

    class Output(BlockSchema):
        response: str = SchemaField(description="LLM response")
        usage: dict = SchemaField(description="Token usage stats")
        error: str = SchemaField(description="Error message")

    async def run(self, input_data: Input, **kwargs) -> Output:
        try:
            client = AsyncOpenAI(api_key=input_data.credentials.api_key)

            response = await client.chat.completions.create(
                model=input_data.model,
                messages=[{"role": "user", "content": input_data.prompt}],
                temperature=input_data.temperature
            )

            return Output(
                response=response.choices[0].message.content,
                usage=response.usage.model_dump(),
                error=""
            )
        except Exception as e:
            return Output(response="", usage={}, error=str(e))
```

---

## Resources

- [Block SDK Guide](BLOCK_SDK.md) - This guide
- [Existing Blocks](../autogpt_platform/backend/backend/blocks/) - Reference implementations
- [Provider Configurations](../autogpt_platform/backend/backend/integrations/providers.py) - Available providers