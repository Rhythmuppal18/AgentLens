from datetime import datetime
from typing import Any, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field


class ProjectCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    slug: Optional[str] = Field(None, max_length=128)
    settings: Optional[dict[str, Any]] = Field(default_factory=dict)


class ProjectUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=128)
    settings: Optional[dict[str, Any]] = None


class ProjectResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    slug: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    settings: dict[str, Any]


class ProjectCreateResponse(ProjectResponse):
    api_key: str  # Plaintext key returned only once upon initial project creation


class ApiKeyRegenerateResponse(BaseModel):
    project_id: UUID
    api_key: str
