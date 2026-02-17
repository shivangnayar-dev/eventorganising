import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/booking_model.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../providers/app_providers.dart';

final bookingControllerProvider =
    StateNotifierProvider<BookingController, BookingState>((ref) {
  final useCases = ref.read(bookingUseCasesProvider);
  return BookingController(useCases);
});

class BookingController extends StateNotifier<BookingState> {
  BookingController(this._useCases) : super(const BookingState.initial());

  final BookingUseCases _useCases;

  Future<bool> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
  }) async {
    state = state.copyWith(status: BookingStatusState.loading);
    try {
      final booking = await _useCases.createBooking(
        serviceId: serviceId,
        scheduledDate: scheduledDate,
      );
      state = state.copyWith(
        status: BookingStatusState.success,
        lastBooking: booking as BookingModel,
        errorMessage: null,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        status: BookingStatusState.error,
        errorMessage: error.message,
      );
      return false;
    }
  }
}

enum BookingStatusState { initial, loading, success, error }

class BookingState {
  const BookingState({
    required this.status,
    this.lastBooking,
    this.errorMessage,
  });

  const BookingState.initial()
      : status = BookingStatusState.initial,
        lastBooking = null,
        errorMessage = null;

  final BookingStatusState status;
  final BookingModel? lastBooking;
  final String? errorMessage;

  BookingState copyWith({
    BookingStatusState? status,
    BookingModel? lastBooking,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      lastBooking: lastBooking ?? this.lastBooking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
