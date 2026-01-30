# Suggested Commands

**Full reference:** See [autogpt_platform/CLAUDE.md](../../autogpt_platform/CLAUDE.md)

## Project Structure

- **TypeScript**: Frontend (Next.js/React) in `autogpt_platform/frontend/`
- **Python**: Backend (FastAPI) in `autogpt_platform/backend/`
- **Tools**: Managed by [mise](https://mise.jdx.dev)

## Essential Commands

| Task | Command |
|------|---------|
| Setup | `mise trust && mise run setup` |
| Start services | `mise run docker:up` |
| Backend server | `mise run backend` |
| Frontend server | `mise run frontend` |
| Format code | `mise run format` |
| Run tests | `mise run test` |
| Run migrations | `mise run db:migrate` |
| List all tasks | `mise tasks` |

## Quick Backend

```bash
cd autogpt_platform/backend
poetry run app        # Run server
poetry run test       # Run tests
poetry run format     # Format code
```

## Quick Frontend

```bash
cd autogpt_platform/frontend
pnpm dev             # Run dev server
pnpm test            # Run E2E tests
pnpm generate:api    # Regenerate API client
```
