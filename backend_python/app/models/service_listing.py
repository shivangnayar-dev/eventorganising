"""
Service Listing model
"""
from datetime import datetime
from typing import Optional, Any, Union
from beanie import Document, Link
from pydantic import Field, field_validator
from enum import Enum
from app.models.user import User
from bson import ObjectId


class ServiceStatus(str, Enum):
    """Service status enum"""
    PENDING = "PENDING"
    ASSIGNED = "ASSIGNED"
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"
    PUBLISHED = "PUBLISHED"


class ServiceListing(Document):
    """Service Listing model"""
    owner_id: str = Field(..., alias="ownerId")
    owner: Optional[Link[User]] = None
    assigned_manager_id: Optional[str] = Field(None, alias="assignedManagerId")
    assigned_manager: Optional[Link[User]] = None
    assigned_nodal_officer_id: Optional[str] = Field(None, alias="assignedNodalOfficerId")
    assigned_nodal_officer: Optional[Link[User]] = None
    
    @field_validator("owner_id", "assigned_manager_id", "assigned_nodal_officer_id", mode="before")
    @classmethod
    def convert_objectid_to_str(cls, v):
        """Convert ObjectId to string"""
        if isinstance(v, ObjectId):
            return str(v)
        return v
    title: str
    description: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    event_types: Optional[str] = Field(None, alias="eventTypes")
    property_type: Optional[str] = Field(None, alias="propertyType")
    capacity: Optional[int] = None
    amenities: Optional[str] = None
    photos: Optional[Any] = None  # JSON field
    price: float
    status: ServiceStatus = ServiceStatus.PENDING
    submitted_at: datetime = Field(default_factory=datetime.utcnow, alias="submittedAt")
    published_at: Optional[datetime] = Field(None, alias="publishedAt")
    
    class Settings:
        name = "ServiceListing"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = ["ownerId", "assignedManagerId", "status"]

