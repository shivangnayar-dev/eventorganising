import '../entities/service_listing.dart';
import '../entities/service_provider.dart';
import '../entities/verification_assignment.dart';
import '../entities/nodal_officer_assignment.dart';
import '../entities/nodal_officer_recommendation.dart';
import '../entities/manager_assignment.dart';
import '../entities/service_category.dart';
import '../entities/form_field_config.dart';
import '../entities/verification_checkpoint_config.dart';

abstract class ServiceRepository {
  Future<ServiceListingEntity> submitService({
    required String title,
    required String description,
    required String location,
    String? address,
    String? pincode,
    String? eventTypes,
    String? propertyType,
    int? capacity,
    String? amenities,
    List<String>? photos,
    required double price,
  });

  Future<List<ServiceListingEntity>> fetchUserServices();

  Future<List<ServiceListingEntity>> fetchPendingServices();

  Future<List<ServiceListingEntity>> fetchPublishedServices();

  Future<List<ServiceListingEntity>> fetchPublicServices();

  Future<List<ServiceListingEntity>> fetchManagedServices();

  Future<void> assignAgents({
    required String serviceId,
    required List<String> agentIds,
    String? nodalOfficerId,
  });

  Future<Map<String, dynamic>> assignNodalOfficer({
    required String serviceId,
    required String nodalOfficerId,
  });

  Future<void> verifyService({
    required String serviceId,
    required String decision,
    String? notes,
  });

  Future<List<VerificationAssignmentEntity>> fetchAssignedTasks();

  Future<List<ServiceProviderEntity>> fetchProviders();

  Future<void> onboardProvider({
    required String kycDocumentUrl,
    required String pricingDetails,
    List<String>? photoUrls,
  });

  // Nodal Officer Methods for Managers
  Future<List<NodalOfficerAssignmentEntity>> fetchNodalOfficersByArea({
    String? location,
    String? area,
    String? pincode,
  });

  Future<NodalOfficerRecommendationEntity> recommendNodalOfficer({
    String? officerId,
    String? newUserEmail,
    String? newUserFullName,
    String? newUserPhone,
    required String area,
    required String location,
    String? address,
    String? pincode,
    String? region,
    String? reason,
  });

  Future<List<NodalOfficerRecommendationEntity>> fetchMyRecommendations();

  Future<Map<String, dynamic>> fetchAvailableNodalOfficersForService(String serviceId);

  Future<ManagerAssignmentEntity> fetchManagerAssignment();

  Future<List<ServiceCategoryEntity>> fetchNavbarServiceCategories();

  Future<List<FormFieldConfigEntity>> fetchFormFieldConfigs();

  Future<List<VerificationCheckpointConfigEntity>> fetchVerificationCheckpointConfigs();

  Future<List<VerificationAssignmentEntity>> fetchServiceVerificationAssignments(String serviceId);
}
