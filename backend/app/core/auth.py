import hashlib
import logging
from typing import Annotated

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.project import Project

logger = logging.getLogger("agentlens.auth")


async def get_authenticated_project(
    authorization: Annotated[str | None, Header(description="Bearer <api_key>")] = None,
    session: AsyncSession = Depends(get_db_session),
) -> Project:
    """Authenticates API requests via Bearer token hashed against projects.api_key_hash."""
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header. Expected 'Authorization: Bearer <api_key>'",
            headers={"WWW-Authenticate": "Bearer"},
        )

    parts = authorization.split(" ")
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Authorization header format. Expected 'Bearer <api_key>'",
            headers={"WWW-Authenticate": "Bearer"},
        )

    raw_token = parts[1].strip()
    if not raw_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Empty bearer token provided",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()

    result = await session.execute(
        select(Project).where(
            Project.api_key_hash == token_hash,
            Project.is_active == True,  # noqa: E712
        )
    )
    project = result.scalar_one_or_none()

    if not project:
        logger.warning("Authentication failed for provided API key hash %s", token_hash[:8])
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or revoked API key",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return project


AuthenticatedProject = Annotated[Project, Depends(get_authenticated_project)]
