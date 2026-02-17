import '../entities/booking.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
  });
}
