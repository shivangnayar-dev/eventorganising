"""
Manager Assignment model
"""
from datetime import datetime
from typing import Optional
from beanie import Document, Link
from pydantic import Field
from enum import Enum
from app.models.user import User


class ManagerAssignmentStatus(str, Enum):
    """Manager Assignment status enum"""
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    SUSPENDED = "SUSPENDED"


class ManagerAssignment(Document):
    """Manager Assignment model"""
    manager_id: str = Field(..., unique=True, alias="managerId")
    manager: Optional[Link[User]] = None  # Made optional to avoid validation errors
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    status: ManagerAssignmentStatus = ManagerAssignmentStatus.ACTIVE
    notes: Optional[str] = None
    assigned_by: Optional[str] = Field(None, alias="assignedBy")
    assigned_at: datetime = Field(default_factory=datetime.utcnow, alias="assignedAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "ManagerAssignment"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = [("location", "pincode"), "status"]

