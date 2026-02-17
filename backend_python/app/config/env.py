"""
Environment configuration
"""
from pydantic_settings import BaseSettings
from typing import List, Optional


class Settings(BaseSettings):
    """Application settings"""
    
    # Environment (read from NODE_ENV for compatibility)
    node_env: str = "development"
    
    @property
    def environment(self) -> str:
        """Get environment"""
        return self.node_env
    
    # Server
    port: int = 3000
    
    # Database
    database_url: str
    
    # JWT
    jwt_secret: str
    jwt_expires_in: str = "1d"
    
    # CORS
    cors_origin: str = "http://localhost:3000"
    
    # Rate Limiting
    rate_limit_window_ms: int = 900000  # 15 minutes
    rate_limit_max: int = 100
    
    # Frontend URL
    frontend_url: str = "http://localhost"
    
    # Email (SMTP)
    smtp_host: Optional[str] = None
    smtp_port: int = 587
    smtp_user: Optional[str] = None
    smtp_pass: Optional[str] = None
    
    class Config:
        env_file = ".env"
        case_sensitive = False
        env_file_encoding = "utf-8"
        
    @property
    def cors_origins(self) -> List[str]:
        """Parse CORS origins from comma-separated string"""
        return [origin.strip() for origin in self.cors_origin.split(",")]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        
        # Validate required fields
        if not self.database_url:
            raise ValueError("DATABASE_URL is required")
        if not self.jwt_secret:
            raise ValueError("JWT_SECRET is required")
        
        # Validate JWT_SECRET strength in production
        if self.environment == "production" and len(self.jwt_secret) < 32:
            raise ValueError(
                "JWT_SECRET must be at least 32 characters long in production. "
                "Use a strong random string."
            )
    


settings = Settings()

