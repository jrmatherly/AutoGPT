# LiteLLM Proxy Configuration Research Report

**Date:** 2026-01-29
**Research Scope:** Identify configuration requirements for LiteLLM Proxy integration
**Current Status:** OpenAI API key configured, but no base URL support for LiteLLM Proxy

---

## Executive Summary

The AutoGPT Platform currently uses native OpenAI SDK clients throughout the codebase but **lacks base URL configuration** needed to route requests through a self-hosted LiteLLM Proxy. This research identifies:

1. **7 locations** where OpenAI clients are instantiated
2. **Mixed base URL support** - Chat service supports it, but LLM blocks and other services don't
3. **Required configuration changes** across backend settings, environment files, workflows, and code
4. **LiteLLM Proxy requirements** based on official documentation

### Key Findings

| Component | Base URL Support | Configuration Needed |

|-----------|------------------|----------------------|
| **Chat Service** | ✅ Already Supported | Environment variable only |
| **LLM Blocks** | ❌ Not Supported | Code + environment changes |
| **Utility Clients** | ❌ Not Supported | Code + environment changes |
| **Block Integrations** | ❌ Not Supported | Code + environment changes |
| **GitHub Workflows** | ❌ Not Configured | Secrets + environment setup |

---

## Research Findings

### 1. OpenAI Client Usage Locations

#### ✅ Already Supports Base URL

**Location:** `autogpt_platform/backend/backend/api/features/chat/service.py:67`

```python
client = openai.AsyncOpenAI(api_key=config.api_key, base_url=config.base_url)
```

**Configuration:** `autogpt_platform/backend/backend/api/features/chat/config.py`

```python
class ChatConfig(BaseSettings):
    api_key: str | None = Field(default=None, description="OpenAI API key")
    base_url: str | None = Field(
        default="https://openrouter.ai/api/v1",
        description="Base URL for API (e.g., for OpenRouter)",
    )

    @field_validator("base_url", mode="before")
    @classmethod
    def get_base_url(cls, v):
        """Get base URL from environment if not provided."""
        if v is None:
            v = os.getenv("CHAT_BASE_URL")
            if not v:
                v = os.getenv("OPENROUTER_BASE_URL")
            if not v:
                v = os.getenv("OPENAI_BASE_URL")
            if not v:
                v = "https://openrouter.ai/api/v1"
        return v
```

**Status:** ✅ This component already supports LiteLLM Proxy via `OPENAI_BASE_URL` environment variable.

---

#### ❌ No Base URL Support - Requires Code Changes

##### 1. Utility Client (`backend/util/clients.py:158`)

```python
@cached(ttl_seconds=3600)
def get_openai_client() -> "AsyncOpenAI | None":
    from openai import AsyncOpenAI

    api_key = settings.secrets.openai_internal_api_key
    if not api_key:
        return None
    return AsyncOpenAI(api_key=api_key)  # ❌ No base_url parameter
```

**Usage:** Used for embeddings generation
**Impact:** Medium - affects store agent embeddings and search functionality

---

##### 2. LLM Block - OpenAI Provider (`backend/blocks/llm.py:656`)

```python
if provider == "openai":
    oai_client = openai.AsyncOpenAI(api_key=credentials.api_key.get_secret_value())
    # ❌ No base_url parameter

    response = await oai_client.chat.completions.create(
        model=llm_model.value,
        messages=prompt,
        response_format=response_format,
        max_completion_tokens=max_tokens,
        tools=tools_param,
        parallel_tool_calls=parallel_tool_calls,
    )
```

**Usage:** Core LLM block for OpenAI models
**Impact:** **HIGH** - This is the primary interface for OpenAI LLM calls in workflows

---

##### 3. LLM Block - OpenRouter Providers (`backend/blocks/llm.py:816, 858, 899, 928`)

**AIML Provider (line 816):**

```python
client = openai.AsyncOpenAI(
    base_url="https://api.aimlapi.com/v1",  # ✅ Already has base_url
    api_key=credentials.api_key.get_secret_value(),
)
```

**Open Router Provider (line 858):**

```python
client = openai.AsyncOpenAI(
    base_url="https://openrouter.ai/api/v1",  # ✅ Already has base_url
    api_key=credentials.api_key.get_secret_value(),
)
```

