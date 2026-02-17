import 'package:equatable/equatable.dart';

import 'user.dart';

enum ProviderStatus { pending, approved, rejected }

class ServiceProviderEntity extends Equatable {
  const ServiceProviderEntity({
    required this.id,
    required this.userId,
    required this.status,
    this.kycDocumentUrl,
    this.pricingDetails,
    this.user,
    this.createdAt,
  });

  final String id;
  final String userId;
  final ProviderStatus status;
  final String? kycDocumentUrl;
  final String? pricingDetails;
  final UserEntity? user;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        kycDocumentUrl,
        pricingDetails,
        user,
        createdAt,
      ];
}

