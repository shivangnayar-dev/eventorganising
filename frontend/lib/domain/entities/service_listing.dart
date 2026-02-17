import 'package:equatable/equatable.dart';

import 'user.dart';

enum ServiceStatus { pending, assigned, verified, rejected, published }

class ServiceListingEntity extends Equatable {
  const ServiceListingEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.status,
    this.submittedAt,
    this.publishedAt,
    this.address,
    this.pincode,
    this.eventTypes,
    this.propertyType,
    this.capacity,
    this.amenities,
    this.photos,
    this.assignedManagerId,
    this.assignedManager,
    this.assignedNodalOfficerId,
    this.assignedNodalOfficer,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String location;
  final double price;
  final ServiceStatus status;
  final DateTime? submittedAt;
  final DateTime? publishedAt;
  final String? address;
  final String? pincode;
  final String? eventTypes;
  final String? propertyType;
  final int? capacity;
  final String? amenities;
  final List<String>? photos;
  final String? assignedManagerId;
  final UserEntity? assignedManager;
  final String? assignedNodalOfficerId;
  final UserEntity? assignedNodalOfficer;

  bool get isPublished => status == ServiceStatus.published;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        location,
        price,
        status,
        submittedAt,
        publishedAt,
        address,
        pincode,
        eventTypes,
        propertyType,
        capacity,
        amenities,
        photos,
        assignedManagerId,
        assignedManager,
        assignedNodalOfficerId,
        assignedNodalOfficer,
      ];
}
