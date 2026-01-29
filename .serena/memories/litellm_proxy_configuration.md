# LiteLLM Proxy Configuration

## Last Updated
- **Date**: January 29, 2026
- **Commit**: f45fc70e3 - feat(platform): implement LiteLLM Proxy integration support
- **Status**: ✅ Implemented and deployed

## Overview

The AutoGPT Platform supports routing OpenAI API calls through a self-hosted LiteLLM Proxy for:
- Centralized LLM provider management
- Cost optimization and usage tracking
- Enhanced observability and rate limiting
- Unified API access across multiple LLM providers

## Implementation Summary

### Backend Configuration

**Settings Fields** (`backend/util/settings.py`):
```python
openai_base_url: str = Field(
    default="https://api.openai.com/v1",
    description="Base URL for OpenAI API (or LiteLLM Proxy)",
)
openai_internal_base_url: str = Field(
    default="",
    description="Base URL for internal OpenAI API calls (or LiteLLM Proxy)",
)
```

**Smart Defaulting**:
- `openai_internal_base_url` automatically defaults to `openai_base_url` if not set
- Both fall back to `https://api.openai.com/v1` for backward compatibility

### OpenAI Client Integration

**3 locations updated with base_url support**:

1. **Utility Client** (`backend/util/clients.py:158`)
   - Used for: Embeddings generation (store search)
   - Configuration: `settings.secrets.openai_internal_base_url`

2. **LLM Block** (`backend/blocks/llm.py:659`)
   - Used for: Core OpenAI LLM calls in workflows
   - Configuration: `settings.secrets.openai_base_url`

3. **Codex Block** (`backend/blocks/codex.py:168`)
   - Used for: Code generation/modification
   - Configuration: `settings.secrets.openai_base_url`

**Already Compatible** (no changes needed):
- Chat Service (`backend/api/features/chat/service.py`) - uses ChatConfig
- Perplexity Block - hardcoded OpenRouter URL
- Other LLM providers (AIML, Open Router, Llama API, V0) - have custom base URLs

### Environment Variables

**File**: `autogpt_platform/backend/.env.default`

```bash
# AI/LLM Services
OPENAI_API_KEY=
OPENAI_BASE_URL=https://api.openai.com/v1

# Internal OpenAI Configuration (for embeddings, etc.)
# Defaults to OPENAI_BASE_URL if not set
# Set this to your LiteLLM Proxy URL to route all internal OpenAI calls through it
# For more information: https://docs.litellm.ai/docs/proxy/configs
OPENAI_INTERNAL_BASE_URL=
```

### GitHub Actions Integration

**File**: `.github/workflows/platform-frontend-ci.yml`

```yaml
- name: Copy backend .env and set OpenAI API key
  run: |
    cp ../backend/.env.default ../backend/.env
    echo "OPENAI_INTERNAL_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> ../backend/.env
    if [ -n "${{ secrets.LITELLM_PROXY_URL }}" ]; then
      echo "OPENAI_INTERNAL_BASE_URL=${{ secrets.LITELLM_PROXY_URL }}" >> ../backend/.env
    fi
```

**Optional Secret**: `LITELLM_PROXY_URL` - If set, E2E tests route through LiteLLM Proxy

## Usage Guide

### Local Development

**1. Configure LiteLLM Proxy URL**:
```bash
# Edit autogpt_platform/backend/.env
OPENAI_BASE_URL=http://your-litellm-proxy:4000
OPENAI_API_KEY=your-litellm-proxy-api-key
```

**2. Restart backend services**:
```bash
mise run backend
```

All OpenAI SDK calls will now route through your LiteLLM Proxy.

### Production Deployment

**Docker Compose** (`autogpt_platform/docker-compose.platform.yml`):

Environment variables are automatically loaded from `.env` files:
1. `backend/.env.default` (defaults)
2. `backend/.env` (user overrides)
3. Docker environment sections (service-specific)

No docker-compose changes needed - just set environment variables.

### CI/CD Configuration

**Add GitHub Repository Secret**:
- Name: `LITELLM_PROXY_URL`
- Value: `http://your-litellm-proxy:4000`

E2E tests will automatically use the proxy for embeddings generation.

## Validation Checklist

✅ **Backend Settings**: Both base URL fields added with validator
✅ **Client Integration**: All 3 OpenAI clients updated
✅ **Environment Config**: Variables documented in .env.default
✅ **CI/CD Support**: Optional proxy configuration in workflows
✅ **Backward Compatibility**: Defaults to OpenAI API, no breaking changes
✅ **Syntax Validation**: All files pass ruff linting
✅ **Developer Experience**: Mise tasks work from project root

## Architecture Benefits

### Before LiteLLM Proxy Support
- Direct OpenAI API calls from each service
- No centralized observability
- Manual cost tracking
- Provider-specific implementations

### After LiteLLM Proxy Support
- Centralized proxy routing
- Unified observability and logging
- Automated cost tracking and rate limiting
- Single configuration point for all providers
- Easy provider switching (OpenAI → Anthropic → etc.)

## Troubleshooting

### Issue: "Connection refused" errors

**Cause**: LiteLLM Proxy not running or not accessible from backend container

**Solution**:
```bash
# Check proxy is running
curl http://your-litellm-proxy:4000/health

# Verify network accessibility from Docker
docker compose exec rest_server curl http://your-litellm-proxy:4000/health
```

### Issue: "Authentication failed" errors

**Cause**: `OPENAI_API_KEY` doesn't match LiteLLM Proxy API key

**Solution**: Verify API key matches your LiteLLM Proxy configuration

### Issue: Embeddings work but LLM blocks don't

**Cause**: Different base URL configurations

**Explanation**:
- Embeddings use `OPENAI_INTERNAL_BASE_URL`
- LLM blocks use `OPENAI_BASE_URL`

**Solution**: Set both to same proxy URL or use smart defaulting (leave internal URL empty)

## References

### Implementation Documents
- **Research Report**: `claudedocs/research_litellm_proxy_configuration_2026-01-29.md`
- **Implementation Commit**: `f45fc70e3`

### External Documentation
- [LiteLLM Proxy Documentation](https://docs.litellm.ai/docs/proxy/configs)
- [LiteLLM Quick Start](https://docs.litellm.ai/docs/proxy/quick_start)
- [LiteLLM CI/CD Guide](https://mise.jdx.dev/continuous-integration.html)

## Future Enhancements

### Potential Improvements (Not Implemented)
1. **Per-Credential Base URLs**: Add base_url field to APIKeyCredentials model
   - Requires: Database migration, UI changes, block configuration updates
   - Benefit: Different LLM providers per user/integration

2. **Health Check Integration**: Monitor LiteLLM Proxy availability
   - Requires: Health check endpoint, fallback logic
   - Benefit: Automatic failover to direct OpenAI

3. **Metrics Integration**: Track LiteLLM Proxy usage and costs
   - Requires: Prometheus/metrics client, dashboard
   - Benefit: Real-time cost and usage visibility

### Recommendation
Start with global settings (current implementation), add per-credential URLs only if needed for multi-tenant scenarios.
