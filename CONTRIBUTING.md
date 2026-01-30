# AutoGPT Contribution Guide

If you are reading this, you are probably looking for the full **[contribution guide]**,
which is part of our [wiki].

[contribution guide]: https://github.com/jrmatherly/AutoGPT/wiki/Contributing
[wiki]: https://github.com/jrmatherly/AutoGPT/wiki

## Prerequisites

Before contributing, ensure you have the following installed:

### Required Tools

1. **mise** (2026.1.0 or newer) - Development tool manager

   ```bash
   curl https://mise.run | sh
   eval "$(mise activate bash)"  # Add to ~/.bashrc or ~/.zshrc
   ```

2. **Docker** (20.10.0+) and **Docker Compose** (2.0.0+)
   - [Install Docker Desktop](https://docs.docker.com/get-docker/)

3. **Git** (2.30+)

### Tools Managed by mise

The following are automatically installed and managed by mise:

- Python 3.13.1
- Node.js 22.22.0
- pnpm 10.28.2+
- Poetry 2.3.1+

### Verify Your Environment

After installing mise:

```bash
cd autogpt_platform
mise trust                    # Trust the mise configuration
mise run doctor              # Verify environment setup
```

---

## Quick Start for Contributors

### 1. Fork and Clone

Fork the repository on GitHub, then clone your fork:

```bash
git clone https://github.com/YOUR_USERNAME/AutoGPT.git
cd AutoGPT/autogpt_platform
```

### 2. Set Up Development Environment

```bash
mise trust && mise run setup
```

This will:

- Install all required tools (Python, Node, pnpm, Poetry)
- Install backend and frontend dependencies
- Run database migrations
- Set up pre-commit hooks

### 3. Create a Feature Branch

Always branch from `master`:

```bash
git checkout master
git pull origin master
git checkout -b feature/your-feature-name
```

### 4. Start Development Services

```bash
# Terminal 1: Start infrastructure
mise run docker:up

# Terminal 2: Start backend
mise run backend

# Terminal 3: Start frontend
mise run frontend
```

Access the application:

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- OpenAPI docs: http://localhost:8000/docs

### 5. Make Changes and Test

Before committing, ensure your code passes all checks:

```bash
mise run format          # Format and lint all code
mise run test            # Run all tests
```

### 6. Submit a Pull Request

- Create a pull request to the `master` branch
- Use conventional commit format: `type(scope): description`
  - Types: `feat`, `fix`, `refactor`, `ci`, `docs`, `dx`
  - Scopes: `platform`, `frontend`, `backend`, `blocks`, `infra`
- Clearly explain your changes

**Example commit messages:**

```git
feat(backend): add new Twitter DM block
fix(frontend): resolve infinite loop in agent builder
docs(platform): update CLAUDE.md with mise commands
```

---

## Contributing to the AutoGPT Platform Folder

⚠️ **Important License Information:**

All contributions to [the autogpt_platform folder](https://github.com/jrmatherly/AutoGPT/blob/master/autogpt_platform) are subject to our [Contribution License Agreement (CLA)](https://github.com/jrmatherly/AutoGPT/blob/master/autogpt_platform/Contributor%20License%20Agreement%20(CLA).md). By submitting a pull request to this folder, you agree to the CLA terms.

Contributions to other folders are licensed under MIT.

## Contribution Guidelines Summary

1. **Avoid duplicate work** - Check existing issues and PRs before starting
2. **Collaborate on big features** - Discuss in issues or the [dev channel] first
3. **Use draft PRs** for work-in-progress on larger changes
4. **Follow [Code Guidelines]** - See the wiki for details
5. **Test your changes** - Run `mise run test` before submitting
6. **Write clear PR descriptions** - Explain what and why, not just how
7. **Keep changes focused** - Avoid unrelated refactoring or style changes
8. **Consider non-code contributions** - Documentation, testing, design, etc.

[code guidelines]: https://github.com/jrmatherly/AutoGPT/wiki/Contributing#code-guidelines
[dev channel]: https://github.com/jrmatherly/AutoGPT/discussions

For deeper involvement beyond contributing PRs, see [Catalyzing](https://github.com/jrmatherly/AutoGPT/wiki/Catalyzing).

---

## Common Development Tasks

| Task | Command |
|------|---------|
| List all available tasks | `mise tasks` |
| Verify environment | `mise run doctor` |
| Format and lint code | `mise run format` |
| Run all tests | `mise run test` |
| Run backend tests only | `mise run test:backend` |
| Run frontend tests only | `mise run test:frontend` |
| Database migrations | `mise run db:migrate` |
| Reset database | `mise run db:reset` |
| Regenerate API client | `cd frontend && pnpm generate:api` |

---

## Getting Help

- **Documentation**: See [autogpt_platform/CLAUDE.md](autogpt_platform/CLAUDE.md) for development guide
- **Issues**: Check [GitHub Issues](https://github.com/jrmatherly/AutoGPT/issues) for known problems
- **Discussions**: Use [GitHub Discussions](https://github.com/jrmatherly/AutoGPT/discussions) for questions
- **Wiki**: Full [contribution guide] in the wiki
