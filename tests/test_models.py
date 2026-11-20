"""Unit and structural validation test suite for AgentLens Step 3 ORM Models.

Validates:
1. All models and Base export cleanly with zero circular imports.
2. Metadata contains exactly the 6 core business tables and 1 auxiliary table.
3. Column names, types, nullability, defaults match approved database design.
4. Primary keys, foreign keys, unique constraints, and check constraints match spec.
5. Critical PostgreSQL-specific constraints:
   - Compound self-reference for spans (parent_span_id, trace_id) -> spans(id, trace_id)
     with ON DELETE SET NULL (parent_span_id).
   - Compound foreign key for traces (environment_id, project_id) -> environments(id, project_id)
     with ON DELETE CASCADE.
   - Compound foreign key for events (span_id, trace_id) -> spans(id, trace_id)
     with ON DELETE CASCADE (enforcing Event-to-Span intra-trace consistency).
   - Check constraint chk_evidence_target on finding_evidence_links.
   - Unique idempotency constraints on failure_findings and finding_evidence_links.
6. Nullability of metric fields (tokens and cost are strictly nullable when absent).
7. Trace model mapping of database "metadata" column without overriding DeclarativeBase.metadata.
8. Deterministic SHA-256 finding fingerprint and evidence hash generation algorithms.
9. Full DDL compilation against PostgreSQL dialect.
10. Strict mapper configuration with zero warnings.
"""

import hashlib
import os
import sys
import unittest
import warnings

# Ensure backend directory is in Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKeyConstraint,
    Integer,
    MetaData,
    Numeric,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects import postgresql
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import configure_mappers
from sqlalchemy.schema import CreateTable

from app.models import (
    Base,
    Environment,
    Event,
    FailureFinding,
    FindingEvidenceLink,
    Project,
    Span,
    Trace,
)


