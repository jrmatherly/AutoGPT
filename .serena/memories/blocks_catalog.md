# Blocks Catalog Quick Reference

Blocks are the fundamental building units of agent workflows. Each block performs a specific task and can be connected in a visual graph editor.

**Complete catalog:** [docs/BLOCK_SDK.md](../../docs/BLOCK_SDK.md)

## Block Categories (224+ blocks)

### AI & LLM
Multi-provider LLM calls, AI conditions, smart decisions, Perplexity search, Claude Code, image/video/music generation
- **Location:** `backend/blocks/llm.py`, `ai_*.py`, `claude_code.py`, etc.

### Social Media
**Twitter/X:** Tweets, DMs, lists, timelines, likes, retweets, follows, spaces  
**Discord:** Bot operations, OAuth integration  
**Multi-Platform (Ayrshare):** Instagram, TikTok, LinkedIn, Facebook, YouTube, Pinterest, Threads, Telegram, Bluesky, Reddit, Snapchat
- **Location:** `backend/blocks/twitter/`, `discord/`, `ayrshare/`, `reddit.py`

### Productivity
**Google:** Sheets, Docs, Calendar, Gmail, Drive  
**Notion:** Pages, databases, search  
**Airtable:** Records, bases, schemas, triggers  
**Todoist:** Tasks, projects, labels  
**Linear:** Issues, projects, comments  
**HubSpot:** Contacts, companies, engagements
- **Location:** `backend/blocks/google/`, `notion/`, `airtable/`, `todoist/`, `linear/`, `hubspot/`

### Developer Tools
**GitHub:** Issues, PRs, reviews, CI, webhooks  
**Firecrawl:** Scraping, crawling, extraction  
**Exa:** Web search, research, code context
- **Location:** `backend/blocks/github/`, `firecrawl/`, `exa/`

### Data & Control Flow
Basic operations, text manipulation, iteration, branching, sampling, math, time/date utilities, XML parsing
- **Location:** `backend/blocks/basic.py`, `text.py`, `iteration.py`, `branching.py`, etc.

### I/O & Communication
HTTP requests, email, RSS feeds, input/output blocks
- **Location:** `backend/blocks/http.py`, `email_block.py`, `rss.py`, `io.py`

### Storage & Persistence
Data persistence, spreadsheets, vector databases (Pinecone), memory management (Mem0)
- **Location:** `backend/blocks/persistence.py`, `spreadsheet.py`, `pinecone.py`, `mem0.py`

### AI Services
**Replicate:** AI model execution, Flux  
**Fal:** Video generation  
**Jina:** Search, embeddings, chunking, fact checking
- **Location:** `backend/blocks/replicate/`, `fal/`, `jina/`

### Specialized Services
Apollo (sales), Smartlead (email), DataForSEO, Wolfram, Bannerbear, ZeroBounce, EnrichLayer, Nvidia (deepfake detection), Slant3D (3D print), Stagehand (browser automation)
- **Location:** `backend/blocks/{service}/`

### System
Agent execution, human-in-the-loop, store operations, library operations, generic webhooks
- **Location:** `backend/blocks/agent.py`, `human_in_the_loop.py`, `system/`, `generic_webhook/`

## Creating a New Block

```python
from backend.data.block import Block, BlockSchema, SchemaField, BlockCategory
import uuid

class MyBlock(Block):
    id = str(uuid.uuid4())  # Generate unique ID
    
    class Input(BlockSchema):
        query: str = SchemaField(description="Input query")
    
    class Output(BlockSchema):
        result: str = SchemaField(description="Output result")
    
    def __init__(self):
        super().__init__(
            name="My Block",
            description="Does something useful",
            categories=[BlockCategory.TEXT],
        )
    
    async def run(self, input_data: Input, **kwargs) -> Output:
        # Implementation
        return Output(result="...")
```

## Testing Blocks

```bash
# Test all blocks
poetry run pytest backend/blocks/test/test_block.py -xvs

# Test specific block
poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[MyBlock]' -xvs
```

**For detailed block development:** See [docs/BLOCK_SDK.md](../../docs/BLOCK_SDK.md)
