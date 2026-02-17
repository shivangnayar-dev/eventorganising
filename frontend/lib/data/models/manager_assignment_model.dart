import '../../domain/entities/manager_assignment.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

class ManagerAssignmentModel extends ManagerAssignmentEntity {
  const ManagerAssignmentModel({
    required super.id,
    required super.managerId,
    required super.area,
    required super.location,
    required super.status,
    super.manager,
    super.address,
    super.pincode,
    super.region,
    super.notes,
    super.assignedBy,
    super.assignedAt,
  });

  factory ManagerAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ManagerAssignmentModel(
      id: json['id']?.toString() ?? '',
      managerId: json['managerId']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      address: json['address']?.toString(),
      pincode: json['pincode']?.toString(),
      region: json['region']?.toString(),
      status: _statusFromString(json['status']?.toString() ?? 'ACTIVE'),
      notes: json['notes']?.toString(),
      assignedBy: json['assignedBy']?.toString(),
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
      manager: json['manager'] != null
          ? UserModel.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
    );
  }

  static ManagerAssignmentStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'INACTIVE':
        return ManagerAssignmentStatus.inactive;
      case 'SUSPENDED':
        return ManagerAssignmentStatus.suspended;
      default:
        return ManagerAssignmentStatus.active;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'managerId': managerId,
        'area': area,
        'location': location,
        'address': address,
        'pincode': pincode,
        'region': region,
        'status': status.name.toUpperCase(),
        'notes': notes,
        'assignedBy': assignedBy,
        'assignedAt': assignedAt?.toIso8601String(),
      };
}

