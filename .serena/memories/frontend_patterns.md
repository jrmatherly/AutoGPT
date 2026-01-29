# Frontend Design Patterns

## Component Pattern

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

## Hook Pattern

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

## Data Fetching Pattern

Always use generated React Query hooks:

```typescript
import { useGetV2ListLibraryAgents } from "@/app/api/__generated__/endpoints/library/library";

export function useAgentList() {
  const { data, isLoading, isError } = useGetV2ListLibraryAgents();
  return { agents: data?.data || [], isLoading, isError };
}
```

## Mutation Pattern

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

## Server-Side Prefetch Pattern

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

## State Management Pattern

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

## Error Handling Pattern

| Error Type | Solution |
|------------|----------|
| Render errors | `<ErrorCard error={error} />` |
| Mutation errors | Toast notifications |
| Exceptions | Sentry capture |

**Example:**
```typescript
import { ErrorCard } from "@/components/molecules/ErrorCard";
import { useToast } from "@/hooks/use-toast";

export function MyComponent() {
  const { toast } = useToast();
  const { mutate, error } = useMutation({
    onError: (error) => {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  if (error) return <ErrorCard error={error} />;
  // ...
}
```

## Feature Flag Pattern

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

- ❌ Using `BackendAPI` or `autogpt-server-api` (deprecated)
- ❌ Using `__legacy__` components
- ❌ Using icons other than Phosphor
- ❌ Arrow functions for components (use function declarations)
- ❌ Barrel files / index.ts re-exports
- ❌ Excessive `useCallback`/`useMemo` (only when strictly needed)
- ❌ Comments unless code is very complex
- ❌ Hardcoded style values instead of design tokens
- ❌ Server actions (prefer API routes)
- ❌ Mixing render logic with business logic
- ❌ Exporting Props interfaces unless needed externally
- ❌ Creating separate types.ts for single components

## Testing Patterns

### E2E Tests (Playwright)

```typescript
// tests/library.spec.ts
import { test, expect } from "@playwright/test";

test("user can create agent", async ({ page }) => {
  await page.goto("/library");
  await page.click('[data-testid="create-agent-button"]');
  await page.fill('[name="name"]', "My Agent");
  await page.click('[type="submit"]');
  await expect(page.locator("text=My Agent")).toBeVisible();
});
```

### Component Tests (Storybook)

```tsx
// StatsPanel.stories.tsx
import type { Meta, StoryObj } from "@storybook/react";
import { StatsPanel } from "./StatsPanel";

const meta: Meta<typeof StatsPanel> = {
  title: "Organisms/StatsPanel",
  component: StatsPanel,
};

export default meta;
type Story = StoryObj<typeof StatsPanel>;

export const Default: Story = {
  args: {
    data: [{ id: "1", value: 100 }],
    isLoading: false,
  },
};

export const Loading: Story = {
  args: {
    data: [],
    isLoading: true,
  },
};
```

### Unit Tests (Vitest)

```typescript
// useStatsPanel.test.ts
import { renderHook, waitFor } from "@testing-library/react";
import { useStatsPanel } from "./useStatsPanel";

test("returns formatted data", async () => {
  const { result } = renderHook(() => useStatsPanel());
  
  await waitFor(() => {
    expect(result.current.isLoading).toBe(false);
  });
  
  expect(result.current.data).toHaveLength(5);
});
```

### API Mocking (MSW in Storybook)

```typescript
// .storybook/preview.tsx
import { http, HttpResponse } from "msw";

export const handlers = [
  http.get("/api/v2/stats", () => {
    return HttpResponse.json({ data: [{ id: "1", value: 100 }] });
  }),
];
```

## Security Patterns

### Authentication Middleware

Protected routes use Supabase middleware:

**Location:** `frontend/lib/supabase/middleware.ts`

**Protected route groups:**
- `(platform)/*` - All platform pages require authentication

**Example:**
```typescript
// middleware.ts
export async function middleware(request: NextRequest) {
  const { supabase, response } = createClient(request);
  const { data: { session } } = await supabase.auth.getSession();

  if (!session && request.nextUrl.pathname.startsWith("/build")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return response;
}
```

### Client-Side Route Protection

For client components that need auth:

```typescript
"use client";

import { useUser } from "@/lib/supabase/use-user";
import { redirect } from "next/navigation";

export function ProtectedComponent() {
  const { user, isLoading } = useUser();

  if (isLoading) return <Skeleton />;
  if (!user) redirect("/login");

  return <div>Protected content</div>;
}
```

### Preventing XSS

- Never use `dangerouslySetInnerHTML` unless absolutely necessary
- Sanitize user input before rendering
- Use design system components (they handle escaping)

### CSRF Protection

- API routes use Supabase auth tokens
- No cookies for authentication (JWT only)
- CORS configured in backend middleware
