"""
Nodal Officer models
"""
from datetime import datetime
from typing import Optional, Annotated
from beanie import Document, Link
from pydantic import Field, BeforeValidator
from enum import Enum
from app.models.user import User
from bson import ObjectId

# Custom type for ObjectId to str conversion
PyObjectId = Annotated[str, BeforeValidator(str)]


class NodalOfficerStatus(str, Enum):
    """Nodal Officer status enum"""
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    SUSPENDED = "SUSPENDED"


class RecommendationStatus(str, Enum):
    """Recommendation status enum"""
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"


class NodalOfficerAssignment(Document):
    """Nodal Officer Assignment model"""
    officer_id: PyObjectId = Field(..., alias="officerId")
    officer: Optional[Link[User]] = None
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    status: NodalOfficerStatus = NodalOfficerStatus.ACTIVE
    notes: Optional[str] = None
    assigned_by: Optional[str] = Field(None, alias="assignedBy")
    assigned_at: datetime = Field(default_factory=datetime.utcnow, alias="assignedAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "NodalOfficerAssignment"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = [("officerId", "area", "location"), ("location", "pincode"), "status"]


class NodalOfficerRecommendation(Document):
    """Nodal Officer Recommendation model"""
    officer_id: Optional[PyObjectId] = Field(None, alias="officerId")
    officer: Optional[Link[User]] = None
    new_user_email: Optional[str] = Field(None, alias="newUserEmail")
    new_user_full_name: Optional[str] = Field(None, alias="newUserFullName")
    new_user_phone: Optional[str] = Field(None, alias="newUserPhone")
    manager_id: PyObjectId = Field(..., alias="managerId")
    manager: Optional[Link[User]] = None
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    reason: Optional[str] = None
    status: RecommendationStatus = RecommendationStatus.PENDING
    notes: Optional[str] = None
    reviewed_by: Optional[str] = Field(None, alias="reviewedBy")
    reviewed_at: Optional[datetime] = Field(None, alias="reviewedAt")
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "NodalOfficerRecommendation"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = ["managerId", "status", ("location", "area")]

