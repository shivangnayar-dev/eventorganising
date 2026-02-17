import 'package:equatable/equatable.dart';

import 'user.dart';

enum RecommendationStatus { pending, approved, rejected }

class NodalOfficerRecommendationEntity extends Equatable {
  const NodalOfficerRecommendationEntity({
    required this.id,
    this.officerId,
    required this.managerId,
    required this.area,
    required this.location,
    required this.status,
    this.officer,
    this.manager,
    this.newUserEmail,
    this.newUserFullName,
    this.newUserPhone,
    this.address,
    this.pincode,
    this.region,
    this.reason,
    this.notes,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
  });

  final String id;
  final String? officerId; // Optional for new user recommendations
  final String managerId;
  final String? newUserEmail;
  final String? newUserFullName;
  final String? newUserPhone;
  final String area;
  final String location;
  final String? address;
  final String? pincode;
  final String? region;
  final String? reason;
  final RecommendationStatus status;
  final String? notes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final UserEntity? officer;
  final UserEntity? manager;

  @override
  List<Object?> get props => [
        id,
        officerId,
        managerId,
        area,
        location,
        address,
        pincode,
        region,
        reason,
        status,
        notes,
        reviewedBy,
        reviewedAt,
        createdAt,
        officer,
        manager,
        newUserEmail,
        newUserFullName,
        newUserPhone,
      ];
}

