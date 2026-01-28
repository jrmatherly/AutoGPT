# AutoGPT Blocks Catalog

Blocks are the fundamental building units of agent workflows. Each block performs a specific task and can be connected to other blocks in a visual graph editor.

## Block Categories

### AI & LLM Blocks

| Block | File | Description |
|-------|------|-------------|
| LLM | `llm.py` | Multi-provider LLM calls (OpenAI, Anthropic, Groq, Ollama) |
| AI Condition | `ai_condition.py` | AI-based conditional branching |
| Smart Decision Maker | `smart_decision_maker.py` | Intelligent multi-option decisions |
| Perplexity | `perplexity.py` | Perplexity AI search and Q&A |
| Claude Code | `claude_code.py` | Claude Code integration |
| Codex | `codex.py` | Code generation and analysis |
| AI Image Generator | `ai_image_generator_block.py` | Generate images with AI |
| AI Image Customizer | `ai_image_customizer.py` | Modify images with AI |

### Media Generation

| Block | File | Description |
|-------|------|-------------|
| AI Short Video | `ai_shortform_video_block.py` | Generate short-form videos |
| AI Music | `ai_music_generator.py` | Generate music |
| Text to Speech | `text_to_speech_block.py` | Convert text to audio |
| Talking Head | `talking_head.py` | Create talking head videos |
| Flux Kontext | `flux_kontext.py` | Flux image generation |
| Ideogram | `ideogram.py` | Ideogram image generation |

### Social Media Integrations

#### Twitter/X (`twitter/`)
| Block | File | Description |
|-------|------|-------------|
| Tweet Management | `tweets/manage.py` | Create, delete tweets |
| Tweet Lookup | `tweets/tweet_lookup.py` | Get tweet details |
| Timeline | `tweets/timeline.py` | Get user timelines |
| Like/Unlike | `tweets/like.py` | Like/unlike tweets |
| Retweet | `tweets/retweet.py` | Retweet management |
| Bookmark | `tweets/bookmark.py` | Bookmark management |
| Quote Tweet | `tweets/quote.py` | Quote tweets |
| User Lookup | `users/user_lookup.py` | Get user info |
| Follows | `users/follows.py` | Follow/unfollow users |
| Mutes/Blocks | `users/mutes.py`, `blocks.py` | User moderation |
| Direct Messages | `direct_message/` | DM operations |
| Lists | `lists/` | Twitter list operations |
| Spaces | `spaces/` | Twitter Spaces lookup |

#### Discord (`discord/`)
| Block | File | Description |
|-------|------|-------------|
| Bot Blocks | `bot_blocks.py` | Discord bot operations |
| OAuth Blocks | `oauth_blocks.py` | Discord OAuth integration |

#### Reddit
| Block | File | Description |
|-------|------|-------------|
| Reddit | `reddit.py` | Reddit API integration |

#### Multi-Platform (Ayrshare) (`ayrshare/`)
| Block | File | Description |
|-------|------|-------------|
| Post to Instagram | `post_to_instagram.py` | Instagram posting |
| Post to TikTok | `post_to_tiktok.py` | TikTok posting |
| Post to LinkedIn | `post_to_linkedin.py` | LinkedIn posting |
| Post to Facebook | `post_to_facebook.py` | Facebook posting |
| Post to X | `post_to_x.py` | X/Twitter posting |
| Post to YouTube | `post_to_youtube.py` | YouTube posting |
| Post to Pinterest | `post_to_pinterest.py` | Pinterest posting |
| Post to Threads | `post_to_threads.py` | Threads posting |
| Post to Telegram | `post_to_telegram.py` | Telegram posting |
| Post to Bluesky | `post_to_bluesky.py` | Bluesky posting |
| Post to Reddit | `post_to_reddit.py` | Reddit posting |
| Post to Snapchat | `post_to_snapchat.py` | Snapchat posting |
| Post to GMB | `post_to_gmb.py` | Google My Business |

