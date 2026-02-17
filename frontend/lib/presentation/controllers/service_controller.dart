import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/service_listing.dart';
import '../../domain/entities/service_provider.dart';
import '../../domain/entities/verification_assignment.dart';
import '../../domain/entities/nodal_officer_assignment.dart';
import '../../domain/entities/nodal_officer_recommendation.dart';
import '../../domain/entities/manager_assignment.dart';
import '../../domain/usecases/service_usecases.dart';
import '../providers/app_providers.dart';
import '../../data/models/nodal_officer_assignment_model.dart';
import '../../data/models/nodal_officer_recommendation_model.dart';
import '../../data/models/manager_assignment_model.dart';

final serviceControllerProvider =
    StateNotifierProvider<ServiceController, ServiceState>((ref) {
  final useCases = ref.read(serviceUseCasesProvider);
  return ServiceController(useCases)..initialize();
});

class ServiceController extends StateNotifier<ServiceState> {
  ServiceController(this._useCases) : super(ServiceState.initial());

  final ServiceUseCases _useCases;

  Future<void> initialize() async {
    await Future.wait([
      loadDashboardData(),
      loadUserServices(),
      loadProviders(),
      loadManagedServices(),
    ]);
  }

  Future<void> loadManagedServices() async {
    try {
      final managed = await _useCases.fetchManagedServices();
      state = state.copyWith(managedServices: managed);
    } on AppException catch (error) {
      // Silently ignore 403 errors
      if (error.code != 403) {
        state = state.copyWith(errorMessage: error.message);
      }
    }
  }

  Future<void> loadProviders() async {
    try {
      final providers = await _useCases.fetchProviders();
      state = state.copyWith(providers: providers);
    } on AppException catch (error) {
      // Silently ignore 403 errors
      if (error.code != 403) {
        state = state.copyWith(errorMessage: error.message);
      }
    }
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(
      status: ServiceControllerStatus.loading,
      errorMessage: null,
    );

    List<ServiceListingEntity> pending = const [];
    List<ServiceListingEntity> published = const [];
    List<VerificationAssignmentEntity> assignments = const [];

    try {
      pending = await _useCases.fetchPendingServices();
    } on AppException catch (error) {
      if (error.code != 403) {
        state = state.copyWith(
          status: ServiceControllerStatus.error,
          errorMessage: error.message,
        );
        return;
      }
    }

    try {
      published = await _useCases.fetchPublishedServices();
    } on AppException catch (error) {
      state = state.copyWith(
        status: ServiceControllerStatus.error,
        errorMessage: error.message,
      );
      return;
    }

    try {
      assignments = await _useCases.fetchAssignedTasks();
    } on AppException catch (error) {
      // Silently ignore 403 errors (user doesn't have PROVIDER role)
      if (error.code != 403) {
        state = state.copyWith(
          status: ServiceControllerStatus.error,
          errorMessage: error.message,
        );
        return;
      }
      // For 403, just leave assignments as empty array
      assignments = const [];
    } catch (error) {
      // Handle any other errors gracefully
      assignments = const [];
    }

        state = state.copyWith(
          status: ServiceControllerStatus.success,
      pendingVerifications: pending,
      approvedServices: published,
      assignments: assignments,
      errorMessage: null,
    );
  }

  Future<void> loadUserServices() async {
    try {
      final requests = await _useCases.fetchUserServices();
      state = state.copyWith(myServices: requests);
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    }
  }

  Future<void> refreshDashboard() async {
    await Future.wait([
      loadDashboardData(),
      loadManagedServices(),
    ]);
  }

