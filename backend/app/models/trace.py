from datetime import datetime
from decimal import Decimal
from typing import TYPE_CHECKING, Optional
import uuid

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    ForeignKeyConstraint,
    Index,
    Integer,
    Numeric,
    String,
    false,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, foreign, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.environment import Environment
    from app.models.event import Event
    from app.models.finding import FailureFinding
    from app.models.project import Project
    from app.models.span import Span


class Trace(Base):
    """Represents a discrete end-to-end agent workflow execution session."""

    __tablename__ = "traces"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    project_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("projects.id", ondelete="CASCADE"),
        nullable=False,
    )
    environment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    agent_name: Mapped[str] = mapped_column(String(128), nullable=False)
    session_id: Mapped[Optional[str]] = mapped_column(String(128), nullable=True)
    user_identifier: Mapped[Optional[str]] = mapped_column(String(128), nullable=True)
    status: Mapped[str] = mapped_column(
        String(32),
        nullable=False,
        default="RUNNING",
        server_default=text("'RUNNING'"),
    )
    start_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_time: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    duration_ms: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)

    # Cost and token metrics remain strictly nullable when unavailable (never fabricated)
    total_tokens: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    prompt_tokens: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    completion_tokens: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    estimated_cost_usd: Mapped[Optional[Decimal]] = mapped_column(Numeric(10, 6), nullable=True)

    root_span_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    span_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default=text("0"))
    has_failures: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
    metadata_: Mapped[dict] = mapped_column(
        "metadata",
        JSONB,
        nullable=False,
        default=dict,
        server_default=text("'{}'::jsonb"),
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.now,
        server_default=func.clock_timestamp(),
    )

    def __init__(self, **kwargs):
        """Allows initializing with 'metadata' without conflicting with DeclarativeBase.metadata."""
        if "metadata" in kwargs and "metadata_" not in kwargs:
            kwargs["metadata_"] = kwargs.pop("metadata")
        super().__init__(**kwargs)

    @property
    def trace_metadata(self) -> dict:
        """Accesses the trace JSONB metadata payload without conflicting with DeclarativeBase.metadata."""
        return self.metadata_

    @trace_metadata.setter
    def trace_metadata(self, value: dict) -> None:
        self.metadata_ = value

    __table_args__ = (
        # Enforce referential consistency: environment must belong to the same project
        ForeignKeyConstraint(
            ["environment_id", "project_id"],
            ["environments.id", "environments.project_id"],
            name="fk_traces_env_project",
            ondelete="CASCADE",
        ),
        Index("idx_traces_proj_env_start", "project_id", "environment_id", text("start_time DESC")),
        Index("idx_traces_status", "status"),
        Index("idx_traces_has_failures", "has_failures", postgresql_where=text("has_failures = TRUE")),
        Index("idx_traces_agent_name", "agent_name"),
        Index("idx_traces_session_id", "session_id", postgresql_where=text("session_id IS NOT NULL")),
        Index("idx_traces_metadata_gin", "metadata", postgresql_using="gin"),
    )

    # Relationships
    project: Mapped["Project"] = relationship("Project", back_populates="traces", overlaps="traces,environment")
    environment: Mapped["Environment"] = relationship(
        "Environment",
        back_populates="traces",
        primaryjoin="and_(foreign(Trace.environment_id) == Environment.id, foreign(Trace.project_id) == Environment.project_id)",
        overlaps="traces,project",
    )
    spans: Mapped[list["Span"]] = relationship(
        "Span",
        back_populates="trace",
        cascade="all, delete-orphan",
        primaryjoin="Trace.id == foreign(Span.trace_id)",
        overlaps="children,parent",
    )
    events: Mapped[list["Event"]] = relationship(
        "Event",
        back_populates="trace",
        cascade="all, delete-orphan",
        primaryjoin="Trace.id == foreign(Event.trace_id)",
        overlaps="events,span",
    )
    failure_findings: Mapped[list["FailureFinding"]] = relationship(
        "FailureFinding",
        back_populates="trace",
        cascade="all, delete-orphan",
        primaryjoin="Trace.id == foreign(FailureFinding.trace_id)",
        overlaps="failure_findings,span",
    )
