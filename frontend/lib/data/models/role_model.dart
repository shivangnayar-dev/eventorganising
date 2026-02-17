import '../../domain/entities/role.dart';

class RoleModel extends RoleEntity {
  const RoleModel({required super.type});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final value =
        json['role']?.toString() ?? json['name']?.toString() ?? 'USER';
    return RoleModel(type: RoleEntity.fromName(value).type);
  }

  Map<String, dynamic> toJson() => {'role': name};
}
