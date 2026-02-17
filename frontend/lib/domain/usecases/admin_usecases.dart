import '../entities/service_listing.dart';
import '../entities/user.dart';
import '../entities/verification_assignment.dart';
import '../entities/nodal_officer_assignment.dart';
import '../entities/nodal_officer_recommendation.dart';
import '../entities/service_category.dart';
import '../entities/form_field_config.dart';
import '../entities/verification_checkpoint_config.dart';
import '../repositories/admin_repository.dart';

class AdminUseCases {
  const AdminUseCases(this._repository);

  final AdminRepository _repository;

  Future<AdminDashboardSummary> fetchDashboard() =>
      _repository.fetchDashboard();

  Future<List<UserEntity>> fetchUsers() => _repository.fetchUsers();

  Future<List<ServiceListingEntity>> fetchServices() =>
      _repository.fetchAllServices();

  Future<List<VerificationAssignmentEntity>> fetchVerifications() =>
      _repository.fetchVerifications();

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
  }) =>
      _repository.createManager(
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
  }) =>
      _repository.updateManager(
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

  Future<void> deleteManager(String id) => _repository.deleteManager(id);

  Future<ServiceListingEntity> assignManagerToService({
    required String serviceId,
    required String managerId,
  }) =>
      _repository.assignManagerToService(
        serviceId: serviceId,
        managerId: managerId,
      );

  // Nodal Officer Use Cases
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
  }) =>
      _repository.createNodalOfficer(
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

  Future<List<NodalOfficerAssignmentEntity>> fetchNodalOfficers({
    String? location,
    String? area,
    String? pincode,
  }) =>
      _repository.fetchNodalOfficers(
        location: location,
        area: area,
        pincode: pincode,
      );

  Future<NodalOfficerAssignmentEntity> assignOfficerToArea({
    required String officerId,
    required String area,
    required String location,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  }) =>
      _repository.assignOfficerToArea(
        officerId: officerId,
        area: area,
        location: location,
        address: address,
        pincode: pincode,
        region: region,
        notes: notes,
      );

  Future<List<NodalOfficerRecommendationEntity>> fetchRecommendations({
    String? status,
  }) =>
      _repository.fetchRecommendations(status: status);

  Future<NodalOfficerRecommendationEntity> approveRecommendation(
    String recommendationId,
  ) =>
      _repository.approveRecommendation(recommendationId);

  Future<NodalOfficerRecommendationEntity> rejectRecommendation(
    String recommendationId, {
    String? notes,
  }) =>
      _repository.rejectRecommendation(
        recommendationId,
        notes: notes,
      );

  // Service Category Use Cases
  Future<List<ServiceCategoryEntity>> fetchServiceCategories() =>
      _repository.fetchServiceCategories();

  Future<ServiceCategoryEntity> createServiceCategory({
    required String name,
    String? description,
    bool showInNavbar = false,
    int displayOrder = 0,
    bool isActive = true,
  }) =>
      _repository.createServiceCategory(
        name: name,
        description: description,
        showInNavbar: showInNavbar,
        displayOrder: displayOrder,
        isActive: isActive,
      );

  Future<ServiceCategoryEntity> updateServiceCategory(
    String id, {
    String? name,
    String? description,
    bool? showInNavbar,
    int? displayOrder,
    bool? isActive,
  }) =>
      _repository.updateServiceCategory(
        id,
        name: name,
        description: description,
        showInNavbar: showInNavbar,
        displayOrder: displayOrder,
        isActive: isActive,
      );

  Future<void> deleteServiceCategory(String id) =>
      _repository.deleteServiceCategory(id);

  // Form Field Configuration Use Cases
  Future<List<FormFieldConfigEntity>> fetchFormFieldConfigs() =>
      _repository.fetchFormFieldConfigs();

  Future<FormFieldConfigEntity> getFormFieldConfig(String id) =>
      _repository.getFormFieldConfig(id);

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
  }) =>
      _repository.createFormFieldConfig(
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
  }) =>
      _repository.updateFormFieldConfig(
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

  Future<void> deleteFormFieldConfig(String id) =>
      _repository.deleteFormFieldConfig(id);

  // Verification Checkpoint Configuration Use Cases
  Future<List<VerificationCheckpointConfigEntity>> fetchVerificationCheckpointConfigs() =>
      _repository.fetchVerificationCheckpointConfigs();

  Future<VerificationCheckpointConfigEntity> getVerificationCheckpointConfig(String id) =>
      _repository.getVerificationCheckpointConfig(id);

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
  }) =>
      _repository.createVerificationCheckpointConfig(
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
  }) =>
      _repository.updateVerificationCheckpointConfig(
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

  Future<void> deleteVerificationCheckpointConfig(String id) =>
      _repository.deleteVerificationCheckpointConfig(id);
}
