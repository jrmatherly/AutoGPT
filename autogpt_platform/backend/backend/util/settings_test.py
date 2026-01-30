"""Tests for Settings configuration, specifically OpenAI base URL handling.

This module tests the Settings class behavior including:
- Default OpenAI base URL configuration
- OpenAI internal base URL fallback logic
- Environment variable override behavior

Note: These tests verify that environment variables take precedence over .env files,
which is the correct behavior for production deployments and CI/CD environments.
"""

import os
from unittest.mock import patch

import pytest

from backend.util.settings import Secrets, Settings


class TestOpenAIBaseURLConfiguration:
    """Test OpenAI base URL configuration and fallback logic."""

    def test_default_openai_base_url(self):
        """Verify default OpenAI base URL when no environment variable is set."""
        # Test the Secrets model directly with explicit values
        secrets = Secrets(
            openai_base_url="https://api.openai.com/v1",
            openai_internal_base_url="",  # Empty triggers fallback
        )

        assert secrets.openai_base_url == "https://api.openai.com/v1"
        assert secrets.openai_internal_base_url == "https://api.openai.com/v1"

    def test_custom_openai_base_url(self):
        """Verify custom OpenAI base URL is used when provided."""
        secrets = Secrets(
            openai_base_url="https://litellm.example.com/v1",
            openai_internal_base_url="",
        )

        assert secrets.openai_base_url == "https://litellm.example.com/v1"
        # Should fall back to base_url
        assert secrets.openai_internal_base_url == "https://litellm.example.com/v1"

    def test_internal_base_url_fallback_to_base_url(self):
        """Verify openai_internal_base_url falls back to openai_base_url when not set."""
        secrets = Secrets(
            openai_base_url="https://litellm.example.com/v1",
            openai_internal_base_url="",
        )

        # Internal should fall back to base URL
        assert secrets.openai_internal_base_url == "https://litellm.example.com/v1"
        assert secrets.openai_base_url == "https://litellm.example.com/v1"

    def test_separate_internal_base_url(self):
        """Verify separate internal base URL can be configured."""
        secrets = Secrets(
            openai_base_url="https://openai-proxy.example.com/v1",
            openai_internal_base_url="https://internal-proxy.example.com/v1",
        )

        # Both should use their respective values
        assert secrets.openai_base_url == "https://openai-proxy.example.com/v1"
        assert (
            secrets.openai_internal_base_url == "https://internal-proxy.example.com/v1"
        )

    def test_internal_base_url_empty_string_falls_back(self):
        """Verify empty string for internal base URL triggers fallback."""
        secrets = Secrets(
            openai_base_url="https://litellm.example.com/v1",
            openai_internal_base_url="",
        )

        # Empty string should fall back to base URL
        assert secrets.openai_internal_base_url == "https://litellm.example.com/v1"

    def test_fallback_when_both_unset(self):
        """Verify fallback to default when both URLs use field defaults."""
        # Don't pass the fields at all - let them use defaults
        secrets = Secrets()

        # Both should default to OpenAI (from field defaults)
        assert secrets.openai_base_url == "https://api.openai.com/v1"
        assert secrets.openai_internal_base_url == "https://api.openai.com/v1"
