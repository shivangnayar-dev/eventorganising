"""
Service Provider model
"""
from datetime import datetime
from typing import Optional, Any
from beanie import Document, Link
from pydantic import Field
from enum import Enum
from app.models.user import User


class ProviderStatus(str, Enum):
    """Provider status enum"""
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"


class ServiceProvider(Document):
    """Service Provider model"""
    user_id: str = Field(..., unique=True, alias="userId")
    user: Link[User]
    kyc_document_url: Optional[str] = Field(None, alias="kycDocumentUrl")
    pricing_details: Optional[str] = Field(None, alias="pricingDetails")
    photos: Optional[Any] = None  # JSON field
    status: ProviderStatus = ProviderStatus.PENDING
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "ServiceProvider"

