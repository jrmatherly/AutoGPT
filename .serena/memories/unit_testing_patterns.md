# Unit Testing Patterns

**Full patterns:** See [docs/development/BACKEND_PATTERNS.md](../../docs/development/BACKEND_PATTERNS.md#testing-patterns)

## Test Infrastructure

Unit tests in `backend/util/` and `backend/blocks/` use local `conftest.py` files to override expensive global fixtures, preventing FastAPI server startup for simple tests.

## Running Tests

```bash
# All backend tests
mise run test:backend

# Specific test file
mise run test:backend:unit -- backend/util/settings_test.py

# Block tests
poetry run pytest backend/blocks/test/test_block.py -xvs
```

## Key Patterns

- Test files colocated with source (`*_test.py`)
- Use pytest fixtures for common setup
- Snapshot testing for API responses
- Mock external services
