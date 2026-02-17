import 'package:equatable/equatable.dart';

enum VerificationStatus { pending, approved, rejected, infoRequested }

class VerificationAssignmentEntity extends Equatable {
  const VerificationAssignmentEntity({
    required this.id,
    required this.serviceId,
    required this.providerId,
    required this.assignedById,
    required this.status,
    this.notes,
    this.requestedInfo,
    this.checkpointResponses,
    this.images,
    this.videos,
    this.overallRating,
    this.credibilityScore,
    this.detailsAccuracy,
    this.submittedAt,
    this.createdAt,
  });

  final String id;
  final String serviceId;
  final String providerId;
  final String assignedById;
  final VerificationStatus status;
  final String? notes;
  final String? requestedInfo;
  final Map<String, dynamic>? checkpointResponses;
  final List<String>? images;
  final List<String>? videos;
  final double? overallRating;
  final double? credibilityScore;
  final String? detailsAccuracy;
  final DateTime? submittedAt;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        serviceId,
        providerId,
        assignedById,
        status,
        notes,
        requestedInfo,
        checkpointResponses,
        images,
        videos,
        overallRating,
        credibilityScore,
        detailsAccuracy,
        submittedAt,
        createdAt,
      ];
}
