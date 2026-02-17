import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart' hide ServiceStatus;
import '../../providers/app_providers.dart';
import '../../../domain/entities/role.dart';
import '../../../domain/entities/service_listing.dart';
import '../../../data/models/user_model.dart';
import '../admin/admin_reports_screen.dart';
import '../admin/admin_services_screen.dart';
import '../admin/admin_users_screen.dart';
import '../admin/admin_add_manager_screen.dart';
import '../admin/admin_nodal_officers_screen.dart';
import '../admin/admin_recommendations_screen.dart';
import '../admin/admin_service_categories_screen.dart';
import '../admin/admin_form_fields_screen.dart';
import '../admin/admin_verification_checkpoints_screen.dart';
import '../admin/verification_progress_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/provider_dashboard_cards.dart';
import '../../widgets/provider_venue_card.dart';
import '../../widgets/admin/stat_card.dart';
import 'book_service_screen.dart';
import 'my_requests_screen.dart';
import 'submit_service_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const routePath = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeProvider);
    final List<RoleEntity> roles =
        authState.user?.roles ?? const <RoleEntity>[];
    bool hasRole(RoleType type) => roles.any((role) => role.type == type);

    final isAdmin = hasRole(RoleType.admin);
    final isManager = hasRole(RoleType.manager);
    final isProvider = hasRole(RoleType.provider);
    final isNodalOfficer = hasRole(RoleType.nodalOfficer);

    final adminState = ref.watch(adminControllerProvider);
    final showAdminView = isAdmin;
    final showProviderActions = isProvider && !showAdminView;
    
    // Refresh admin dashboard when state changes to ensure latest data
    if (showAdminView && adminState.status == AdminStatus.initial) {
      // Load dashboard if not already loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(adminControllerProvider.notifier).loadDashboard();
      });
    }

    Widget buildNonAdminContent() {
      // Helper methods for manager dashboard
      Color getManagerStatusColor(ServiceStatus status) {
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
            return const Color(0xFF2196F3);
        }
      }

      String getManagerStatusLabel(ServiceStatus status) {
        switch (status) {
          case ServiceStatus.pending:
            return 'Pending';
          case ServiceStatus.assigned:
            return 'Assigned';
          case ServiceStatus.verified:
            return 'Verified';
          case ServiceStatus.rejected:
            return 'Rejected';
          case ServiceStatus.published:
            return 'Published';
        }
      }

      Widget buildManagerServiceCard(BuildContext context, ServiceListingEntity service) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => context.push('/manager/assign', extra: service),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_city_outlined, color: Color(0xFF2196F3), size: 28),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      service.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: getManagerStatusColor(service.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      getManagerStatusLabel(service.status),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: getManagerStatusColor(service.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.location,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  if (service.propertyType != null) ...[
                                    Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(service.propertyType!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ],
                              ),
                              if (service.assignedNodalOfficer != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.verified_user_outlined, size: 14, color: Colors.green.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Nodal Officer: ${service.assignedNodalOfficer!.fullName}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // View Progress Button
                if (service.assignedNodalOfficerId != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        VerificationProgressScreen.routePath,
                        extra: service,
                      );
                    },
                    icon: const Icon(Icons.track_changes_outlined, size: 18),
                    label: const Text('View Progress'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                service.assignedNodalOfficerId != null
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          // Allow reassignment
                          try {
                            debugPrint('Navigating to reassign nodal officer for service: ${service.id}');
                            final success = await context.push<bool>(
                              '/manager/assign-nodal-officer',
                              extra: service,
                            );
                            debugPrint('Navigation result: $success');
                            if (success == true && context.mounted) {
                              ref.read(serviceControllerProvider.notifier).loadDashboardData();
                            }
                          } catch (e, stackTrace) {
                            debugPrint('Error navigating to assign nodal officer: $e');
                            debugPrint('Stack trace: $stackTrace');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Change Officer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: () async {
                          try {
                            debugPrint('Navigating to assign nodal officer for service: ${service.id}');
                            final success = await context.push<bool>(
                              '/manager/assign-nodal-officer',
                              extra: service,
                            );
                            debugPrint('Navigation result: $success');
                            // Refresh dashboard after assignment
                            if (success == true && context.mounted) {
                              // Reload services to show updated status
                              ref.read(serviceControllerProvider.notifier).loadDashboardData();
                            }
                          } catch (e, stackTrace) {
                            debugPrint('Error navigating to assign nodal officer: $e');
                            debugPrint('Stack trace: $stackTrace');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.verified_user_outlined, size: 18),
                        label: const Text('Assign Nodal Officer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
              ],
            ),
          ),
        );
      }

      switch (serviceState.status) {
        case ServiceControllerStatus.loading:
          return const Center(child: AppLoader());
        case ServiceControllerStatus.error:
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                serviceState.errorMessage ?? 'Failed to load dashboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref
                    .read(serviceControllerProvider.notifier)
                    .loadDashboardData(),
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Retry'),
              ),
            ],
          );
        case ServiceControllerStatus.submitting:
        case ServiceControllerStatus.initial:
        case ServiceControllerStatus.success:
          final cards = <Widget>[];
          if (isManager) {
            cards.add(
              SizedBox(
                width: 260,
                child: AppCard(
                  title: 'Pending Verifications',
                  subtitle:
                      '${serviceState.pendingVerifications.length} services awaiting approval',
                  icon: Icons.verified_outlined,
                  onTap: () => ref
                      .read(serviceControllerProvider.notifier)
                      .loadDashboardData(),
                ),
              ),
            );
          }
          cards.add(
            SizedBox(
              width: 260,
              child: AppCard(
                title: 'Published Services',
                subtitle:
                    '${serviceState.approvedServices.length} services live',
                icon: Icons.public_outlined,
                onTap: () => context.push(MyRequestsScreen.routePath),
              ),
            ),
          );
          if (isProvider) {
            cards.add(
              SizedBox(
                width: 260,
                child: AppCard(
                  title: 'Assigned Tasks',
                  subtitle:
                      '${serviceState.assignments.length} verifications assigned',
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push('/provider/tasks'),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Welcome card with avatar
              _ProviderDashboardHelpers.buildWelcomeCard(
                  context, authState.user?.fullName ?? 'User'),
              const SizedBox(height: 24),
              // Stats cards
              _ProviderDashboardHelpers.buildStatsCards(
                  context, isProvider, serviceState, isManager),
              if (isProvider) ...[
                const SizedBox(height: 32),
                // Quick actions
                _ProviderDashboardHelpers.buildQuickActionsSection(context),
                const SizedBox(height: 32),
                // My venues section
                _ProviderDashboardHelpers.buildMyVenuesSection(
                    context, serviceState),
              ],
              if (isManager) ...[
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Assigned Properties',
                  actions: [
                    TextButton.icon(
                      onPressed: () => ref
                          .read(serviceControllerProvider.notifier)
                          .refreshDashboard(),
                      icon: const Icon(Icons.refresh_outlined, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (serviceState.managedServices.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No assigned properties yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Admin will assign properties to you for verification',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...serviceState.managedServices.map(
                        (service) => buildManagerServiceCard(context, service),
                      ),
              ],
              if (isNodalOfficer) ...[
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Assigned Properties',
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        ref.read(serviceControllerProvider.notifier).loadUserServices();
                      },
                      icon: const Icon(Icons.refresh_outlined, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (serviceState.myServices.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_city_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No assigned properties yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Managers will assign properties to you',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...serviceState.myServices.map(
                        (service) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                              child: const Icon(
                                Icons.location_city_outlined,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            title: Text(
                              service.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      service.location,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (service.address != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    service.address!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  '₹${service.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                            ),
                            onTap: () {
                              // TODO: Navigate to property details
                            },
                          ),
                        ),
                      ),
              ],
              if (!isProvider && !isManager && !isNodalOfficer) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Browse Services',
                  actions: [
                    TextButton(
                      onPressed: () =>
                          context.push(BookServiceScreen.routePath),
                      child: const Text('Book a service'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...serviceState.approvedServices.take(5).map(
                      (service) => ListTile(
                        leading: const Icon(Icons.house_outlined),
                        title: Text(service.title),
                        subtitle:
                            Text('${service.location} • ₹${service.price}'),
                      ),
                    ),
              ],
            ],
          );
      }
    }

    if (showAdminView) {
      return AdminDashboardContent(adminState: adminState, themeMode: themeMode, ref: ref);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(LoginScreen.routePath);
              }
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      floatingActionButton: showProviderActions
          ? FloatingActionButton.extended(
              onPressed: () => context.push(SubmitServiceScreen.routePath),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Submit Service'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(serviceControllerProvider.notifier).refreshDashboard();
          if (showAdminView) {
            await ref.read(adminControllerProvider.notifier).loadDashboard();
          }
        },
        child: buildNonAdminContent(),
      ),
    );
  }
}

class _ProviderDashboardHelpers {
  static Widget buildWelcomeCard(BuildContext context, String name) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF9C8CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your venues, track verification requests, and monitor bookings.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildStatsCards(BuildContext context, bool isProvider,
      ServiceState serviceState, bool isManager) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: isProvider ? 3 : (isManager ? 2 : 2),
          itemBuilder: (context, index) {
            if (isProvider) {
              switch (index) {
                case 0:
                  return ProviderDashboardCard(
                    title: 'My Venues',
                    count: serviceState.myServices.length,
                    icon: Icons.location_city_outlined,
                    subtitle: 'Total submissions',
                  );
                case 1:
                  return ProviderDashboardCard(
                    title: 'Published',
                    count: serviceState.approvedServices.length,
                    icon: Icons.check_circle_outlined,
                    subtitle: 'Live venues',
                  );
                case 2:
                  return ProviderDashboardCard(
                    title: 'Pending',
                    count: serviceState.myServices
                        .where((s) => s.status == ServiceStatus.pending)
                        .length,
                    icon: Icons.hourglass_empty_outlined,
                    subtitle: 'Under review',
                  );
                default:
                  return const SizedBox();
              }
            } else if (isManager) {
              return index == 0
                  ? ProviderDashboardCard(
                      title: 'Assigned Properties',
                      count: serviceState.managedServices.length,
                      icon: Icons.assignment_outlined,
                      subtitle: 'Properties assigned to you',
                    )
                  : ProviderDashboardCard(
                      title: 'Published',
                      count: serviceState.approvedServices.length,
                      icon: Icons.public_outlined,
                      subtitle: 'Live services',
                    );
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  static Widget buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ActionTile(
              icon: Icons.add_circle_outlined,
              label: 'Submit New Venue',
              onTap: () => context.push(SubmitServiceScreen.routePath),
              color: const Color(0xFF6A5AE0),
            ),
            ActionTile(
              icon: Icons.edit_outlined,
              label: 'View My Venues',
              onTap: () => context.push(MyRequestsScreen.routePath),
              color: Colors.blue,
            ),
            ActionTile(
              icon: Icons.track_changes_outlined,
              label: 'Track Requests',
              onTap: () => context.push(MyRequestsScreen.routePath),
              color: Colors.orange,
            ),
            ActionTile(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {},
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildMyVenuesSection(
      BuildContext context, ServiceState serviceState) {
    if (serviceState.myServices.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(Icons.location_off_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No venues submitted yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by submitting your first venue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push(SubmitServiceScreen.routePath),
                icon: const Icon(Icons.add_circle_outlined),
                label: const Text('Submit Your First Venue'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My Venues',
          actions: [
            TextButton(
              onPressed: () => context.push(MyRequestsScreen.routePath),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1000
                ? 3
                : constraints.maxWidth > 700
                    ? 2
                    : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: serviceState.myServices.take(6).length,
              itemBuilder: (context, index) {
                final service = serviceState.myServices[index];
                return ProviderVenueCard(
                  service: service,
                  onEdit: () {},
                  onView: () {},
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class AdminDashboardContent extends ConsumerStatefulWidget {
  const AdminDashboardContent({super.key, required this.adminState, required this.themeMode, required this.ref});

  final AdminState adminState;
  final ThemeMode themeMode;
  final WidgetRef ref;

  @override
  ConsumerState<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends ConsumerState<AdminDashboardContent> {
  String _selectedNavItem = 'Home';
  
  final _navItems = [
    {'title': 'Home', 'icon': Icons.home_outlined, 'route': 'home'},
    {'title': 'Users', 'icon': Icons.people_outlined, 'route': 'users'},
    {'title': 'Services', 'icon': Icons.store_outlined, 'route': 'services'},
    {'title': 'Managers', 'icon': Icons.badge_outlined, 'route': 'managers'},
    {'title': 'Nodal Officers', 'icon': Icons.verified_user_outlined, 'route': 'officers'},
    {'title': 'Reports', 'icon': Icons.analytics_outlined, 'route': 'reports'},
    {'title': 'Settings', 'icon': Icons.settings_outlined, 'route': 'settings'},
  ];

  @override
  Widget build(BuildContext context) {
    switch (widget.adminState.status) {
      case AdminStatus.loading:
        return Scaffold(
          body: const Center(child: AppLoader()),
        );
      case AdminStatus.error:
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.adminState.errorMessage ?? 'Failed to load admin data',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        );
      case AdminStatus.initial:
      case AdminStatus.success:
        break;
    }

    final dashboard = widget.adminState.dashboard;
    final managers = widget.adminState.users
        .where(
            (user) => user.roles.any((role) => role.type == RoleType.manager))
        .toList();
    final pendingServices = widget.adminState.services
        .where((service) => service.status == ServiceStatus.pending)
        .toList();

    // Green accent color inspired by hotel UI
    const primaryGreen = Color(0xFF4CAF50);
    const lightGreen = Color(0xFF81C784);
    const bgColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(context, primaryGreen),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildAppBar(context, widget.themeMode, widget.ref, primaryGreen),
                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await widget.ref.read(adminControllerProvider.notifier).loadDashboard();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildDashboardContent(
                        context,
                        dashboard,
                        managers,
                        pendingServices,
                        primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, Color primaryGreen) {
    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: _navItems.map((item) {
                final isSelected = _selectedNavItem == item['title'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedNavItem = item['title'] as String;
                    });
                    // Handle navigation
                    _handleNavigation(context, item['route'] as String);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: primaryGreen.withOpacity(0.3), width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 22,
                          color: isSelected ? primaryGreen : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? primaryGreen : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                await widget.ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(LoginScreen.routePath);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 22, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeMode themeMode, WidgetRef ref, Color primaryGreen) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          // User Profile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    dynamic dashboard,
    List<UserModel> managers,
    List<ServiceListingEntity> pendingServices,
    Color primaryGreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards Row (inspired by hotel UI)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Users',
                dashboard?.totalUsers.toString() ?? '--',
                Icons.people_alt_outlined,
                primaryGreen,
                () => context.push(AdminUsersScreen.routePath),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Services',
                dashboard?.totalServices.toString() ?? '--',
                Icons.store_mall_directory_outlined,
                primaryGreen,
                () => context.push(AdminServicesScreen.routePath),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Pending Verifications',
                dashboard?.verificationPending.toString() ?? '--',
                Icons.verified_outlined,
                Colors.orange,
                () => context.push('/admin/verifications'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Bookings',
                dashboard?.totalBookings.toString() ?? '--',
                Icons.book_online_outlined,
                Colors.blue,
                null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Service Managers Section
        _buildSectionHeader(
          context,
          'Service Managers',
          [
            TextButton.icon(
              onPressed: () => context.push(AdminAddManagerScreen.routePath),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Manager'),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
            TextButton.icon(
              onPressed: () => context.push(AdminUsersScreen.routePath),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: managers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No managers onboarded yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use "Add manager" to create one.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Table header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('Manager Name', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
                            Expanded(flex: 3, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
                            Expanded(flex: 2, child: Text('Roles', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
                            Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
                            const SizedBox(width: 80), // Actions column
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Table rows
                      ...managers.map((manager) => _buildManagerRow(context, manager)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          context,
          'Nodal Officers',
          [
            TextButton.icon(
              onPressed: () => context.push(AdminNodalOfficersScreen.routePath),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Manage Officers'),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                TextButton.icon(
                  onPressed: () => context.push(AdminRecommendationsScreen.routePath),
                  icon: const Icon(Icons.checklist, size: 18),
                  label: const Text('Recommendations'),
                ),
                if (widget.adminState.recommendations.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${widget.adminState.recommendations.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Manage Nodal Officers',
                'Add officers, assign them to areas',
                Icons.verified_user_outlined,
                Colors.blue,
                () => context.push(AdminNodalOfficersScreen.routePath),
                'Go to Officers',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Pending Recommendations',
                '${widget.adminState.recommendations.length} pending ${widget.adminState.recommendations.length == 1 ? 'recommendation' : 'recommendations'}',
                Icons.pending_actions,
                Colors.orange,
                () => context.push(AdminRecommendationsScreen.routePath),
                'View All',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          context,
          'Service Categories',
          [
            TextButton.icon(
              onPressed: () => context.push(AdminServiceCategoriesScreen.routePath),
              icon: const Icon(Icons.category, size: 18),
              label: const Text('Manage Categories'),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickActionCard(
          context,
          'Manage Navbar Services',
          'Control which service categories appear in the navbar dropdown',
          Icons.category_outlined,
          const Color(0xFF9C27B0),
          () => context.push(AdminServiceCategoriesScreen.routePath),
          'Manage',
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          context,
          'Form Field Configurations',
          [
            TextButton.icon(
              onPressed: () => context.push(AdminFormFieldsScreen.routePath),
              icon: const Icon(Icons.text_fields, size: 18),
              label: const Text('Manage Fields'),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickActionCard(
          context,
          'Manage Venue Form Fields',
          'Configure which fields users need to fill when adding a new venue',
          Icons.text_fields_outlined,
          const Color(0xFF2196F3),
          () => context.push(AdminFormFieldsScreen.routePath),
          'Manage',
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          context,
          'Verification Checkpoints',
          [
            TextButton.icon(
              onPressed: () => context.push(AdminVerificationCheckpointsScreen.routePath),
              icon: const Icon(Icons.checklist_rtl, size: 18),
              label: const Text('Manage Checkpoints'),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickActionCard(
          context,
          'Manage Verification Checkpoints',
          'Configure what details nodal officers need to verify and submit',
          Icons.checklist_rtl_outlined,
          const Color(0xFF9C27B0),
          () => context.push(AdminVerificationCheckpointsScreen.routePath),
          'Manage',
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          context,
          'Verification Activity',
          [
            TextButton.icon(
              onPressed: () => context.push(AdminReportsScreen.routePath),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Go to Reports'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        pendingServices.isEmpty
            ? Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No pending verifications',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: pendingServices.take(5).map(
                    (service) => _buildVerificationActivityCard(context, service),
                  ).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, List<Widget> actions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Row(
          children: actions,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    String buttonLabel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    switch (route) {
      case 'home':
        // Already on home
        break;
      case 'users':
        context.push(AdminUsersScreen.routePath);
        break;
      case 'services':
        context.push(AdminServicesScreen.routePath);
        break;
      case 'managers':
        context.push(AdminAddManagerScreen.routePath);
        break;
      case 'officers':
        context.push(AdminNodalOfficersScreen.routePath);
        break;
      case 'reports':
        context.push(AdminReportsScreen.routePath);
        break;
      case 'settings':
        // TODO: Navigate to settings
        break;
    }
  }

  Widget _buildVerificationActivityCard(BuildContext context, ServiceListingEntity service) {
    final statusColor = _getStatusColorForVerification(service.status);
    final statusLabel = _getStatusLabelForVerification(service.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/manager/assign', extra: service),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_city_outlined, color: const Color(0xFF4CAF50), size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          service.location,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        if (service.propertyType != null) ...[
                          Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(service.propertyType!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ],
                    ),
                    if (service.eventTypes != null && service.eventTypes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: service.eventTypes!.split(',').take(3).map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.1)),
                            ),
                            child: Text(
                              type.trim(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (service.assignedManager != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigned Manager',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    service.assignedManager!.fullName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  if (service.assignedManagerId == null)
                    FilledButton.icon(
                      onPressed: () => _showAssignManagerDialog(context, service),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Assign Manager'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    )
                  else ...[
                    if (service.assignedNodalOfficerId != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            VerificationProgressScreen.routePath,
                            extra: service,
                          );
                        },
                        icon: const Icon(Icons.track_changes_outlined, size: 18),
                        label: const Text('View Progress'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    if (service.assignedNodalOfficerId != null)
                      const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showServiceDetailsDialog(context, service),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildManagerRow(BuildContext context, UserModel manager) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                manager.fullName.isNotEmpty ? manager.fullName[0].toUpperCase() : 'M',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            flex: 2,
            child: Text(
              manager.fullName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          // Email
          Expanded(
            flex: 3,
            child: Text(
              manager.email,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          // Roles
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 6,
              children: manager.roles.map((role) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getRoleColor(role.name),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) async {
              if (value == 'edit') {
                _showEditManagerDialog(context, manager);
              } else if (value == 'remove') {
                _showDeleteManagerDialog(context, manager);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              )),
              const PopupMenuItem(value: 'remove', child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: Colors.red)),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditManagerDialog(BuildContext context, UserModel manager) {
    final fullNameController = TextEditingController(text: manager.fullName);
    final phoneController = TextEditingController(text: manager.phone ?? '');
    final passwordController = TextEditingController();
    final areaController = TextEditingController();
    final locationController = TextEditingController();
    final addressController = TextEditingController();
    final pincodeController = TextEditingController();
    final regionController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Manager'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password (leave empty to keep current)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(labelText: 'Area'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(labelText: 'Region'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await widget.ref
                  .read(adminControllerProvider.notifier)
                  .updateManager(
                    id: manager.id,
                    fullName: fullNameController.text.trim(),
                    password: passwordController.text.trim().isEmpty
                        ? null
                        : passwordController.text.trim(),
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    area: areaController.text.trim().isEmpty
                        ? null
                        : areaController.text.trim(),
                    location: locationController.text.trim().isEmpty
                        ? null
                        : locationController.text.trim(),
                    address: addressController.text.trim().isEmpty
                        ? null
                        : addressController.text.trim(),
                    pincode: pincodeController.text.trim().isEmpty
                        ? null
                        : pincodeController.text.trim(),
                    region: regionController.text.trim().isEmpty
                        ? null
                        : regionController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

              if (!context.mounted) return;
              Navigator.of(context).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manager updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = widget.ref
                        .read(adminControllerProvider)
                        .errorMessage ??
                    'Failed to update manager';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteManagerDialog(BuildContext context, UserModel manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Manager?'),
        content: Text(
          'Are you sure you want to delete "${manager.fullName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await widget.ref
                  .read(adminControllerProvider.notifier)
                  .deleteManager(manager.id);

              if (!context.mounted) return;
              Navigator.of(context).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manager deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = widget.ref
                        .read(adminControllerProvider)
                        .errorMessage ??
                    'Failed to delete manager';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const Color(0xFF4CAF50);
      case 'MANAGER':
        return const Color(0xFF2196F3);
      case 'PROVIDER':
        return const Color(0xFFFF9800);
      case 'USER':
        return const Color(0xFF9E9E9E);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColorForVerification(ServiceStatus status) {
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
        return const Color(0xFF4CAF50);
    }
  }

  String _getStatusLabelForVerification(ServiceStatus status) {
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

  void _showAssignManagerDialog(BuildContext context, ServiceListingEntity service) {
    showDialog(
      context: context,
      builder: (context) => _AssignManagerDialog(service: service),
    );
  }

  void _showServiceDetailsDialog(BuildContext context, ServiceListingEntity service) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDetailsDialog(service: service),
    );
  }
}

class _ServiceDetailsDialog extends ConsumerWidget {
  const _ServiceDetailsDialog({required this.service});

  final ServiceListingEntity service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Service Details'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Location', service.location),
            if (service.propertyType != null) _buildDetailRow('Type', service.propertyType!),
            if (service.capacity != null) _buildDetailRow('Capacity', '${service.capacity} people'),
            if (service.eventTypes != null && service.eventTypes!.isNotEmpty)
              _buildDetailRow('Event Types', service.eventTypes!),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (service.assignedManager != null) ...[
              const Text(
                'Assigned Manager',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        service.assignedManager!.fullName.isNotEmpty
                            ? service.assignedManager!.fullName[0].toUpperCase()
                            : 'M',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.assignedManager!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            service.assignedManager!.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Verification Progress',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'No providers assigned yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _AssignManagerDialog extends ConsumerStatefulWidget {
  const _AssignManagerDialog({required this.service});

  final ServiceListingEntity service;

  @override
  ConsumerState<_AssignManagerDialog> createState() => _AssignManagerDialogState();
}

class _AssignManagerDialogState extends ConsumerState<_AssignManagerDialog> {
  UserModel? _selectedManager;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final managers = adminState.users
        .where((user) => user.roles.any((role) => role.type == RoleType.manager))
        .toList();

    return AlertDialog(
      title: const Text('Assign Manager'),
      content: SizedBox(
        width: 400,
        child: managers.isEmpty
            ? const Text('No managers available. Please create one first.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Assign a manager to oversee verification of: ${widget.service.title}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: managers.length,
                    itemBuilder: (context, index) {
                      final manager = managers[index];
                      final isSelected = _selectedManager?.id == manager.id;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              manager.fullName.isNotEmpty
                                  ? manager.fullName[0].toUpperCase()
                                  : 'M',
                            ),
                          ),
                          title: Text(manager.fullName),
                          subtitle: Text(manager.email),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedManager = manager;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting || _selectedManager == null ? null : _assignManager,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }

  Future<void> _assignManager() async {
    if (_selectedManager == null) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(adminControllerProvider.notifier).assignManagerToService(
          serviceId: widget.service.id,
          managerId: _selectedManager!.id,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager assigned successfully')),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(adminControllerProvider).errorMessage ?? 'Failed to assign manager.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      setState(() => _isSubmitting = false);
    }
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: AppCard(
        title: title,
        subtitle: value,
        icon: icon,
        onTap: onTap,
      ),
    );
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