**Llama API Provider (line 899):**

```python
client = openai.OpenAI(
    base_url="https://api.llama-api.com",  # ✅ Already has base_url
    api_key=credentials.api_key.get_secret_value(),
)
```

**V0 Provider (line 928):**

```python
client = openai.AsyncOpenAI(
    base_url="https://v0-api.v0.dev/v1",  # ✅ Already has base_url
    api_key=credentials.api_key.get_secret_value(),
)
```

**Status:** These providers use hardcoded non-OpenAI base URLs and won't be affected.

---

##### 4. Perplexity Block (`backend/blocks/perplexity.py:138`)

```python
client = openai.AsyncOpenAI(
    base_url="https://openrouter.ai/api/v1",  # ✅ Already has base_url (hardcoded)
    api_key=credentials.api_key.get_secret_value(),
)
```

**Status:** ✅ Uses OpenRouter, won't be affected.

---

##### 5. Codex Block (`backend/blocks/codex.py:165`)

```python
client = AsyncOpenAI(api_key=credentials.api_key.get_secret_value())
# ❌ No base_url parameter
```

**Usage:** Code generation/modification using OpenAI Codex models
**Impact:** Medium - affects code-related workflow blocks

---

##### 6. Chat Service Summarization (`backend/api/features/chat/service.py:842`)

```python
summarization_client = openai.AsyncOpenAI(
    api_key=config.api_key,
    base_url=config.base_url,  # ✅ Already uses config.base_url
)
```

**Status:** ✅ Already supports base URL via ChatConfig.

---

### 2. Environment Variable Configuration

#### Current Configuration Files

**Backend `.env.default` (line 52):**

```bash
# AI/LLM Services
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GROQ_API_KEY=
# ... other API keys ...
```

**Missing:** No `OPENAI_BASE_URL` or `OPENAI_INTERNAL_BASE_URL` variables.

---

#### Backend Settings (`backend/util/settings.py`)

**Current Secrets Class (lines 596-599):**

```python
class Secrets(UpdateTrackingModel["Secrets"], BaseSettings):
    openai_api_key: str = Field(default="", description="OpenAI API key")
    openai_internal_api_key: str = Field(
        default="", description="OpenAI Internal API key"
    )
```

**Missing:** No base URL fields for OpenAI configuration.

---

### 3. GitHub Actions Workflows

#### Frontend E2E Workflow

**Location:** `.github/workflows/platform-frontend-ci.yml:132-138`

```yaml
- name: Copy backend .env and set OpenAI API key
  run: |
    cp ../backend/.env.default ../backend/.env
    echo "OPENAI_INTERNAL_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> ../backend/.env
  env:
    # Used by E2E test data script to generate embeddings for approved store agents
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

**Usage:** Sets `OPENAI_INTERNAL_API_KEY` for E2E test data generation (embeddings)
**Missing:** No base URL configuration for LiteLLM Proxy routing

---

### 4. LiteLLM Proxy Requirements

Based on official [LiteLLM documentation](https://docs.litellm.ai/docs/proxy/configs), the required configuration is:

#### Environment Variables

| Variable | Purpose | Example |

|----------|---------|---------|
| `LITELLM_PROXY_API_KEY` | Authentication to LiteLLM Proxy | `sk-1234` |
| `LITELLM_PROXY_API_BASE` | LiteLLM Proxy endpoint URL | `http://localhost:4000` |

#### OpenAI SDK Configuration

When using OpenAI SDK with LiteLLM Proxy:

```python
from openai import AsyncOpenAI

client = AsyncOpenAI(
    api_key="your-litellm-proxy-api-key",  # LITELLM_PROXY_API_KEY
    base_url="http://localhost:4000"       # LITELLM_PROXY_API_BASE
)
```

**Key Points:**

- The `api_key` should be the **LiteLLM Proxy API key**, not the underlying provider key
- The `base_url` points to your **self-hosted LiteLLM Proxy**
- LiteLLM Proxy handles routing to underlying providers (OpenAI, Anthropic, etc.)
- Supports standard OpenAI SDK interface (drop-in replacement)

---

## Recommendations

