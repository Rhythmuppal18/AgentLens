from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

# Locate root directory containing .env
ROOT_DIR = Path(__file__).resolve().parent.parent.parent.parent
ENV_FILE = ROOT_DIR / ".env"

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=ENV_FILE if ENV_FILE.exists() else ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Database Configuration
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "agentlens"
    POSTGRES_USER: str = "agentlens"
    POSTGRES_PASSWORD: str = "agentlens_password"

    DATABASE_URL: str | None = None

    # Connection Pool Configuration (Configurable via environment variables)
    DB_POOL_SIZE: int = 5
    DB_MAX_OVERFLOW: int = 15
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 1800
    DB_ECHO: bool = False

    # Application Configuration
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "INFO"

    # SLA Latency Thresholds Configuration (in milliseconds)
    AGENTLENS_SLA_LLM_MS: int = 10000
    AGENTLENS_SLA_TOOL_MS: int = 5000
    AGENTLENS_SLA_RETRIEVAL_MS: int = 2000
    AGENTLENS_SLA_AGENT_STEP_MS: int = 15000

    @property
    def async_database_url(self) -> str:
        """Returns normalized asyncpg database connection string."""
        if self.DATABASE_URL:
            # Ensure the asyncpg driver prefix is present
            if self.DATABASE_URL.startswith("postgresql://"):
                return self.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)
            return self.DATABASE_URL
        return (
            f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

settings = Settings()
