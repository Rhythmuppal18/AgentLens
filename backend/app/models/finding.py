from datetime import datetime
import hashlib
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
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
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.event import Event
    from app.models.span import Span
    from app.models.trace import Trace


class FailureFinding(Base):
    """Represents an evidence-backed defect identified by deterministic rules."""

    __tablename__ = "failure_findings"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    finding_fingerprint: Mapped[str] = mapped_column(
        String(64),
        unique=True,
        nullable=False,
        index=True,
    )
    rule_version: Mapped[str] = mapped_column(
        String(16),
        nullable=False,
        default="v1.0.0",
        server_default=text("'v1.0.0'"),
    )
    trace_id: Mapped[str] = mapped_column(
        String(64),
        ForeignKey("traces.id", ondelete="CASCADE"),
        nullable=False,
    )
    span_id: Mapped[Optional[str]] = mapped_column(
        String(64),
        nullable=True,
    )
    rule_type: Mapped[str] = mapped_column(String(64), nullable=False)
    severity: Mapped[str] = mapped_column(String(32), nullable=False)
    iteration_count: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=1,
        server_default=text("1"),
    )
    summary: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_summary: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_data: Mapped[dict] = mapped_column(JSONB, nullable=False)
    first_detected_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.now,
        server_default=func.clock_timestamp(),
    )
    last_updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
        server_default=func.clock_timestamp(),
    )

    @staticmethod
    def generate_fingerprint(
        rule_type: str,
        trace_id: str,
        span_id: Optional[str] = None,
        rule_version: str = "v1.0.0",
    ) -> str:
        """Computes deterministic SHA-256 finding fingerprint.

        Approved formula: SHA256(rule_type + ":" + trace_id + ":" + COALESCE(span_id, '') + ":" + rule_version)
        """
        s_id = span_id or ""
        raw = f"{rule_type}:{trace_id}:{s_id}:{rule_version}"
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()

    __table_args__ = (
        ForeignKeyConstraint(
            ["span_id", "trace_id"],
            ["spans.id", "spans.trace_id"],
            name="fk_findings_span_same_trace",
            ondelete="CASCADE",
        ),
        Index("idx_findings_trace_id", "trace_id"),
        Index("idx_findings_rule_type", "rule_type"),
        Index("idx_findings_severity", "severity"),
        Index("idx_findings_detected", text("first_detected_at DESC")),
    )

    # Relationships
    trace: Mapped["Trace"] = relationship(
        "Trace",
        back_populates="failure_findings",
        primaryjoin="foreign(FailureFinding.trace_id) == Trace.id",
        overlaps="failure_findings,span",
    )
    span: Mapped[Optional["Span"]] = relationship(
        "Span",
        back_populates="failure_findings",
        primaryjoin="foreign(FailureFinding.span_id) == Span.id",
        overlaps="failure_findings,trace",
    )
    evidence_links: Mapped[list["FindingEvidenceLink"]] = relationship(
        "FindingEvidenceLink",
        back_populates="finding",
        cascade="all, delete-orphan",
        primaryjoin="FailureFinding.id == foreign(FindingEvidenceLink.finding_id)",
    )


class FindingEvidenceLink(Base):
    """Auxiliary junction table linking a finding to multiple contributing spans/events."""

    __tablename__ = "finding_evidence_links"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    finding_id: Mapped[str] = mapped_column(
        String(64),
        ForeignKey("failure_findings.id", ondelete="CASCADE"),
        nullable=False,
    )
    span_id: Mapped[Optional[str]] = mapped_column(
        String(64),
        ForeignKey("spans.id", ondelete="CASCADE"),
        nullable=True,
    )
    event_id: Mapped[Optional[str]] = mapped_column(
        String(64),
        ForeignKey("events.id", ondelete="CASCADE"),
        nullable=True,
    )
    role: Mapped[str] = mapped_column(
        String(64),
        nullable=False,
        default="contributing",
        server_default=text("'contributing'"),
    )
    evidence_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.now,
        server_default=func.clock_timestamp(),
    )

    @staticmethod
    def generate_evidence_hash(
        finding_id: str,
        span_id: Optional[str] = None,
        event_id: Optional[str] = None,
        role: str = "contributing",
    ) -> str:
        """Computes deterministic SHA-256 evidence link hash for idempotency.

        Formula: SHA256(finding_id + ":" + COALESCE(span_id, '') + ":" + COALESCE(event_id, '') + ":" + role)
        """
        s_id = span_id or ""
        e_id = event_id or ""
        raw = f"{finding_id}:{s_id}:{e_id}:{role}"
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()

    __table_args__ = (
        # Ensure at least one evidence target (span or event) is associated
        CheckConstraint("span_id IS NOT NULL OR event_id IS NOT NULL", name="chk_evidence_target"),
        # Idempotency constraint preventing duplicate evidence links on repeated rule evaluation
        UniqueConstraint("finding_id", "evidence_hash", name="uq_finding_evidence_hash"),
        Index("idx_evidence_finding_id", "finding_id"),
        Index("idx_evidence_span_id", "span_id", postgresql_where=text("span_id IS NOT NULL")),
    )

    # Relationships
    finding: Mapped["FailureFinding"] = relationship(
        "FailureFinding",
        back_populates="evidence_links",
        primaryjoin="foreign(FindingEvidenceLink.finding_id) == FailureFinding.id",
    )
    span: Mapped[Optional["Span"]] = relationship(
        "Span",
        back_populates="evidence_links",
        primaryjoin="foreign(FindingEvidenceLink.span_id) == Span.id",
    )
    event: Mapped[Optional["Event"]] = relationship(
        "Event",
        back_populates="evidence_links",
        primaryjoin="foreign(FindingEvidenceLink.event_id) == Event.id",
    )
