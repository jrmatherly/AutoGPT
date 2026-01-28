# Code Style and Conventions

## General Principles
- Avoid over-engineering; keep solutions simple and focused
- Prefer editing existing files over creating new ones
- Avoid comments unless code is very complex
- Use early returns to reduce nesting

## Python (Backend)

### Style
- **Formatter**: Black + isort
- **Linter**: Ruff, Flake8
- **Type Checker**: Pyright
- **Python Version**: 3.10+

### Conventions
- Use type hints throughout
- Async/await for I/O operations
- Pydantic models for data validation
- Prisma ORM for database operations
- Test files colocated with source (`*_test.py`)

### Imports
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

### Style
- **Formatter**: Prettier
- **Linter**: ESLint (Next.js config)
- **Type Checker**: TypeScript strict mode
- **Node Version**: 22.x

### Component Structure
```
ComponentName/
  ComponentName.tsx      # Render logic only
  useComponentName.ts    # Hook: data fetching, behavior, state
  helpers.ts             # Pure helper functions
  components/            # Local sub-components
```

### Naming Conventions
- Components: `PascalCase` (files and exports)
- Hooks: `useCamelCase`
- Other files: `kebab-case`
- Props interface: `interface Props { ... }` (not exported unless needed externally)

### Code Conventions
- **Function declarations** for components and handlers (not arrow functions)
- **Arrow functions** only for small inline callbacks
- **No barrel files** or `index.ts` re-exports
- **No `useCallback`/`useMemo`** unless strictly needed
- **No comments** unless code is very complex
- **Colocate state** when possible
- Separate render logic from business logic

### Data Fetching
- Use generated API hooks from `@/app/api/__generated__/endpoints/`
- Pattern: `use{Method}{Version}{OperationName}`
- Never use deprecated `BackendAPI` or `src/lib/autogpt-server-api/*`

### Styling
- Tailwind CSS only
- Use design tokens over hardcoded values
- Use shadcn/ui components from `src/components/`
- Never use `src/components/__legacy__/*`
- Only use **Phosphor Icons** (`@phosphor-icons/react`)

### State Management
- React Query for server state
- Zustand for complex local state flows
- Colocate UI state in components/hooks

## Commit Messages (Conventional Commits)

### Format
```
<type>(<scope>): <description>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change (no new feature or fix)
- `ci`: CI configuration changes
- `docs`: Documentation only
- `dx`: Developer experience improvements

### Scopes
- `platform`: Both frontend and backend
- `frontend`, `backend`, `infra`, `blocks`
- Subscopes: `backend/executor`, `backend/db`, `frontend/builder`, `infra/prod`

### Examples
```
feat(frontend): add agent activity panel
fix(backend): resolve authentication timeout
refactor(blocks): simplify HTTP request block
```

## Pull Requests
- Create PRs against `dev` branch
- Use descriptive branch names: `feature/add-new-block`
- Fill out the PR template in `.github/PULL_REQUEST_TEMPLATE.md`
- Keep out-of-scope changes under 20% of PR
- Run pre-commit hooks before pushing
