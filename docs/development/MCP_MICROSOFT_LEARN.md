# Microsoft Learn MCP Server Integration Guide

## Overview

The Microsoft Learn MCP server provides direct access to official Microsoft documentation, code examples, and technical references for Microsoft technologies used throughout the AutoGPT Platform.

### Why Microsoft Learn for AutoGPT?

The AutoGPT Platform leverages several Microsoft/TypeScript ecosystem technologies:

**Frontend Stack:**
- **TypeScript** - Primary language for Next.js frontend
- **React** - UI library (via Next.js 15)
- **Next.js 15** - React framework with App Router
- **Playwright** - E2E testing framework (Microsoft-maintained)

**Development Tools:**
- **VS Code** - Primary IDE (Microsoft-maintained)
- **GitHub Actions** - CI/CD (Microsoft-owned)
- **TypeScript** - Type system and compiler

**Why use Microsoft Learn MCP vs. web search?**
- Official, authoritative documentation
- Up-to-date API references (always current)
- Code examples validated by Microsoft
- Structured content optimized for AI consumption
- No outdated blog posts or Stack Overflow noise

---

## Available Tools

### 1. microsoft_docs_search

**Purpose**: Quick documentation lookups and concept understanding

**Returns**: Up to 10 concise content chunks (max 500 tokens each) with title, URL, and excerpt

**Best For**:
- Understanding concepts (e.g., "TypeScript generics", "Playwright selectors")
- Quick API reference checks
- Finding relevant documentation sections
- Getting authoritative answers to "how do I" questions

**When to Use**:
```
✅ "How does TypeScript type inference work?"
✅ "What are React Server Components?"
✅ "Playwright page.waitForSelector options"
✅ "Next.js App Router data fetching"
```

**When NOT to Use**:
```
❌ AutoGPT-specific implementation details (use Serena/Grep)
❌ Third-party library docs (use web search or Context7)
❌ Historical context or comparisons (use web search)
```

### 2. microsoft_code_sample_search

**Purpose**: Find working code examples from official Microsoft docs

**Returns**: Up to 20 relevant code samples with context

**Best For**:
- Implementation examples (e.g., "Playwright API testing", "TypeScript async patterns")
- Code snippet discovery
- Learning new APIs through examples
- Finding production-ready code patterns

**Optional Parameter**: `language` filter (e.g., "typescript", "python", "javascript")

### 3. microsoft_docs_fetch

**Purpose**: Retrieve complete documentation pages in markdown format

**Returns**: Full page content converted to markdown

**Best For**:
- Deep-dive tutorials requiring complete context
- Comprehensive API reference
- Detailed troubleshooting guides
- Multi-step procedures requiring full workflow

---

## Recommended Workflow

### Pattern 1: Quick Concept Check
```
1. Use microsoft_docs_search with focused query
2. Review returned chunks for answer
3. If incomplete, use microsoft_docs_fetch on specific URL
```

### Pattern 2: Finding Code Examples
```
1. Use microsoft_code_sample_search with specific task
2. Optional: add language filter for precision
3. If examples insufficient, microsoft_docs_fetch tutorial
```

### Pattern 3: Deep Learning
```
1. Use microsoft_docs_search to find right topic/page
2. Use microsoft_docs_fetch to get complete tutorial
3. Use microsoft_code_sample_search for specific implementations
```

---

## Integration with AutoGPT Development

### When Working on Frontend (Next.js/React/TypeScript)

**Use Microsoft Learn for**:
- TypeScript type system questions
- Next.js 15 App Router patterns
- React Server Components
- Playwright test implementation
- VS Code configuration

### When Working on Testing (Playwright)

**Use Microsoft Learn for**:
- Playwright test patterns (official Microsoft docs)
- Locator strategies
- API testing examples
- CI/CD integration

### When Working on GitHub Actions

**Use Microsoft Learn for**:
- GitHub Actions syntax (Microsoft-owned)
- Workflow patterns
- Secrets management
- Deployment strategies

---

## Technology Coverage Matrix

| Technology | Coverage | Best MCP Tool | Alternative |
|-----------|----------|---------------|-------------|
| **TypeScript** | Excellent | microsoft_docs_search | Context7 (community patterns) |
| **Playwright** | Excellent | microsoft_code_sample_search | Official docs (duplicate) |
| **GitHub Actions** | Excellent | microsoft_docs_search | Web search (community) |
| **Next.js** | Partial | microsoft_docs_search | Vercel docs (primary) |
| **React** | Partial | microsoft_docs_search | React docs (primary) |
| **VS Code** | Excellent | microsoft_docs_fetch | Web search |
| **Pydantic** | Limited | Web search | Pydantic docs (primary) |
| **FastAPI** | Limited | Web search | FastAPI docs (primary) |
| **Prisma** | None | Context7 | Prisma docs (primary) |

---

## Best Practices

### Do's
1. **Use for Microsoft Technologies**: TypeScript, Playwright, GitHub Actions, VS Code
2. **Search First**: Start with microsoft_docs_search for quick answers
3. **Code Samples for Implementation**: Use microsoft_code_sample_search when coding
4. **Fetch for Deep Dives**: Use microsoft_docs_fetch for comprehensive understanding
5. **Language Filters**: Specify language when using code sample search

### Don'ts
1. **Don't Use for AutoGPT Specifics**: Use Serena/Grep/Read for codebase patterns
2. **Don't Fetch Without Search**: Always search first to find the right page
3. **Don't Use for Third-Party**: Use Context7 or web search for non-Microsoft tech
4. **Don't Over-Fetch**: Fetching is verbose, only for complex topics

---

## Troubleshooting

### Issue: "No results found"

**Solutions**:
- Avoid AutoGPT-specific terminology
- Check if technology is in Microsoft Learn scope
- Use more generic technology terms

### Issue: "Results not relevant"

**Solutions**:
- Make query more specific
- Separate queries for each technology
- Use the right tool (search vs. fetch)

---

## Quick Reference Card

**When to Use microsoft-learn MCP**:
```
✅ TypeScript syntax/concepts
✅ Playwright testing patterns
✅ GitHub Actions workflows
✅ VS Code configuration
✅ Microsoft ecosystem tools

❌ AutoGPT-specific code
❌ Third-party libraries
❌ Codebase patterns
❌ Community practices
```

**Tool Selection Guide**:
```
Quick answer     → microsoft_docs_search
Code examples    → microsoft_code_sample_search
Deep learning    → microsoft_docs_fetch
AutoGPT patterns → Serena/Grep/Read
Other libraries  → Context7/web search
```