### Productivity Integrations

#### Google (`google/`)
| Block | File | Description |
|-------|------|-------------|
| Sheets | `sheets.py` | Google Sheets operations |
| Docs | `docs.py` | Google Docs operations |
| Calendar | `calendar.py` | Google Calendar events |
| Gmail | `gmail.py` | Email operations |

#### Notion (`notion/`)
| Block | File | Description |
|-------|------|-------------|
| Create Page | `create_page.py` | Create Notion pages |
| Read Page | `read_page.py` | Read page content |
| Read Page Markdown | `read_page_markdown.py` | Get page as markdown |
| Read Database | `read_database.py` | Query databases |
| Search | `search.py` | Search Notion |

#### Airtable (`airtable/`)
| Block | File | Description |
|-------|------|-------------|
| Records | `records.py` | CRUD operations |
| Bases | `bases.py` | Base management |
| Schema | `schema.py` | Schema operations |
| Triggers | `triggers.py` | Webhook triggers |

#### Todoist (`todoist/`)
| Block | File | Description |
|-------|------|-------------|
| Tasks | `tasks.py` | Task management |
| Projects | `projects.py` | Project management |
| Sections | `sections.py` | Section management |
| Labels | `labels.py` | Label management |
| Comments | `comments.py` | Comment management |

#### Linear (`linear/`)
| Block | File | Description |
|-------|------|-------------|
| Issues | `issues.py` | Issue management |
| Projects | `projects.py` | Project management |
| Comments | `comment.py` | Issue comments |

#### HubSpot (`hubspot/`)
| Block | File | Description |
|-------|------|-------------|
| Contacts | `contact.py` | Contact management |
| Companies | `company.py` | Company management |
| Engagements | `engagement.py` | Engagement tracking |

### Developer Tools

#### GitHub (`github/`)
| Block | File | Description |
|-------|------|-------------|
| Issues | `issues.py` | Issue operations |
| Pull Requests | `pull_requests.py` | PR operations |
| Reviews | `reviews.py` | Code review operations |
| CI | `ci.py` | CI/CD operations |
| Checks | `checks.py` | Check status |
| Statuses | `statuses.py` | Commit statuses |
| Repo | `repo.py` | Repository operations |
| Triggers | `triggers.py` | Webhook triggers |

#### Firecrawl (`firecrawl/`)
| Block | File | Description |
|-------|------|-------------|
| Scrape | `scrape.py` | Scrape single page |
| Crawl | `crawl.py` | Crawl website |
| Search | `search.py` | Search and scrape |
| Map | `map.py` | Map site structure |
| Extract | `extract.py` | Extract structured data |

#### Exa (`exa/`)
| Block | File | Description |
|-------|------|-------------|
| Search | `search.py` | Web search |
| Research | `research.py` | Deep research |
| Similar | `similar.py` | Find similar content |
| Contents | `contents.py` | Get page contents |
| Answers | `answers.py` | Get answers |
| Websets | `websets*.py` | Webset management |
| Code Context | `code_context.py` | Code context search |

### Data & Control Flow

| Block | File | Description |
|-------|------|-------------|
| Basic Operations | `basic.py` | Basic data operations |
| Text | `text.py` | String manipulation |
| Data Manipulation | `data_manipulation.py` | Data transformations |
| Iteration | `iteration.py` | Loops and iteration |
| Branching | `branching.py` | Conditional branching |
| Sampling | `sampling.py` | Random sampling |
| Maths | `maths.py` | Mathematical operations |
| Time Blocks | `time_blocks.py` | Date/time utilities |
| Count Words/Chars | `count_words_and_char_block.py` | Text counting |
| Code Extraction | `code_extraction_block.py` | Extract code blocks |
| XML Parser | `xml_parser.py` | Parse XML data |
| Decoder | `decoder_block.py` | Decode various formats |

### I/O & Communication

