import '../../domain/entities/service_provider.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

class ServiceProviderModel extends ServiceProviderEntity {
  const ServiceProviderModel({
    required super.id,
    required super.userId,
    required super.status,
    super.kycDocumentUrl,
    super.pricingDetails,
    super.user,
    super.createdAt,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      status: _statusFromString(json['status']?.toString() ?? 'PENDING'),
      kycDocumentUrl: json['kycDocumentUrl']?.toString(),
      pricingDetails: json['pricingDetails']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static ProviderStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return ProviderStatus.approved;
      case 'REJECTED':
        return ProviderStatus.rejected;
      default:
        return ProviderStatus.pending;
    }
  }

  // Note: toJson not needed as we only receive providers from backend
}

