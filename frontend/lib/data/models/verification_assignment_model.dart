import '../../domain/entities/verification_assignment.dart';

class VerificationAssignmentModel extends VerificationAssignmentEntity {
  const VerificationAssignmentModel({
    required super.id,
    required super.serviceId,
    required super.providerId,
    required super.assignedById,
    required super.status,
    super.notes,
    super.requestedInfo,
    super.checkpointResponses,
    super.images,
    super.videos,
    super.overallRating,
    super.credibilityScore,
    super.detailsAccuracy,
    super.submittedAt,
    super.createdAt,
  });

  factory VerificationAssignmentModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? checkpointResponses;
    if (json['checkpointResponses'] != null) {
      if (json['checkpointResponses'] is Map) {
        checkpointResponses = Map<String, dynamic>.from(json['checkpointResponses']);
      }
    }

    List<String>? images;
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = (json['images'] as List).map((e) => e.toString()).toList();
      }
    }

    List<String>? videos;
    if (json['videos'] != null) {
      if (json['videos'] is List) {
        videos = (json['videos'] as List).map((e) => e.toString()).toList();
      }
    }

    double? overallRating;
    if (json['overallRating'] != null) {
      overallRating = (json['overallRating'] is num)
          ? (json['overallRating'] as num).toDouble()
          : double.tryParse(json['overallRating'].toString());
    }

    double? credibilityScore;
    if (json['credibilityScore'] != null) {
      credibilityScore = (json['credibilityScore'] is num)
          ? (json['credibilityScore'] as num).toDouble()
          : double.tryParse(json['credibilityScore'].toString());
    }

    return VerificationAssignmentModel(
      id: json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      assignedById: json['assignedById']?.toString() ?? '',
      status: _statusFromString(json['status']?.toString() ?? 'PENDING'),
      notes: json['notes']?.toString(),
      requestedInfo: json['requestedInfo']?.toString(),
      checkpointResponses: checkpointResponses,
      images: images,
      videos: videos,
      overallRating: overallRating,
      credibilityScore: credibilityScore,
      detailsAccuracy: json['detailsAccuracy']?.toString(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static VerificationStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return VerificationStatus.approved;
      case 'REJECTED':
        return VerificationStatus.rejected;
      case 'INFO_REQUESTED':
        return VerificationStatus.infoRequested;
      default:
        return VerificationStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'providerId': providerId,
        'assignedById': assignedById,
        'status': status.name.toUpperCase(),
        'notes': notes,
        'requestedInfo': requestedInfo,
        'checkpointResponses': checkpointResponses,
        'images': images,
        'videos': videos,
        'overallRating': overallRating,
        'credibilityScore': credibilityScore,
        'detailsAccuracy': detailsAccuracy,
        'submittedAt': submittedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };
}
