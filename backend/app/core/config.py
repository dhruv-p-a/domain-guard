from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "DomainGuard"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "super-secret-key-change-in-production-domainguard-2026"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    ALGORITHM: str = "HS256"

    # Database
    DATABASE_URL: str = "sqlite+aiosqlite:///./domainguard.db"
    POSTGRES_SERVER: Optional[str] = None
    POSTGRES_USER: Optional[str] = None
    POSTGRES_PASSWORD: Optional[str] = None
    POSTGRES_DB: Optional[str] = None

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost",
        "http://localhost:8000",
        "http://localhost:8080",
        "http://localhost:3000",
        "http://127.0.0.1",
        "http://127.0.0.1:8000",
        "*"
    ]

    # GitHub OAuth & App
    GITHUB_CLIENT_ID: str = "mock_github_client_id"
    GITHUB_CLIENT_SECRET: str = "mock_github_client_secret"
    GITHUB_WEBHOOK_SECRET: str = "mock_github_webhook_secret"
    GITHUB_APP_ID: Optional[str] = "123456"

    # Redis & Celery
    REDIS_URL: str = "redis://localhost:6379/0"

    # Security & Scanning
    ALLOWED_SCAN_TIMEOUT: int = 15  # seconds
    MAX_SCAN_CONCURRENCY: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )

settings = Settings()
