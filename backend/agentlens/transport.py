import gzip
import json
import logging
from typing import Any, Optional
import urllib.error
import urllib.request

logger = logging.getLogger("agentlens.transport")


class TransportError(Exception):
    """Base transport error."""

    def __init__(self, message: str, status_code: Optional[int] = None, retryable: bool = True):
        super().__init__(message)
        self.status_code = status_code
        self.retryable = retryable


class HttpTransport:
    """Zero-dependency HTTP transport utilizing Python standard library urllib."""

    def __init__(
        self,
        api_url: str = "http://localhost:8000",
        api_key: Optional[str] = None,
        timeout: float = 10.0,
    ):
        self.api_url = api_url.rstrip("/")
        self.api_key = api_key
        self.timeout = timeout
        self.ingest_endpoint = f"{self.api_url}/api/v1/telemetry/ingest"

    def send_batch(self, payload: dict[str, Any]) -> bool:
        """Sends a telemetry batch via Gzip-compressed HTTP POST."""
        try:
            raw_json = json.dumps(payload, default=str).encode("utf-8")
            compressed_data = gzip.compress(raw_json)

            headers = {
                "Content-Type": "application/json",
                "Content-Encoding": "gzip",
                "User-Agent": "AgentLens-Python-SDK/0.1.0",
            }
            if self.api_key:
                headers["Authorization"] = f"Bearer {self.api_key}"

            req = urllib.request.Request(
                url=self.ingest_endpoint,
                data=compressed_data,
                headers=headers,
                method="POST",
            )

            with urllib.request.urlopen(req, timeout=self.timeout) as response:
                status_code = response.getcode()
                if status_code in (200, 201, 202):
                    return True
                logger.warning("Unexpected HTTP status from ingestion endpoint: %d", status_code)
                return True

        except urllib.error.HTTPError as exc:
            # Fatal client errors: 400 (Bad Request), 422 (Validation), 401/403 (Auth)
            # These are non-retryable poison pills
            if exc.code in (400, 401, 403, 422):
                try:
                    error_body = exc.read().decode("utf-8")
                except Exception:
                    error_body = str(exc)
                logger.error(
                    "Non-retryable ingestion rejection (HTTP %d): %s",
                    exc.code,
                    error_body,
                )
                raise TransportError(
                    f"HTTP {exc.code} Fatal Rejection: {error_body}",
                    status_code=exc.code,
                    retryable=False,
                ) from exc

            # 5xx server errors or 429 rate limit are retryable
            raise TransportError(
                f"HTTP {exc.code} Server Error: {exc.reason}",
                status_code=exc.code,
                retryable=True,
            ) from exc

        except urllib.error.URLError as exc:
            raise TransportError(
                f"Network unreachable: {exc.reason}",
                status_code=None,
                retryable=True,
            ) from exc

        except Exception as exc:
            raise TransportError(
                f"Transport failure: {exc}",
                status_code=None,
                retryable=True,
            ) from exc
