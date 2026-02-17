import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, success, failed }

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.status,
    this.processedAt,
  });

  final String id;
  final String bookingId;
  final double amount;
  final PaymentStatus status;
  final DateTime? processedAt;

  @override
  List<Object?> get props => [id, bookingId, amount, status, processedAt];
}