class TestModelsSchema(unittest.TestCase):
    """Structural, metadata, and formula tests for AgentLens SQLAlchemy 2.0 models."""

    def test_01_all_models_importable_and_no_circular_imports(self):
        """Verify all 6 core models, auxiliary model, and Base are registered."""
        models = [Project, Environment, Trace, Span, Event, FailureFinding, FindingEvidenceLink]
        for m in models:
            self.assertTrue(issubclass(m, Base), f"{m.__name__} must be a subclass of Base")

    def test_02_metadata_contains_all_seven_tables(self):
        """Verify Base.metadata contains the 6 core business tables + 1 auxiliary table."""
        expected_tables = {
            "projects",
            "environments",
            "traces",
            "spans",
            "events",
            "failure_findings",
            "finding_evidence_links",
        }
        actual_tables = set(Base.metadata.tables.keys())
        self.assertEqual(expected_tables, actual_tables)

    def test_03_projects_table_schema(self):
        """Verify projects table structure and constraints."""
        table = Base.metadata.tables["projects"]
        # Primary key
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])
        self.assertIsInstance(table.c.id.type, UUID)

        # Columns
        self.assertIsInstance(table.c.name.type, String)
        self.assertFalse(table.c.name.nullable)
        self.assertIsInstance(table.c.slug.type, String)
        self.assertFalse(table.c.slug.nullable)
        self.assertTrue(table.c.slug.unique)
        self.assertIsInstance(table.c.description.type, Text)
        self.assertTrue(table.c.description.nullable)
        self.assertIsInstance(table.c.api_key_hash.type, String)
        self.assertTrue(table.c.api_key_hash.nullable)
        self.assertIsInstance(table.c.settings.type, JSONB)
        self.assertFalse(table.c.settings.nullable)
        self.assertIsInstance(table.c.is_active.type, Boolean)
        self.assertFalse(table.c.is_active.nullable)
        self.assertIsInstance(table.c.created_at.type, DateTime)
        self.assertIsInstance(table.c.updated_at.type, DateTime)

    def test_04_environments_table_schema(self):
        """Verify environments table structure, FK, and compound unique constraints."""
        table = Base.metadata.tables["environments"]
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])
        self.assertIsInstance(table.c.id.type, UUID)
        self.assertIsInstance(table.c.project_id.type, UUID)

        # Foreign key to projects.id with CASCADE
        fks = list(table.foreign_keys)
        self.assertEqual(len(fks), 1)
        self.assertEqual(fks[0].target_fullname, "projects.id")
        self.assertEqual(fks[0].ondelete, "CASCADE")

        # Unique constraints
        uq_names = {uq.name for uq in table.constraints if isinstance(uq, UniqueConstraint)}
        self.assertIn("uq_project_env_slug", uq_names)
        self.assertIn("uq_environments_id_project_id", uq_names)

        # Verify compound constraint (id, project_id) exists for trace referential consistency
        id_proj_uq = next(uq for uq in table.constraints if uq.name == "uq_environments_id_project_id")
        self.assertEqual({c.name for c in id_proj_uq.columns}, {"id", "project_id"})

    def test_05_traces_table_schema_and_metrics_nullability(self):
        """Verify traces schema, metrics nullability, and compound environment-project FK."""
        table = Base.metadata.tables["traces"]
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])

        # Cost and token usage fields MUST remain nullable when actual usage is unavailable
        self.assertTrue(table.c.total_tokens.nullable, "total_tokens must be nullable")
        self.assertTrue(table.c.prompt_tokens.nullable, "prompt_tokens must be nullable")
        self.assertTrue(table.c.completion_tokens.nullable, "completion_tokens must be nullable")
        self.assertTrue(table.c.estimated_cost_usd.nullable, "estimated_cost_usd must be nullable")
        self.assertIsInstance(table.c.estimated_cost_usd.type, Numeric)
        self.assertEqual(table.c.estimated_cost_usd.type.precision, 10)
        self.assertEqual(table.c.estimated_cost_usd.type.scale, 6)

        # Compound FK to environments(id, project_id)
        compound_fks = [c for c in table.constraints if isinstance(c, ForeignKeyConstraint) and c.name == "fk_traces_env_project"]
        self.assertEqual(len(compound_fks), 1, "Must enforce fk_traces_env_project compound foreign key")
        fk = compound_fks[0]
        self.assertEqual([c.name for c in fk.columns], ["environment_id", "project_id"])
        self.assertEqual(fk.ondelete, "CASCADE")

    def test_06_spans_compound_self_reference_and_nullification(self):
        """Verify spans schema and compound foreign key with column-specific nullification."""
        table = Base.metadata.tables["spans"]
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])

        # Compound unique constraint (id, trace_id)
        uqs = [c for c in table.constraints if isinstance(c, UniqueConstraint) and c.name == "uq_spans_id_trace_id"]
        self.assertEqual(len(uqs), 1)
        self.assertEqual({c.name for c in uqs[0].columns}, {"id", "trace_id"})

        # Compound FK (parent_span_id, trace_id) -> spans(id, trace_id)
        same_trace_fks = [c for c in table.constraints if isinstance(c, ForeignKeyConstraint) and c.name == "fk_spans_parent_same_trace"]
        self.assertEqual(len(same_trace_fks), 1, "Must enforce fk_spans_parent_same_trace compound self-referencing FK")
        fk = same_trace_fks[0]
        self.assertEqual([col.name for col in fk.columns], ["parent_span_id", "trace_id"])
        self.assertEqual(fk.ondelete, "SET NULL (parent_span_id)")

        # Verify trace_id FK to traces.id
        trace_fks = [c for c in table.foreign_keys if c.column.table.name == "traces"]
        self.assertTrue(len(trace_fks) >= 1)
        self.assertEqual(trace_fks[0].ondelete, "CASCADE")

    def test_07_events_table_schema_and_intra_trace_consistency(self):
        """Verify events schema and Event-to-Span intra-trace consistency compound FK."""
        table = Base.metadata.tables["events"]
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])
        self.assertFalse(table.c.span_id.nullable)
        self.assertFalse(table.c.trace_id.nullable)
        self.assertFalse(table.c.name.nullable)
        self.assertFalse(table.c.timestamp.nullable)
        self.assertFalse(table.c.data.nullable)

        # Compound FK enforcing that an event cannot reference a span in another trace
        compound_fks = [c for c in table.constraints if isinstance(c, ForeignKeyConstraint) and c.name == "fk_events_span_same_trace"]
        self.assertEqual(len(compound_fks), 1, "Must enforce fk_events_span_same_trace compound foreign key")
        fk = compound_fks[0]
        self.assertEqual([col.name for col in fk.columns], ["span_id", "trace_id"])
        self.assertEqual(fk.ondelete, "CASCADE")

    def test_08_failure_findings_idempotency_fingerprint(self):
        """Verify failure_findings schema and deterministic fingerprint unique constraint."""
        table = Base.metadata.tables["failure_findings"]
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])
        self.assertTrue(table.c.finding_fingerprint.unique, "finding_fingerprint must be unique for idempotent detection")
        self.assertFalse(table.c.finding_fingerprint.nullable)
        self.assertFalse(table.c.rule_version.nullable)
        self.assertFalse(table.c.rule_type.nullable)
        self.assertFalse(table.c.severity.nullable)
        self.assertFalse(table.c.iteration_count.nullable)
        self.assertFalse(table.c.summary.nullable)
        self.assertFalse(table.c.evidence_summary.nullable)
        self.assertFalse(table.c.evidence_data.nullable)

    def test_09_finding_evidence_links_auxiliary_table(self):
        """Verify finding_evidence_links auxiliary junction table, check constraint, and unique hash."""
        table = Base.metadata.tables["finding_evidence_links"]
        self.assertEqual([c.name for c in table.primary_key.columns], ["id"])
        self.assertIsInstance(table.c.id.type, BigInteger)

        # Check constraint: at least span_id or event_id must be provided
        chk_constraints = [c for c in table.constraints if isinstance(c, CheckConstraint) and c.name == "chk_evidence_target"]
        self.assertEqual(len(chk_constraints), 1, "Must enforce chk_evidence_target check constraint")

        # Unique constraint on (finding_id, evidence_hash) for idempotency
        uq_hashes = [c for c in table.constraints if isinstance(c, UniqueConstraint) and c.name == "uq_finding_evidence_hash"]
        self.assertEqual(len(uq_hashes), 1, "Must enforce uq_finding_evidence_hash unique constraint")
        self.assertEqual({c.name for c in uq_hashes[0].columns}, {"finding_id", "evidence_hash"})

    def test_10_postgresql_ddl_compilation(self):
        """Verify all 7 table DDL statements compile cleanly against PostgreSQL dialect."""
        dialect = postgresql.dialect()
        compiled_ddls = {}
        for table in Base.metadata.sorted_tables:
            ddl = str(CreateTable(table).compile(dialect=dialect)).strip()
            compiled_ddls[table.name] = ddl
            self.assertTrue(ddl.startswith(f"CREATE TABLE {table.name}"))

        # Verify PostgreSQL 16 compound self-reference in compiled DDL
        spans_ddl = compiled_ddls["spans"]
        self.assertIn("ON DELETE SET NULL (parent_span_id)", spans_ddl)
        self.assertIn("CONSTRAINT uq_spans_id_trace_id UNIQUE (id, trace_id)", spans_ddl)

        # Verify compound project consistency FK in traces DDL
        traces_ddl = compiled_ddls["traces"]
        self.assertIn("CONSTRAINT fk_traces_env_project FOREIGN KEY(environment_id, project_id) REFERENCES environments (id, project_id) ON DELETE CASCADE", traces_ddl)

        # Verify compound Event-to-Span intra-trace consistency FK in events DDL
        events_ddl = compiled_ddls["events"]
        self.assertIn("CONSTRAINT fk_events_span_same_trace FOREIGN KEY(span_id, trace_id) REFERENCES spans (id, trace_id) ON DELETE CASCADE", events_ddl)

        # Verify evidence target check constraint in finding_evidence_links DDL
        evidence_ddl = compiled_ddls["finding_evidence_links"]
        self.assertIn("CONSTRAINT chk_evidence_target CHECK (span_id IS NOT NULL OR event_id IS NOT NULL)", evidence_ddl)
        self.assertIn("CONSTRAINT uq_finding_evidence_hash UNIQUE (finding_id, evidence_hash)", evidence_ddl)

    def test_11_trace_metadata_attribute_safety(self):
        """Verify Trace model maps database metadata column without overriding DeclarativeBase.metadata."""
        # Class-level metadata must strictly remain the SQLAlchemy MetaData registry
        self.assertIsInstance(Trace.metadata, MetaData)
        self.assertIs(Trace.metadata, Base.metadata)

        # Instance initialized with metadata_
        t1 = Trace(id="trc_1", metadata_={"env": "staging", "sdk_version": "0.1.0"})
        self.assertEqual(t1.metadata_, {"env": "staging", "sdk_version": "0.1.0"})
        self.assertEqual(t1.trace_metadata, {"env": "staging", "sdk_version": "0.1.0"})
        self.assertIs(t1.metadata, Base.metadata)

        # Instance initialized via 'metadata' parameter seamlessly redirected by __init__
        t2 = Trace(id="trc_2", metadata={"env": "prod", "cluster": "us-east-1"})
        self.assertEqual(t2.metadata_, {"env": "prod", "cluster": "us-east-1"})
        self.assertEqual(t2.trace_metadata, {"env": "prod", "cluster": "us-east-1"})
        self.assertIs(t2.metadata, Base.metadata)

    def test_12_finding_fingerprint_generation_formula(self):
        """Verify FailureFinding.generate_fingerprint implements the approved SHA256 formula:
        SHA256(rule_type + ":" + trace_id + ":" + COALESCE(span_id, '') + ":" + rule_version)
        """
        trace_id = "trc_test_001"
        span_id = "spn_test_002"
        rule_type = "REPEATED_TOOL_CALL"
        rule_version = "v1.0.0"

        expected_raw = f"{rule_type}:{trace_id}:{span_id}:{rule_version}"
        expected_hash = hashlib.sha256(expected_raw.encode("utf-8")).hexdigest()

        actual_hash = FailureFinding.generate_fingerprint(
            rule_type=rule_type,
            trace_id=trace_id,
            span_id=span_id,
            rule_version=rule_version,
        )
        self.assertEqual(actual_hash, expected_hash)

        # Handling when span_id is None / COALESCE(span_id, '')
        none_span_raw = f"{rule_type}:{trace_id}::{rule_version}"
        expected_none_hash = hashlib.sha256(none_span_raw.encode("utf-8")).hexdigest()
        self.assertEqual(
            FailureFinding.generate_fingerprint(rule_type, trace_id, None, rule_version),
            expected_none_hash,
        )

    def test_13_evidence_link_hash_generation_formula(self):
        """Verify FindingEvidenceLink.generate_evidence_hash implements the approved SHA256 formula."""
        finding_id = "flr_test_100"
        span_id = "spn_trigger_01"
        role = "trigger"

        expected_raw = f"{finding_id}:{span_id}::{role}"
        expected_hash = hashlib.sha256(expected_raw.encode("utf-8")).hexdigest()

        actual_hash = FindingEvidenceLink.generate_evidence_hash(
            finding_id=finding_id,
            span_id=span_id,
            event_id=None,
            role=role,
        )
        self.assertEqual(actual_hash, expected_hash)

    def test_14_strict_mapper_configuration_zero_warnings(self):
        """Verify configure_mappers completes with zero warnings under strict error escalation."""
        with warnings.catch_warnings():
            warnings.simplefilter("error")
            configure_mappers()


if __name__ == "__main__":
    unittest.main()