### Strategy: Unified Base URL Configuration

Use a **single environment variable pattern** across all OpenAI client instantiations:

**Proposed Variables:**

- `OPENAI_BASE_URL` - Base URL for standard OpenAI clients (defaults to `https://api.openai.com/v1`)
- `OPENAI_INTERNAL_BASE_URL` - Base URL for internal OpenAI clients (defaults to `OPENAI_BASE_URL`)

This allows:

1. **LiteLLM Proxy:** Set both to LiteLLM Proxy URL
2. **Native OpenAI:** Leave unset or set to OpenAI API URL
3. **Mixed usage:** Use proxy for some, native for others

---

### Implementation Plan

#### Phase 1: Backend Settings (High Priority)

**File:** `autogpt_platform/backend/backend/util/settings.py`

**Add to `Secrets` class:**

```python
class Secrets(UpdateTrackingModel["Secrets"], BaseSettings):
    # Existing fields...
    openai_api_key: str = Field(default="", description="OpenAI API key")
    openai_internal_api_key: str = Field(
        default="", description="OpenAI Internal API key"
    )

    # NEW: Base URL configuration
    openai_base_url: str = Field(
        default="https://api.openai.com/v1",
        description="Base URL for OpenAI API (or LiteLLM Proxy)"
    )
    openai_internal_base_url: str = Field(
        default="",  # Defaults to openai_base_url if not set
        description="Base URL for internal OpenAI API calls (or LiteLLM Proxy)"
    )

    @field_validator("openai_internal_base_url", mode="after")
    @classmethod
    def default_internal_base_url(cls, v, info: ValidationInfo):
        """Default to openai_base_url if internal base URL not set."""
        if not v and info.data.get("openai_base_url"):
            return info.data["openai_base_url"]
        return v or "https://api.openai.com/v1"
```

**Rationale:**

- Centralized configuration in Settings
- Maintains backward compatibility (defaults to OpenAI API)
- Allows separate control of internal vs external clients

---

#### Phase 2: Update OpenAI Client Instantiations (High Priority)

##### 2.1 Utility Client (`backend/util/clients.py`)

**Before:**

```python
@cached(ttl_seconds=3600)
def get_openai_client() -> "AsyncOpenAI | None":
    from openai import AsyncOpenAI

    api_key = settings.secrets.openai_internal_api_key
    if not api_key:
        return None
    return AsyncOpenAI(api_key=api_key)
```

**After:**

```python
@cached(ttl_seconds=3600)
def get_openai_client() -> "AsyncOpenAI | None":
    from openai import AsyncOpenAI

    api_key = settings.secrets.openai_internal_api_key
    if not api_key:
        return None
    return AsyncOpenAI(
        api_key=api_key,
        base_url=settings.secrets.openai_internal_base_url
    )
```

---

##### 2.2 LLM Block OpenAI Provider (`backend/blocks/llm.py`)

**Before (line 656):**

```python
if provider == "openai":
    oai_client = openai.AsyncOpenAI(api_key=credentials.api_key.get_secret_value())
```

**After:**

```python
if provider == "openai":
    from backend.util.settings import Settings
    settings = Settings()

    oai_client = openai.AsyncOpenAI(
        api_key=credentials.api_key.get_secret_value(),
        base_url=settings.secrets.openai_base_url
    )
```

**Alternative Approach** (if you want per-credential base URL):

Add `base_url` field to `APIKeyCredentials` model and allow users to configure it per integration. This would require:

1. Database migration to add `base_url` column to credentials table
2. UI changes to allow base URL input
3. Block configuration updates

**Recommendation:** Use global settings first (simpler), add per-credential later if needed.

---

##### 2.3 Codex Block (`backend/blocks/codex.py`)

**Before (line 165):**

```python
client = AsyncOpenAI(api_key=credentials.api_key.get_secret_value())
```

**After:**

```python
from backend.util.settings import Settings
settings = Settings()

client = AsyncOpenAI(
    api_key=credentials.api_key.get_secret_value(),
    base_url=settings.secrets.openai_base_url
)
```

---

#### Phase 3: Environment Configuration (High Priority)

##### 3.1 Backend `.env.default`

**File:** `autogpt_platform/backend/.env.default`

