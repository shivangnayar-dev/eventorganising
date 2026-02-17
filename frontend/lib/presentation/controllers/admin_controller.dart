import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/service_listing_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/verification_assignment_model.dart';
import '../../domain/entities/service_listing.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/verification_assignment.dart';
import '../../domain/entities/nodal_officer_assignment.dart';
import '../../domain/entities/nodal_officer_recommendation.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../providers/app_providers.dart';
import '../../data/models/nodal_officer_assignment_model.dart';
import '../../data/models/nodal_officer_recommendation_model.dart';
import '../../data/models/service_category_model.dart';
import '../../data/models/form_field_config_model.dart';
import '../../data/models/verification_checkpoint_config_model.dart';
import '../../domain/entities/form_field_config.dart';
import '../../domain/entities/verification_checkpoint_config.dart';

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  final useCases = ref.read(adminUseCasesProvider);
  return AdminController(useCases)..loadDashboard();
});

class AdminController extends StateNotifier<AdminState> {
  AdminController(this._useCases) : super(const AdminState.initial());

  final AdminUseCases _useCases;

  Future<void> loadDashboard() async {
    state = state.copyWith(status: AdminStatus.loading);
    try {
      final summary = await _useCases.fetchDashboard();
      final results = await Future.wait([
        _useCases.fetchUsers(),
        _useCases.fetchServices(),
        _useCases.fetchVerifications(),
      ]);

      final users = (results[0] as List<UserEntity>)
          .map((user) => user as UserModel)
          .toList(growable: false);
      final services = (results[1] as List<ServiceListingEntity>)
          .map((service) => service as ServiceListingModel)
          .toList(growable: false);
      final verifications = (results[2] as List<VerificationAssignmentEntity>)
          .map((verification) => verification as VerificationAssignmentModel)
          .toList(growable: false);

      // Load pending recommendations separately (don't fail dashboard if this fails)
      List<NodalOfficerRecommendationModel> pendingRecommendations = [];
      try {
        final pendingRecs = await _useCases.fetchRecommendations(status: 'PENDING');
        pendingRecommendations = pendingRecs
            .map((r) => r as NodalOfficerRecommendationModel)
            .toList(growable: false);
      } catch (e) {
        // Silently fail - recommendations will load when user navigates to that screen
      }

      state = state.copyWith(
        status: AdminStatus.success,
        dashboard: summary,
        users: users,
        services: services,
        verifications: verifications,
        recommendations: pendingRecommendations,
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> createManager({
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
    try {
      await _useCases.createManager(
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
      await loadDashboard();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> updateManager({
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
    try {
      await _useCases.updateManager(
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
      await loadDashboard();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> deleteManager(String id) async {
    try {
      await _useCases.deleteManager(id);
      await loadDashboard();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> assignManagerToService({
    required String serviceId,
    required String managerId,
  }) async {
    try {
      await _useCases.assignManagerToService(
        serviceId: serviceId,
        managerId: managerId,
      );
      await loadDashboard();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  // Nodal Officer Methods
  Future<void> loadNodalOfficers({
    String? location,
    String? area,
    String? pincode,
  }) async {
    state = state.copyWith(status: AdminStatus.loading);
    try {
      final officers = await _useCases.fetchNodalOfficers(
        location: location,
        area: area,
        pincode: pincode,
      );
      state = state.copyWith(
        status: AdminStatus.success,
        nodalOfficers: officers
            .map((o) => o as NodalOfficerAssignmentModel)
            .toList(),
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> createNodalOfficer({
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
    try {
      await _useCases.createNodalOfficer(
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
      await loadNodalOfficers();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<void> loadRecommendations({String? status}) async {
    state = state.copyWith(status: AdminStatus.loading);
    try {
      final recommendations = await _useCases.fetchRecommendations(status: status);
      state = state.copyWith(
        status: AdminStatus.success,
        recommendations: recommendations
            .map((r) => r as NodalOfficerRecommendationModel)
            .toList(),
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<void> _refreshPendingRecommendations() async {
    try {
      final pendingRecs = await _useCases.fetchRecommendations(status: 'PENDING');
      final pendingRecommendations = pendingRecs
          .map((r) => r as NodalOfficerRecommendationModel)
          .toList(growable: false);
      state = state.copyWith(recommendations: pendingRecommendations);
    } catch (e) {
      // Silently fail - recommendations will be updated on next full dashboard load
    }
  }

  Future<bool> approveRecommendation(String recommendationId) async {
    try {
      await _useCases.approveRecommendation(recommendationId);
      await loadRecommendations();
      await loadNodalOfficers();
      // Reload pending recommendations count for dashboard
      await _refreshPendingRecommendations();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> rejectRecommendation(String recommendationId, {String? notes}) async {
    try {
      await _useCases.rejectRecommendation(recommendationId, notes: notes);
      await loadRecommendations();
      // Reload pending recommendations count for dashboard
      await _refreshPendingRecommendations();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  // Service Category Methods
  Future<void> loadServiceCategories() async {
    try {
      state = state.copyWith(status: AdminStatus.loading);
      final categories = await _useCases.fetchServiceCategories();
      state = state.copyWith(
        status: AdminStatus.success,
        serviceCategories: categories
            .map((c) => c as ServiceCategoryModel)
            .toList(),
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> createServiceCategory({
    required String name,
    String? description,
    bool showInNavbar = false,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    try {
      await _useCases.createServiceCategory(
        name: name,
        description: description,
        showInNavbar: showInNavbar,
        displayOrder: displayOrder,
        isActive: isActive,
      );
      await loadServiceCategories();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> updateServiceCategory(
    String id, {
    String? name,
    String? description,
    bool? showInNavbar,
    int? displayOrder,
    bool? isActive,
  }) async {
    try {
      await _useCases.updateServiceCategory(
        id,
        name: name,
        description: description,
        showInNavbar: showInNavbar,
        displayOrder: displayOrder,
        isActive: isActive,
      );
      await loadServiceCategories();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> deleteServiceCategory(String id) async {
    try {
      await _useCases.deleteServiceCategory(id);
      await loadServiceCategories();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  // Form Field Configuration Methods
  Future<void> loadFormFieldConfigs() async {
    try {
      state = state.copyWith(status: AdminStatus.loading);
      final fields = await _useCases.fetchFormFieldConfigs();
      state = state.copyWith(
        status: AdminStatus.success,
        formFieldConfigs: fields
            .map((f) => f as FormFieldConfigModel)
            .toList(),
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> createFormFieldConfig({
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
    try {
      await _useCases.createFormFieldConfig(
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
      await loadFormFieldConfigs();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> updateFormFieldConfig(
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
    try {
      await _useCases.updateFormFieldConfig(
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
      await loadFormFieldConfigs();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> deleteFormFieldConfig(String id) async {
    try {
      await _useCases.deleteFormFieldConfig(id);
      await loadFormFieldConfigs();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  // Verification Checkpoint Configuration Methods
  Future<void> loadVerificationCheckpointConfigs() async {
    try {
      state = state.copyWith(status: AdminStatus.loading);
      final checkpoints = await _useCases.fetchVerificationCheckpointConfigs();
      state = state.copyWith(
        status: AdminStatus.success,
        verificationCheckpointConfigs: checkpoints
            .map((c) => c as VerificationCheckpointConfigModel)
            .toList(),
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> createVerificationCheckpointConfig({
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
    try {
      await _useCases.createVerificationCheckpointConfig(
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
      await loadVerificationCheckpointConfigs();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> updateVerificationCheckpointConfig(
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
    try {
      await _useCases.updateVerificationCheckpointConfig(
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
      await loadVerificationCheckpointConfigs();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> deleteVerificationCheckpointConfig(String id) async {
    try {
      await _useCases.deleteVerificationCheckpointConfig(id);
      await loadVerificationCheckpointConfigs();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }
}

enum AdminStatus { initial, loading, success, error }

class AdminState {
  const AdminState({
    required this.status,
    this.dashboard,
    required this.users,
    required this.services,
    required this.verifications,
    required this.nodalOfficers,
    required this.recommendations,
    required this.serviceCategories,
    required this.formFieldConfigs,
    required this.verificationCheckpointConfigs,
    this.errorMessage,
  });

  const AdminState.initial()
      : status = AdminStatus.initial,
        dashboard = null,
        users = const <UserModel>[],
        services = const <ServiceListingModel>[],
        verifications = const <VerificationAssignmentModel>[],
        nodalOfficers = const <NodalOfficerAssignmentModel>[],
        recommendations = const <NodalOfficerRecommendationModel>[],
        serviceCategories = const <ServiceCategoryModel>[],
        formFieldConfigs = const <FormFieldConfigModel>[],
        verificationCheckpointConfigs = const <VerificationCheckpointConfigModel>[],
        errorMessage = null;

  final AdminStatus status;
  final AdminDashboardSummary? dashboard;
  final List<UserModel> users;
  final List<ServiceListingModel> services;
  final List<VerificationAssignmentModel> verifications;
  final List<NodalOfficerAssignmentModel> nodalOfficers;
  final List<NodalOfficerRecommendationModel> recommendations;
  final List<ServiceCategoryModel> serviceCategories;
  final List<FormFieldConfigModel> formFieldConfigs;
  final List<VerificationCheckpointConfigModel> verificationCheckpointConfigs;
  final String? errorMessage;

  AdminState copyWith({
    AdminStatus? status,
    AdminDashboardSummary? dashboard,
    List<UserModel>? users,
    List<ServiceListingModel>? services,
    List<VerificationAssignmentModel>? verifications,
    List<NodalOfficerAssignmentModel>? nodalOfficers,
    List<NodalOfficerRecommendationModel>? recommendations,
    List<ServiceCategoryModel>? serviceCategories,
    List<FormFieldConfigModel>? formFieldConfigs,
    List<VerificationCheckpointConfigModel>? verificationCheckpointConfigs,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      users: users ?? this.users,
      services: services ?? this.services,
      verifications: verifications ?? this.verifications,
      nodalOfficers: nodalOfficers ?? this.nodalOfficers,
      recommendations: recommendations ?? this.recommendations,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      formFieldConfigs: formFieldConfigs ?? this.formFieldConfigs,
      verificationCheckpointConfigs: verificationCheckpointConfigs ?? this.verificationCheckpointConfigs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
