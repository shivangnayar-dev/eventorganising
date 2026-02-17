import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../sources/booking_remote_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remoteSource);

  final BookingRemoteSource _remoteSource;

  @override
  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
  }) async {
    final result = await _remoteSource.createBooking(
      serviceId: serviceId,
      scheduledDate: scheduledDate,
    );
    return result;
  }
}
