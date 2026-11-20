"""Test suite for Step 1 & Step 2: Database Configuration and Async Engine.

Validates:
1. Database configuration loading from environment and .env.
2. Connection pool settings (pool_size=5, max_overflow=15, timeout=30, recycle=1800).
3. Async SQLAlchemy 2.0 Engine and AsyncSessionLocal factory.
4. FastAPI database dependency (get_db_session).
5. Engine shutdown cleanup (close_db_engine).
6. FastAPI application endpoints (/ and /health) and CORS middleware configuration.
"""

import inspect
import os
import sys
import unittest
from unittest.mock import AsyncMock, MagicMock, patch

# Ensure backend directory is in Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app.core.config import Settings, settings
from app.core.database import (
    AsyncSessionLocal,
    close_db_engine,
    engine,
    get_db_session,
)
from app.main import app, health_check, root
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker


class TestDatabaseStep2(unittest.IsolatedAsyncioTestCase):
    """Unit and integration tests for Step 2 Async Database Engine."""

    def test_01_configuration_loading(self):
        """Verify environment variables and settings load correctly."""
        self.assertIsInstance(settings, Settings)
        self.assertEqual(settings.POSTGRES_DB, "agentlens")
        self.assertEqual(settings.POSTGRES_USER, "agentlens")
        self.assertEqual(settings.POSTGRES_HOST, "localhost")
        self.assertEqual(settings.POSTGRES_PORT, 5432)
        self.assertEqual(settings.DB_POOL_SIZE, 5)
        self.assertEqual(settings.DB_MAX_OVERFLOW, 15)
        self.assertEqual(settings.DB_POOL_TIMEOUT, 30)
        self.assertEqual(settings.DB_POOL_RECYCLE, 1800)
        self.assertFalse(settings.DB_ECHO)
        self.assertTrue(settings.async_database_url.startswith("postgresql+asyncpg://"))

    def test_02_async_engine_and_pool_configuration(self):
        """Verify the SQLAlchemy 2.0 Async engine and pool parameters."""
        self.assertIsInstance(engine, AsyncEngine)
        self.assertEqual(engine.url.drivername, "postgresql+asyncpg")
        self.assertEqual(engine.url.database, "agentlens")

        # Verify connection pool size and max overflow match approved specifications
        pool = engine.pool
        self.assertEqual(pool.size(), 5, "pool_size must be configured to 5")
        self.assertEqual(pool._max_overflow, 15, "max_overflow must be configured to 15")
        self.assertEqual(pool._timeout, 30, "pool_timeout must be configured to 30")
        self.assertEqual(pool._recycle, 1800, "pool_recycle must be configured to 1800")

    def test_03_async_session_factory(self):
        """Verify AsyncSessionLocal factory configuration."""
        self.assertIsInstance(AsyncSessionLocal, async_sessionmaker)
        self.assertEqual(AsyncSessionLocal.class_, AsyncSession)
        self.assertFalse(AsyncSessionLocal.kw.get("expire_on_commit"))

    def test_04_database_dependency_signature(self):
        """Verify get_db_session is an async generator function."""
        self.assertTrue(
            inspect.isasyncgenfunction(get_db_session),
            "get_db_session must be an async generator function for FastAPI dependency injection",
        )

    async def test_05_database_dependency_success_no_autocommit(self):
        """Verify get_db_session yields session, avoids auto-commit, and closes cleanly."""
        mock_session = AsyncMock(spec=AsyncSession)
        mock_session.__aenter__.return_value = mock_session
        mock_factory = MagicMock(return_value=mock_session)

        with patch("app.core.database.AsyncSessionLocal", mock_factory):
            gen = get_db_session()
            session = await anext(gen)
            self.assertEqual(session, mock_session)
            # Advance generator to simulate clean route completion without write
            try:
                await anext(gen)
            except StopAsyncIteration:
                pass
            # Transactions must NOT be auto-committed; caller must commit explicitly
            mock_session.commit.assert_not_awaited()
            # Session must always be closed
            mock_session.close.assert_awaited()

    async def test_05b_database_dependency_exception_rollback(self):
        """Verify get_db_session rolls back on unhandled exception and closes cleanly."""
        mock_session = AsyncMock(spec=AsyncSession)
        mock_session.__aenter__.return_value = mock_session
        mock_factory = MagicMock(return_value=mock_session)

        with patch("app.core.database.AsyncSessionLocal", mock_factory):
            gen = get_db_session()
            session = await anext(gen)
            self.assertEqual(session, mock_session)
            # Simulate an unhandled exception inside the request handler
            with self.assertRaises(ValueError):
                await gen.athrow(ValueError("Database route failed"))
            # Session must be rolled back on error
            mock_session.rollback.assert_awaited_once()
            # Session must always be closed
            mock_session.close.assert_awaited()

    async def test_06_connection_cleanup_on_shutdown(self):
        """Verify close_db_engine disposes the async engine cleanly."""
        mock_engine = AsyncMock(spec=AsyncEngine)
        with patch("app.core.database.engine", mock_engine):
            await close_db_engine()
            mock_engine.dispose.assert_awaited_once()

    async def test_07_fastapi_endpoints_and_cors(self):
        """Verify existing FastAPI endpoints and CORS configuration."""
        # 1. Root endpoint handler
        root_data = await root()
        self.assertEqual(root_data, {"message": "Welcome to AgentLens API", "status": "running"})

        # 2. Health endpoint handler
        health_data = await health_check()
        self.assertEqual(health_data, {"status": "healthy", "service": "AgentLens Backend", "version": "0.1.0"})

        # 3. CORS Middleware configuration
        cors_middlewares = [m for m in app.user_middleware if m.cls.__name__ == "CORSMiddleware"]
        self.assertTrue(len(cors_middlewares) > 0, "CORSMiddleware must be configured on app")
        cors_kwargs = cors_middlewares[0].kwargs
        self.assertIn("http://localhost:5173", cors_kwargs.get("allow_origins", []))
        self.assertTrue(cors_kwargs.get("allow_credentials"))


if __name__ == "__main__":
    unittest.main()
