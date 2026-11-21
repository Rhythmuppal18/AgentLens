import gzip
import json
import logging
from typing import Any
import zlib

logger = logging.getLogger("agentlens.middleware")

MAX_BODY_SIZE = 10 * 1024 * 1024  # 10 MB maximum request body size


class GzipRequestMiddleware:
    """Pure ASGI middleware decompressing gzip request bodies and enforcing payload size limits."""

    def __init__(self, app: Any):
        self.app = app

    async def __call__(self, scope: dict, receive: Any, send: Any) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        headers = dict(scope.get("headers", []))
        content_encoding = headers.get(b"content-encoding", b"").lower()
        content_length_hdr = headers.get(b"content-length")

        if content_length_hdr:
            try:
                cl = int(content_length_hdr)
                if cl > MAX_BODY_SIZE:
                    await self._send_json_error(
                        send=send,
                        status_code=413,
                        payload={
                            "type": "https://agentlens.dev/errors/payload-too-large",
                            "title": "Payload Too Large",
                            "status": 413,
                            "detail": f"Request body length of {cl} bytes exceeds maximum limit of {MAX_BODY_SIZE} bytes (10MB)",
                            "instance": scope.get("path", "/"),
                        },
                    )
                    return
            except ValueError:
                pass

        if b"gzip" in content_encoding:
            body_chunks: list[bytes] = []
            while True:
                message = await receive()
                if message["type"] == "http.request":
                    body_chunks.append(message.get("body", b""))
                    if not message.get("more_body", False):
                        break
                elif message["type"] == "http.disconnect":
                    return

            raw_body = b"".join(body_chunks)
            try:
                decompressed = gzip.decompress(raw_body)
            except (gzip.BadGzipFile, zlib.error, EOFError, OSError) as exc:
                logger.warning("Corrupt or invalid gzip payload received on %s: %s", scope.get("path"), exc)
                await self._send_json_error(
                    send=send,
                    status_code=400,
                    payload={
                        "type": "https://agentlens.dev/errors/bad-request",
                        "title": "Malformed Gzip Payload",
                        "status": 400,
                        "detail": f"Failed to decompress gzip request body: {exc}",
                        "instance": scope.get("path", "/"),
                    },
                )
                return

            if len(decompressed) > MAX_BODY_SIZE:
                await self._send_json_error(
                    send=send,
                    status_code=413,
                    payload={
                        "type": "https://agentlens.dev/errors/payload-too-large",
                        "title": "Payload Too Large",
                        "status": 413,
                        "detail": f"Decompressed payload size of {len(decompressed)} bytes exceeds maximum allowed limit of {MAX_BODY_SIZE} bytes (10MB)",
                        "instance": scope.get("path", "/"),
                    },
                )
                return

            # Strip content-encoding and update content-length in scope headers
            new_headers = []
            for k, v in scope.get("headers", []):
                if k.lower() == b"content-encoding":
                    continue
                elif k.lower() == b"content-length":
                    new_headers.append((b"content-length", str(len(decompressed)).encode("ascii")))
                else:
                    new_headers.append((k, v))
            scope["headers"] = new_headers

            sent_decompressed = False

            async def new_receive():
                nonlocal sent_decompressed
                if not sent_decompressed:
                    sent_decompressed = True
                    return {"type": "http.request", "body": decompressed, "more_body": False}
                return {"type": "http.disconnect"}

            await self.app(scope, new_receive, send)
            return

        await self.app(scope, receive, send)

    async def _send_json_error(self, send: Any, status_code: int, payload: dict) -> None:
        """Sends an RFC 7807 JSON error response over ASGI."""
        body = json.dumps(payload).encode("utf-8")
        headers = [
            (b"content-type", b"application/problem+json"),
            (b"content-length", str(len(body)).encode("ascii")),
        ]
        await send({"type": "http.response.start", "status": status_code, "headers": headers})
        await send({"type": "http.response.body", "body": body, "more_body": False})
