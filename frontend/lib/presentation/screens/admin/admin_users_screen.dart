import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/admin_controller.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  static const routePath = '/admin/users';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All Users')),
      body: switch (adminState.status) {
        AdminStatus.loading => const Center(child: CircularProgressIndicator()),
        AdminStatus.error => Center(
            child: Text(adminState.errorMessage ?? 'Failed to load users'),
          ),
        _ => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminState.users.length,
            itemBuilder: (context, index) {
              final user = adminState.users[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : 'U',
                    ),
                  ),
                  title: Text(user.fullName.isNotEmpty ? user.fullName : 'No name'),
                  subtitle: Text(
                      '${user.email}\nRoles: ${user.roles.isEmpty ? 'No roles' : user.roles.map((r) => r.name).join(', ')}'),
                  isThreeLine: true,
                ),
              );
            },
          ),
      },
    );
  }
}
