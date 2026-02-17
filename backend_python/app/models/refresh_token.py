"""
Refresh Token model
"""
from datetime import datetime
from typing import Optional
from beanie import Document
from pydantic import Field


class RefreshToken(Document):
    """Refresh Token model"""
    user_id: str = Field(..., alias="userId")
    token: str = Field(..., unique=True)  # Hashed refresh token
    device_id: Optional[str] = Field(None, alias="deviceId")
    ip_address: Optional[str] = Field(None, alias="ipAddress")
    user_agent: Optional[str] = Field(None, alias="userAgent")
    expires_at: datetime = Field(..., alias="expiresAt")
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    last_used_at: Optional[datetime] = Field(None, alias="lastUsedAt")
    
    class Settings:
        name = "RefreshToken"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = ["userId", "token", "expiresAt"]

