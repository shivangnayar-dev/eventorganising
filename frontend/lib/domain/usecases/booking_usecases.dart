import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class BookingUseCases {
  const BookingUseCases(this._repository);

  final BookingRepository _repository;

  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
  }) =>
      _repository.createBooking(
        serviceId: serviceId,
        scheduledDate: scheduledDate,
      );
}
