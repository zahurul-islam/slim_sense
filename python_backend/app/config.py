import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Settings(BaseSettings):
    """Application settings"""
    # App info
    APP_NAME: str = "SlimSense Backend API"
    APP_VERSION: str = "1.0.0"
    API_PREFIX: str = "/api/v1"
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # Server settings
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    
    # Firebase config
    FIREBASE_CREDENTIALS: str = os.getenv("FIREBASE_CREDENTIALS", "")
    
    # API keys
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    NUTRITIONIX_APP_ID: str = os.getenv("NUTRITIONIX_APP_ID", "")
    NUTRITIONIX_API_KEY: str = os.getenv("NUTRITIONIX_API_KEY", "")
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-placeholder")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day
    
    # CORS
    CORS_ORIGINS: list = ["*"]
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Create settings instance
settings = Settings()
