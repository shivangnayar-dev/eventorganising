import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../controllers/admin_controller.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  static const routePath = '/admin/reports';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    final dashboard = adminState.dashboard;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: switch (adminState.status) {
        AdminStatus.loading => const Center(child: CircularProgressIndicator()),
        AdminStatus.error => Center(
            child: Text(adminState.errorMessage ?? 'Failed to load dashboard'),
          ),
        _ => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    AppCard(
                      title: 'Total Users',
                      subtitle: '${dashboard?.totalUsers ?? 0}',
                      icon: Icons.people_alt_outlined,
                    ),
                    AppCard(
                      title: 'Total Services',
                      subtitle: '${dashboard?.totalServices ?? 0}',
                      icon: Icons.store_mall_directory_outlined,
                    ),
                    AppCard(
                      title: 'Total Bookings',
                      subtitle: '${dashboard?.totalBookings ?? 0}',
                      icon: Icons.book_online_outlined,
                    ),
                    AppCard(
                      title: 'Pending Verifications',
                      subtitle: '${dashboard?.verificationPending ?? 0}',
                      icon: Icons.verified_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Recent Verification Activity',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: adminState.verifications.length,
                    itemBuilder: (context, index) {
                      final verification = adminState.verifications[index];
                      return Card(
                        child: ListTile(
                          title: Text('Service: ${verification.serviceId}'),
                          subtitle: Text(
                            'Status: ${verification.status.name.toUpperCase()}\nAgent: ${verification.providerId}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      },
    );
  }
}
