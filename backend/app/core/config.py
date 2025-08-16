from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    """
    GEMINI_API_KEY: str
    DATABASE_URL: str
    SUPABASE_URL: str
    SUPABASE_KEY: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    EMAIL_ENABLED: bool = True
    EMAIL_FROM: str
    EMAIL_APP_PASSWORD: str
    SMTP_SERVER: str
    SMTP_PORT: int
    FRONTEND_URL: str

    # ChromaDB Configuration
    CHROMADB_HOST: str = "localhost"
    CHROMADB_PORT: int = 8000
    CHROMADB_COLLECTION_NAME: str = "government_services_v1"
    
    # Web Monitoring Settings
    SCRAPING_INTERVAL_MINUTES: int = 30
    MAX_CONCURRENT_SCRAPES: int = 5
    REQUEST_TIMEOUT: int = 30
    MAX_RETRIES: int = 3
    
    # Celery Configuration
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"
    
    # Government Sources
    GOVERNMENT_SOURCES: dict = {
        "national": [
            "https://dmt.gov.lk/index.php?lang=en",
            "https://www.gov.lk/services/erl/es/erl/view/index.action",
            "https://www.transport.gov.lk/web/index.php?option=com_content&view=article&id=26&Itemid=146&lang=en",
        ],
        "provincial": [],
        "local": [],
    }

    class Config:
        # Tell Pydantic to look for a .env file
        env_file = ".env"

@lru_cache()
def get_settings() -> Settings:
    """
    Creates and returns a cached instance of the Settings class.
    Uses lru_cache to ensure we only create one instance.
    """
    return Settings()

# Create a global settings instance
settings = get_settings()
