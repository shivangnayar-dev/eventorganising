import '../../domain/entities/service_category.dart';

class ServiceCategoryModel extends ServiceCategoryEntity {
  const ServiceCategoryModel({
    required super.id,
    required super.name,
    required super.showInNavbar,
    required super.isActive,
    super.description,
    super.displayOrder,
    super.createdAt,
    super.updatedAt,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      showInNavbar: json['showInNavbar'] == true,
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : 0,
      isActive: json['isActive'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'showInNavbar': showInNavbar,
        'displayOrder': displayOrder,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

