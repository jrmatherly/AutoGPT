# Design Patterns and Guidelines

## Backend Patterns

### Block Architecture

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

### Provider Pattern

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

### Credentials Pattern

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

### Webhook Block Pattern

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

### Multiple Outputs Pattern

For blocks that produce multiple results:

```python
from typing import AsyncGenerator

class IteratorBlock(Block):
    async def run(self, input_data: Input, **kwargs) -> AsyncGenerator[Output, None]:
        for item in input_data.items:
            yield Output(item=item)
```

### Block Testing Pattern

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

### API Route Pattern

Routes are in `/backend/server/routers/` with colocated Pydantic models and tests.

### Database Pattern

- Prisma ORM for all database operations
- Models defined in `schema.prisma`
- Use transactions for multi-step operations
- Always verify user ID checks in data layer

## Frontend Patterns

### Component Pattern

Separate concerns into distinct files:

```
ComponentName/
  ComponentName.tsx      # Pure render logic
  useComponentName.ts    # All hooks, state, effects
  helpers.ts             # Pure functions
  components/            # Sub-components
```

**Example:**

```tsx
// StatsPanel.tsx (render only)
interface Props {
  data: Stats[];
  isLoading: boolean;
  onRefresh: () => void;
}

export function StatsPanel({ data, isLoading, onRefresh }: Props) {
  if (isLoading) return <Skeleton />;
  return (
    <div>
      {data.map((stat) => (
        <StatCard key={stat.id} stat={stat} />
      ))}
      <button onClick={onRefresh}>Refresh</button>
    </div>
  );
}
```

### Hook Pattern

Hooks return objects with data and methods:

```typescript
// useStatsPanel.ts
export function useStatsPanel() {
  const { data, isLoading, refetch } = useGetV2Stats();

  return {
    data: data?.data || [],
    isLoading,
    refresh: refetch,
  };
}
```

### Data Fetching Pattern

Always use generated React Query hooks:

```typescript
import { useGetV2ListLibraryAgents } from "@/app/api/__generated__/endpoints/library/library";

export function useAgentList() {
  const { data, isLoading, isError } = useGetV2ListLibraryAgents();
  return { agents: data?.data || [], isLoading, isError };
}
```

### Mutation Pattern

```typescript
import { useQueryClient } from "@tanstack/react-query";
import {
  usePostV2CreateAgent,
  getGetV2ListAgentsQueryKey,
} from "@/app/api/__generated__/endpoints/agents/agents";

export function useCreateAgent() {
  const queryClient = useQueryClient();

  const { mutateAsync, isPending } = usePostV2CreateAgent({
    mutation: {
      onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: getGetV2ListAgentsQueryKey() });
      },
      onError: (error) => {
        toast({ title: "Error", description: error.message, variant: "destructive" });
      },
    },
  });

  return { createAgent: mutateAsync, isCreating: isPending };
}
```

### Server-Side Prefetch Pattern

For improved TTFB with client hydration:

```tsx
// Server component
import { getQueryClient } from "@/lib/tanstack-query/getQueryClient";
import { HydrationBoundary, dehydrate } from "@tanstack/react-query";
import { prefetchGetV2ListStoreAgentsQuery } from "@/app/api/__generated__/endpoints/store/store";

export default async function MarketplacePage() {
  const queryClient = getQueryClient();

  await Promise.all([
    prefetchGetV2ListStoreAgentsQuery(queryClient, { featured: true }),
    prefetchGetV2ListStoreAgentsQuery(queryClient, { sorted_by: "runs" }),
  ]);

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      {/* Client component tree */}
    </HydrationBoundary>
  );
}
```

### State Management Pattern

| State Type | Solution |
|------------|----------|
| Server state | React Query |
| Local UI state | `useState` in component/hook |
| Complex flows | Zustand store colocated with feature |

**Zustand Example:**

```typescript
// FeatureX/store.ts
import { create } from "zustand";

interface WizardState {
  step: number;
  data: Record<string, unknown>;
  next(): void;
  back(): void;
  setField(args: { key: string; value: unknown }): void;
}

export const useWizardStore = create<WizardState>((set) => ({
  step: 0,
  data: {},
  next() { set((state) => ({ step: state.step + 1 })); },
  back() { set((state) => ({ step: Math.max(0, state.step - 1) })); },
  setField({ key, value }) {
    set((state) => ({ data: { ...state.data, [key]: value } }));
  },
}));
```

### Error Handling Pattern

| Error Type | Solution |
|------------|----------|
| Render errors | `<ErrorCard error={error} />` |
| Mutation errors | Toast notifications |
| Exceptions | Sentry capture |

### Feature Flag Pattern

```typescript
import { Flag, useGetFlag } from "@/services/feature-flags/use-get-flag";
import { withFeatureFlag } from "@/services/feature-flags/with-feature-flag";

// Hook usage
export function MyComponent() {
  const isEnabled = useGetFlag(Flag.MY_FEATURE);
  if (!isEnabled) return null;
  return <div>Feature content</div>;
}

// HOC usage for pages
export const MyFeaturePage = withFeatureFlag(function Page() {
  return <div>My feature page</div>;
}, "my-feature-flag");
```

## Anti-Patterns to Avoid

### Backend

- Synchronous I/O in async functions
- Raw SQL instead of Prisma ORM
- Skipping user ID validation in data layer
- Large monolithic functions
- Not yielding for blocks that produce multiple outputs

### Frontend

- Using `BackendAPI` or `autogpt-server-api` (deprecated)
- Using `__legacy__` components
- Using icons other than Phosphor
- Arrow functions for components
- Barrel files / index.ts re-exports
- Excessive `useCallback`/`useMemo`
- Comments unless code is very complex
- Hardcoded style values instead of design tokens
- Server actions (prefer API routes)

## Testing Patterns

### Backend Tests

- Colocate tests with source (`*_test.py`)
- Use pytest fixtures
- Snapshot testing for API responses
- Mock external services

### Frontend Tests

- Playwright for E2E flows
- Storybook for component isolation
- Vitest for unit tests
- MSW for API mocking in Storybook

## Security Patterns

### Cache Control

All endpoints have caching disabled by default via middleware. Only explicitly allowed paths can be cached:

- Static assets
- Public store pages
- Health checks
- Documentation

### Authentication

- JWT-based via Supabase
- Protected routes in `(platform)` route group
- Middleware at `frontend/lib/supabase/middleware.ts`

### File Uploads

- ClamAV integration for virus scanning
- File type validation
- Size limits enforced
