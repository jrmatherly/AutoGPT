# LiteLLM Proxy Configuration

## Overview

The AutoGPT Platform supports routing OpenAI API calls through a self-hosted LiteLLM Proxy for:
- Centralized LLM provider management
- Cost optimization and usage tracking
- Enhanced observability and rate limiting
- Unified API access across multiple LLM providers

## Configuration

### Environment Variables

**File**: `autogpt_platform/backend/.env`

```bash
# Route OpenAI API calls through LiteLLM Proxy
OPENAI_BASE_URL=http://your-litellm-proxy:4000
OPENAI_API_KEY=your-litellm-proxy-api-key

# Optional: Separate URL for internal calls (embeddings)
# Defaults to OPENAI_BASE_URL if not set
OPENAI_INTERNAL_BASE_URL=
```

### Components Updated

| Component | Location | Configuration |
|-----------|----------|---------------|
| Utility Client | `backend/util/clients.py` | `openai_internal_base_url` |
| LLM Block | `backend/blocks/llm.py` | `openai_base_url` |
| Codex Block | `backend/blocks/codex.py` | `openai_base_url` |

### Smart Defaulting

- `openai_internal_base_url` automatically defaults to `openai_base_url` if not set
- Both fall back to `https://api.openai.com/v1` for backward compatibility

## Usage

### Local Development

```bash
# 1. Configure in autogpt_platform/backend/.env
OPENAI_BASE_URL=http://your-litellm-proxy:4000
OPENAI_API_KEY=your-litellm-proxy-api-key

# 2. Restart backend
mise run backend
```

### CI/CD Configuration

Add GitHub Repository Secret:
- Name: `LITELLM_PROXY_URL`
- Value: `http://your-litellm-proxy:4000`

E2E tests will automatically use the proxy for embeddings generation.

## Troubleshooting

### Connection refused errors
```bash
# Check proxy is running
curl http://your-litellm-proxy:4000/health
```

### Authentication failed errors
Verify API key matches your LiteLLM Proxy configuration.

### Embeddings work but LLM blocks don't
- Embeddings use `OPENAI_INTERNAL_BASE_URL`
- LLM blocks use `OPENAI_BASE_URL`
- Set both to same URL or leave internal empty (uses smart defaulting)

## References

- [LiteLLM Proxy Documentation](https://docs.litellm.ai/docs/proxy/configs)
- [LiteLLM Quick Start](https://docs.litellm.ai/docs/proxy/quick_start)
