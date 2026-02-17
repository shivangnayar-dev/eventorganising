import '../../domain/entities/service_listing.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/verification_assignment.dart';
import '../../domain/entities/nodal_officer_assignment.dart';
import '../../domain/entities/nodal_officer_recommendation.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/form_field_config.dart';
import '../../domain/entities/verification_checkpoint_config.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/service_listing_model.dart';
import '../models/user_model.dart';
import '../models/verification_assignment_model.dart';
import '../models/nodal_officer_assignment_model.dart';
import '../models/nodal_officer_recommendation_model.dart';
import '../models/service_category_model.dart';
import '../models/form_field_config_model.dart';
import '../models/verification_checkpoint_config_model.dart';
import '../sources/admin_remote_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remoteSource);

  final AdminRemoteSource _remoteSource;

  @override
  Future<AdminDashboardSummary> fetchDashboard() =>
      _remoteSource.fetchDashboard();

  @override
  Future<List<UserEntity>> fetchUsers() async {
    final result = await _remoteSource.fetchUsers();
    return List<UserEntity>.from(result);
  }

  @override
  Future<List<ServiceListingEntity>> fetchAllServices() async {
    final result = await _remoteSource.fetchServices();
    return List<ServiceListingEntity>.from(result);
  }

  @override
  Future<List<VerificationAssignmentEntity>> fetchVerifications() async {
    final result = await _remoteSource.fetchVerifications();
    return List<VerificationAssignmentEntity>.from(result);
  }

  @override
  Future<UserEntity> createManager({
    required String email,
    required String fullName,
    required String password,
    String? phone,
    required String area,
    required String location,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  }) async {
    final result = await _remoteSource.createManager(
      email: email,
      fullName: fullName,
      password: password,
      phone: phone,
      area: area,
      location: location,
      address: address,
      pincode: pincode,
      region: region,
      notes: notes,
    );
    return result;
  }

  @override
  Future<UserEntity> updateManager({
    required String id,
    String? fullName,
    String? password,
    String? phone,
    String? area,
    String? location,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  }) async {
    return await _remoteSource.updateManager(
      id: id,
      fullName: fullName,
      password: password,
      phone: phone,
      area: area,
      location: location,
      address: address,
      pincode: pincode,
      region: region,
      notes: notes,
    );
  }

  @override
  Future<void> deleteManager(String id) async {
    await _remoteSource.deleteManager(id);
  }

  @override
  Future<ServiceListingEntity> assignManagerToService({
    required String serviceId,
    required String managerId,
  }) async {
    final result = await _remoteSource.assignManagerToService(
      serviceId: serviceId,
      managerId: managerId,
    );
    return result;
  }

  // Nodal Officer Methods
  @override
  Future<UserEntity> createNodalOfficer({
    required String email,
    required String fullName,
    required String password,
    required String area,
    required String location,
    String? phone,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  }) async {
    return await _remoteSource.createNodalOfficer(
      email: email,
      fullName: fullName,
      password: password,
      area: area,
      location: location,
      phone: phone,
      address: address,
      pincode: pincode,
      region: region,
      notes: notes,
    );
  }

  @override
  Future<List<NodalOfficerAssignmentEntity>> fetchNodalOfficers({
    String? location,
    String? area,
    String? pincode,
  }) async {
    final result = await _remoteSource.fetchNodalOfficers(
      location: location,
      area: area,
      pincode: pincode,
    );
    return List<NodalOfficerAssignmentEntity>.from(result);
  }

  @override
  Future<NodalOfficerAssignmentEntity> assignOfficerToArea({
    required String officerId,
    required String area,
    required String location,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  }) async {
    return await _remoteSource.assignOfficerToArea(
      officerId: officerId,
      area: area,
      location: location,
      address: address,
      pincode: pincode,
      region: region,
      notes: notes,
    );
  }

  @override
  Future<List<NodalOfficerRecommendationEntity>> fetchRecommendations({
    String? status,
  }) async {
    final result = await _remoteSource.fetchRecommendations(status: status);
    return List<NodalOfficerRecommendationEntity>.from(result);
  }

  @override
  Future<NodalOfficerRecommendationEntity> approveRecommendation(
    String recommendationId,
  ) async {
    return await _remoteSource.approveRecommendation(recommendationId);
  }

  @override
  Future<NodalOfficerRecommendationEntity> rejectRecommendation(
    String recommendationId, {
    String? notes,
  }) async {
    return await _remoteSource.rejectRecommendation(
      recommendationId,
      notes: notes,
    );
  }

  @override
  Future<List<ServiceCategoryEntity>> fetchServiceCategories() async {
    final result = await _remoteSource.fetchServiceCategories();
    return List<ServiceCategoryEntity>.from(result);
  }

  @override
  Future<ServiceCategoryEntity> createServiceCategory({
    required String name,
    String? description,
    bool showInNavbar = false,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    return await _remoteSource.createServiceCategory(
      name: name,
      description: description,
      showInNavbar: showInNavbar,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }

  @override
  Future<ServiceCategoryEntity> updateServiceCategory(
    String id, {
    String? name,
    String? description,
    bool? showInNavbar,
    int? displayOrder,
    bool? isActive,
  }) async {
    return await _remoteSource.updateServiceCategory(
      id,
      name: name,
      description: description,
      showInNavbar: showInNavbar,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }

  @override
  Future<void> deleteServiceCategory(String id) async {
    await _remoteSource.deleteServiceCategory(id);
  }

  // Form Field Configuration Methods
  @override
  Future<List<FormFieldConfigEntity>> fetchFormFieldConfigs() async {
    final result = await _remoteSource.fetchFormFieldConfigs();
    return List<FormFieldConfigEntity>.from(result);
  }

  @override
  Future<FormFieldConfigEntity> getFormFieldConfig(String id) async {
    return await _remoteSource.getFormFieldConfig(id);
  }

  @override
  Future<FormFieldConfigEntity> createFormFieldConfig({
    required String fieldKey,
    required String label,
    required String fieldType,
    bool isRequired = false,
    bool isEnabled = true,
    int displayOrder = 0,
    Map<String, dynamic>? validation,
    List<String>? options,
    String? placeholder,
    String? hint,
    String? step,
  }) async {
    return await _remoteSource.createFormFieldConfig(
      fieldKey: fieldKey,
      label: label,
      fieldType: fieldType,
      isRequired: isRequired,
      isEnabled: isEnabled,
      displayOrder: displayOrder,
      validation: validation,
      options: options,
      placeholder: placeholder,
      hint: hint,
      step: step,
    );
  }

  @override
  Future<FormFieldConfigEntity> updateFormFieldConfig(
    String id, {
    String? fieldKey,
    String? label,
    String? fieldType,
    bool? isRequired,
    bool? isEnabled,
    int? displayOrder,
    Map<String, dynamic>? validation,
    List<String>? options,
    String? placeholder,
    String? hint,
    String? step,
  }) async {
    return await _remoteSource.updateFormFieldConfig(
      id,
      fieldKey: fieldKey,
      label: label,
      fieldType: fieldType,
      isRequired: isRequired,
      isEnabled: isEnabled,
      displayOrder: displayOrder,
      validation: validation,
      options: options,
      placeholder: placeholder,
      hint: hint,
      step: step,
    );
  }

  @override
  Future<void> deleteFormFieldConfig(String id) async {
    await _remoteSource.deleteFormFieldConfig(id);
  }

  // Verification Checkpoint Configuration Methods
  @override
  Future<List<VerificationCheckpointConfigEntity>> fetchVerificationCheckpointConfigs() async {
    final result = await _remoteSource.fetchVerificationCheckpointConfigs();
    return List<VerificationCheckpointConfigEntity>.from(result);
  }

  @override
  Future<VerificationCheckpointConfigEntity> getVerificationCheckpointConfig(String id) async {
    return await _remoteSource.getVerificationCheckpointConfig(id);
  }

  @override
  Future<VerificationCheckpointConfigEntity> createVerificationCheckpointConfig({
    required String checkpointKey,
    required String label,
    required String checkpointType,
    String? description,
    bool isRequired = true,
    bool isEnabled = true,
    int displayOrder = 0,
    Map<String, dynamic>? validation,
    List<String>? options,
    String? placeholder,
    String? hint,
    String? category,
  }) async {
    return await _remoteSource.createVerificationCheckpointConfig(
      checkpointKey: checkpointKey,
      label: label,
      checkpointType: checkpointType,
      description: description,
      isRequired: isRequired,
      isEnabled: isEnabled,
      displayOrder: displayOrder,
      validation: validation,
      options: options,
      placeholder: placeholder,
      hint: hint,
      category: category,
    );
  }

  @override
  Future<VerificationCheckpointConfigEntity> updateVerificationCheckpointConfig(
    String id, {
    String? checkpointKey,
    String? label,
    String? checkpointType,
    String? description,
    bool? isRequired,
    bool? isEnabled,
    int? displayOrder,
    Map<String, dynamic>? validation,
    List<String>? options,
    String? placeholder,
    String? hint,
    String? category,
  }) async {
    return await _remoteSource.updateVerificationCheckpointConfig(
      id,
      checkpointKey: checkpointKey,
      label: label,
      checkpointType: checkpointType,
      description: description,
      isRequired: isRequired,
      isEnabled: isEnabled,
      displayOrder: displayOrder,
      validation: validation,
      options: options,
      placeholder: placeholder,
      hint: hint,
      category: category,
    );
  }

  @override
  Future<void> deleteVerificationCheckpointConfig(String id) async {
    await _remoteSource.deleteVerificationCheckpointConfig(id);
  }
}
