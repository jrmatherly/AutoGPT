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
class MyBlock(Block):
    id = "unique-uuid-here"
    
    class Input(BlockSchema):
        query: str = SchemaField(description="Input query")
    
    class Output(BlockSchema):
        result: str = SchemaField(description="Output result")
    
    async def run(self, input_data: Input) -> Output:
        # Implementation
        return Output(result="...")
```

### Provider Pattern
Use `ProviderBuilder` for blocks that need configuration:
```python
from backend.integrations.providers import ProviderBuilder

provider = ProviderBuilder.create_provider("my-provider")
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

### Hook Pattern
Hooks return objects with data and methods:
```typescript
export function useFeature() {
  const [data, setData] = useState<Data[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchData().then(setData);
  }, []);

  return {
    data,
    isLoading,
    refresh: () => fetchData().then(setData),
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
const { mutateAsync, isPending } = usePostV2CreateAgent({
  mutation: {
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: getAgentsQueryKey() });
    },
    onError: (error) => {
      toast({ title: "Error", description: error.message, variant: "destructive" });
    },
  },
});
```

### State Management Pattern
- **Server state**: React Query
- **Local UI state**: useState in component/hook
- **Complex flows**: Zustand store colocated with feature

### Error Handling Pattern
- Render errors: `<ErrorCard error={error} />`
- Mutation errors: Toast notifications
- Exceptions: Sentry capture

### Feature Flag Pattern
```typescript
import { Flag, useGetFlag } from "@/services/feature-flags/use-get-flag";

export function MyComponent() {
  const isEnabled = useGetFlag(Flag.MY_FEATURE);
  if (!isEnabled) return null;
  return <div>Feature content</div>;
}
```

## Anti-Patterns to Avoid

### Backend
- Synchronous I/O in async functions
- Raw SQL instead of Prisma ORM
- Skipping user ID validation in data layer
- Large monolithic functions

### Frontend
- Using `BackendAPI` or `autogpt-server-api` (deprecated)
- Using `__legacy__` components
- Using icons other than Phosphor
- Arrow functions for components
- Barrel files / index.ts re-exports
- Excessive `useCallback`/`useMemo`
- Comments unless code is very complex
- Hardcoded style values instead of design tokens

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
