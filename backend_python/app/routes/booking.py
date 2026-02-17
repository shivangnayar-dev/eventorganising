"""
Booking routes
"""
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.middleware.auth_middleware import get_current_user
from app.services.booking_service import BookingService

router = APIRouter()


# Request models
class CreateBookingRequest(BaseModel):
    serviceId: str
    scheduledDate: str


# Routes
@router.post("/create")
async def create_booking(
    data: CreateBookingRequest,
    user: dict = Depends(get_current_user),
):
    """Create a new booking"""
    booking = await BookingService.create_booking(user["id"], data.dict())
    return booking.dict()
