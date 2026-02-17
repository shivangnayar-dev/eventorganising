import '../../core/network/api_client.dart';
import '../models/service_listing_model.dart';
import '../models/user_model.dart';
import '../models/verification_assignment_model.dart';
import '../models/nodal_officer_assignment_model.dart';
import '../models/nodal_officer_recommendation_model.dart';
import '../models/service_category_model.dart';
import '../models/form_field_config_model.dart';
import '../models/verification_checkpoint_config_model.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRemoteSource {
  final _client = ApiClient.instance;

  Future<AdminDashboardSummary> fetchDashboard() async {
    final response =
        await _client.get<Map<String, dynamic>>('/admin/dashboard');
    final data = response.data ?? const {};
    return AdminDashboardSummary(
      totalUsers: data['totalUsers'] as int? ?? 0,
      totalServices: data['totalServices'] as int? ?? 0,
      totalBookings: data['totalBookings'] as int? ?? 0,
      verificationPending: data['verificationPending'] as int? ?? 0,
    );
  }

  Future<List<UserModel>> fetchUsers() async {
    final response = await _client.get<List<dynamic>>('/admin/users');
    final result = response.data ?? [];
    return result
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceListingModel>> fetchServices() async {
    final response = await _client.get<List<dynamic>>('/admin/services');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<VerificationAssignmentModel>> fetchVerifications() async {
    final response = await _client.get<List<dynamic>>('/admin/verifications');
    final result = response.data ?? [];
    return result
        .map((item) => VerificationAssignmentModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<UserModel> createManager({
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
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/managers',
      data: {
        'email': email,
        'fullName': fullName,
        'password': password,
        'phone': phone,
        'area': area,
        'location': location,
        'address': address,
        'pincode': pincode,
        'region': region,
        'notes': notes,
      },
    );
    return UserModel.fromJson(response.data ?? const {});
  }

  Future<UserModel> updateManager({
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
    final response = await _client.put<Map<String, dynamic>>(
      '/admin/managers/$id',
      data: {
        if (fullName != null) 'fullName': fullName,
        if (password != null && password.isNotEmpty) 'password': password,
        if (phone != null) 'phone': phone,
        if (area != null) 'area': area,
        if (location != null) 'location': location,
        if (address != null) 'address': address,
        if (pincode != null) 'pincode': pincode,
        if (region != null) 'region': region,
        if (notes != null) 'notes': notes,
      },
    );
    return UserModel.fromJson(response.data ?? const {});
  }

  Future<void> deleteManager(String id) async {
    await _client.delete('/admin/managers/$id');
  }

  Future<ServiceListingModel> assignManagerToService({
    required String serviceId,
    required String managerId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/assign-manager',
      data: {
        'serviceId': serviceId,
        'managerId': managerId,
      },
    );
    return ServiceListingModel.fromJson(response.data ?? const {});
  }

  // Nodal Officer Methods
  Future<UserModel> createNodalOfficer({
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
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/nodal-officers',
      data: {
        'email': email,
        'fullName': fullName,
        'password': password,
        'phone': phone,
        'area': area,
        'location': location,
        'address': address,
        'pincode': pincode,
        'region': region,
        'notes': notes,
      },
    );
    return UserModel.fromJson(response.data ?? const {});
  }

  Future<List<NodalOfficerAssignmentModel>> fetchNodalOfficers({
    String? location,
    String? area,
    String? pincode,
  }) async {
    final queryParams = <String, dynamic>{};
    if (location != null) queryParams['location'] = location;
    if (area != null) queryParams['area'] = area;
    if (pincode != null) queryParams['pincode'] = pincode;

    final response = await _client.get<List<dynamic>>(
      '/admin/nodal-officers',
      queryParameters: queryParams,
    );
    final result = response.data ?? [];
    return result
        .map((item) => NodalOfficerAssignmentModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<NodalOfficerAssignmentModel> assignOfficerToArea({
    required String officerId,
    required String area,
    required String location,
    String? address,
    String? pincode,
    String? region,
    String? notes,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/nodal-officers/assign',
      data: {
        'officerId': officerId,
        'area': area,
        'location': location,
        'address': address,
        'pincode': pincode,
        'region': region,
        'notes': notes,
      },
    );
    return NodalOfficerAssignmentModel.fromJson(response.data ?? const {});
  }

  Future<List<NodalOfficerRecommendationModel>> fetchRecommendations({
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _client.get<List<dynamic>>(
      '/admin/recommendations',
      queryParameters: queryParams,
    );
    final result = response.data ?? [];
    return result
        .map((item) => NodalOfficerRecommendationModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<NodalOfficerRecommendationModel> approveRecommendation(
    String recommendationId,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/recommendations/$recommendationId/approve',
    );
    return NodalOfficerRecommendationModel.fromJson(response.data ?? const {});
  }

  Future<NodalOfficerRecommendationModel> rejectRecommendation(
    String recommendationId, {
    String? notes,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/recommendations/$recommendationId/reject',
      data: {'notes': notes},
    );
    return NodalOfficerRecommendationModel.fromJson(response.data ?? const {});
  }

  // Service Category Methods
  Future<List<ServiceCategoryModel>> fetchServiceCategories() async {
    final response = await _client.get<List<dynamic>>('/admin/service-categories');
    final result = response.data ?? [];
    return result
        .map((item) => ServiceCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceCategoryModel> createServiceCategory({
    required String name,
    String? description,
    bool showInNavbar = false,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/service-categories',
      data: {
        'name': name,
        'description': description,
        'showInNavbar': showInNavbar,
        'displayOrder': displayOrder,
        'isActive': isActive,
      },
    );
    return ServiceCategoryModel.fromJson(response.data ?? const {});
  }

  Future<ServiceCategoryModel> updateServiceCategory(
    String id, {
    String? name,
    String? description,
    bool? showInNavbar,
    int? displayOrder,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (showInNavbar != null) data['showInNavbar'] = showInNavbar;
    if (displayOrder != null) data['displayOrder'] = displayOrder;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _client.put<Map<String, dynamic>>(
      '/admin/service-categories/$id',
      data: data,
    );
    return ServiceCategoryModel.fromJson(response.data ?? const {});
  }

  Future<void> deleteServiceCategory(String id) async {
    await _client.delete('/admin/service-categories/$id');
  }

  // Form Field Configuration Methods
  Future<List<FormFieldConfigModel>> fetchFormFieldConfigs() async {
    final response = await _client.get<List<dynamic>>('/admin/form-fields');
    final result = response.data ?? [];
    return result
        .map((item) => FormFieldConfigModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FormFieldConfigModel> getFormFieldConfig(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/admin/form-fields/$id');
    return FormFieldConfigModel.fromJson(response.data ?? const {});
  }

  Future<FormFieldConfigModel> createFormFieldConfig({
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
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/form-fields',
      data: {
        'fieldKey': fieldKey,
        'label': label,
        'fieldType': fieldType,
        'isRequired': isRequired,
        'isEnabled': isEnabled,
        'displayOrder': displayOrder,
        if (validation != null) 'validation': validation,
        if (options != null) 'options': options,
        if (placeholder != null) 'placeholder': placeholder,
        if (hint != null) 'hint': hint,
        if (step != null) 'step': step,
      },
    );
    return FormFieldConfigModel.fromJson(response.data ?? const {});
  }

  Future<FormFieldConfigModel> updateFormFieldConfig(
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
    final data = <String, dynamic>{};
    if (fieldKey != null) data['fieldKey'] = fieldKey;
    if (label != null) data['label'] = label;
    if (fieldType != null) data['fieldType'] = fieldType;
    if (isRequired != null) data['isRequired'] = isRequired;
    if (isEnabled != null) data['isEnabled'] = isEnabled;
    if (displayOrder != null) data['displayOrder'] = displayOrder;
    if (validation != null) data['validation'] = validation;
    if (options != null) data['options'] = options;
    if (placeholder != null) data['placeholder'] = placeholder;
    if (hint != null) data['hint'] = hint;
    if (step != null) data['step'] = step;

    final response = await _client.put<Map<String, dynamic>>(
      '/admin/form-fields/$id',
      data: data,
    );
    return FormFieldConfigModel.fromJson(response.data ?? const {});
  }

  Future<void> deleteFormFieldConfig(String id) async {
    await _client.delete('/admin/form-fields/$id');
  }

  // Verification Checkpoint Configuration Methods
  Future<List<VerificationCheckpointConfigModel>> fetchVerificationCheckpointConfigs() async {
    final response = await _client.get<List<dynamic>>('/admin/verification-checkpoints');
    final result = response.data ?? [];
    return result
        .map((item) => VerificationCheckpointConfigModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<VerificationCheckpointConfigModel> getVerificationCheckpointConfig(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/admin/verification-checkpoints/$id');
    return VerificationCheckpointConfigModel.fromJson(response.data ?? const {});
  }

  Future<VerificationCheckpointConfigModel> createVerificationCheckpointConfig({
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
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/verification-checkpoints',
      data: {
        'checkpointKey': checkpointKey,
        'label': label,
        'checkpointType': checkpointType,
        if (description != null) 'description': description,
        'isRequired': isRequired,
        'isEnabled': isEnabled,
        'displayOrder': displayOrder,
        if (validation != null) 'validation': validation,
        if (options != null) 'options': options,
        if (placeholder != null) 'placeholder': placeholder,
        if (hint != null) 'hint': hint,
        if (category != null) 'category': category,
      },
    );
    return VerificationCheckpointConfigModel.fromJson(response.data ?? const {});
  }

  Future<VerificationCheckpointConfigModel> updateVerificationCheckpointConfig(
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
    final data = <String, dynamic>{};
    if (checkpointKey != null) data['checkpointKey'] = checkpointKey;
    if (label != null) data['label'] = label;
    if (checkpointType != null) data['checkpointType'] = checkpointType;
    if (description != null) data['description'] = description;
    if (isRequired != null) data['isRequired'] = isRequired;
    if (isEnabled != null) data['isEnabled'] = isEnabled;
    if (displayOrder != null) data['displayOrder'] = displayOrder;
    if (validation != null) data['validation'] = validation;
    if (options != null) data['options'] = options;
    if (placeholder != null) data['placeholder'] = placeholder;
    if (hint != null) data['hint'] = hint;
    if (category != null) data['category'] = category;

    final response = await _client.put<Map<String, dynamic>>(
      '/admin/verification-checkpoints/$id',
      data: data,
    );
    return VerificationCheckpointConfigModel.fromJson(response.data ?? const {});
  }

  Future<void> deleteVerificationCheckpointConfig(String id) async {
    await _client.delete('/admin/verification-checkpoints/$id');
  }
}
