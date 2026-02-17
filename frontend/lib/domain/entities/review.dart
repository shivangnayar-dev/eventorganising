import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String serviceId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, serviceId, userId, rating, comment, createdAt];
}
