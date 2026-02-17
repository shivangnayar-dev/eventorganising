import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/service_controller.dart';
import 'manager_assign_screen.dart';
import 'manager_approval_screen.dart';

class ManagerIncomingScreen extends ConsumerWidget {
  const ManagerIncomingScreen({super.key});

  static const routePath = '/manager/incoming';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Service Requests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviceState.pendingVerifications.length,
        itemBuilder: (context, index) {
          final service = serviceState.pendingVerifications[index];
          return Card(
            child: ListTile(
              title: Text(service.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.description),
                  const SizedBox(height: 4),
                  Text('Location: ${service.location}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'assign':
                      context.push(ManagerAssignScreen.routePath,
                          extra: service);
                      break;
                    case 'approve':
                      context.push(ManagerApprovalScreen.routePath,
                          extra: service);
                      break;
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'assign', child: Text('Assign Agents')),
                  PopupMenuItem(
                      value: 'approve', child: Text('Approve/Reject')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
