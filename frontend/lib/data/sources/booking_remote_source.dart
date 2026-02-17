import '../../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingRemoteSource {
  final _client = ApiClient.instance;

  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/booking/create',
      data: {
        'serviceId': serviceId,
        'scheduledDate': scheduledDate.toIso8601String(),
      },
    );
    return BookingModel.fromJson(response.data ?? const {});
  }
}
