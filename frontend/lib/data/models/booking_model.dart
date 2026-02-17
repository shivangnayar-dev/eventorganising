import '../../domain/entities/booking.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.serviceId,
    required super.userId,
    required super.scheduledDate,
    required super.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      status: _statusFromString(json['status']?.toString() ?? 'CONFIRMED'),
    );
  }

  static BookingStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'COMPLETED':
        return BookingStatus.completed;
      default:
        return BookingStatus.confirmed;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'userId': userId,
        'scheduledDate': scheduledDate.toIso8601String(),
        'status': status.name.toUpperCase(),
      };
}
