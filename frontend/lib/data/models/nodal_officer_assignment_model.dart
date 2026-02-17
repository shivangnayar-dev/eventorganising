import '../../domain/entities/nodal_officer_assignment.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

class NodalOfficerAssignmentModel extends NodalOfficerAssignmentEntity {
  const NodalOfficerAssignmentModel({
    required super.id,
    required super.officerId,
    required super.area,
    required super.location,
    required super.status,
    super.officer,
    super.address,
    super.pincode,
    super.region,
    super.notes,
    super.assignedBy,
    super.assignedAt,
  });

  factory NodalOfficerAssignmentModel.fromJson(Map<String, dynamic> json) {
    return NodalOfficerAssignmentModel(
      id: json['id']?.toString() ?? '',
      officerId: json['officerId']?.toString() ?? '',
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
      officer: json['officer'] != null
          ? UserModel.fromJson(json['officer'] as Map<String, dynamic>)
          : null,
    );
  }

  static NodalOfficerStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'INACTIVE':
        return NodalOfficerStatus.inactive;
      case 'SUSPENDED':
        return NodalOfficerStatus.suspended;
      default:
        return NodalOfficerStatus.active;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officerId': officerId,
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