| Block | File | Description |
|-------|------|-------------|
| IO | `io.py` | Input/output blocks |
| HTTP | `http.py` | HTTP requests |
| Email | `email_block.py` | Send emails |
| RSS | `rss.py` | RSS feed parsing |

### Storage & Persistence

| Block | File | Description |
|-------|------|-------------|
| Persistence | `persistence.py` | Data persistence |
| Spreadsheet | `spreadsheet.py` | Spreadsheet operations |
| Pinecone | `pinecone.py` | Vector database |
| Mem0 | `mem0.py` | Memory management |

### External Services

| Block | File | Description |
|-------|------|-------------|
| Google Maps | `google_maps.py` | Maps and geocoding |
| Screenshotone | `screenshotone.py` | Website screenshots |
| YouTube | `youtube.py` | YouTube data |
| Medium | `medium.py` | Medium publishing |
| WordPress | `wordpress/blog.py` | WordPress publishing |

### AI Services

#### Replicate (`replicate/`)
| Block | File | Description |
|-------|------|-------------|
| Replicate | `replicate_block.py` | Run Replicate models |
| Flux Advanced | `flux_advanced.py` | Advanced Flux models |

#### Fal (`fal/`)
| Block | File | Description |
|-------|------|-------------|
| AI Video Generator | `ai_video_generator.py` | Fal video generation |

#### Jina (`jina/`)
| Block | File | Description |
|-------|------|-------------|
| Search | `search.py` | Jina search |
| Embeddings | `embeddings.py` | Generate embeddings |
| Chunking | `chunking.py` | Text chunking |
| Fact Checker | `fact_checker.py` | Fact verification |

### Specialized Services

| Integration | Path | Description |
|-------------|------|-------------|
| Apollo | `apollo/` | Sales intelligence |
| Smartlead | `smartlead/` | Email campaigns |
| DataForSEO | `dataforseo/` | SEO keyword data |
| Wolfram | `wolfram/` | Computational intelligence |
| Bannerbear | `bannerbear/` | Image automation |
| ZeroBounce | `zerobounce/` | Email validation |
| EnrichLayer | `enrichlayer/` | Data enrichment |
| Nvidia | `nvidia/` | Deepfake detection |
| Slant3D | `slant3d/` | 3D printing |
| Compass | `compass/` | Navigation triggers |
| Stagehand | `stagehand/` | Browser automation |
| BaaS | `baas/` | Bot-as-a-Service |

### System Blocks

| Block | Path | Description |
|-------|------|-------------|
| Agent | `agent.py` | Execute nested agents |
| Human in the Loop | `human_in_the_loop.py` | Require human approval |
| Store Operations | `system/store_operations.py` | Store system ops |
| Library Operations | `system/library_operations.py` | Library system ops |
| Generic Webhook | `generic_webhook/` | Custom webhooks |

## Creating a New Block

```python
from backend.data.block import Block, BlockSchema, SchemaField
import uuid

class MyCustomBlock(Block):
    id = str(uuid.uuid4())  # Generate unique ID
    
    class Input(BlockSchema):
        query: str = SchemaField(description="Input query")
        max_results: int = SchemaField(default=10, description="Max results")
    
    class Output(BlockSchema):
        result: str = SchemaField(description="Output result")
        error: str = SchemaField(description="Error message if failed")
    
    def __init__(self):
        super().__init__(
            name="My Custom Block",
            description="Does something useful",
            categories=[BlockCategory.TEXT],
            # Optional: Add credentials
            # input_credentials=[...],
        )
    
    async def run(self, input_data: Input, **kwargs) -> Output:
        try:
            result = await do_something(input_data.query)
            return Output(result=result, error="")
        except Exception as e:
            return Output(result="", error=str(e))
```

## Block Testing

```bash
# Test all blocks
poetry run pytest backend/blocks/test/test_block.py -xvs

# Test specific block
poetry run pytest 'backend/blocks/test/test_block.py::test_available_blocks[MyCustomBlock]' -xvs
```
