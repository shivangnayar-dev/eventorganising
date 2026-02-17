import '../entities/service_listing.dart';
import '../entities/user.dart';
import '../entities/verification_assignment.dart';
import '../entities/nodal_officer_assignment.dart';
import '../entities/nodal_officer_recommendation.dart';
import '../entities/service_category.dart';
import '../entities/form_field_config.dart';
import '../entities/verification_checkpoint_config.dart';

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.totalUsers,
    required this.totalServices,
    required this.totalBookings,
    required this.verificationPending,
  });

  final int totalUsers;
  final int totalServices;
  final int totalBookings;
  final int verificationPending;
}

abstract class AdminRepository {
  Future<AdminDashboardSummary> fetchDashboard();

  Future<List<UserEntity>> fetchUsers();

  Future<List<ServiceListingEntity>> fetchAllServices();

  Future<List<VerificationAssignmentEntity>> fetchVerifications();

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
  });

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
  });

  Future<void> deleteManager(String id);

  Future<ServiceListingEntity> assignManagerToService({
    required String serviceId,
    required String managerId,
  });

  // Nodal Officer Methods
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
  });

  Future<List<NodalOfficerAssignmentEntity>> fetchNodalOfficers({
    String? location,
    String? area,
    String? pincode,
  });

  Future<NodalOfficerAssignmentEntity> assignOfficerToArea({
    required String officerId,
    required String area,
    required String location,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  });

  Future<List<NodalOfficerRecommendationEntity>> fetchRecommendations({
    String? status,
  });

  Future<NodalOfficerRecommendationEntity> approveRecommendation(
    String recommendationId,
  );

  Future<NodalOfficerRecommendationEntity> rejectRecommendation(
    String recommendationId, {
    String? notes,
  });

  // Service Category Methods
  Future<List<ServiceCategoryEntity>> fetchServiceCategories();

  Future<ServiceCategoryEntity> createServiceCategory({
    required String name,
    String? description,
    bool showInNavbar = false,
    int displayOrder = 0,
    bool isActive = true,
  });

  Future<ServiceCategoryEntity> updateServiceCategory(
    String id, {
    String? name,
    String? description,
    bool? showInNavbar,
    int? displayOrder,
    bool? isActive,
  });

  Future<void> deleteServiceCategory(String id);

  // Form Field Configuration Methods
  Future<List<FormFieldConfigEntity>> fetchFormFieldConfigs();

  Future<FormFieldConfigEntity> getFormFieldConfig(String id);

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
  });

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
  });

  Future<void> deleteFormFieldConfig(String id);

  // Verification Checkpoint Configuration Methods
  Future<List<VerificationCheckpointConfigEntity>> fetchVerificationCheckpointConfigs();

  Future<VerificationCheckpointConfigEntity> getVerificationCheckpointConfig(String id);

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
  });

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
  });

  Future<void> deleteVerificationCheckpointConfig(String id);
}
