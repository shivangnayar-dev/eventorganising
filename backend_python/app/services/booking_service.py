"""
Booking service
"""
from datetime import datetime
from app.models.booking import Booking, BookingStatus
from app.middleware.error_handler import HttpError


class BookingService:
    """Booking operations"""
    
    @staticmethod
    async def create_booking(
        user_id: str,
        data: dict,
    ) -> Booking:
        """Create a new booking"""
        booking = Booking(
            userId=user_id,
            serviceId=data["serviceId"],
            scheduledDate=datetime.fromisoformat(data["scheduledDate"].replace("Z", "+00:00")),
            status=BookingStatus.CONFIRMED,
        )
        await booking.insert()
        return booking

