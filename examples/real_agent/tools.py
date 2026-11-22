"""Real tool functions for the AgentLens AI Agent example.

Demonstrates actual external API lookup and structured mathematical computation.
Instruments real inputs, execution time, and output payloads.
"""

import json
import logging
import math
import time
from typing import Any
import urllib.error
import urllib.request

logger = logging.getLogger("agentlens.real_agent.tools")


def fetch_github_repository_stats(owner_repo: str) -> dict[str, Any]:
    """Fetches real-time metadata and metrics from GitHub's public REST API.

    Executes an actual outbound HTTP request over the network.
    """
    clean_repo = owner_repo.strip().strip("/")
    url = f"https://api.github.com/repos/{clean_repo}"
    headers = {
        "User-Agent": "AgentLens-AI-Agent/1.0",
        "Accept": "application/vnd.github.v3+json",
    }

    req = urllib.request.Request(url, headers=headers, method="GET")
    t0 = time.time()

    try:
        with urllib.request.urlopen(req, timeout=10.0) as resp:
            elapsed_ms = int((time.time() - t0) * 1000)
            data = json.loads(resp.read().decode("utf-8"))

            return {
                "repository": data.get("full_name", clean_repo),
                "description": data.get("description", "No description provided"),
                "stars": data.get("stargazers_count", 0),
                "forks": data.get("forks_count", 0),
                "open_issues": data.get("open_issues_count", 0),
                "primary_language": data.get("language", "Unknown"),
                "license": (data.get("license") or {}).get("spdx_id", "None"),
                "last_push": data.get("pushed_at"),
                "network_latency_ms": elapsed_ms,
                "is_live_api": True,
            }
    except urllib.error.HTTPError as err:
        elapsed_ms = int((time.time() - t0) * 1000)
        logger.warning("GitHub API returned HTTP %s for repo %s", err.code, clean_repo)
        # Handle rate limits or 404s gracefully with real status indicators
        return {
            "repository": clean_repo,
            "error": f"HTTP {err.code}: {err.reason}",
            "is_live_api": True,
            "network_latency_ms": elapsed_ms,
            "status": "rate_limited" if err.code == 403 else "not_found",
            "stars": 0,
            "forks": 0,
            "open_issues": 0,
            "primary_language": "Unknown",
        }
    except urllib.error.URLError as err:
        elapsed_ms = int((time.time() - t0) * 1000)
        logger.warning("GitHub API network connection failed: %s", err.reason)
        return {
            "repository": clean_repo,
            "error": f"Network error: {err.reason}",
            "is_live_api": False,
            "network_latency_ms": elapsed_ms,
            "status": "offline",
            "stars": 0,
            "forks": 0,
            "open_issues": 0,
            "primary_language": "Unknown",
        }


def calculate_repository_health_metrics(repo_stats: dict[str, Any]) -> dict[str, Any]:
    """Performs structured analytical calculation on repository statistics."""
    t0 = time.time()

    stars = max(0, int(repo_stats.get("stars", 0)))
    forks = max(0, int(repo_stats.get("forks", 0)))
    open_issues = max(0, int(repo_stats.get("open_issues", 0)))

    # Compute popularity score (logarithmic 0-100 scale)
    popularity_score = round(min(100.0, math.log10(stars + 1) * 20.0), 2)

    # Community engagement ratio
    fork_ratio = round(forks / max(stars, 1), 4)

    # Issue load ratio
    issue_load = round(open_issues / max(stars, 1), 4)

    # Overall Health Score (0 - 100)
    base_health = 75.0
    health_adjustment = (popularity_score * 0.25) + (fork_ratio * 20.0) - (issue_load * 50.0)
    composite_health = round(max(10.0, min(100.0, base_health + health_adjustment)), 1)

    if composite_health >= 80.0:
        tier = "EXCELLENT"
    elif composite_health >= 60.0:
        tier = "GOOD"
    elif composite_health >= 40.0:
        tier = "MODERATE"
    else:
        tier = "CRITICAL_ATTENTION_REQUIRED"

    elapsed_ms = int((time.time() - t0) * 1000)

    return {
        "repository": repo_stats.get("repository", "unknown"),
        "composite_health_score": composite_health,
        "health_tier": tier,
        "metrics": {
            "popularity_score": popularity_score,
            "fork_ratio": fork_ratio,
            "issue_load_ratio": issue_load,
            "stars": stars,
            "forks": forks,
            "open_issues": open_issues,
        },
        "computation_time_ms": elapsed_ms,
    }
