# Microsoft Learn MCP Server Integration Guide

## Last Updated
- **Date**: January 29, 2026
- **Status**: ✅ Active MCP Server
- **Tools**: 3 available (docs search, code samples, full page fetch)

## Overview

The Microsoft Learn MCP server provides direct access to official Microsoft documentation, code examples, and technical references for Microsoft technologies used throughout the AutoGPT Platform.

### Why Microsoft Learn for AutoGPT?

The AutoGPT Platform leverages several Microsoft/TypeScript ecosystem technologies:

**Frontend Stack:**
- **TypeScript** - Primary language for Next.js frontend
- **React** - UI library (via Next.js 15)
- **Next.js 15** - React framework with App Router
- **Playwright** - E2E testing framework (Microsoft-maintained)

**Backend Stack:**
- **FastAPI** - Python async web framework (uses Pydantic, related to TypeScript type systems)
- **Pydantic** - Data validation (inspired by TypeScript)
- **Prisma** - Database ORM with TypeScript-like schema

**Development Tools:**
- **VS Code** - Primary IDE (Microsoft-maintained)
- **GitHub Actions** - CI/CD (Microsoft-owned)
- **TypeScript** - Type system and compiler

**Why use Microsoft Learn MCP vs. web search?**
- ✅ Official, authoritative documentation
- ✅ Up-to-date API references (always current)
- ✅ Code examples validated by Microsoft
- ✅ Structured content optimized for AI consumption
- ✅ No outdated blog posts or Stack Overflow noise

---

## Available Tools

### 1. microsoft_docs_search

**Purpose**: Quick documentation lookups and concept understanding

**Returns**: Up to 10 concise content chunks (max 500 tokens each) with title, URL, and excerpt

**Best For**:
- Understanding concepts (e.g., "TypeScript generics", "Playwright selectors")
- Quick API reference checks (e.g., "FastAPI dependency injection")
- Finding relevant documentation sections
- Getting authoritative answers to "how do I" questions

**When to Use**:
```
✅ "How does TypeScript type inference work?"
✅ "What are React Server Components?"
✅ "Playwright page.waitForSelector options"
✅ "Next.js App Router data fetching"
✅ "Pydantic field validators"
```

**When NOT to Use**:
```
❌ AutoGPT-specific implementation details (use Serena/Grep)
❌ Third-party library docs (use web search or Context7)
❌ Historical context or comparisons (use web search)
❌ Community best practices (use web search)
```

### 2. microsoft_code_sample_search

**Purpose**: Find working code examples from official Microsoft docs

**Returns**: Up to 20 relevant code samples with context

**Best For**:
- Implementation examples (e.g., "Playwright API testing", "TypeScript async patterns")
- Code snippet discovery (e.g., "FastAPI WebSocket example")
- Learning new APIs through examples
- Finding production-ready code patterns

**Optional Parameter**: `language` filter (e.g., "typescript", "python", "javascript")

**When to Use**:
```
✅ "Playwright authentication example"
✅ "TypeScript generic constraints code"
✅ "Next.js middleware examples"
✅ "React Query mutation patterns"
✅ "Pydantic custom validators code"
```

**When NOT to Use**:
```
❌ AutoGPT codebase examples (use Grep/Read)
❌ Non-Microsoft technology examples (use Context7 or web search)
❌ Framework-specific patterns outside Microsoft ecosystem
```

### 3. microsoft_docs_fetch

**Purpose**: Retrieve complete documentation pages in markdown format

**Returns**: Full page content converted to markdown

**Best For**:
- Deep-dive tutorials requiring complete context
- Comprehensive API reference (e.g., entire Playwright API page)
- Detailed troubleshooting guides
- When search results are incomplete
- Multi-step procedures requiring full workflow

**When to Use**:
```
✅ After microsoft_docs_search identifies the right page
✅ Complex tutorials (e.g., "Playwright advanced testing")
✅ Complete API references (e.g., TypeScript utility types)
✅ Migration guides (e.g., "Next.js 14 to 15 upgrade")
✅ Troubleshooting pages with multiple solutions
```

**When NOT to Use**:
```
❌ Quick lookups (use microsoft_docs_search instead)
❌ Just browsing (too verbose, use search first)
❌ Non-Microsoft documentation
```

---

## Recommended Workflow

### Pattern 1: Quick Concept Check
```
1. Use microsoft_docs_search with focused query
2. Review returned chunks for answer
3. If incomplete, use microsoft_docs_fetch on specific URL
```

**Example**:
```
Query: "TypeScript discriminated unions"
→ microsoft_docs_search returns overview + examples
→ If need more detail, microsoft_docs_fetch the full page
```

### Pattern 2: Finding Code Examples
```
1. Use microsoft_code_sample_search with specific task
2. Optional: add language filter for precision
3. If examples insufficient, microsoft_docs_fetch tutorial
```

**Example**:
```
Query: "Playwright testing API endpoints" language="typescript"
→ Returns 20 code samples
→ If need full context, fetch the API testing guide
```

