"""
Verification Assignment model
"""
from datetime import datetime
from typing import Optional, Dict, Any, List
from beanie import Document, Link
from pydantic import Field
from enum import Enum
from app.models.user import User
from app.models.service_provider import ServiceProvider
from app.models.service_listing import ServiceListing


class VerificationStatus(str, Enum):
    """Verification status enum"""
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    INFO_REQUESTED = "INFO_REQUESTED"


class VerificationAssignment(Document):
    """Verification Assignment model"""
    service_id: str = Field(..., alias="serviceId")
    service: Link[ServiceListing]
    provider_id: str = Field(..., alias="providerId")
    provider: Link[ServiceProvider]
    assigned_by_id: str = Field(..., alias="assignedById")
    assigned_by: Link[User]
    status: VerificationStatus = VerificationStatus.PENDING
    notes: Optional[str] = None
    requested_info: Optional[str] = Field(None, alias="requestedInfo")
    # Checkpoint responses from nodal officer
    checkpoint_responses: Optional[Dict[str, Any]] = Field(None, alias="checkpointResponses")  # {checkpointKey: response}
    images: Optional[List[str]] = None  # URLs or paths to uploaded images
    videos: Optional[List[str]] = None  # URLs or paths to uploaded videos
    overall_rating: Optional[float] = Field(None, alias="overallRating")  # 1-5 rating
    credibility_score: Optional[float] = Field(None, alias="credibilityScore")  # Calculated score
    details_accuracy: Optional[str] = Field(None, alias="detailsAccuracy")  # "CORRECT", "PARTIAL", "INCORRECT"
    submitted_at: Optional[datetime] = Field(None, alias="submittedAt")
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "VerificationAssignment"

