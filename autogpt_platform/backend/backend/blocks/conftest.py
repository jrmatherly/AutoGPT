"""Local conftest for block unit tests that don't require the full server fixture."""

import pytest


@pytest.fixture(scope="session")
def server():
    """Override the global server fixture to prevent it from loading.

    Unit tests in this directory don't need the full FastAPI server,
    so we provide a no-op fixture that prevents the expensive global
    server fixture from being initialized.
    """
    return None


@pytest.fixture(scope="session", autouse=True)
def graph_cleanup():
    """Override the global graph_cleanup fixture to prevent it from loading.

    Unit tests in this directory don't need graph cleanup functionality,
    so we provide a no-op fixture.
    """
    return None
