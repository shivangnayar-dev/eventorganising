import '../entities/service_listing.dart';
import '../entities/service_provider.dart';
import '../entities/verification_assignment.dart';
import '../entities/nodal_officer_assignment.dart';
import '../entities/nodal_officer_recommendation.dart';
import '../entities/manager_assignment.dart';
import '../entities/service_category.dart';
import '../entities/form_field_config.dart';
import '../entities/verification_checkpoint_config.dart';
import '../repositories/service_repository.dart';

class ServiceUseCases {
  const ServiceUseCases(this._repository);

  final ServiceRepository _repository;

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
  }) =>
      _repository.submitService(
        title: title,
        description: description,
        location: location,
        address: address,
        pincode: pincode,
        eventTypes: eventTypes,
        propertyType: propertyType,
        capacity: capacity,
        amenities: amenities,
        photos: photos,
        price: price,
      );

  Future<List<ServiceListingEntity>> fetchUserServices() =>
      _repository.fetchUserServices();

  Future<List<ServiceListingEntity>> fetchPendingServices() =>
      _repository.fetchPendingServices();

  Future<List<ServiceListingEntity>> fetchPublishedServices() =>
      _repository.fetchPublishedServices();

  Future<List<ServiceListingEntity>> fetchPublicServices() =>
      _repository.fetchPublicServices();

  Future<List<ServiceListingEntity>> fetchManagedServices() =>
      _repository.fetchManagedServices();

  Future<void> assignAgents({
    required String serviceId,
    required List<String> agentIds,
    String? nodalOfficerId,
  }) =>
      _repository.assignAgents(
        serviceId: serviceId,
        agentIds: agentIds,
        nodalOfficerId: nodalOfficerId,
      );

  Future<Map<String, dynamic>> assignNodalOfficer({
    required String serviceId,
    required String nodalOfficerId,
  }) =>
      _repository.assignNodalOfficer(
        serviceId: serviceId,
        nodalOfficerId: nodalOfficerId,
      );

  Future<void> verifyService({
    required String serviceId,
    required String decision,
    String? notes,
  }) =>
      _repository.verifyService(
        serviceId: serviceId,
        decision: decision,
        notes: notes,
      );

  Future<List<VerificationAssignmentEntity>> fetchAssignedTasks() =>
      _repository.fetchAssignedTasks();

  Future<List<ServiceProviderEntity>> fetchProviders() =>
      _repository.fetchProviders();

  Future<void> onboardProvider({
    required String kycDocumentUrl,
    required String pricingDetails,
    List<String>? photoUrls,
  }) =>
      _repository.onboardProvider(
        kycDocumentUrl: kycDocumentUrl,
        pricingDetails: pricingDetails,
        photoUrls: photoUrls,
      );

  // Nodal Officer Use Cases for Managers
  Future<List<NodalOfficerAssignmentEntity>> fetchNodalOfficersByArea({
    String? location,
    String? area,
    String? pincode,
  }) =>
      _repository.fetchNodalOfficersByArea(
        location: location,
        area: area,
        pincode: pincode,
      );

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
  }) =>
      _repository.recommendNodalOfficer(
        officerId: officerId,
        newUserEmail: newUserEmail,
        newUserFullName: newUserFullName,
        newUserPhone: newUserPhone,
        area: area,
        location: location,
        address: address,
        pincode: pincode,
        region: region,
        reason: reason,
      );

  Future<List<NodalOfficerRecommendationEntity>> fetchMyRecommendations() =>
      _repository.fetchMyRecommendations();

  Future<Map<String, dynamic>> fetchAvailableNodalOfficersForService(String serviceId) =>
      _repository.fetchAvailableNodalOfficersForService(serviceId);

  Future<ManagerAssignmentEntity> fetchManagerAssignment() =>
      _repository.fetchManagerAssignment();

  Future<List<ServiceCategoryEntity>> fetchNavbarServiceCategories() =>
      _repository.fetchNavbarServiceCategories();

  Future<List<FormFieldConfigEntity>> fetchFormFieldConfigs() =>
      _repository.fetchFormFieldConfigs();

  Future<List<VerificationCheckpointConfigEntity>> fetchVerificationCheckpointConfigs() =>
      _repository.fetchVerificationCheckpointConfigs();

  Future<List<VerificationAssignmentEntity>> fetchServiceVerificationAssignments(String serviceId) =>
      _repository.fetchServiceVerificationAssignments(serviceId);
}
