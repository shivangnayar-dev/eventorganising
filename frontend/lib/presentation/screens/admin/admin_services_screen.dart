import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/admin_controller.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  static const routePath = '/admin/services';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All Services')),
      body: switch (adminState.status) {
        AdminStatus.loading => const Center(child: CircularProgressIndicator()),
        AdminStatus.error => Center(
            child: Text(adminState.errorMessage ?? 'Failed to load services'),
          ),
        _ => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Owner')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Price')),
              ],
              rows: [
                for (final service in adminState.services)
                  DataRow(
                    cells: [
                      DataCell(Text(service.title)),
                      DataCell(Text(service.ownerId)),
                      DataCell(Text(service.status.name.toUpperCase())),
                      DataCell(Text(service.location)),
                      DataCell(Text('₹${service.price.toStringAsFixed(2)}')),
                    ],
                  ),
              ],
            ),
          ),
      },
    );
  }
}
