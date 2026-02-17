import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/verification_controller.dart';
import 'provider_verification_detail_screen.dart';

class ProviderTasksScreen extends ConsumerWidget {
  const ProviderTasksScreen({super.key});

  static const routePath = '/provider/tasks';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationState = ref.watch(verificationControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Verifications')),
      body: switch (verificationState.status) {
        VerificationStatusState.loading => const Center(
            child: CircularProgressIndicator(),
          ),
        VerificationStatusState.error => Center(
            child: Text(
              verificationState.errorMessage ?? 'Failed to load assignments',
            ),
          ),
        _ => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verificationState.assignments.length,
            itemBuilder: (context, index) {
              final assignment = verificationState.assignments[index];
              return Card(
                child: ListTile(
                  title: Text('Service: ${assignment.serviceId}'),
                  subtitle:
                      Text('Status: ${assignment.status.name.toUpperCase()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    onPressed: () => context.push(
                      ProviderVerificationDetailScreen.routePath,
                      extra: assignment,
                    ),
                  ),
                ),
              );
            },
          ),
      },
    );
  }
}
