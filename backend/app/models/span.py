from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DateTime,
    ForeignKey,
    ForeignKeyConstraint,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, foreign, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.event import Event
    from app.models.finding import FailureFinding, FindingEvidenceLink
    from app.models.trace import Trace


class Span(Base):
    """Represents a discrete hierarchical unit of work in a trace."""

    __tablename__ = "spans"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    trace_id: Mapped[str] = mapped_column(
        String(64),
        ForeignKey("traces.id", ondelete="CASCADE"),
        nullable=False,
    )
    parent_span_id: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    span_type: Mapped[str] = mapped_column(String(32), nullable=False)
    status: Mapped[str] = mapped_column(
        String(32),
        nullable=False,
        default="RUNNING",
        server_default=text("'RUNNING'"),
    )
    start_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_time: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    duration_ms: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    input_payload: Mapped[Optional[dict]] = mapped_column(JSONB, nullable=True)
    input_hash: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    output_payload: Mapped[Optional[dict]] = mapped_column(JSONB, nullable=True)
    error_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    error_type: Mapped[Optional[str]] = mapped_column(String(128), nullable=True)
    error_stack: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    attributes: Mapped[dict] = mapped_column(
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

    __table_args__ = (
        # Enforce intra-trace boundary for parent-child spans
        UniqueConstraint("id", "trace_id", name="uq_spans_id_trace_id"),
        # Compound Foreign Key with column-specific nullification on parent span deletion
        ForeignKeyConstraint(
            ["parent_span_id", "trace_id"],
            ["spans.id", "spans.trace_id"],
            name="fk_spans_parent_same_trace",
            ondelete="SET NULL (parent_span_id)",
        ),
        Index("idx_spans_trace_id_start", "trace_id", text("start_time ASC")),
        Index("idx_spans_parent_span_id", "parent_span_id"),
        Index("idx_spans_span_type", "span_type"),
        Index("idx_spans_status_error", "trace_id", "status", postgresql_where=text("status = 'ERROR'")),
        Index("idx_spans_input_hash", "trace_id", "input_hash", postgresql_where=text("input_hash IS NOT NULL")),
        Index("idx_spans_attributes_gin", "attributes", postgresql_using="gin"),
    )

    # Relationships
    trace: Mapped["Trace"] = relationship(
        "Trace",
        back_populates="spans",
        primaryjoin="foreign(Span.trace_id) == Trace.id",
        overlaps="children,parent",
    )
    parent: Mapped[Optional["Span"]] = relationship(
        "Span",
        back_populates="children",
        primaryjoin="and_(foreign(Span.parent_span_id) == Span.id, foreign(Span.trace_id) == Span.trace_id)",
        remote_side=[id, trace_id],
        overlaps="children,spans,trace",
    )
    children: Mapped[list["Span"]] = relationship(
        "Span",
        back_populates="parent",
        overlaps="parent,spans,trace",
    )
    events: Mapped[list["Event"]] = relationship(
        "Event",
        back_populates="span",
        cascade="all, delete-orphan",
        primaryjoin="and_(Span.id == foreign(Event.span_id), Span.trace_id == foreign(Event.trace_id))",
        overlaps="events,trace",
    )
    failure_findings: Mapped[list["FailureFinding"]] = relationship(
        "FailureFinding",
        back_populates="span",
        cascade="all, delete-orphan",
        primaryjoin="Span.id == foreign(FailureFinding.span_id)",
        overlaps="failure_findings,trace",
    )
    evidence_links: Mapped[list["FindingEvidenceLink"]] = relationship(
        "FindingEvidenceLink",
        back_populates="span",
        passive_deletes=True,
        primaryjoin="Span.id == foreign(FindingEvidenceLink.span_id)",
    )
