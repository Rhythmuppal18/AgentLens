import hashlib
import json
import re
from typing import Any

# Sensitive key regex pattern: api_key, auth, bearer, secret, password, token, private, etc.
SENSITIVE_KEY_PATTERN = re.compile(
    r"(?i)(api[_-]?key|auth|bearer|secret|password|token|private|credentials|access[_-]?token)"
)

MAX_PAYLOAD_STRING_BYTES = 64 * 1024  # 64 KB limit
PREVIEW_BYTES = 1024  # 1 KB preview for truncated payloads


def redact_sensitive_data(obj: Any) -> Any:
    """Recursively redacts sensitive keys matching known credential and secret patterns."""
    if isinstance(obj, dict):
        sanitized = {}
        for key, value in obj.items():
            if SENSITIVE_KEY_PATTERN.search(str(key)):
                sanitized[key] = "[REDACTED]"
            else:
                sanitized[key] = redact_sensitive_data(value)
        return sanitized
    elif isinstance(obj, (list, tuple)):
        return [redact_sensitive_data(item) for item in obj]
    elif isinstance(obj, str):
        # Truncate string if exceeding max payload size
        encoded = obj.encode("utf-8")
        if len(encoded) > MAX_PAYLOAD_STRING_BYTES:
            preview = encoded[:PREVIEW_BYTES].decode("utf-8", errors="ignore")
            return {
                "_truncated": True,
                "original_bytes": len(encoded),
                "preview": f"{preview}... [TRUNCATED]",
            }
        return obj
    return obj


def canonical_json_dumps(obj: Any) -> str:
    """Produces canonical JSON string with sorted keys and no extraneous whitespace."""
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), default=str)


def compute_canonical_input_hash(payload: Any) -> str | None:
    """Computes SHA-256 hash of canonical JSON payload for O(1) duplicate detection."""
    if payload is None:
        return None
    try:
        canonical_str = canonical_json_dumps(payload)
        return hashlib.sha256(canonical_str.encode("utf-8")).hexdigest()
    except Exception:
        return None
