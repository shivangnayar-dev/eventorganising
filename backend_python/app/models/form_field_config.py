"""
Form Field Configuration model
Stores configuration for dynamic form fields in service submission
"""
from datetime import datetime
from typing import Optional, Dict, Any, List
from beanie import Document
from pydantic import Field, field_validator
from enum import Enum


class FieldType(str, Enum):
    """Field type enum"""
    TEXT = "text"
    TEXTAREA = "textarea"
    NUMBER = "number"
    DROPDOWN = "dropdown"
    MULTISELECT = "multiselect"
    URL = "url"
    PINCODE = "pincode"


class FormFieldConfig(Document):
    """Form Field Configuration model"""
    field_key: str = Field(..., alias="fieldKey", unique=True)  # Unique identifier (e.g., "title", "location")
    label: str  # Display name (e.g., "Property/Venue Name")
    field_type: FieldType = Field(..., alias="fieldType")
    is_required: bool = Field(default=False, alias="isRequired")
    is_enabled: bool = Field(default=True, alias="isEnabled")
    display_order: int = Field(default=0, alias="displayOrder")
    validation: Optional[Dict[str, Any]] = None  # Validation rules as dict (minLength, maxLength, pattern, etc.)
    options: Optional[List[str]] = None  # Options for dropdowns/multiselects
    placeholder: Optional[str] = None
    hint: Optional[str] = None
    step: Optional[str] = None  # Which step this field belongs to (basic_info, location, amenities, review)
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    @field_validator("field_type", mode="before")
    @classmethod
    def validate_field_type(cls, v):
        """Convert string to FieldType enum"""
        if isinstance(v, str):
            try:
                return FieldType(v)
            except ValueError:
                return v
        return v
    
    class Settings:
        name = "FormFieldConfig"
        # Note: Indexes are managed by Prisma, so we don't define them here to avoid conflicts
        # indexes = ["fieldKey", "isEnabled", "displayOrder", "step"]

