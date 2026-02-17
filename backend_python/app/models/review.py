"""
Review model
"""
from datetime import datetime
from typing import Optional
from beanie import Document, Link
from pydantic import Field
from app.models.user import User
from app.models.service_listing import ServiceListing


class Review(Document):
    """Review model"""
    service_id: str = Field(..., alias="serviceId")
    service: Link[ServiceListing]
    user_id: str = Field(..., alias="userId")
    user: Link[User]
    rating: int
    comment: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    
    class Settings:
        name = "Review"

