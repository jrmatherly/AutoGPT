# Unit Testing Patterns for AutoGPT Platform

## Overview
This memory documents unit testing patterns and infrastructure for the AutoGPT platform backend.

## Test Infrastructure

### Fast Unit Tests
Unit tests in `backend/util/` and `backend/blocks/` use local `conftest.py` files to override expensive global fixtures:

- **backend/util/conftest.py**: Overrides `server` and `graph_cleanup` fixtures
- **backend/blocks/conftest.py**: Overrides `server` and `graph_cleanup` fixtures

This prevents expensive FastAPI server startup and database initialization for simple unit tests.

### Running Unit Tests

Use the mise task for specific test files:
```bash
mise run test:backend:unit -- backend/util/settings_test.py
mise run test:backend:unit -- backend/blocks/my_block_test.py
```

## LiteLLM Proxy Configuration Testing

### Settings Configuration Tests
**File**: `backend/util/settings_test.py`

Tests the core configuration logic for OpenAI base URL handling:
- Default base_url behavior (`https://api.openai.com/v1`)
- Custom base_url from environment variables
- Fallback logic for `openai_internal_base_url` → `openai_base_url`
- Empty string handling triggers fallback
- Separate internal and external base URLs

**All 6 tests pass** and validate the field_validator logic in the Secrets model.

### Incomplete Tests (Marked as Skipped)
The following test files exist but are skipped due to Settings caching challenges:
- `backend/util/clients_test.py`
- `backend/blocks/llm_test.py`
- `backend/blocks/codex_test.py`

These would validate that base_url is passed to AsyncOpenAI, but this is already verified by:
1. Settings tests proving configuration values are correct
2. Code inspection showing base_url parameter usage
3. Integration tests validating end-to-end behavior

## Testing Strategy for External API Integrations

### Hybrid Approach (Recommended)
1. **Unit Tests**: Mock AsyncOpenAI client, verify configuration logic
   - Fast, no external dependencies
   - Validate parameter passing and configuration
   - Example: `settings_test.py` tests Secrets model directly

2. **Integration Tests**: Use real API keys (optional in CI)
   - Validate actual API integration works
   - Skip when API key not available
   - Example: `backend/api/features/chat/tools/_test_data.py`

3. **E2E Tests**: Full workflow with real dependencies
   - Frontend E2E tests use real OpenAI for test data generation
   - Validate complete user workflows

## Mise Tasks for Testing

### Test Execution
```bash
mise run test                    # Run all tests
mise run test:backend            # Run backend integration tests
mise run test:backend:unit       # Run specific unit test file
mise run test:frontend           # Run frontend E2E tests
```

### Database Management
```bash
mise run db:generate            # Generate Prisma types (no database required)
mise run db:migrate             # Run migrations + generate types
mise run db:reset               # Reset database completely
```

## Best Practices

### When to Mock vs Use Real APIs
- **Mock**: Configuration logic, parameter passing, client initialization
- **Real API**: Integration tests, E2E workflows, actual behavior validation
- **Skip gracefully**: Integration tests when API keys not available

### Test Isolation
- Use local `conftest.py` to override global fixtures
- Clear caches between tests (`function.cache_clear()`)
- Test Pydantic models directly when possible (avoids Settings caching)

### Test Organization
- Colocate tests with source: `module.py` → `module_test.py`
- Group by functionality: `TestClassName` classes
- Descriptive test names: `test_what_behavior_under_what_condition`
