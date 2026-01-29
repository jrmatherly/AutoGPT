# GitHub Secrets Setup Guide

## Overview

This guide documents all required and optional GitHub secrets for AutoGPT workflows to run properly. Secrets are used to protect sensitive credentials and allow workflows to interact with external services.

## Required Secrets

These secrets **must** be configured for workflows to function correctly:

### 1. `OPENAI_API_KEY`

**Used by:**
- `ci-mise.yml` - Backend tests that require OpenAI embeddings
- `platform-backend-ci.yml` - Backend CI tests
- `platform-frontend-ci.yml` - Frontend E2E test data generation

**Purpose:** Provides OpenAI API access for:
- Generating embeddings for test data
- Testing LLM-related blocks
- Store agent test data creation

**How to obtain:**
1. Create account at [platform.openai.com](https://platform.openai.com)
2. Navigate to API Keys
3. Create new secret key
4. Copy the key (starts with `sk-`)

**How to set:**
```bash
# Via GitHub CLI
gh secret set OPENAI_API_KEY

# Or via GitHub UI:
# Settings → Secrets and variables → Actions → New repository secret
```

**Cost considerations:**
- Tests use minimal API calls (~$0.01-0.05 per CI run)
- Consider setting usage limits in OpenAI dashboard
- Use a separate API key for CI (not production)

---

### 2. `CLAUDE_CODE_OAUTH_TOKEN`

**Used by:**
- `claude-code-review.yml` - Automated code reviews
- `claude-ci-failure-auto-fix.yml` - CI failure fixes
- `claude-dependabot.yml` - Dependabot automation
- `claude.yml` - General Claude Code tasks
- `docs-claude-review.yml` - Documentation reviews
- `docs-enhance.yml` - Documentation enhancement

**Purpose:** Authenticates Claude Code action for AI-assisted development

**How to obtain:**
1. Visit [Claude Code Settings](https://claude.ai/code/settings)
2. Generate OAuth token for GitHub Actions
3. Copy the token

**How to set:**
```bash
gh secret set CLAUDE_CODE_OAUTH_TOKEN
```

**Note:** Required only if using Claude Code workflows. Can be disabled by removing/commenting those workflow files.

---

## Optional Secrets (with Defaults)

These secrets have safe defaults for testing but should be customized for production forks:

### 3. `RABBITMQ_DEFAULT_USER`

**Default:** `rabbitmq_user_default`

**Used by:**
- `ci-mise.yml` - RabbitMQ service authentication
- `platform-backend-ci.yml` - Backend tests

**Purpose:** Username for RabbitMQ message queue service in tests

**When to customize:**
- Running tests against production-like infrastructure
- Security hardening requirements
- Multi-tenant CI environments

**How to set:**
```bash
gh secret set RABBITMQ_DEFAULT_USER
# Enter custom username when prompted
```

---

### 4. `RABBITMQ_DEFAULT_PASS`

**Default:** `k0VMxyIJF9S35f3x2uaw5IWAl6Y536O7`

**Used by:**
- `ci-mise.yml` - RabbitMQ service authentication
- `platform-backend-ci.yml` - Backend tests

**Purpose:** Password for RabbitMQ message queue service in tests

**Security note:** Default is a well-known test credential. **DO NOT use in production.**

**When to customize:**
- Security compliance requirements
- Production-like test environments
- Shared CI infrastructure

**How to set:**
```bash
gh secret set RABBITMQ_DEFAULT_PASS
# Enter custom password when prompted
```

---

### 5. `TEST_ENCRYPTION_KEY`

**Default:** `dvziYgz0KSK8FENhju0ZYi8-fRTfAdlz6YLhdB_jhNw=`

**Used by:**
- `ci-mise.yml` - Test data encryption

**Purpose:** Encryption key for sensitive test data (credentials, tokens, etc.)

**Security note:** Default is a well-known test key. **DO NOT use in production.**

**When to customize:**
- Security compliance requirements
- Testing encryption/decryption workflows
- Production-like environments

**How to generate:**
```bash
# Generate secure encryption key
python3 -c "import base64; import os; print(base64.urlsafe_b64encode(os.urandom(32)).decode())"
```

**How to set:**
```bash
gh secret set TEST_ENCRYPTION_KEY
# Paste generated key when prompted
```

---

## Deployment-Only Secrets

These secrets are only required if using deployment workflows:

### 6. `BACKEND_DATABASE_URL`

**Used by:**
- `platform-autogpt-deploy-prod.yml` - Production deployments
- `platform-autogpt-deploy-dev.yaml` - Development deployments

**Purpose:** PostgreSQL connection string for production/staging databases

**Format:**
```
postgresql://user:password@host:5432/database?schema=platform
```

**How to set:**
```bash
gh secret set BACKEND_DATABASE_URL
# Enter connection string when prompted
```

**Security:**
- Use read-write user with limited permissions
- Enable SSL: `?sslmode=require`
- Consider IP allowlist for database access

---

### 7. `DEPLOY_TOKEN`

**Used by:**
- `platform-autogpt-deploy-prod.yml` - Triggers infrastructure deploy
- `platform-autogpt-deploy-dev.yaml` - Triggers dev deploy

**Purpose:** Personal Access Token for triggering deploy workflows in infrastructure repository

**How to create:**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes needed: `repo`, `workflow`
4. Copy token

**How to set:**
```bash
gh secret set DEPLOY_TOKEN
```

**Note:** Only needed if you have a forked infrastructure repository. Original references `Significant-Gravitas/AutoGPT_cloud_infrastructure`.

---

### 8. `DISPATCH_TOKEN`

**Used by:**
- `platform-dev-deploy-event-dispatcher.yml` - PR environment deployments

**Purpose:** Token for dispatching PR deployment events

**Same as `DEPLOY_TOKEN`** - Can use the same PAT or create separate token.

**How to set:**
```bash
gh secret set DISPATCH_TOKEN
```

---

## Optional Enhancement Secrets

### 9. `CODECOV_TOKEN`

**Currently commented out** in workflows

**Purpose:** Upload coverage reports to Codecov.io

**How to obtain:**
1. Sign up at [codecov.io](https://codecov.io)
2. Add your repository
3. Copy upload token

**To enable:**
```bash
gh secret set CODECOV_TOKEN

# Uncomment in .github/workflows/platform-backend-ci.yml:
# - name: Upload coverage reports to Codecov
#   uses: codecov/codecov-action@v4
#   with:
#     token: ${{ secrets.CODECOV_TOKEN }}
```

---

## Automatic Secrets

These are automatically provided by GitHub Actions:

### `GITHUB_TOKEN`

**Automatically available** - No setup required

**Used by:**
- All workflows using `mise-action` (prevents API rate limiting)
- PR labeling workflows
- GitHub API interactions

**Permissions:** Automatically scoped per workflow based on `permissions:` block

---

## Setup Checklist

### Minimal Setup (Open Source Forks)

For running CI tests on a fork:

- [ ] `OPENAI_API_KEY` - **Required** for backend tests
- [ ] All other secrets use defaults (acceptable for testing)

### Enhanced Setup (Private Development)

For production-like testing:

- [ ] `OPENAI_API_KEY` - OpenAI access
- [ ] `CLAUDE_CODE_OAUTH_TOKEN` - AI assistance (if using)
- [ ] `RABBITMQ_DEFAULT_USER` - Custom RabbitMQ user
- [ ] `RABBITMQ_DEFAULT_PASS` - Custom RabbitMQ password
- [ ] `TEST_ENCRYPTION_KEY` - Custom encryption key

### Full Setup (Deployment Enabled)

For deployments to infrastructure:

- [ ] All enhanced setup secrets
- [ ] `BACKEND_DATABASE_URL` - Production database
- [ ] `DEPLOY_TOKEN` - Infrastructure repository access
- [ ] `DISPATCH_TOKEN` - PR environment triggers

---

## Verification

### Check Configured Secrets

```bash
# List all configured secrets (names only, not values)
gh secret list
```

### Test Secret Configuration

```bash
# Trigger CI workflow to verify secrets work
git commit --allow-empty -m "test: verify GitHub secrets configuration"
git push

# Watch workflow run
gh run watch
```

### Common Issues

**Symptom:** "Backend tests fail with OpenAI API errors"
```
Error: OpenAI API key not configured
```

**Solution:**
```bash
gh secret set OPENAI_API_KEY
# Paste your OpenAI API key
```

---

**Symptom:** "RabbitMQ connection refused"
```
Error: Could not connect to RabbitMQ
```

**Solution:** Verify service is using correct credentials:
```yaml
# Check ci-mise.yml services section
env:
  RABBITMQ_DEFAULT_USER: ${{ secrets.RABBITMQ_DEFAULT_USER || 'rabbitmq_user_default' }}
```

---

**Symptom:** "mise-action rate limited"
```
Error: API rate limit exceeded
```

**Solution:** Ensure `github_token` is configured:
```yaml
- uses: jdx/mise-action@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}  # ← Must be present
```

---

## Security Best Practices

1. **Rotate regularly:** Change secrets every 90 days
2. **Separate environments:** Use different secrets for dev/staging/prod
3. **Audit access:** Review who can modify secrets in repository settings
4. **Least privilege:** Only grant necessary permissions to tokens
5. **Monitor usage:** Watch for unexpected API usage patterns
6. **Secret scanning:** Enable GitHub's secret scanning in repository settings

---

## Updating Secrets

### Via GitHub CLI

```bash
# Update existing secret
gh secret set SECRET_NAME

# Delete secret
gh secret remove SECRET_NAME
```

### Via GitHub UI

1. Navigate to repository
2. Settings → Secrets and variables → Actions
3. Click secret name to update
4. Enter new value → Update secret

---

## Environment-Specific Secrets

For organization-level or environment-specific secrets:

```bash
# Set organization secret (requires org admin)
gh secret set SECRET_NAME --org ORGANIZATION_NAME

# Set environment secret
gh secret set SECRET_NAME --env production
```

See [GitHub Environments documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) for environment setup.

---

## Related Documentation

- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [CI Migration Guide](./CI_MIGRATION_GUIDE.md)
- [Architecture Documentation](./ARCHITECTURE.md)
- [API Reference](./API_REFERENCE.md)

---

## Quick Reference

| Secret | Required? | Default Available? | Used By |

|--------|-----------|-------------------|---------|
| `OPENAI_API_KEY` | ✅ Yes | ❌ No | CI tests |
| `CLAUDE_CODE_OAUTH_TOKEN` | ⚠️ If using Claude | ❌ No | Claude workflows |
| `RABBITMQ_DEFAULT_USER` | ❌ No | ✅ Yes (`rabbitmq_user_default`) | CI tests |
| `RABBITMQ_DEFAULT_PASS` | ❌ No | ✅ Yes (test value) | CI tests |
| `TEST_ENCRYPTION_KEY` | ❌ No | ✅ Yes (test value) | CI tests |
| `BACKEND_DATABASE_URL` | ⚠️ If deploying | ❌ No | Deployments |
| `DEPLOY_TOKEN` | ⚠️ If deploying | ❌ No | Deployments |
| `DISPATCH_TOKEN` | ⚠️ If deploying | ❌ No | PR deploys |
| `GITHUB_TOKEN` | ✅ Auto | ✅ Auto | All workflows |

**Legend:**
- ✅ Yes = Must configure
- ❌ No = Not available by default
- ⚠️ Conditional = Only if using feature
- ✅ Auto = Automatically provided
