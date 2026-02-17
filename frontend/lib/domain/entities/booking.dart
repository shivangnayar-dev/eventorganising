import 'package:equatable/equatable.dart';

enum BookingStatus { confirmed, cancelled, completed }

class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.scheduledDate,
    required this.status,
  });

  final String id;
  final String serviceId;
  final String userId;
  final DateTime scheduledDate;
  final BookingStatus status;

  @override
  List<Object?> get props => [id, serviceId, userId, scheduledDate, status];
}
