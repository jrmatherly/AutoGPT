# Code Style and Conventions

## General Principles

- Avoid over-engineering; keep solutions simple and focused
- Prefer editing existing files over creating new ones
- Avoid comments unless code is very complex
- Use early returns to reduce nesting
- Don't add features, refactor code, or make "improvements" beyond what was asked

## Python (Backend)

### Style & Tooling

| Tool | Purpose |
|------|---------|
| **Black + isort** | Formatting (`poetry run format`) |
| **Ruff** | Linting (`poetry run lint`) |
| **Pyright** | Type checking |
| **Python** | 3.10+ |

### Conventions

- Use type hints throughout
- Async/await for all I/O operations
- Pydantic models for data validation
- Prisma ORM for database operations
- Test files colocated with source (`*_test.py`)

### Import Order

```python
# Standard library
import os
from typing import Optional

# Third-party
from fastapi import APIRouter
from pydantic import BaseModel

# Local
from backend.data import models
```

## TypeScript/React (Frontend)

### Style & Tooling

| Tool | Purpose |
|------|---------|
| **Prettier** | Formatting (`pnpm format`) |
| **ESLint** | Linting (`pnpm lint`) |
| **TypeScript** | Strict mode type checking (`pnpm types`) |
| **Node** | 22.x |

### Component Structure

**Standard pattern for components with logic:**

```
ComponentName/
  ComponentName.tsx      # Render logic ONLY
  useComponentName.ts    # Hook: data fetching, behavior, state
  helpers.ts             # Pure helper functions
  components/            # Local sub-components
```

**Exceptions:**
- Small hook logic (3-4 lines): Keep inline with render function
- Render-only components: Direct file without folder needed

### Page Structure

```
app/(platform)/feature-name/
  page.tsx               # Page component
  useFeaturePage.ts      # Page hook for logic
  components/            # Page sub-components
    StatsPanel/
      StatsPanel.tsx
      useStatsPanel.ts
```

### Naming Conventions

| Type | Convention |
|------|------------|
| Component files | `PascalCase.tsx` |
| Hook files | `useCamelCase.ts` |
| Other files | `kebab-case.ts` |
| Props interface | `interface Props { ... }` (not exported unless needed externally) |

### Code Conventions

**DO:**
- Use function declarations for components and handlers
- Separate render logic from business logic
- Colocate state when possible
- Use precise types; avoid `any` and unsafe casts
- Use early returns to reduce nesting
- Keep component files focused and readable

**DON'T:**
- Use arrow functions for components (only for small inline callbacks)
- Create barrel files or `index.ts` re-exports
- Use `useCallback`/`useMemo` unless strictly needed
- Add comments unless code is very complex
- Export `Props` interface unless needed externally
- Create separate `types.ts` files for single components

### Data Fetching

**Always use generated React Query hooks:**

```typescript
import { useGetV2ListLibraryAgents } from "@/app/api/__generated__/endpoints/library/library";

export function useAgentList() {
  const { data, isLoading, isError, error } = useGetV2ListLibraryAgents();
  return {
    agents: data?.data || [],
    isLoading,
    isError,
    error,
  };
}
```

**Hook naming pattern:** `use{Method}{Version}{OperationName}`

**NEVER use:**
- `BackendAPI`
- `src/lib/autogpt-server-api/*`

### Mutations with Query Invalidation

```typescript
import { useQueryClient } from "@tanstack/react-query";
import {
  useDeleteV2DeleteStoreSubmission,
  getGetV2ListMySubmissionsQueryKey,
} from "@/app/api/__generated__/endpoints/store/store";

export function useDeleteSubmission() {
  const queryClient = useQueryClient();
  const { mutateAsync, isPending } = useDeleteV2DeleteStoreSubmission({
    mutation: {
      onSuccess: () => {
        queryClient.invalidateQueries({
          queryKey: getGetV2ListMySubmissionsQueryKey(),
        });
      },
    },
  });

  return { deleteSubmission: mutateAsync, isPending };
}
```

### State Management

| State Type | Solution |
|------------|----------|
| Server state | React Query |
| Local UI state | `useState` in component/hook |
| Complex multi-step flows | Zustand store colocated with feature |

### Styling

- **Tailwind CSS only** - no inline styles or CSS modules
- **Use design tokens** over hardcoded values
- **Use shadcn/ui components** from `src/components/`
- **NEVER use** `src/components/__legacy__/*`
- **Only Phosphor Icons** (`@phosphor-icons/react`)

### Error Handling

| Error Type | Solution |
|------------|----------|
| Render/runtime errors | `<ErrorCard error={error} />` |
| Mutation errors | Toast notifications via `useToast` |
| Exceptions | Sentry capture |

### Feature Flags

```typescript
import { Flag, useGetFlag } from "@/services/feature-flags/use-get-flag";

export function MyComponent() {
  const isEnabled = useGetFlag(Flag.MY_FEATURE);
  if (!isEnabled) return null;
  return <div>Feature content</div>;
}
```

## Commit Messages (Conventional Commits)

### Format

```
<type>(<scope>): <description>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change (no new feature or fix) |
| `ci` | CI configuration changes |
| `docs` | Documentation only |
| `dx` | Developer experience improvements |

### Scopes

**Base scopes:** `platform`, `frontend`, `backend`, `infra`, `blocks`

**Subscopes:**
- `backend/executor`, `backend/db`
- `frontend/builder`, `frontend/library`, `frontend/marketplace`
- `infra/prod`

### Examples

```
feat(frontend): add agent activity panel
fix(backend): resolve authentication timeout
refactor(blocks): simplify HTTP request block
```

## Pull Requests

- Create PRs against `master` branch
- Use descriptive branch names: `feature/add-new-block`
- Fill out the PR template in `.github/PULL_REQUEST_TEMPLATE.md`
- Keep out-of-scope changes under 20% of PR
- Run pre-commit hooks before pushing
- For `data/*.py` changes, validate user ID checks or explain why not needed
- For protected frontend routes, update `frontend/lib/supabase/middleware.ts`
