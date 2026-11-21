from datetime import datetime, timezone
import hashlib
import re
import secrets
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.environment import Environment
from app.models.project import Project
from app.schemas.project import (
    ApiKeyRegenerateResponse,
    ProjectCreate,
    ProjectCreateResponse,
    ProjectResponse,
    ProjectUpdate,
)

router = APIRouter(tags=["Projects"])


def _slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    return re.sub(r"[-\s]+", "-", text) or "project"


@router.get("", response_model=list[ProjectResponse])
async def list_projects(
    session: AsyncSession = Depends(get_db_session),
) -> list[ProjectResponse]:
    """Retrieves all registered projects ordered by creation date."""
    result = await session.execute(
        select(Project).order_by(desc(Project.created_at))
    )
    return list(result.scalars().all())


@router.post("", response_model=ProjectCreateResponse, status_code=status.HTTP_201_CREATED)
async def create_project(
    payload: ProjectCreate,
    session: AsyncSession = Depends(get_db_session),
) -> ProjectCreateResponse:
    """Creates a new project, generates a secure API key, and provisions default environments."""
    slug = payload.slug or _slugify(payload.name)

    # Check for existing project with same slug
    existing = await session.execute(select(Project).where(Project.slug == slug))
    if existing.scalar_one_or_none():
        slug = f"{slug}-{secrets.token_hex(3)}"

    # Generate secure random API key
    raw_api_key = f"al_live_{secrets.token_hex(24)}"
    api_key_hash = hashlib.sha256(raw_api_key.encode("utf-8")).hexdigest()

    project = Project(
        id=uuid4(),
        name=payload.name,
        slug=slug,
        api_key_hash=api_key_hash,
        is_active=True,
        settings=payload.settings or {},
    )
    session.add(project)
    await session.flush()

    # Automatically provision default environments for the new project
    for env_name in ["development", "production"]:
        default_env = Environment(
            id=uuid4(),
            project_id=project.id,
            name=env_name,
            slug=env_name,
        )
        session.add(default_env)

    await session.commit()
    await session.refresh(project)

    return ProjectCreateResponse(
        id=project.id,
        name=project.name,
        slug=project.slug,
        is_active=project.is_active,
        created_at=project.created_at,
        updated_at=project.updated_at,
        settings=project.settings or {},
        api_key=raw_api_key,
    )


@router.get("/{project_id}", response_model=ProjectResponse)
async def get_project(
    project_id: UUID,
    session: AsyncSession = Depends(get_db_session),
) -> ProjectResponse:
    """Retrieves a single project by UUID."""
    result = await session.execute(select(Project).where(Project.id == project_id))
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Project '{project_id}' not found",
        )
    return project


@router.patch("/{project_id}", response_model=ProjectResponse)
@router.put("/{project_id}", response_model=ProjectResponse)
async def update_project(
    project_id: UUID,
    payload: ProjectUpdate,
    session: AsyncSession = Depends(get_db_session),
) -> ProjectResponse:
    """Updates an existing project's name or settings."""
    result = await session.execute(select(Project).where(Project.id == project_id))
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Project '{project_id}' not found",
        )

    if payload.name is not None:
        project.name = payload.name
    if payload.settings is not None:
        project.settings = {**project.settings, **payload.settings}
    project.updated_at = datetime.now(timezone.utc)

    await session.commit()
    await session.refresh(project)
    return project


@router.post("/{project_id}/api-key", response_model=ApiKeyRegenerateResponse)
async def regenerate_api_key(
    project_id: UUID,
    session: AsyncSession = Depends(get_db_session),
) -> ApiKeyRegenerateResponse:
    """Regenerates the API key for a project. Returns the new plaintext key once."""
    result = await session.execute(select(Project).where(Project.id == project_id))
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Project '{project_id}' not found",
        )

    raw_api_key = f"al_live_{secrets.token_hex(24)}"
    project.api_key_hash = hashlib.sha256(raw_api_key.encode("utf-8")).hexdigest()
    project.updated_at = datetime.now(timezone.utc)

    await session.commit()
    return ApiKeyRegenerateResponse(
        project_id=project.id,
        api_key=raw_api_key,
    )
