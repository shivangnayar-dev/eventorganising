import 'package:equatable/equatable.dart';

import 'role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final DateTime? createdAt;
  final List<RoleEntity> roles;

  bool get isManager => roles.any((role) => role.type == RoleType.manager);
  bool get isProvider => roles.any((role) => role.type == RoleType.provider);
  bool get isAdmin => roles.any((role) => role.type == RoleType.admin);

  @override
  List<Object?> get props => [id, email, fullName, phone, createdAt, roles];
}
