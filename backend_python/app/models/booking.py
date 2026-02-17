"""
Booking and Payment models
"""
from datetime import datetime
from typing import Optional
from beanie import Document, Link
from pydantic import Field
from enum import Enum
from app.models.user import User
from app.models.service_listing import ServiceListing
from app.models.service_provider import ServiceProvider


class BookingStatus(str, Enum):
    """Booking status enum"""
    CONFIRMED = "CONFIRMED"
    CANCELLED = "CANCELLED"
    COMPLETED = "COMPLETED"


class PaymentStatus(str, Enum):
    """Payment status enum"""
    PENDING = "PENDING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"


class Booking(Document):
    """Booking model"""
    service_id: str = Field(..., alias="serviceId")
    service: Link[ServiceListing]
    user_id: str = Field(..., alias="userId")
    user: Link[User]
    scheduled_date: datetime = Field(..., alias="scheduledDate")
    status: BookingStatus = BookingStatus.CONFIRMED
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    
    class Settings:
        name = "Booking"


class Payment(Document):
    """Payment model"""
    booking_id: str = Field(..., unique=True, alias="bookingId")
    booking: Link[Booking]
    amount: float
    status: PaymentStatus = PaymentStatus.PENDING
    provider_id: Optional[str] = Field(None, alias="providerId")
    provider: Optional[Link[ServiceProvider]] = None
    processed_at: Optional[datetime] = Field(None, alias="processedAt")
    
    class Settings:
        name = "Payment"

