"""Real AI Agent package for AgentLens.

Provides pluggable LLM provider abstractions, real-world tool implementations,
and telemetry instrumentation.
"""

from examples.real_agent.providers import (
    BaseLLMProvider,
    FallbackSimulatedProvider,
    LLMResponse,
    OpenAICompatibleProvider,
    get_configured_provider,
)
from examples.real_agent.tools import (
    calculate_repository_health_metrics,
    fetch_github_repository_stats,
)

__all__ = [
    "BaseLLMProvider",
    "OpenAICompatibleProvider",
    "FallbackSimulatedProvider",
    "LLMResponse",
    "get_configured_provider",
    "fetch_github_repository_stats",
    "calculate_repository_health_metrics",
]
