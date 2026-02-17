import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import 'role_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.roles,
    super.phone,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) {
            try {
              return RoleModel.fromJson(role as Map<String, dynamic>);
            } catch (e) {
              // If role parsing fails, return a default USER role
              return RoleModel(type: RoleType.user);
            }
          })
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'createdAt': createdAt?.toIso8601String(),
        'roles': roles.map((role) => RoleModel(type: role.type).toJson()),
      };
}
