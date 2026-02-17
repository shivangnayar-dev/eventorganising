import '../../domain/entities/payment.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    required super.status,
    super.processedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      status: _statusFromString(json['status']?.toString() ?? 'PENDING'),
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
    );
  }

  static PaymentStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'SUCCESS':
        return PaymentStatus.success;
      case 'FAILED':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'amount': amount,
        'status': status.name.toUpperCase(),
        'processedAt': processedAt?.toIso8601String(),
      };
}
