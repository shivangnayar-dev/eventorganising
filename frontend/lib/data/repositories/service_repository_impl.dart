import '../../domain/entities/service_listing.dart';
import '../../domain/entities/service_provider.dart';
import '../../domain/entities/verification_assignment.dart';
import '../../domain/entities/nodal_officer_assignment.dart';
import '../../domain/entities/nodal_officer_recommendation.dart';
import '../../domain/entities/manager_assignment.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/form_field_config.dart';
import '../../domain/entities/verification_checkpoint_config.dart';
import '../../domain/repositories/service_repository.dart';
import '../models/service_listing_model.dart';
import '../models/service_provider_model.dart';
import '../models/verification_assignment_model.dart';
import '../models/nodal_officer_assignment_model.dart';
import '../models/nodal_officer_recommendation_model.dart';
import '../models/manager_assignment_model.dart';
import '../models/service_category_model.dart';
import '../sources/service_remote_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._remoteSource);

  final ServiceRemoteSource _remoteSource;

  @override
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
  }) async {
    final result = await _remoteSource.submitService(
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
    return result;
  }

  @override
  Future<List<ServiceListingEntity>> fetchUserServices() async {
    final result = await _remoteSource.fetchUserServices();
    return result;
  }

  @override
  Future<List<ServiceListingEntity>> fetchPendingServices() async {
    final result = await _remoteSource.fetchPending();
    return result;
  }

  @override
  Future<List<ServiceListingEntity>> fetchPublishedServices() async {
    final result = await _remoteSource.fetchPublished();
    return result;
  }

  @override
  Future<List<ServiceListingEntity>> fetchPublicServices() async {
    final result = await _remoteSource.fetchPublic();
    return result;
  }

  @override
  Future<List<ServiceListingEntity>> fetchManagedServices() async {
    final result = await _remoteSource.fetchManaged();
    return result;
  }

  @override
  Future<void> assignAgents({
    required String serviceId,
    required List<String> agentIds,
    String? nodalOfficerId,
  }) =>
      _remoteSource.assignAgents(
        serviceId: serviceId,
        agentIds: agentIds,
        nodalOfficerId: nodalOfficerId,
      );

  @override
  Future<Map<String, dynamic>> assignNodalOfficer({
    required String serviceId,
    required String nodalOfficerId,
  }) =>
      _remoteSource.assignNodalOfficer(
        serviceId: serviceId,
        nodalOfficerId: nodalOfficerId,
      );

  @override
  Future<void> verifyService({
    required String serviceId,
    required String decision,
    String? notes,
  }) =>
      _remoteSource.verifyService(
        serviceId: serviceId,
        decision: decision,
        notes: notes,
      );

  @override
  Future<List<VerificationAssignmentEntity>> fetchAssignedTasks() async {
    final result = await _remoteSource.fetchAssignments();
    return result;
  }

  @override
  Future<List<ServiceProviderEntity>> fetchProviders() async {
    final result = await _remoteSource.fetchProviders();
    return result;
  }

  @override
  Future<void> onboardProvider({
    required String kycDocumentUrl,
    required String pricingDetails,
    List<String>? photoUrls,
  }) async {
    await _remoteSource.onboardProvider(
      kycDocumentUrl: kycDocumentUrl,
      pricingDetails: pricingDetails,
      photoUrls: photoUrls,
    );
  }

  // Nodal Officer Methods for Managers
  @override
  Future<List<NodalOfficerAssignmentEntity>> fetchNodalOfficersByArea({
    String? location,
    String? area,
    String? pincode,
  }) async {
    final result = await _remoteSource.fetchNodalOfficersByArea(
      location: location,
      area: area,
      pincode: pincode,
    );
    return List<NodalOfficerAssignmentEntity>.from(result);
  }

  @override
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
  }) async {
    return await _remoteSource.recommendNodalOfficer(
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
  }

  @override
  Future<List<NodalOfficerRecommendationEntity>> fetchMyRecommendations() async {
    final result = await _remoteSource.fetchMyRecommendations();
    return List<NodalOfficerRecommendationEntity>.from(result);
  }

  @override
  Future<Map<String, dynamic>> fetchAvailableNodalOfficersForService(String serviceId) async {
    return await _remoteSource.fetchAvailableNodalOfficersForService(serviceId);
  }

  @override
  Future<ManagerAssignmentEntity> fetchManagerAssignment() async {
    return await _remoteSource.fetchManagerAssignment();
  }

  @override
  Future<List<ServiceCategoryEntity>> fetchNavbarServiceCategories() async {
    final result = await _remoteSource.fetchNavbarServiceCategories();
    return List<ServiceCategoryEntity>.from(result);
  }

  @override
  Future<List<FormFieldConfigEntity>> fetchFormFieldConfigs() async {
    final result = await _remoteSource.fetchFormFieldConfigs();
    return List<FormFieldConfigEntity>.from(result);
  }

  @override
  Future<List<VerificationCheckpointConfigEntity>> fetchVerificationCheckpointConfigs() async {
    final result = await _remoteSource.fetchVerificationCheckpointConfigs();
    return List<VerificationCheckpointConfigEntity>.from(result);
  }

  @override
  Future<List<VerificationAssignmentEntity>> fetchServiceVerificationAssignments(String serviceId) async {
    final result = await _remoteSource.fetchServiceVerificationAssignments(serviceId);
    return List<VerificationAssignmentEntity>.from(result);
  }
}
