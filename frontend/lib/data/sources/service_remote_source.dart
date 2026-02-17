import '../../core/network/api_client.dart';
import '../models/service_listing_model.dart';
import '../models/service_provider_model.dart';
import '../models/verification_assignment_model.dart';
import '../models/nodal_officer_assignment_model.dart';
import '../models/nodal_officer_recommendation_model.dart';
import '../models/manager_assignment_model.dart';
import '../models/service_category_model.dart';
import '../models/form_field_config_model.dart';
import '../models/verification_checkpoint_config_model.dart';

class ServiceRemoteSource {
  final _client = ApiClient.instance;

  Future<ServiceListingModel> submitService({
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
    final response = await _client.post<Map<String, dynamic>>(
      '/service/create',
      data: {
        'title': title,
        'description': description,
        'location': location,
        if (address != null) 'address': address,
        if (pincode != null) 'pincode': pincode,
        if (eventTypes != null) 'eventTypes': eventTypes,
        if (propertyType != null) 'propertyType': propertyType,
        if (capacity != null) 'capacity': capacity,
        if (amenities != null) 'amenities': amenities,
        if (photos != null && photos.isNotEmpty) 'photos': photos,
        'price': price,
      },
    );
    return ServiceListingModel.fromJson(response.data ?? const {});
  }

  Future<List<ServiceListingModel>> fetchUserServices() async {
    final response = await _client.get<List<dynamic>>('/service/my');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceListingModel>> fetchPending() async {
    final response = await _client.get<List<dynamic>>('/service/pending');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceListingModel>> fetchPublished() async {
    final response = await _client.get<List<dynamic>>('/service/list');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceListingModel>> fetchPublic() async {
    final response = await _client.get<List<dynamic>>('/service/public');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceListingModel>> fetchManaged() async {
    final response = await _client.get<List<dynamic>>('/service/managed');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignAgents({
    required String serviceId,
    required List<String> agentIds,
    String? nodalOfficerId,
  }) async {
    final data = <String, dynamic>{
      'serviceId': serviceId,
      'agentIds': agentIds,
    };
    if (nodalOfficerId != null) {
      data['nodalOfficerId'] = nodalOfficerId;
    }
    await _client.post('/service/assign', data: data);
  }

  Future<Map<String, dynamic>> assignNodalOfficer({
    required String serviceId,
    required String nodalOfficerId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/service/assign-nodal-officer',
      data: {
        'serviceId': serviceId,
        'nodalOfficerId': nodalOfficerId,
      },
    );
    return response.data ?? const {};
  }

  Future<void> verifyService({
    required String serviceId,
    required String decision,
    String? notes,
  }) async {
    await _client.post(
      '/service/verify',
      data: {
        'serviceId': serviceId,
        'decision': decision,
        'notes': notes,
      },
    );
  }

  Future<List<VerificationAssignmentModel>> fetchAssignments() async {
    final response = await _client.get<List<dynamic>>('/service/assigned');
    final result = response.data ?? [];
    return result
        .map((item) => VerificationAssignmentModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> onboardProvider({
    required String kycDocumentUrl,
    required String pricingDetails,
    List<String>? photoUrls,
  }) async {
    await _client.post(
      '/service/provider/onboard',
      data: {
        'kycDocumentUrl': kycDocumentUrl,
        'pricingDetails': pricingDetails,
        'photoUrls': photoUrls,
      },
    );
  }

  Future<List<ServiceProviderModel>> fetchProviders() async {
    final response = await _client.get<List<dynamic>>('/service/providers');
    final result = response.data ?? [];
    return result
        .map((item) =>
            ServiceProviderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Nodal Officer Methods for Managers
  Future<List<NodalOfficerAssignmentModel>> fetchNodalOfficersByArea({
    String? location,
    String? area,
    String? pincode,
  }) async {
    final queryParams = <String, dynamic>{};
    if (location != null) queryParams['location'] = location;
    if (area != null) queryParams['area'] = area;
    if (pincode != null) queryParams['pincode'] = pincode;

    final response = await _client.get<List<dynamic>>(
      '/service/nodal-officers',
      queryParameters: queryParams,
    );
    final result = response.data ?? [];
    return result
        .map((item) => NodalOfficerAssignmentModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<NodalOfficerRecommendationModel> recommendNodalOfficer({
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
    final data = <String, dynamic>{
      'area': area,
      'location': location,
    };
    
    if (officerId != null) {
      data['officerId'] = officerId;
    } else {
      data['newUserEmail'] = newUserEmail;
      data['newUserFullName'] = newUserFullName;
      if (newUserPhone != null) {
        data['newUserPhone'] = newUserPhone;
      }
    }
    
    if (address != null) data['address'] = address;
    if (pincode != null) data['pincode'] = pincode;
    if (region != null) data['region'] = region;
    if (reason != null) data['reason'] = reason;

    final response = await _client.post<Map<String, dynamic>>(
      '/service/nodal-officers/recommend',
      data: data,
    );
    return NodalOfficerRecommendationModel.fromJson(response.data ?? const {});
  }

  Future<Map<String, dynamic>> fetchAvailableNodalOfficersForService(
    String serviceId,
  ) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/service/$serviceId/nodal-officers',
    );
    return response.data ?? const {};
  }

  Future<List<NodalOfficerRecommendationModel>> fetchMyRecommendations() async {
    final response = await _client.get<List<dynamic>>(
      '/service/nodal-officers/my-recommendations',
    );
    final result = response.data ?? [];
    return result
        .map((item) => NodalOfficerRecommendationModel.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<ManagerAssignmentModel> fetchManagerAssignment() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/service/manager/assignment',
    );
    return ManagerAssignmentModel.fromJson(response.data ?? const {});
  }

  // Public endpoint for navbar service categories
  Future<List<ServiceCategoryModel>> fetchNavbarServiceCategories() async {
    final response = await _client.get<List<dynamic>>('/service/categories/navbar');
    final result = response.data ?? [];
    return result
        .map((item) => ServiceCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Public endpoint for form field configurations
  Future<List<FormFieldConfigModel>> fetchFormFieldConfigs() async {
    final response = await _client.get<List<dynamic>>('/service/form-fields');
    final result = response.data ?? [];
    return result
        .map((item) => FormFieldConfigModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Public endpoint for verification checkpoint configurations
  Future<List<VerificationCheckpointConfigModel>> fetchVerificationCheckpointConfigs() async {
    final response = await _client.get<List<dynamic>>('/service/verification-checkpoints');
    final result = response.data ?? [];
    return result
        .map((item) => VerificationCheckpointConfigModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get verification assignments for a service (for admins/managers)
  Future<List<VerificationAssignmentModel>> fetchServiceVerificationAssignments(String serviceId) async {
    final response = await _client.get<List<dynamic>>('/service/$serviceId/verification-assignments');
    final result = response.data ?? [];
    return result
        .map((item) => VerificationAssignmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
