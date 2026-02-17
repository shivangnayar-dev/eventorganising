import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/verification_assignment.dart';
import '../../domain/usecases/service_usecases.dart';
import '../providers/app_providers.dart';

final verificationControllerProvider =
    StateNotifierProvider<VerificationController, VerificationState>((ref) {
  final useCases = ref.read(serviceUseCasesProvider);
  return VerificationController(useCases)..fetchAssignments();
});

class VerificationController extends StateNotifier<VerificationState> {
  VerificationController(this._useCases)
      : super(const VerificationState.initial());

  final ServiceUseCases _useCases;

  Future<void> fetchAssignments() async {
    state = state.copyWith(status: VerificationStatusState.loading);
    try {
      final tasks = await _useCases.fetchAssignedTasks();
      state = state.copyWith(
        status: VerificationStatusState.success,
        assignments: tasks,
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: VerificationStatusState.error,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> submitVerification({
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
      await fetchAssignments();
      return true;
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }
}

enum VerificationStatusState { initial, loading, success, error }

class VerificationState {
  const VerificationState({
    required this.status,
    required this.assignments,
    this.errorMessage,
  });

  const VerificationState.initial()
      : status = VerificationStatusState.initial,
        assignments = const <VerificationAssignmentEntity>[],
        errorMessage = null;

  final VerificationStatusState status;
  final List<VerificationAssignmentEntity> assignments;
  final String? errorMessage;

  VerificationState copyWith({
    VerificationStatusState? status,
    List<VerificationAssignmentEntity>? assignments,
    String? errorMessage,
  }) {
    return VerificationState(
      status: status ?? this.status,
      assignments: assignments ?? this.assignments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