  Future<bool> submitService({
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
    state = state.copyWith(status: ServiceControllerStatus.submitting);
    try {
      final service = await _useCases.submitService(
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
      state = state.copyWith(
        status: ServiceControllerStatus.success,
        myServices: [service, ...state.myServices],
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        status: ServiceControllerStatus.error,
        errorMessage: error.message,
      );
      return false;
    }
  }

  Future<bool> assignAgents({
    required String serviceId,
    required List<String> agentIds,
    String? nodalOfficerId,
  }) async {
    try {
      await _useCases.assignAgents(
        serviceId: serviceId,
        agentIds: agentIds,
        nodalOfficerId: nodalOfficerId,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> verifyService({
    required String serviceId,
    required String decision,
    String? notes,
  }) async {
    try {
      await _useCases.verifyService(
        serviceId: serviceId,
        decision: decision,
        notes: notes,
      );
      await loadDashboardData();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  // Nodal Officer Methods for Managers
  Future<void> loadNodalOfficers({
    String? location,
    String? area,
    String? pincode,
  }) async {
    state = state.copyWith(status: ServiceControllerStatus.loading);
    try {
      final officers = await _useCases.fetchNodalOfficersByArea(
        location: location,
        area: area,
        pincode: pincode,
      );
      state = state.copyWith(
        status: ServiceControllerStatus.success,
        nodalOfficers: officers
            .map((o) => o as NodalOfficerAssignmentModel)
            .toList(),
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: ServiceControllerStatus.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> recommendNodalOfficer({
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
    try {
      await _useCases.recommendNodalOfficer(
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
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> assignNodalOfficer({
    required String serviceId,
    required String nodalOfficerId,
  }) async {
    try {
      await _useCases.assignNodalOfficer(
        serviceId: serviceId,
        nodalOfficerId: nodalOfficerId,
      );
      await loadDashboardData();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }

  Future<void> loadMyRecommendations() async {
    try {
      final recommendations = await _useCases.fetchMyRecommendations();
      state = state.copyWith(
        myRecommendations: recommendations
            .map((r) => r as NodalOfficerRecommendationModel)
            .toList(),
      );
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    }
  }

  Future<void> loadManagerAssignment() async {
    try {
      final assignment = await _useCases.fetchManagerAssignment();
      state = state.copyWith(
        managerAssignment: assignment as ManagerAssignmentModel,
      );
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    }
  }
}

enum ServiceControllerStatus { initial, loading, submitting, success, error }

class ServiceState {
  const ServiceState({
    required this.status,
    required this.pendingVerifications,
    required this.approvedServices,
    required this.myServices,
    required this.assignments,
    required this.providers,
    required this.managedServices,
      required this.nodalOfficers,
      required this.myRecommendations,
      this.managerAssignment,
      this.errorMessage,
    });

  factory ServiceState.initial() => const ServiceState(
        status: ServiceControllerStatus.initial,
        pendingVerifications: <ServiceListingEntity>[],
        approvedServices: <ServiceListingEntity>[],
        myServices: <ServiceListingEntity>[],
        assignments: <VerificationAssignmentEntity>[],
        providers: <ServiceProviderEntity>[],
        managedServices: <ServiceListingEntity>[],
        nodalOfficers: <NodalOfficerAssignmentEntity>[],
        myRecommendations: <NodalOfficerRecommendationEntity>[],
        managerAssignment: null,
      );

  final ServiceControllerStatus status;
  final List<ServiceListingEntity> pendingVerifications;
  final List<ServiceListingEntity> approvedServices;
  final List<ServiceListingEntity> myServices;
  final List<VerificationAssignmentEntity> assignments;
  final List<ServiceProviderEntity> providers;
  final List<ServiceListingEntity> managedServices;
  final List<NodalOfficerAssignmentEntity> nodalOfficers;
  final List<NodalOfficerRecommendationEntity> myRecommendations;
  final ManagerAssignmentEntity? managerAssignment;
  final String? errorMessage;

  ServiceState copyWith({
    ServiceControllerStatus? status,
    List<ServiceListingEntity>? pendingVerifications,
    List<ServiceListingEntity>? approvedServices,
    List<ServiceListingEntity>? myServices,
    List<VerificationAssignmentEntity>? assignments,
    List<ServiceProviderEntity>? providers,
    List<ServiceListingEntity>? managedServices,
    List<NodalOfficerAssignmentEntity>? nodalOfficers,
    List<NodalOfficerRecommendationEntity>? myRecommendations,
    ManagerAssignmentEntity? managerAssignment,
    String? errorMessage,
  }) {
    return ServiceState(
      status: status ?? this.status,
      pendingVerifications: pendingVerifications ?? this.pendingVerifications,
      approvedServices: approvedServices ?? this.approvedServices,
      myServices: myServices ?? this.myServices,
      assignments: assignments ?? this.assignments,
      providers: providers ?? this.providers,
      managedServices: managedServices ?? this.managedServices,
      nodalOfficers: nodalOfficers ?? this.nodalOfficers,
      myRecommendations: myRecommendations ?? this.myRecommendations,
      managerAssignment: managerAssignment ?? this.managerAssignment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
