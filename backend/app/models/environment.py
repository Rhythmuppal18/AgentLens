from datetime import datetime
from typing import TYPE_CHECKING
import uuid

from sqlalchemy import DateTime, ForeignKey, Index, String, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.project import Project
    from app.models.trace import Trace


class Environment(Base):
    """Represents isolated runtime deployment tiers within a project."""

    __tablename__ = "environments"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        server_default=func.gen_random_uuid(),
    )
    project_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("projects.id", ondelete="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(64), nullable=False)
    slug: Mapped[str] = mapped_column(String(32), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.now,
        server_default=func.clock_timestamp(),
    )

    __table_args__ = (
        UniqueConstraint("project_id", "slug", name="uq_project_env_slug"),
        # Compound constraint required for foreign key referential integrity from traces
        UniqueConstraint("id", "project_id", name="uq_environments_id_project_id"),
        Index("idx_environments_project_id", "project_id"),
    )

    # Relationships
    project: Mapped["Project"] = relationship("Project", back_populates="environments")
    traces: Mapped[list["Trace"]] = relationship(
        "Trace",
        back_populates="environment",
        cascade="all, delete-orphan",
        primaryjoin="and_(Environment.id == foreign(Trace.environment_id), Environment.project_id == foreign(Trace.project_id))",
        overlaps="traces,project",
    )