**Add after line 52:**

```bash
# AI/LLM Services
OPENAI_API_KEY=
OPENAI_BASE_URL=https://api.openai.com/v1

# Internal OpenAI Configuration (for embeddings, etc.)
# Defaults to OPENAI_BASE_URL if not set
# Set this to your LiteLLM Proxy URL to route all internal OpenAI calls through it
OPENAI_INTERNAL_BASE_URL=

ANTHROPIC_API_KEY=
# ... rest of API keys ...
```

**Documentation Comment to Add:**

```bash
# LiteLLM Proxy Configuration:
# To route OpenAI API calls through a self-hosted LiteLLM Proxy:
# 1. Set OPENAI_BASE_URL to your LiteLLM Proxy endpoint (e.g., http://localhost:4000)
# 2. Set OPENAI_API_KEY to your LiteLLM Proxy API key
# 3. (Optional) Set OPENAI_INTERNAL_BASE_URL if internal calls should use different endpoint
#
# For more information: https://docs.litellm.ai/docs/proxy/configs
```

---

##### 3.2 Chat Service Environment Variables

**File:** `autogpt_platform/backend/backend/api/features/chat/config.py`

**Current code already supports:**

- `CHAT_BASE_URL`
- `OPENROUTER_BASE_URL`
- `OPENAI_BASE_URL`

**Action:** Document that chat service can use LiteLLM Proxy via these variables.

---

#### Phase 4: GitHub Actions Workflows (Medium Priority)

##### 4.1 Frontend E2E Workflow

**File:** `.github/workflows/platform-frontend-ci.yml`

**Before (lines 132-138):**

```yaml
- name: Copy backend .env and set OpenAI API key
  run: |
    cp ../backend/.env.default ../backend/.env
    echo "OPENAI_INTERNAL_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> ../backend/.env
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

**After:**

```yaml
- name: Copy backend .env and set OpenAI API key
  run: |
    cp ../backend/.env.default ../backend/.env
    echo "OPENAI_INTERNAL_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> ../backend/.env
    if [ -n "${{ secrets.LITELLM_PROXY_URL }}" ]; then
      echo "OPENAI_INTERNAL_BASE_URL=${{ secrets.LITELLM_PROXY_URL }}" >> ../backend/.env
    fi
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

**New GitHub Secrets Required:**

- `LITELLM_PROXY_URL` - URL of self-hosted LiteLLM Proxy (optional)

**Rationale:**

- Backward compatible - only applies if `LITELLM_PROXY_URL` secret is set
- Allows CI to use LiteLLM Proxy for E2E tests
- No changes needed if continuing to use native OpenAI

---

#### Phase 5: Documentation (Low Priority)

##### 5.1 Update CLAUDE.md

**File:** `autogpt_platform/CLAUDE.md`

**Add section under "Environment Configuration":**

```markdown
#### LiteLLM Proxy Configuration

The platform supports routing OpenAI API calls through a self-hosted LiteLLM Proxy.

**Environment Variables:**
- `OPENAI_BASE_URL` - Base URL for OpenAI API calls (default: `https://api.openai.com/v1`)
- `OPENAI_INTERNAL_BASE_URL` - Base URL for internal OpenAI calls (default: same as `OPENAI_BASE_URL`)

**To use LiteLLM Proxy:**
1. Deploy your LiteLLM Proxy instance
2. Set `OPENAI_BASE_URL=http://your-litellm-proxy:4000` in `backend/.env`
3. Set `OPENAI_API_KEY` to your LiteLLM Proxy API key
4. All OpenAI SDK calls will route through your proxy

**Components affected:**
- LLM blocks (OpenAI provider)
- Embeddings generation (`get_openai_client()`)
- Codex code generation blocks
- Chat service (already supports via `CHAT_BASE_URL`)

