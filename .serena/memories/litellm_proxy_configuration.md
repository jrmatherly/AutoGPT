# LiteLLM Proxy Configuration

**Full documentation:** [docs/platform/LITELLM_PROXY.md](../../docs/platform/LITELLM_PROXY.md)

## Quick Reference

| Variable | Purpose |
|----------|---------|
| `OPENAI_BASE_URL` | Route OpenAI API calls (LLM blocks, Codex) |
| `OPENAI_INTERNAL_BASE_URL` | Route internal calls (embeddings) - defaults to above |

## Configuration

```bash
# In autogpt_platform/backend/.env
OPENAI_BASE_URL=http://your-litellm-proxy:4000
OPENAI_API_KEY=your-proxy-api-key
```

## CI/CD

GitHub secret `LITELLM_PROXY_URL` enables proxy routing in E2E tests.
