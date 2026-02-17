import 'package:equatable/equatable.dart';

import 'user.dart';

enum NodalOfficerStatus { active, inactive, suspended }

class NodalOfficerAssignmentEntity extends Equatable {
  const NodalOfficerAssignmentEntity({
    required this.id,
    required this.officerId,
    required this.area,
    required this.location,
    required this.status,
    this.officer,
    this.address,
    this.pincode,
    this.region,
    this.notes,
    this.assignedBy,
    this.assignedAt,
  });

  final String id;
  final String officerId;
  final String area;
  final String location;
  final String? address;
  final String? pincode;
  final String? region;
  final NodalOfficerStatus status;
  final String? notes;
  final String? assignedBy;
  final DateTime? assignedAt;
  final UserEntity? officer;

  @override
  List<Object?> get props => [
        id,
        officerId,
        area,
        location,
        address,
        pincode,
        region,
        status,
        notes,
        assignedBy,
        assignedAt,
        officer,
      ];
}

