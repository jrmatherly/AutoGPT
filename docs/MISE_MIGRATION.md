# Mise Migration Guide

## What Changed

We've migrated from Makefile to Mise for development task management.

## Why Mise?

1. **Unified Tooling**: One tool for Python, Node.js, and task running
2. **Version Pinning**: Exact tool versions in mise.lock
3. **Auto-Install**: Tools install automatically when entering the directory
4. **Better UX**: Descriptive tasks, tab completion, parallel execution
5. **Virtual Environment Management**: Mise manages Python venvs that Poetry uses

## Quick Setup

```bash
# Install mise (one-time)
curl https://mise.run | sh

# Add to shell (one-time, add to ~/.bashrc or ~/.zshrc)
eval "$(mise activate bash)"  # or zsh

# Setup project (first time)
mise trust
mise run setup
```

## Migration Cheat Sheet

| Old Command | New Command |

|-------------|-------------|
| `make start-core` | `mise run docker:up` |
| `make stop-core` | `mise run docker:down` |
| `make logs-core` | `mise run docker:logs` |
| `make reset-db` | `mise run db:reset` |
| `make run-backend` | `mise run backend` |
| `make run-frontend` | `mise run frontend` |
| `make format` | `mise run format` |
| `make migrate` | `mise run db:migrate` |
| `make test-data` | `mise run test:data` |
| `make load-store-agents` | `mise run store:load` |
| `make apply-rls` | `mise run db:rls-apply` |
| `make verify-rls` | `mise run db:rls-verify` |
| `make drift-full` | `mise run drift:full` |
| `make help` | `mise tasks` |

## Common Tasks

### Daily Development

```bash
# Start your day
mise run docker:up          # Start infrastructure

# In terminal 1: Backend
mise run backend            # Runs with venv auto-activated

# In terminal 2: Frontend
mise run frontend           # Runs with correct Node version

# In terminal 3: Testing
mise run test:backend       # Run tests as you develop
```

### New Feature Development

```bash
# 1. Ensure environment is correct
mise run doctor

# 2. Install any new dependencies
mise run install

# 3. Format before committing
mise run format

# 4. Run tests
mise run test
```

## Key Features

### Automatic Virtual Environment

Mise automatically creates and activates Python virtual environments:

- Backend: `backend/.venv` is created when you enter `backend/`
- Poetry is configured to use this venv (no separate `poetry shell` needed)
- Just `cd backend` and your venv is ready

### Task Caching

Build tasks use smart caching:

```bash
mise run build:backend   # Only rebuilds if Python files or dependencies changed
mise run build:frontend  # Only rebuilds if source or package.json changed
```

### Parallel Execution

Installation runs in parallel:

```bash
mise run install  # Installs backend, frontend, and libs simultaneously
```

## Troubleshooting

### "mise: command not found"

**Solution:**

```bash
# Install mise
curl https://mise.run | sh

# Add to shell (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"  # or zsh
```

### "Config file is not trusted"

**Solution:**

```bash
mise trust
```

### Wrong Python/Node version showing

**Solution:**

```bash
# Check mise status
mise doctor

# Reinstall tools
mise install
```

### Tools not switching when changing directories

**Solution:**

```bash
# Add to ~/.bashrc or ~/.zshrc
eval "$(mise activate bash)"  # or zsh

# Reload shell
source ~/.bashrc
```

## Resources

- [Mise Documentation](https://mise.jdx.dev/)
- [Complete Implementation Plan](../../docs/plans/2026-01-29-mise-integration.md)
- [Mise Tasks Reference](https://mise.jdx.dev/tasks/)
