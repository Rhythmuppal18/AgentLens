from collections.abc import AsyncGenerator
import logging
from typing import Annotated

from fastapi import Depends
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import settings

logger = logging.getLogger("agentlens.database")

# 1. Asynchronous SQLAlchemy Engine
# Configured with pool_size=5, max_overflow=15, and environment overrides
engine: AsyncEngine = create_async_engine(
    url=settings.async_database_url,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_timeout=settings.DB_POOL_TIMEOUT,
    pool_recycle=settings.DB_POOL_RECYCLE,
    echo=settings.DB_ECHO,
    future=True,
)

# 2. Asynchronous Session Factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# 3. Reusable Database Dependency for FastAPI
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    """FastAPI dependency yielding an isolated async database session per request.

    Rolls back automatically on unhandled exceptions and guarantees closure.
    Does NOT auto-commit: write operations must explicitly commit transactions.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

# Type alias for cleaner route handler signatures
DbSession = Annotated[AsyncSession, Depends(get_db_session)]

# 4. Asynchronous Engine Cleanup on Application Shutdown
async def close_db_engine() -> None:
    """Closes all connections in the pool cleanly during application shutdown."""
    logger.info("Closing database engine and disposing async connection pool...")
    await engine.dispose()
    logger.info("Database connection pool cleanly disposed.")
