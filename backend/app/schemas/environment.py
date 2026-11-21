from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field


class EnvironmentCreate(BaseModel):
    project_id: Optional[UUID] = None
    name: str = Field(..., min_length=1, max_length=64)
    slug: Optional[str] = Field(None, max_length=64)


class EnvironmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    project_id: UUID
    name: str
    slug: str
    created_at: datetime