For more information: [LiteLLM Proxy Documentation](https://docs.litellm.ai/docs/proxy/configs)
```

---

##### 5.2 Create Migration Guide

**File:** `docs/LITELLM_PROXY_MIGRATION.md` (new file)

```markdown
# LiteLLM Proxy Migration Guide

## Overview

This guide explains how to configure AutoGPT Platform to use a self-hosted LiteLLM Proxy instead of native OpenAI API calls.

## Prerequisites

- Self-hosted LiteLLM Proxy deployed and running
- LiteLLM Proxy API key
- LiteLLM Proxy endpoint URL

## Configuration Steps

### 1. Update Backend Environment

Edit `autogpt_platform/backend/.env`:

```bash
# LiteLLM Proxy Configuration
OPENAI_BASE_URL=http://your-litellm-proxy:4000
OPENAI_API_KEY=your-litellm-proxy-api-key

# Optional: Separate internal base URL
OPENAI_INTERNAL_BASE_URL=http://your-litellm-proxy:4000
```

### 2. Update Chat Service (if needed)

The chat service supports additional base URL variables:

```bash
CHAT_BASE_URL=http://your-litellm-proxy:4000
CHAT_API_KEY=your-litellm-proxy-api-key
```

### 3. Docker Compose (if applicable)

No changes needed - environment variables are loaded automatically.

### 4. GitHub Actions (CI/CD)

Add GitHub repository secrets:

- `LITELLM_PROXY_URL` - Your LiteLLM Proxy endpoint
- `OPENAI_API_KEY` - Your LiteLLM Proxy API key

### 5. Verify Configuration

Test that LiteLLM Proxy is working:

```bash
# Start backend
cd autogpt_platform
mise run backend

# Check logs for base URL
# Should show: "Using OpenAI base URL: http://your-litellm-proxy:4000"
```

## Rollback

To revert to native OpenAI:

1. Remove `OPENAI_BASE_URL` from `.env` (or set to `https://api.openai.com/v1`)
2. Set `OPENAI_API_KEY` to your native OpenAI API key
3. Restart backend services

## Troubleshooting

**Issue:** "Connection refused" errors

**Solution:** Verify LiteLLM Proxy is running and accessible from backend container.

**Issue:** "Authentication failed" errors

**Solution:** Verify `OPENAI_API_KEY` matches your LiteLLM Proxy API key.

## References

- [LiteLLM Proxy Documentation](https://docs.litellm.ai/docs/proxy/configs)
- [LiteLLM Quick Start](https://docs.litellm.ai/docs/proxy/quick_start)

---

## Testing Strategy

### Unit Tests

**File:** `autogpt_platform/backend/backend/util/test/test_clients.py` (new file)

```python
import pytest
from unittest.mock import patch, MagicMock
from backend.util.clients import get_openai_client
from backend.util.settings import Settings

def test_openai_client_uses_base_url():
    """Test that OpenAI client uses configured base URL."""
    with patch("backend.util.clients.settings") as mock_settings:
        mock_settings.secrets.openai_internal_api_key = "test-key"
        mock_settings.secrets.openai_internal_base_url = "http://litellm-proxy:4000"

        client = get_openai_client()

        assert client is not None
        assert client.base_url == "http://litellm-proxy:4000"
        assert client.api_key == "test-key"

def test_openai_client_defaults_to_openai_api():
    """Test that OpenAI client defaults to OpenAI API if no base URL set."""
    with patch("backend.util.clients.settings") as mock_settings:
        mock_settings.secrets.openai_internal_api_key = "test-key"
        mock_settings.secrets.openai_internal_base_url = ""

        client = get_openai_client()

        assert client is not None
        # Should default to OpenAI API
        assert "openai.com" in str(client.base_url)
```

---

### Integration Tests

**File:** `autogpt_platform/backend/test/test_litellm_integration.py` (new file)

```python
import pytest
import asyncio
from backend.blocks.llm import llm_call, LlmModel
from backend.data.model import APIKeyCredentials
from pydantic import SecretStr

@pytest.mark.integration
@pytest.mark.asyncio
async def test_llm_block_with_litellm_proxy():
    """Integration test for LLM block with LiteLLM Proxy."""
    # This test requires OPENAI_BASE_URL to be set to LiteLLM Proxy
    credentials = APIKeyCredentials(
        id="test-id",
        provider="openai",
        api_key=SecretStr("test-key"),
        title="Test OpenAI",
        expires_at=None,
    )

    prompt = [{"role": "user", "content": "Say 'test'"}]

    response = await llm_call(
        credentials=credentials,
        llm_model=LlmModel.GPT4O_MINI,
        prompt=prompt,
        max_tokens=10,
    )

    assert response.response is not None
    assert len(response.response) > 0
```

---

### Manual Testing Checklist

- [ ] **Chat Service:** Verify chat works with LiteLLM Proxy URL
- [ ] **LLM Blocks:** Test OpenAI model blocks route through proxy
- [ ] **Embeddings:** Verify store agent search uses proxy for embeddings
- [ ] **Codex Blocks:** Test code generation blocks work with proxy
- [ ] **E2E Tests:** Run frontend E2E tests with proxy configuration
- [ ] **Rollback:** Verify switching back to native OpenAI works

---

## Migration Timeline

| Phase | Priority | Effort | Dependencies |

|-------|----------|--------|--------------|
| **Phase 1:** Backend Settings | High | 1 hour | None |
| **Phase 2:** Client Updates | High | 2-3 hours | Phase 1 |
| **Phase 3:** Environment Config | High | 30 min | Phase 1 |
| **Phase 4:** CI/CD Workflows | Medium | 1 hour | Phase 2, 3 |
| **Phase 5:** Documentation | Low | 2 hours | Phase 2, 3 |
| **Testing** | High | 3-4 hours | All phases |

**Total Estimated Effort:** 9-11 hours

---

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |

|------|--------|-------------|------------|
| Breaking existing OpenAI integrations | High | Low | Default to OpenAI API URL, backward compatible |
| LiteLLM Proxy downtime affects all LLM calls | High | Medium | Document rollback procedure, monitor proxy health |
| Performance degradation through proxy | Medium | Low | Benchmark before/after, optimize proxy configuration |
| API key confusion (proxy vs native) | Medium | Medium | Clear naming (`LITELLM_PROXY_API_KEY` in docs) |
| E2E tests fail with proxy | Medium | Low | Make proxy optional in CI via secret check |

---

## Sources

Research sources used for this report:

- [All settings | liteLLM](https://docs.litellm.ai/docs/proxy/config_settings)
- [Overview | liteLLM](https://docs.litellm.ai/docs/proxy/configs)
- [LiteLLM Proxy (LLM Gateway)](https://docs.litellm.ai/docs/providers/litellm_proxy)
- [Quick Start - LiteLLM Proxy CLI](https://docs.litellm.ai/docs/proxy/quick_start)
- [LiteLLM - Getting Started](https://docs.litellm.ai/docs/)
- [Docker, Helm, Terraform | liteLLM](https://docs.litellm.ai/docs/proxy/deploy)

---

## Appendix: Code Locations Reference

### Files to Modify

1. **Settings:** `autogpt_platform/backend/backend/util/settings.py`
2. **Utility Client:** `autogpt_platform/backend/backend/util/clients.py`
3. **LLM Block:** `autogpt_platform/backend/backend/blocks/llm.py`
4. **Codex Block:** `autogpt_platform/backend/backend/blocks/codex.py`
5. **Backend .env:** `autogpt_platform/backend/.env.default`
6. **Frontend E2E Workflow:** `.github/workflows/platform-frontend-ci.yml`
7. **Documentation:** `autogpt_platform/CLAUDE.md`

### Files Already Compatible

1. **Chat Service:** `autogpt_platform/backend/backend/api/features/chat/service.py` ✅
2. **Chat Config:** `autogpt_platform/backend/backend/api/features/chat/config.py` ✅
3. **Perplexity Block:** `autogpt_platform/backend/backend/blocks/perplexity.py` ✅ (uses OpenRouter)
4. **Other Providers:** AIML, Open Router, Llama API, V0 (all use custom base URLs)

---

## Next Steps

1. **Review & Approve** this research report
2. **Implement Phase 1-3** (backend settings, client updates, environment config)
3. **Test locally** with your LiteLLM Proxy instance
4. **Implement Phase 4** (CI/CD workflows) after local validation
5. **Create documentation** (Phase 5)
6. **Monitor production** for performance/stability after deployment

---

**Report Confidence:** High
**Completeness:** Comprehensive (all OpenAI client locations identified)
**Validation:** Cross-referenced with LiteLLM official documentation