### Pattern 3: Deep Learning
```
1. Use microsoft_docs_search to find right topic/page
2. Use microsoft_docs_fetch to get complete tutorial
3. Use microsoft_code_sample_search for specific implementations
```

**Example**:
```
Topic: "Next.js Server Actions"
→ Search finds overview page
→ Fetch complete page for full understanding
→ Search code samples for implementation patterns
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

**Example Queries**:
```typescript
// Before: Generic web search for "react hooks"
// Better: microsoft_docs_search "React hooks rules of use"

// Before: Stack Overflow for "TypeScript generic constraints"
// Better: microsoft_code_sample_search "TypeScript generic constraints" language="typescript"

// Before: Blog post for "Next.js middleware"
// Better: microsoft_docs_fetch (Next.js middleware official guide)
```

### When Working on Backend (FastAPI/Pydantic/Prisma)

**Use Microsoft Learn for**:
- Pydantic validation patterns (TypeScript-inspired)
- FastAPI async patterns (similar to TypeScript async/await)
- Prisma schema syntax (TypeScript-influenced)
- Python type hints (related to TypeScript types)

**Example Queries**:
```python
# Pydantic validation (TypeScript-inspired library)
microsoft_docs_search "Pydantic field validators"

# FastAPI async patterns
microsoft_code_sample_search "Python async await patterns"

# Type hints (similar to TypeScript)
microsoft_docs_search "Python type hints generics"
```

### When Working on Testing (Playwright)

**Use Microsoft Learn for**:
- Playwright test patterns (official Microsoft docs)
- Locator strategies
- API testing examples
- CI/CD integration

**Example Queries**:
```typescript
// Playwright is Microsoft-maintained
microsoft_docs_search "Playwright page object model"
microsoft_code_sample_search "Playwright API testing" language="typescript"
microsoft_docs_fetch (Playwright best practices guide)
```

### When Working on GitHub Actions

**Use Microsoft Learn for**:
- GitHub Actions syntax (Microsoft-owned)
- Workflow patterns
- Secrets management
- Deployment strategies

**Example Queries**:
```yaml
microsoft_docs_search "GitHub Actions composite actions"
microsoft_code_sample_search "GitHub Actions matrix strategy"
microsoft_docs_fetch (GitHub Actions security best practices)
```

---

## CLAUDE.md Integration

**Recommended Section Addition** (after "Key Technologies"):

### Microsoft Technologies Documentation

When working with Microsoft ecosystem technologies (TypeScript, Playwright, GitHub Actions), use the **microsoft-learn** MCP server for authoritative documentation:

**Quick Lookups**:
```bash
# TypeScript concepts
microsoft_docs_search "TypeScript utility types"

# Playwright testing
microsoft_code_sample_search "Playwright authentication"

# Next.js patterns
microsoft_docs_fetch (specific Next.js guide URL)
```

**Technology Coverage**:
- TypeScript: Official language documentation and API reference
- Playwright: Testing framework (Microsoft-maintained)
- GitHub Actions: CI/CD workflows (Microsoft-owned)
- VS Code: Editor configuration and extensions
- Pydantic/FastAPI: TypeScript-inspired Python libraries

**When to Use**:
- ✅ Official API documentation needed
- ✅ Working code examples required
- ✅ TypeScript/Playwright/GitHub Actions questions
- ✅ Migration guides for framework updates

**When to Use Web Search Instead**:
- ❌ AutoGPT-specific implementation details
- ❌ Community best practices and patterns
- ❌ Third-party library documentation
- ❌ Troubleshooting specific error messages

---

## Serena Memory Reference

### When to Document Using microsoft-learn

**Include in Serena memories when**:
- Documenting Microsoft technology patterns (TypeScript, Playwright, etc.)
- Creating coding guidelines that reference official docs
- Establishing best practices for Microsoft ecosystem tools
- Recording API changes from official Microsoft sources

**Example Memory Enhancement**:

**Before**:
```markdown
## Frontend Testing Patterns

Use Playwright for E2E testing with page object model.
```

**After**:
```markdown
## Frontend Testing Patterns

Use Playwright for E2E testing with page object model.

**Official Documentation**: microsoft_docs_fetch (Playwright best practices)
**Code Examples**: microsoft_code_sample_search "Playwright page object model" language="typescript"

