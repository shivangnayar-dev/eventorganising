import '../../domain/entities/service_listing.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

class ServiceListingModel extends ServiceListingEntity {
  const ServiceListingModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.location,
    required super.price,
    required super.status,
    super.submittedAt,
    super.publishedAt,
    super.address,
    super.pincode,
    super.eventTypes,
    super.propertyType,
    super.capacity,
    super.amenities,
    super.photos,
    super.assignedManagerId,
    super.assignedManager,
    super.assignedNodalOfficerId,
    super.assignedNodalOfficer,
  });

  factory ServiceListingModel.fromJson(Map<String, dynamic> json) {
    return ServiceListingModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      status: _statusFromString(json['status']?.toString() ?? 'PENDING'),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
      address: json['address']?.toString(),
      pincode: json['pincode']?.toString(),
      eventTypes: json['eventTypes']?.toString(),
      propertyType: json['propertyType']?.toString(),
      capacity: json['capacity'] != null
          ? int.tryParse(json['capacity'].toString())
          : null,
      amenities: json['amenities']?.toString(),
      photos: json['photos'] != null
          ? (json['photos'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      assignedManagerId: json['assignedManagerId']?.toString(),
      assignedManager: json['assignedManager'] != null
          ? UserModel.fromJson(json['assignedManager'] as Map<String, dynamic>)
          : null,
      assignedNodalOfficerId: json['assignedNodalOfficerId']?.toString(),
      assignedNodalOfficer: json['assignedNodalOfficer'] != null
          ? UserModel.fromJson(json['assignedNodalOfficer'] as Map<String, dynamic>)
          : null,
    );
  }

  static ServiceStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'ASSIGNED':
        return ServiceStatus.assigned;
      case 'VERIFIED':
        return ServiceStatus.verified;
      case 'REJECTED':
        return ServiceStatus.rejected;
      case 'PUBLISHED':
        return ServiceStatus.published;
      default:
        return ServiceStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'location': location,
        'price': price,
        'status': status.name.toUpperCase(),
        'submittedAt': submittedAt?.toIso8601String(),
        'publishedAt': publishedAt?.toIso8601String(),
      };
}
