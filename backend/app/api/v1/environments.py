import re
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.environment import Environment
from app.models.project import Project
from app.schemas.environment import EnvironmentCreate, EnvironmentResponse

router = APIRouter(tags=["Environments"])


def _slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    return re.sub(r"[-\s]+", "-", text) or "env"


@router.get("", response_model=list[EnvironmentResponse])
async def list_environments(
    project_id: Optional[UUID] = Query(None, description="Filter environments by project UUID"),
    session: AsyncSession = Depends(get_db_session),
) -> list[EnvironmentResponse]:
    """Retrieves all environments, optionally filtered by project."""
    query = select(Environment)
    if project_id is not None:
        query = query.where(Environment.project_id == project_id)
    query = query.order_by(Environment.created_at.asc())

    result = await session.execute(query)
    return list(result.scalars().all())


@router.post("", response_model=EnvironmentResponse, status_code=status.HTTP_201_CREATED)
async def create_environment(
    payload: EnvironmentCreate,
    project_id: Optional[UUID] = Query(None, description="Project UUID to associate with this environment"),
    session: AsyncSession = Depends(get_db_session),
) -> EnvironmentResponse:
    """Creates a new environment for a project if it does not already exist."""
    effective_project_id = payload.project_id or project_id
    if not effective_project_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="project_id is required either in request body or query parameter",
        )

    # Verify project exists
    p_res = await session.execute(select(Project).where(Project.id == effective_project_id))
    if not p_res.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Project '{effective_project_id}' not found",
        )

    slug = payload.slug or _slugify(payload.name)

    # Check for existing environment in this project
    existing = await session.execute(
        select(Environment).where(
            Environment.project_id == effective_project_id,
            Environment.slug == slug,
        )
    )
    env = existing.scalar_one_or_none()
    if env:
        return env

    new_env = Environment(
        id=uuid4(),
        project_id=effective_project_id,
        name=payload.name,
        slug=slug,
    )
    session.add(new_env)
    await session.commit()
    await session.refresh(new_env)
    return new_env
