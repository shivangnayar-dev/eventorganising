"""
Verification Checkpoint Configuration model
Defines what details nodal officers need to verify and submit
"""
from datetime import datetime
from typing import Optional, Dict, Any, List
from beanie import Document
from pydantic import Field, field_validator
from enum import Enum


class CheckpointType(str, Enum):
    """Types of verification checkpoints"""
    BOOLEAN = "boolean"  # Yes/No question
    TEXT = "text"  # Text feedback
    TEXTAREA = "textarea"  # Long text feedback
    RATING = "rating"  # 1-5 star rating
    IMAGE = "image"  # Image upload
    VIDEO = "video"  # Video upload
    MULTI_IMAGE = "multi_image"  # Multiple images
    DROPDOWN = "dropdown"  # Dropdown selection
    NUMBER = "number"  # Numeric value


class VerificationCheckpointConfig(Document):
    """Configuration for verification checkpoints that nodal officers must complete"""
    checkpoint_key: str = Field(..., alias="checkpointKey", unique=True)
    label: str
    checkpoint_type: CheckpointType = Field(..., alias="checkpointType")
    description: Optional[str] = None
    is_required: bool = Field(default=True, alias="isRequired")
    is_enabled: bool = Field(default=True, alias="isEnabled")
    display_order: int = Field(default=0, alias="displayOrder")
    validation: Optional[Dict[str, Any]] = None  # e.g., {"min": 1, "max": 5} for rating
    options: Optional[List[str]] = None  # For dropdown type
    placeholder: Optional[str] = None
    hint: Optional[str] = None
    category: Optional[str] = None  # e.g., "credibility", "details", "facilities", "safety"
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")

    @field_validator("checkpoint_type", mode="before")
    @classmethod
    def validate_checkpoint_type(cls, v):
        if isinstance(v, str):
            try:
                return CheckpointType(v)
            except ValueError:
                return v
        return v

    class Settings:
        name = "VerificationCheckpointConfig"

