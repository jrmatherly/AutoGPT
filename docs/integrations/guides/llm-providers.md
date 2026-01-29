# LLM Providers

AutoGPT supports 9 different LLM providers with 100+ models, giving you flexibility to choose the right model for your use case based on performance, cost, and capabilities.

## Provider Overview

| Provider      | Models | Key Features                             | Best For                          |
| ------------- | ------ | ---------------------------------------- | --------------------------------- |
| **OpenAI**    | 15+    | Latest GPT-5, O-series reasoning models  | Production apps, complex reasoning |
| **Anthropic** | 8      | Claude 4.5 series, long context (200K)   | Analysis, coding, research        |
| **Groq**      | 2      | Ultra-fast inference with Llama models   | High-throughput applications      |
| **Ollama**    | 5      | Local deployment, no API costs           | Privacy-sensitive, offline use    |
| **OpenRouter**| 30+    | Unified access to multiple providers     | Model experimentation, fallback   |
| **AI/ML API** | 5      | Enterprise Llama variants                | Cost-effective production         |
| **Llama API** | 4      | Official Meta-hosted Llama models        | Meta ecosystem integration        |
| **V0**        | 3      | Vercel's UI generation models            | Frontend development              |

---

## OpenAI

The leading commercial LLM provider with the most advanced models available.

### Available Models

**O-Series (Reasoning Models)**
- `o3` - Most advanced reasoning model (200K context, 100K output)
- `o3-mini` - Faster reasoning model (200K context, 100K output)
- `o1` - Production reasoning model (200K context, 100K output)
- `o1-mini` - Cost-effective reasoning (128K context, 65K output)

**GPT-5 Series**
- `gpt-5.2-2025-12-11` - Latest GPT-5 variant (400K context)
- `gpt-5.1-2025-11-13` - GPT-5.1 (400K context)
- `gpt-5-2025-08-07` - Base GPT-5 (400K context)
- `gpt-5-mini-2025-08-07` - Smaller GPT-5 (400K context)
- `gpt-5-nano-2025-08-07` - Fastest GPT-5 (400K context)
- `gpt-5-chat-latest` - Optimized for chat (400K context)

**GPT-4 Series**
- `gpt-4.1-2025-04-14` - GPT-4.1 (1M context)
- `gpt-4.1-mini-2025-04-14` - Smaller GPT-4.1 (1M context)
- `gpt-4o` - Optimized GPT-4 (128K context)
- `gpt-4o-mini` - Cost-effective GPT-4 (128K context)
- `gpt-4-turbo` - Fast GPT-4 (128K context)
- `gpt-3.5-turbo` - Legacy model (16K context)

### Setup

1. Get API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. In AutoGPT, select any OpenAI model from the AI blocks
3. Add your OpenAI credentials when prompted

### Use Cases

- **O-series**: Complex reasoning, math, coding challenges, scientific analysis
- **GPT-5**: Production applications requiring latest capabilities
- **GPT-4**: Balanced performance and cost for most use cases
- **GPT-3.5**: High-volume, simple tasks

---

## Anthropic

Provider of Claude models known for extended context windows and strong coding capabilities.

### Available Models

**Claude 4.5 Series (Latest)**
- `claude-opus-4-5-20251101` - Most capable (200K context, 64K output)
- `claude-sonnet-4-5-20250929` - Balanced performance (200K context, 64K output)
- `claude-haiku-4-5-20251001` - Fast and efficient (200K context, 64K output)

**Claude 4 Series**
- `claude-opus-4-1-20250805` - Claude 4.1 Opus (200K context)
- `claude-opus-4-20250514` - Claude 4 Opus (200K context)
- `claude-sonnet-4-20250514` - Claude 4 Sonnet (200K context)

**Claude 3 Series**
- `claude-3-7-sonnet-20250219` - Claude 3.7 Sonnet (200K context)
- `claude-3-haiku-20240307` - Fast Claude 3 (200K context)

### Setup

