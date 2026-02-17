import 'package:equatable/equatable.dart';

enum RoleType { user, provider, manager, admin, nodalOfficer }

class RoleEntity extends Equatable {
  const RoleEntity({required this.type});

  final RoleType type;

  @override
  List<Object?> get props => [type];

  String get name => switch (type) {
        RoleType.user => 'USER',
        RoleType.provider => 'PROVIDER',
        RoleType.manager => 'MANAGER',
        RoleType.admin => 'ADMIN',
        RoleType.nodalOfficer => 'NODAL_OFFICER',
      };

  factory RoleEntity.fromName(String role) {
    return RoleEntity(
      type: switch (role.toUpperCase()) {
        'PROVIDER' => RoleType.provider,
        'MANAGER' => RoleType.manager,
        'ADMIN' => RoleType.admin,
        'NODAL_OFFICER' => RoleType.nodalOfficer,
        _ => RoleType.user,
      },
    );
  }
}
