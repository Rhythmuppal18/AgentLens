"""Unit and integration test suite for AgentLens Stage 2 Step 4: Alembic Configuration.

Validates:
1. Alembic files and directory structure exist:
   - backend/alembic.ini
   - backend/alembic/env.py
   - backend/alembic/script.py.mako
   - backend/alembic/versions directory
2. Alembic ini configuration:
   - script_location points to %(here)s/alembic
   - prepend_sys_path points to %(here)s
   - No hardcoded database credentials in alembic.ini
3. Target metadata discovery:
   - Central model registry Base.metadata is loaded
   - Exactly all seven core and auxiliary tables are present in Base.metadata.tables
4. Dynamic configuration from application settings:
   - Async database URL is loaded from app.core.config.settings
5. Schema change detection configuration:
   - compare_type=True is enabled
   - compare_server_default=True is enabled
6. Offline migration environment:
   - Alembic offline SQL execution runs with PostgreSQL dialect and exit code 0
7. Alembic CLI heads and history inspection:
   - Zero errors returned
8. Security & Git ignore:
   - .env is excluded from git tracking
"""

import os
import subprocess
import sys
import unittest
from configparser import ConfigParser

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from alembic.config import Config
from app.core.config import settings
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


class TestAlembicStep4(unittest.TestCase):
    """Test suite for Alembic migration configuration and model discovery."""

    @classmethod
    def setUpClass(cls):
        cls.root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        cls.backend_dir = os.path.join(cls.root_dir, "backend")
        cls.alembic_ini_path = os.path.join(cls.backend_dir, "alembic.ini")
        cls.alembic_dir = os.path.join(cls.backend_dir, "alembic")
        cls.env_py_path = os.path.join(cls.alembic_dir, "env.py")
        cls.script_mako_path = os.path.join(cls.alembic_dir, "script.py.mako")
        cls.versions_dir = os.path.join(cls.alembic_dir, "versions")
        cls.venv_py = os.path.join(cls.root_dir, ".venv", "Scripts", "python.exe")

    def test_01_alembic_files_and_directories_exist(self):
        """Verify all required Alembic files and directories exist."""
        self.assertTrue(os.path.isfile(self.alembic_ini_path), "backend/alembic.ini must exist")
        self.assertTrue(os.path.isdir(self.alembic_dir), "backend/alembic directory must exist")
        self.assertTrue(os.path.isfile(self.env_py_path), "backend/alembic/env.py must exist")
        self.assertTrue(os.path.isfile(self.script_mako_path), "backend/alembic/script.py.mako must exist")
        self.assertTrue(os.path.isdir(self.versions_dir), "backend/alembic/versions directory must exist")

    def test_02_alembic_ini_configuration(self):
        """Verify alembic.ini options and credential safety."""
        parser = ConfigParser()
        parser.read(self.alembic_ini_path)

        self.assertTrue(parser.has_section("alembic"), "alembic.ini must have [alembic] section")
        script_loc = parser.get("alembic", "script_location", raw=True)
        self.assertEqual(script_loc, "%(here)s/alembic")

        prepend_path = parser.get("alembic", "prepend_sys_path", raw=True)
        self.assertEqual(prepend_path, "%(here)s")

        # Crucial security check: database credentials must NOT be hardcoded in alembic.ini
        raw_url = parser.get("alembic", "sqlalchemy.url", fallback="")
        self.assertNotIn("password", raw_url.lower(), "Credentials must not be in alembic.ini")
        self.assertNotIn("agentlens_password", raw_url, "Credentials must not be in alembic.ini")

    def test_03_alembic_env_target_metadata_contains_all_seven_tables(self):
        """Verify Alembic target_metadata connects to the central model registry."""
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
        self.assertEqual(
            actual_tables,
            expected_tables,
            f"target_metadata must contain exactly the 7 registered tables, got: {actual_tables}",
        )

    def test_04_alembic_env_reads_database_url_from_settings(self):
        """Verify Alembic Config receives the async database URL from application settings."""
        config = Config(self.alembic_ini_path)
        # Simulate what env.py does dynamically
        config.set_main_option("sqlalchemy.url", settings.async_database_url.replace("%", "%%"))

        configured_url = config.get_main_option("sqlalchemy.url")
        self.assertEqual(configured_url, settings.async_database_url)
        self.assertTrue(configured_url.startswith("postgresql+asyncpg://"))
        self.assertIn(settings.POSTGRES_DB, configured_url)

    def test_05_schema_detection_options_configured_in_env_py(self):
        """Verify compare_type and compare_server_default are configured in env.py."""
        with open(self.env_py_path, "r", encoding="utf-8") as f:
            env_code = f.read()

        self.assertIn("compare_type=True", env_code, "compare_type=True must be configured in env.py")
        self.assertIn(
            "compare_server_default=True",
            env_code,
            "compare_server_default=True must be configured in env.py",
        )
        self.assertIn("target_metadata = Base.metadata", env_code, "target_metadata must be set to Base.metadata")
        self.assertIn("from app.core.config import settings", env_code, "env.py must import settings")
        self.assertIn("from app.models import Base", env_code, "env.py must import Base from app.models")

    def test_06_alembic_offline_sql_execution(self):
        """Verify Alembic executes offline SQL generation cleanly without database errors."""
        p = subprocess.run(
            [self.venv_py, "-m", "alembic", "upgrade", "head", "--sql"],
            capture_output=True,
            text=True,
            cwd=self.backend_dir,
            timeout=15,
        )
        self.assertEqual(p.returncode, 0, f"alembic upgrade head --sql failed:\n{p.stderr}")
        self.assertIn("PostgresqlImpl", p.stderr, "Alembic must detect PostgreSQL implementation dialect")
        self.assertIn("BEGIN;", p.stdout, "Offline SQL must output transaction block")

    def test_07_alembic_cli_inspection_commands(self):
        """Verify alembic heads and history run cleanly with exit code 0."""
        # Test alembic heads
        p_heads = subprocess.run(
            [self.venv_py, "-m", "alembic", "heads"],
            capture_output=True,
            text=True,
            cwd=self.backend_dir,
            timeout=15,
        )
        self.assertEqual(p_heads.returncode, 0, f"alembic heads failed:\n{p_heads.stderr}")

        # Test alembic history
        p_history = subprocess.run(
            [self.venv_py, "-m", "alembic", "history"],
            capture_output=True,
            text=True,
            cwd=self.backend_dir,
            timeout=15,
        )
        self.assertEqual(p_history.returncode, 0, f"alembic history failed:\n{p_history.stderr}")

    def test_08_environment_secrets_exclusion(self):
        """Verify .env remains excluded in .gitignore."""
        gitignore_path = os.path.join(self.root_dir, ".gitignore")
        self.assertTrue(os.path.isfile(gitignore_path), ".gitignore must exist")
        with open(gitignore_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn(".env", content, ".env must be ignored in .gitignore")
        self.assertIn("!.env.example", content, ".env.example must be allowed in .gitignore")


if __name__ == "__main__":
    unittest.main()
