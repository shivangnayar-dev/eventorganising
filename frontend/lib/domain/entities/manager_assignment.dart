import 'package:equatable/equatable.dart';

import 'user.dart';

enum ManagerAssignmentStatus { active, inactive, suspended }

class ManagerAssignmentEntity extends Equatable {
  const ManagerAssignmentEntity({
    required this.id,
    required this.managerId,
    required this.area,
    required this.location,
    required this.status,
    this.manager,
    this.address,
    this.pincode,
    this.region,
    this.notes,
    this.assignedBy,
    this.assignedAt,
  });

  final String id;
  final String managerId;
  final String area;
  final String location;
  final String? address;
  final String? pincode;
  final String? region;
  final ManagerAssignmentStatus status;
  final String? notes;
  final String? assignedBy;
  final DateTime? assignedAt;
  final UserEntity? manager;

  @override
  List<Object?> get props => [
        id,
        managerId,
        area,
        location,
        address,
        pincode,
        region,
        status,
        notes,
        assignedBy,
        assignedAt,
        manager,
      ];
}

