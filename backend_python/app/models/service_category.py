"""
Service Category model
"""
from datetime import datetime
from typing import Optional
from beanie import Document
from pydantic import Field


class ServiceCategory(Document):
    """Service Category model"""
    name: str = Field(..., unique=True)
    description: Optional[str] = None
    show_in_navbar: bool = Field(default=False, alias="showInNavbar")
    display_order: int = Field(default=0, alias="displayOrder")
    is_active: bool = Field(default=True, alias="isActive")
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "ServiceCategory"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = [("showInNavbar", "isActive"), "displayOrder"]

