import 'package:equatable/equatable.dart';

class ServiceCategoryEntity extends Equatable {
  const ServiceCategoryEntity({
    required this.id,
    required this.name,
    required this.showInNavbar,
    required this.isActive,
    this.description,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool showInNavbar;
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        showInNavbar,
        displayOrder,
        isActive,
        createdAt,
        updatedAt,
      ];
}

