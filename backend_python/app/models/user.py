"""
User and Role models
"""
from datetime import datetime
from typing import Optional, List
from beanie import Document, Link
from pydantic import Field, EmailStr
from enum import Enum


class UserRole(str, Enum):
    """User role enum"""
    USER = "USER"
    PROVIDER = "PROVIDER"
    MANAGER = "MANAGER"
    ADMIN = "ADMIN"
    NODAL_OFFICER = "NODAL_OFFICER"


class Role(Document):
    """Role model"""
    role: UserRole
    user_id: str = Field(..., alias="userId")
    
    class Settings:
        name = "Role"
        # Note: Unique constraint is handled by Prisma schema
        # indexes = [("userId", "role")]


class User(Document):
    """User model"""
    email: EmailStr = Field(..., unique=True)
    password_hash: str = Field(..., alias="passwordHash")
    full_name: str = Field(..., alias="fullName")
    phone: Optional[str] = None
    roles: List[Link[Role]] = []
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "User"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = ["email"]