1. Get API key from [Anthropic Console](https://console.anthropic.com/)
2. Select any Claude model from the AI blocks
3. Add your Anthropic credentials when prompted

### Use Cases

- **Opus**: Research, analysis, complex coding projects
- **Sonnet**: General-purpose development, content creation
- **Haiku**: High-volume tasks, real-time applications

---

## Groq

Ultra-fast inference provider using specialized hardware for open-source models.

### Available Models

- `llama-3.3-70b-versatile` - Llama 3.3 70B (128K context, 32K output)
- `llama-3.1-8b-instant` - Llama 3.1 8B (128K context, 8K output)

### Setup

1. Get API key from [Groq Console](https://console.groq.com/)
2. Select a Groq model from the AI blocks
3. Add your Groq credentials when prompted

### Use Cases

- High-throughput applications requiring fast responses
- Real-time conversational AI
- Cost-effective alternative to commercial models
- Applications needing predictable latency

---

## Ollama

Run LLMs locally on your own hardware without API costs or internet dependency.

### Available Models

- `llama3.3` - Llama 3.3 (8K context)
- `llama3.2` - Llama 3.2 (8K context)
- `llama3` - Llama 3 8B (8K context)
- `llama3.1:405b` - Llama 3.1 405B (8K context)
- `dolphin-mistral:latest` - Dolphin Mistral (32K context)

### Setup

1. Install Ollama from [ollama.com](https://ollama.com/)
2. Pull models: `ollama pull llama3.3`
3. Start Ollama service: `ollama serve`
4. Select Ollama models from AI blocks (no API key needed)

### Use Cases

- Privacy-sensitive applications (healthcare, legal, finance)
- Offline environments without internet access
- Development and testing without API costs
- Full control over model deployment

---

## OpenRouter

Unified API providing access to 30+ models from multiple providers with a single API key.

### Available Models

**Google Models**
- `google/gemini-2.5-pro-preview-03-25` - Gemini 2.5 Pro (1M context)
- `google/gemini-3-pro-preview` - Gemini 3 Pro (1M context)
- `google/gemini-2.5-flash` - Gemini 2.5 Flash (1M context)
- `google/gemini-2.0-flash-001` - Gemini 2.0 Flash (1M context)
- `google/gemini-2.5-flash-lite-preview-06-17` - Gemini Flash Lite (1M context)
- `google/gemini-2.0-flash-lite-001` - Gemini 2.0 Flash Lite (1M context)

**OpenAI Models**
- `openai/gpt-oss-120b` - GPT-OSS 120B (131K context)
- `openai/gpt-oss-20b` - GPT-OSS 20B (131K context)

**Meta Models**
- `meta-llama/llama-4-scout` - Llama 4 Scout (131K context)
- `meta-llama/llama-4-maverick` - Llama 4 Maverick (1M context)

**xAI Models**
- `x-ai/grok-4` - Grok 4 (256K context)
- `x-ai/grok-4-fast` - Grok 4 Fast (2M context)
- `x-ai/grok-4.1-fast` - Grok 4.1 Fast (2M context)
- `x-ai/grok-code-fast-1` - Grok Code Fast (256K context)

**DeepSeek Models**
- `deepseek/deepseek-chat` - DeepSeek V3 (64K context)
- `deepseek/deepseek-r1-0528` - DeepSeek R1 (163K context)

**Perplexity Models**
- `perplexity/sonar` - Sonar (127K context)
- `perplexity/sonar-pro` - Sonar Pro (200K context)
- `perplexity/sonar-deep-research` - Deep Research (128K context)

**Other Models**
- `mistralai/mistral-nemo` - Mistral Nemo (128K context)
- `cohere/command-r-08-2024` - Command R (128K context)
- `cohere/command-r-plus-08-2024` - Command R Plus (128K context)
- `amazon/nova-lite-v1` - Amazon Nova Lite (300K context)
- `amazon/nova-micro-v1` - Amazon Nova Micro (128K context)
- `amazon/nova-pro-v1` - Amazon Nova Pro (300K context)
- `nousresearch/hermes-3-llama-3.1-405b` - Hermes 3 405B (131K context)
- `nousresearch/hermes-3-llama-3.1-70b` - Hermes 3 70B (12K context)
- `microsoft/wizardlm-2-8x22b` - WizardLM 2 8x22B (65K context)
- `moonshotai/kimi-k2` - Kimi K2 (131K context)
- `qwen/qwen3-235b-a22b-thinking-2507` - Qwen 3 Thinking (262K context)
- `qwen/qwen3-coder` - Qwen 3 Coder (262K context)
- `gryphe/mythomax-l2-13b` - MythoMax L2 13B (4K context)

### Setup

1. Get API key from [OpenRouter](https://openrouter.ai/keys)
2. Select any OpenRouter model from the AI blocks
3. Add your OpenRouter credentials when prompted

### Use Cases

- Model comparison and evaluation
- Fallback routing when primary provider is down
- Access to latest models from multiple providers
- Cost optimization through dynamic routing

---

## AI/ML API

Enterprise-focused provider offering optimized variants of popular open-source models.

### Available Models

- `Qwen/Qwen2.5-72B-Instruct-Turbo` - Qwen 2.5 72B (32K context)
- `nvidia/llama-3.1-nemotron-70b-instruct` - Nvidia Llama 3.1 70B (128K context)
- `meta-llama/Llama-3.3-70B-Instruct-Turbo` - Llama 3.3 70B (128K context)
- `meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo` - Llama 3.1 70B (131K context)
- `meta-llama/Llama-3.2-3B-Instruct-Turbo` - Llama 3.2 3B (128K context)

### Setup

1. Get API key from [AI/ML API](https://aimlapi.com/)
2. Select any AI/ML API model from the AI blocks
3. Add your AI/ML API credentials when prompted

### Use Cases

- Enterprise deployments requiring support
- Cost-effective access to Llama and Qwen models
- High-reliability production workloads
- Custom model fine-tuning and deployment

---

## Llama API

Official Meta-hosted API service for Llama models with OpenAI-compatible endpoints.

### Available Models

- `Llama-4-Scout-17B-16E-Instruct-FP8` - Llama 4 Scout (128K context)
- `Llama-4-Maverick-17B-128E-Instruct-FP8` - Llama 4 Maverick (128K context)
- `Llama-3.3-8B-Instruct` - Llama 3.3 8B (128K context)
- `Llama-3.3-70B-Instruct` - Llama 3.3 70B (128K context)

### Setup

1. Join the [waitlist](https://llama.developer.meta.com/?utm_source=partner-autogpt&utm_medium=readme) for access
2. Get API key from Llama API dashboard
3. Select any Llama API model from the AI blocks
4. Add your Llama API credentials when prompted

### Use Cases

- Direct access to latest Meta Llama models
- OpenAI-compatible API integration
- Meta ecosystem integration
- Official support from Meta

---

## V0 by Vercel

Specialized models for generating UI components and frontend code.

### Available Models

- `v0-1.5-md` - V0 1.5 Medium (128K context, 64K output)
- `v0-1.5-lg` - V0 1.5 Large (512K context, 64K output)
- `v0-1.0-md` - V0 1.0 Medium (128K context, 64K output)

### Setup

1. Get API key from [Vercel V0](https://v0.dev)
2. Select a V0 model from the AI blocks
3. Add your V0 credentials when prompted

### Use Cases

- Frontend component generation
- UI/UX prototyping
- React/Next.js code generation
- Design-to-code workflows

---

## Model Selection Guide

### By Use Case

**Complex Reasoning & Math**
- OpenAI O-series (o3, o1)
- DeepSeek R1 (via OpenRouter)
- Qwen 3 Thinking (via OpenRouter)

**Long Context (>100K tokens)**
- OpenAI GPT-5 (400K), GPT-4.1 (1M)
- Anthropic Claude (200K)
- Google Gemini (1M+ via OpenRouter)
- xAI Grok 4 Fast (2M via OpenRouter)

**Coding & Development**
- Anthropic Claude Sonnet/Opus
- OpenAI GPT-4o/GPT-5
- Qwen 3 Coder (via OpenRouter)
- V0 (for UI/frontend)

**Cost-Effective Production**
- OpenAI GPT-4o-mini
- Anthropic Claude Haiku
- Groq Llama models
- AI/ML API Llama variants

**Privacy & Local Deployment**
- Ollama (all models)

**High Throughput**
- Groq (ultra-fast inference)
- OpenAI GPT-4o-mini
- Anthropic Claude Haiku

### By Context Window

| Context Need      | Recommended Models                    |
| ----------------- | ------------------------------------- |
| <50K tokens       | GPT-4o-mini, Claude Haiku, Groq Llama |
| 50-200K tokens    | GPT-4o, Claude Sonnet, Llama 3.3      |
| 200K-500K tokens  | GPT-5, Claude Opus, Gemini Flash      |
| 500K-1M tokens    | GPT-4.1, Gemini Pro                   |
| >1M tokens        | Gemini 3 Pro, Grok 4 Fast             |

### By Price Tier

**Tier 1 (Most Affordable)**
- Groq: Llama models
- Ollama: All models (self-hosted)
- AI/ML API: Llama/Qwen models
- OpenAI: GPT-4o-mini, GPT-3.5-turbo
- Anthropic: Claude Haiku

**Tier 2 (Balanced)**
- OpenAI: GPT-4o, O3-mini, GPT-5.1
- Anthropic: Claude Sonnet
- OpenRouter: Most models

**Tier 3 (Premium)**
- OpenAI: O3, GPT-5.2, GPT-4 Turbo
- Anthropic: Claude Opus
- OpenRouter: Grok 4, Qwen 3 Coder
- Perplexity: Sonar Deep Research

---

## Getting Help

- **Model not working?** Check your API key has sufficient credits/permissions
- **Context limit errors?** Use a model with larger context window
- **Cost optimization?** Consider Groq, Ollama, or tier 1 models
- **Latest models?** Check [AutoGPT blocks documentation](../../integrations/README.md) for updates

---

## Additional Resources

- [OpenAI Platform Docs](https://platform.openai.com/docs)
- [Anthropic Claude Docs](https://docs.anthropic.com/)
- [Groq Documentation](https://console.groq.com/docs)
- [Ollama Model Library](https://ollama.com/library)
- [OpenRouter Models](https://openrouter.ai/models)
- [AutoGPT Block SDK Guide](../../BLOCK_SDK.md)
