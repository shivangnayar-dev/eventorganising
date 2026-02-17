import '../../domain/entities/nodal_officer_recommendation.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

class NodalOfficerRecommendationModel extends NodalOfficerRecommendationEntity {
  const NodalOfficerRecommendationModel({
    required super.id,
    super.officerId,
    required super.managerId,
    required super.area,
    required super.location,
    required super.status,
    super.officer,
    super.manager,
    super.newUserEmail,
    super.newUserFullName,
    super.newUserPhone,
    super.address,
    super.pincode,
    super.region,
    super.reason,
    super.notes,
    super.reviewedBy,
    super.reviewedAt,
    super.createdAt,
  });

  factory NodalOfficerRecommendationModel.fromJson(Map<String, dynamic> json) {
    return NodalOfficerRecommendationModel(
      id: json['id']?.toString() ?? '',
      officerId: json['officerId']?.toString(),
      managerId: json['managerId']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      address: json['address']?.toString(),
      pincode: json['pincode']?.toString(),
      region: json['region']?.toString(),
      reason: json['reason']?.toString(),
      status: _statusFromString(json['status']?.toString() ?? 'PENDING'),
      notes: json['notes']?.toString(),
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      officer: json['officer'] != null
          ? UserModel.fromJson(json['officer'] as Map<String, dynamic>)
          : null,
      manager: json['manager'] != null
          ? UserModel.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      newUserEmail: json['newUserEmail']?.toString(),
      newUserFullName: json['newUserFullName']?.toString(),
      newUserPhone: json['newUserPhone']?.toString(),
    );
  }

  static RecommendationStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return RecommendationStatus.approved;
      case 'REJECTED':
        return RecommendationStatus.rejected;
      default:
        return RecommendationStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officerId': officerId,
        'managerId': managerId,
        'area': area,
        'location': location,
        'address': address,
        'pincode': pincode,
        'region': region,
        'reason': reason,
        'status': status.name.toUpperCase(),
        'notes': notes,
      };
}

