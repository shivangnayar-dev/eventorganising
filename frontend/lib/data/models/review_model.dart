import '../../domain/entities/review.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.serviceId,
    required super.userId,
    required super.rating,
    super.comment,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt?.toIso8601String(),
      };
}