See Microsoft's official guide for latest patterns and API changes.
```

---

## Best Practices

### Do's ✅

1. **Use for Microsoft Technologies**: TypeScript, Playwright, GitHub Actions, VS Code
2. **Search First**: Start with microsoft_docs_search for quick answers
3. **Code Samples for Implementation**: Use microsoft_code_sample_search when coding
4. **Fetch for Deep Dives**: Use microsoft_docs_fetch for comprehensive understanding
5. **Language Filters**: Specify language when using code sample search
6. **Update Documentation**: Reference Microsoft Learn in Serena memories

### Don'ts ❌

1. **Don't Use for AutoGPT Specifics**: Use Serena/Grep/Read for codebase patterns
2. **Don't Fetch Without Search**: Always search first to find the right page
3. **Don't Use for Third-Party**: Use Context7 or web search for non-Microsoft tech
4. **Don't Ignore Results**: Microsoft docs are authoritative, trust them
5. **Don't Skip Version Checks**: Verify docs match your technology versions
6. **Don't Over-Fetch**: Fetching is verbose, only for complex topics

---

## Common Use Cases

### Use Case 1: Implementing Playwright Test

**Scenario**: Need to add API testing to frontend CI

**Workflow**:
1. `microsoft_docs_search "Playwright API testing"` → Get overview
2. `microsoft_code_sample_search "Playwright API testing" language="typescript"` → Get examples
3. Adapt examples to AutoGPT patterns from `frontend/src/tests/CLAUDE.md`

### Use Case 2: TypeScript Type Error

**Scenario**: Complex generic type error in frontend code

**Workflow**:
1. `microsoft_docs_search "TypeScript generic constraints"` → Understand concept
2. `microsoft_code_sample_search "TypeScript generic constraints"` → See examples
3. Apply fix using official patterns

### Use Case 3: Next.js Upgrade

**Scenario**: Upgrading from Next.js 14 to 15

**Workflow**:
1. `microsoft_docs_search "Next.js 15 migration guide"`→ Find guide URL
2. `microsoft_docs_fetch <guide-url>` → Get complete migration steps
3. Document breaking changes in Serena memory

### Use Case 4: GitHub Actions Optimization

**Scenario**: Improve CI/CD workflow performance

**Workflow**:
1. `microsoft_docs_search "GitHub Actions caching"` → Best practices
2. `microsoft_code_sample_search "GitHub Actions cache" language="yaml"` → Examples
3. Implement caching per official patterns

---

## Technology Coverage Matrix

| Technology | Coverage | Best MCP Tool | Alternative |
|-----------|----------|---------------|-------------|
| **TypeScript** | ✅ Excellent | microsoft_docs_search | Context7 (community patterns) |
| **Playwright** | ✅ Excellent | microsoft_code_sample_search | Official docs (duplicate) |
| **GitHub Actions** | ✅ Excellent | microsoft_docs_search | Web search (community) |
| **Next.js** | ⚠️ Partial | microsoft_docs_search | Vercel docs (primary) |
| **React** | ⚠️ Partial | microsoft_docs_search | React docs (primary) |
| **VS Code** | ✅ Excellent | microsoft_docs_fetch | Web search |
| **Pydantic** | ❌ Limited | Web search | Pydantic docs (primary) |
| **FastAPI** | ❌ Limited | Web search | FastAPI docs (primary) |
| **Prisma** | ❌ None | Context7 | Prisma docs (primary) |

---

## Troubleshooting

### Issue: "No results found"

**Causes**:
- Query too specific or uses AutoGPT terminology
- Technology not in Microsoft Learn scope
- Outdated API/feature name

**Solutions**:
```bash
# Instead of: "AutoGPT Playwright setup"
# Try: "Playwright configuration TypeScript"

# Instead of: "platform frontend testing"
# Try: "Next.js Playwright integration"

# If still no results, switch to web search or Context7
```

### Issue: "Results not relevant"

**Causes**:
- Query too broad
- Mixed technologies in one query
- Wrong tool selection

**Solutions**:
```bash
# Too broad: "React testing"
# Better: "React Testing Library hooks"

# Mixed: "Next.js Playwright FastAPI"
# Better: Separate queries for each technology

# Wrong tool: microsoft_docs_fetch without URL
# Correct: microsoft_docs_search first, then fetch
```

### Issue: "Outdated information"

**Causes**:
- Major version changes in technology
- Recent API changes not yet documented

**Solutions**:
```bash
# Verify version in results
# Cross-reference with package.json versions
# If mismatch, search for migration guide
# Last resort: web search for latest changes
```

---

## Future Enhancements

### Potential Improvements

1. **Auto-Version Detection**: Automatically filter results by project's package.json versions
2. **Context Integration**: Combine microsoft-learn with Context7 for comprehensive coverage
3. **Smart Routing**: Auto-select best MCP server based on query technology
4. **Result Caching**: Cache frequent queries to reduce API calls
5. **Version Compatibility Checks**: Warn if docs don't match installed versions

### Integration Opportunities

- **CLAUDE.md**: Add Microsoft Learn query examples for each technology
- **Serena Memories**: Reference official docs in all TypeScript/Playwright patterns
- **CI/CD Docs**: Link GitHub Actions patterns to Microsoft Learn
- **Testing Guides**: Integrate Playwright official examples

---

## References

### Internal Documentation
- **CLAUDE.md**: Project development guidelines
- **frontend/CONTRIBUTING.md**: Frontend-specific patterns
- **frontend/src/tests/CLAUDE.md**: Testing guidelines

### External Resources
- [Microsoft Learn Documentation](https://learn.microsoft.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Playwright Documentation](https://playwright.dev/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

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

**Workflow Template**:
```
1. Search → Find relevant docs
2. Samples → Get code examples
3. Fetch → Deep dive if needed
4. Apply → Adapt to AutoGPT
5. Document → Update Serena memory
```
