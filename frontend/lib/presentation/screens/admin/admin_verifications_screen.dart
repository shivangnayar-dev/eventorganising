import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../domain/entities/service_listing.dart';
import '../../../domain/entities/role.dart';
import '../manager/manager_assign_screen.dart';
import '../admin/verification_progress_screen.dart';
import '../../widgets/provider_dashboard_cards.dart';

class AdminVerificationsScreen extends ConsumerWidget {
  const AdminVerificationsScreen({super.key});

  static const routePath = '/admin/verifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    final serviceState = ref.watch(serviceControllerProvider);
    final authState = ref.watch(authControllerProvider);
    
    // Get pending services from service state
    final pendingServices = serviceState.pendingVerifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Verifications'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminControllerProvider.notifier).loadDashboard();
          await ref.read(serviceControllerProvider.notifier).refreshDashboard();
        },
        child: pendingServices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No pending verifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All submitted services have been reviewed.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Stats summary
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ProviderDashboardCard(
                        title: 'Total Pending',
                        count: pendingServices.length,
                        icon: Icons.verified_outlined,
                        subtitle: 'Awaiting review',
                      ),
                      ProviderDashboardCard(
                        title: 'Published',
                        count: serviceState.approvedServices.length,
                        icon: Icons.check_circle_outlined,
                        subtitle: 'Live services',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Service managers section
                  SectionHeader(
                    title: 'Service Managers',
                    actions: [
                      TextButton(
                        onPressed: () => context.push('/admin/managers/new'),
                        child: const Text('Add Manager'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildManagersList(context, ref, authState),
                  const SizedBox(height: 32),
                  
                  // Pending verifications
                  SectionHeader(
                    title: 'Pending Verifications',
                    actions: [
                      Text(
                        '${pendingServices.length} services',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Service cards
                  ...pendingServices.map((service) => _buildVerificationCard(
                        context,
                        ref,
                        service,
                      )),
                ],
              ),
      ),
    );
  }

  Widget _buildManagersList(BuildContext context, WidgetRef ref, authState) {
    final managers = authState.user?.roles ?? [];
    final isManager = managers.any((role) => role.type == RoleType.manager);
    
    if (!isManager) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Assign managers to review and verify submitted services.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildVerificationCard(
    BuildContext context,
    WidgetRef ref,
    ServiceListingEntity service,
  ) {
    final statusColor = _getStatusColor(service.status);
    final statusLabel = _getStatusLabel(service.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push(
          '/manager/assign',
          extra: service,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_city_outlined,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.location,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (service.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (service.propertyType != null)
                    _buildInfoChip(
                      Icons.category_outlined,
                      service.propertyType!,
                    ),
                  if (service.capacity != null)
                    _buildInfoChip(
                      Icons.people_outline,
                      '${service.capacity} capacity',
                    ),
                  _buildInfoChip(
                    Icons.currency_rupee_outlined,
                    '₹${service.price.toStringAsFixed(2)}',
                  ),
                  if (service.eventTypes != null && service.eventTypes!.isNotEmpty)
                    _buildInfoChip(
                      Icons.event_outlined,
                      service.eventTypes!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (service.assignedNodalOfficerId != null)
                    TextButton.icon(
                      onPressed: () {
                        context.push(
                          VerificationProgressScreen.routePath,
                          extra: service,
                        );
                      },
                      icon: const Icon(Icons.track_changes_outlined),
                      label: const Text('View Progress'),
                    ),
                  if (service.assignedNodalOfficerId != null)
                    const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // View details
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => context.push(
                      '/manager/assign',
                      extra: service,
                    ),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Assign Manager'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.orange;
      case ServiceStatus.assigned:
        return Colors.blue;
      case ServiceStatus.verified:
        return Colors.green;
      case ServiceStatus.rejected:
        return Colors.red;
      case ServiceStatus.published:
        return const Color(0xFF6A5AE0);
    }
  }

  String _getStatusLabel(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return 'Pending Review';
      case ServiceStatus.assigned:
        return 'Under Review';
      case ServiceStatus.verified:
        return 'Verified';
      case ServiceStatus.rejected:
        return 'Rejected';
      case ServiceStatus.published:
        return 'Published';
    }
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (actions != null) Row(children: actions!),
      ],
    );
  }
}

