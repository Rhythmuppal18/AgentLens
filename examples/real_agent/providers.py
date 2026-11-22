"""LLM provider abstractions for AgentLens real AI agent integrations.

Uses Python standard library (urllib.request, json) to avoid introducing
external dependencies. Pluggable architecture supports Groq, OpenAI, Ollama,
or any OpenAI-compatible Chat Completions endpoint.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
import json
import logging
import os
import time
from typing import Any, Optional
import urllib.error
import urllib.request

logger = logging.getLogger("agentlens.real_agent.providers")


# Standard Pricing per 1,000,000 tokens (USD)
MODEL_PRICING: dict[str, dict[str, float]] = {
    # Groq Cloud
    "llama-3.3-70b-versatile": {"input": 0.59, "output": 0.79},
    "llama-3.1-8b-instant": {"input": 0.05, "output": 0.08},
    "mixtral-8x7b-32768": {"input": 0.24, "output": 0.24},
    # OpenAI
    "gpt-4o-mini": {"input": 0.15, "output": 0.60},
    "gpt-4o": {"input": 2.50, "output": 10.00},
    # Local / Ollama (Free)
    "ollama": {"input": 0.0, "output": 0.0},
}


@dataclass
class LLMResponse:
    """Standardized response from an LLM call."""

    content: str
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    estimated_cost_usd: float
    model: str
    latency_ms: int
    is_simulated: bool = False
    raw_response: Optional[dict[str, Any]] = None


class BaseLLMProvider(ABC):
    """Abstract interface for LLM provider execution."""

    @abstractmethod
    def generate(self, prompt: str, system_prompt: Optional[str] = None) -> LLMResponse:
        """Executes LLM completion and returns normalized response with tokens and cost."""
        pass

    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Human-readable provider identifier."""
        pass


class OpenAICompatibleProvider(BaseLLMProvider):
    """Connects to any OpenAI-compatible Chat Completions HTTP endpoint.

    Supports Groq, OpenAI, Together, OpenRouter, and Ollama.
    """

    def __init__(
        self,
        api_key: str,
        base_url: str = "https://api.openai.com/v1",
        model: str = "gpt-4o-mini",
        temperature: float = 0.2,
        timeout: float = 30.0,
        provider_name: str = "OpenAI-Compatible",
    ):
        self.api_key = api_key
        self.base_url = base_url.rstrip("/")
        self.model = model
        self.temperature = temperature
        self.timeout = timeout
        self._provider_name = provider_name

    @property
    def provider_name(self) -> str:
        return self._provider_name

    def generate(self, prompt: str, system_prompt: Optional[str] = None) -> LLMResponse:
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})

        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": self.temperature,
        }

        url = f"{self.base_url}/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}",
            "User-Agent": "AgentLens-Observability/1.0",
        }

        body_bytes = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=body_bytes, headers=headers, method="POST")

        t0 = time.time()
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                elapsed_ms = int((time.time() - t0) * 1000)
                resp_text = resp.read().decode("utf-8")
                data = json.loads(resp_text)
        except urllib.error.HTTPError as err:
            err_body = err.read().decode("utf-8", errors="replace")
            raise RuntimeError(
                f"LLM API request failed [{err.code}]: {err_body}"
            ) from err
        except urllib.error.URLError as err:
            raise ConnectionError(
                f"LLM API connection failed: {err.reason}"
            ) from err

        # Extract message content
        choices = data.get("choices", [])
        if not choices:
            raise ValueError(f"No choices returned from LLM provider: {data}")
        content = choices[0].get("message", {}).get("content", "")

        # Extract tokens
        usage = data.get("usage", {})
        prompt_tokens = usage.get("prompt_tokens", 0)
        completion_tokens = usage.get("completion_tokens", 0)
        total_tokens = usage.get("total_tokens", prompt_tokens + completion_tokens)

        # Estimate cost
        pricing = MODEL_PRICING.get(self.model, {"input": 0.50, "output": 1.50})
        cost = (
            (prompt_tokens / 1_000_000) * pricing["input"]
            + (completion_tokens / 1_000_000) * pricing["output"]
        )

        return LLMResponse(
            content=content,
            prompt_tokens=prompt_tokens,
            completion_tokens=completion_tokens,
            total_tokens=total_tokens,
            estimated_cost_usd=round(cost, 6),
            model=self.model,
            latency_ms=elapsed_ms,
            is_simulated=False,
            raw_response=data,
        )


class FallbackSimulatedProvider(BaseLLMProvider):
    """Fallback provider used when no real LLM API key has been configured.

    Clearly flags all outputs as simulated to prevent misattribution.
    """

    def __init__(self, model: str = "simulated-agent-model"):
        self.model = model

    @property
    def provider_name(self) -> str:
        return "Simulated-Fallback (No API key configured)"

    def generate(self, prompt: str, system_prompt: Optional[str] = None) -> LLMResponse:
        time.sleep(0.08)  # Realistic simulated latency

        content = (
            f"[SIMULATED LLM RESPONSE]\n"
            f"Synthesized Analysis based on input data:\n"
            f"- Project demonstrates healthy code health and active maintainer engagement.\n"
            f"- Key indicators suggest strong operational stability with consistent release cycles.\n"
            f"(Note: To execute genuine live LLM completions, configure GROQ_API_KEY or OPENAI_API_KEY)."
        )

        prompt_tokens = len(prompt.split()) * 2
        completion_tokens = len(content.split()) * 2
        total_tokens = prompt_tokens + completion_tokens
        cost = round((prompt_tokens * 0.15 + completion_tokens * 0.60) / 1_000_000, 6)

        return LLMResponse(
            content=content,
            prompt_tokens=prompt_tokens,
            completion_tokens=completion_tokens,
            total_tokens=total_tokens,
            estimated_cost_usd=cost,
            model=self.model,
            latency_ms=80,
            is_simulated=True,
            raw_response={"simulation": True, "provider": self.provider_name},
        )


def get_configured_provider() -> BaseLLMProvider:
    """Inspects environment configuration and returns the appropriate LLM provider.

    Precedence:
    1. GROQ_API_KEY -> Groq (ultra-fast, generous free tier recommended)
    2. OPENAI_API_KEY -> OpenAI (gpt-4o-mini)
    3. OLLAMA_BASE_URL -> Local Ollama (zero API key required)
    4. Fallback -> FallbackSimulatedProvider with instructions
    """
    # 1. Groq (Recommended: Fast & Free Tier available)
    groq_key = os.getenv("GROQ_API_KEY")
    if groq_key:
        return OpenAICompatibleProvider(
            api_key=groq_key,
            base_url="https://api.groq.com/openai/v1",
            model=os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile"),
            provider_name="Groq Cloud",
        )

    # 2. OpenAI
    openai_key = os.getenv("OPENAI_API_KEY")
    if openai_key:
        return OpenAICompatibleProvider(
            api_key=openai_key,
            base_url=os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1"),
            model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
            provider_name="OpenAI",
        )

    # 3. Ollama (Local)
    ollama_url = os.getenv("OLLAMA_BASE_URL")
    if ollama_url:
        return OpenAICompatibleProvider(
            api_key="ollama",
            base_url=ollama_url,
            model=os.getenv("OLLAMA_MODEL", "llama3"),
            provider_name="Ollama Local",
        )

    # 4. Fallback
    return FallbackSimulatedProvider()
