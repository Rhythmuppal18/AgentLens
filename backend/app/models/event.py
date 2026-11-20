from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, ForeignKeyConstraint, Index, String, func, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.finding import FindingEvidenceLink
    from app.models.span import Span
    from app.models.trace import Trace


class Event(Base):
    """Represents an instantaneous occurrence or milestone within a span."""

    __tablename__ = "events"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    span_id: Mapped[str] = mapped_column(
        String(64),
        nullable=False,
    )
    trace_id: Mapped[str] = mapped_column(
        String(64),
        ForeignKey("traces.id", ondelete="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(128), nullable=False)
    timestamp: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    data: Mapped[dict] = mapped_column(
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
        # Enforce Event-to-Span consistency: an event cannot reference a span in another trace
        ForeignKeyConstraint(
            ["span_id", "trace_id"],
            ["spans.id", "spans.trace_id"],
            name="fk_events_span_same_trace",
            ondelete="CASCADE",
        ),
        Index("idx_events_span_timestamp", "span_id", text("timestamp ASC")),
        Index("idx_events_trace_id", "trace_id"),
        Index("idx_events_name", "name"),
    )

    # Relationships
    span: Mapped["Span"] = relationship(
        "Span",
        back_populates="events",
        primaryjoin="and_(foreign(Event.span_id) == Span.id, foreign(Event.trace_id) == Span.trace_id)",
        overlaps="events,trace",
    )
    trace: Mapped["Trace"] = relationship(
        "Trace",
        back_populates="events",
        primaryjoin="foreign(Event.trace_id) == Trace.id",
        overlaps="events,span",
    )
    evidence_links: Mapped[list["FindingEvidenceLink"]] = relationship(
        "FindingEvidenceLink",
        back_populates="event",
        passive_deletes=True,
        primaryjoin="Event.id == foreign(FindingEvidenceLink.event_id)",
    )
