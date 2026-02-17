import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/role.dart';
import '../domain/entities/service_listing.dart';
import '../domain/entities/verification_assignment.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/screens/admin/admin_add_manager_screen.dart';
import '../presentation/screens/admin/admin_reports_screen.dart';
import '../presentation/screens/admin/admin_services_screen.dart';
import '../presentation/screens/admin/admin_users_screen.dart';
import '../presentation/screens/admin/admin_verifications_screen.dart';
import '../presentation/screens/admin/admin_nodal_officers_screen.dart';
import '../presentation/screens/admin/admin_recommendations_screen.dart';
import '../presentation/screens/admin/admin_service_categories_screen.dart';
import '../presentation/screens/admin/admin_form_fields_screen.dart';
import '../presentation/screens/admin/admin_verification_checkpoints_screen.dart';
import '../presentation/screens/admin/verification_progress_screen.dart';
import '../presentation/screens/manager/manager_nodal_officers_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/otp_verification_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/landing_screen.dart';
import '../presentation/screens/user/browse_services_screen.dart';
import '../presentation/screens/manager/manager_approval_screen.dart';
import '../presentation/screens/manager/manager_assign_screen.dart';
import '../presentation/screens/manager/manager_assign_nodal_officer_screen.dart';
import '../presentation/screens/manager/manager_incoming_screen.dart';
import '../presentation/screens/provider/provider_onboarding_screen.dart';
import '../presentation/screens/provider/provider_tasks_screen.dart';
import '../presentation/screens/provider/provider_verification_detail_screen.dart';
import '../presentation/screens/user/book_service_screen.dart';
import '../presentation/screens/user/dashboard_screen.dart';
import '../presentation/screens/user/my_requests_screen.dart';
import '../presentation/screens/user/submit_service_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authControllerProvider.notifier);
  final authState = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: LandingScreen.routePath,
    refreshListenable: GoRouterRefreshStream(authNotifier.authStateStream),
    routes: [
      GoRoute(
        path: LandingScreen.routePath,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: BrowseServicesScreen.routePath,
        builder: (context, state) => const BrowseServicesScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        builder: (context, state) => RegisterScreen(
          initialAccountType: state.extra is AccountType
              ? state.extra as AccountType
              : AccountType.customer,
        ),
      ),
      GoRoute(
        path: ForgotPasswordScreen.routePath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: OtpVerificationScreen.routePath,
        builder: (context, state) {
          final email = state.extra as String?;
          return OtpVerificationScreen(email: email ?? '');
        },
      ),
      GoRoute(
        path: DashboardScreen.routePath,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: SubmitServiceScreen.routePath,
        builder: (context, state) => const SubmitServiceScreen(),
      ),
      GoRoute(
        path: MyRequestsScreen.routePath,
        builder: (context, state) => const MyRequestsScreen(),
      ),
      GoRoute(
        path: BookServiceScreen.routePath,
        builder: (context, state) => const BookServiceScreen(),
      ),
      GoRoute(
        path: ProviderOnboardingScreen.routePath,
        builder: (context, state) => const ProviderOnboardingScreen(),
      ),
      GoRoute(
        path: ProviderTasksScreen.routePath,
        builder: (context, state) => const ProviderTasksScreen(),
      ),
      GoRoute(
        path: ProviderVerificationDetailScreen.routePath,
        builder: (context, state) {
          final assignment = state.extra;
          if (assignment is! VerificationAssignmentEntity) {
            return const Scaffold(
              body: Center(child: Text('Assignment not found')),
            );
          }
          return ProviderVerificationDetailScreen(assignment: assignment);
        },
      ),
      GoRoute(
        path: ManagerIncomingScreen.routePath,
        builder: (context, state) => const ManagerIncomingScreen(),
      ),
      GoRoute(
        path: ManagerAssignScreen.routePath,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            final service = extra['service'];
            final nodalOfficerId = extra['nodalOfficerId'] as String?;
            if (service is! ServiceListingEntity) {
              return const Scaffold(
                body: Center(child: Text('Service not found')),
              );
            }
            return ManagerAssignScreen(
              service: service,
              nodalOfficerId: nodalOfficerId,
            );
          } else if (extra is ServiceListingEntity) {
            return ManagerAssignScreen(service: extra);
          }
          return const Scaffold(
            body: Center(child: Text('Service not found')),
          );
        },
      ),
      GoRoute(
        path: ManagerAssignNodalOfficerScreen.routePath,
        builder: (context, state) {
          final service = state.extra;
          if (service is! ServiceListingEntity) {
            return const Scaffold(
              body: Center(child: Text('Service not found')),
            );
          }
          return ManagerAssignNodalOfficerScreen(service: service);
        },
      ),
      GoRoute(
        path: ManagerApprovalScreen.routePath,
        builder: (context, state) {
          final service = state.extra;
          if (service is! ServiceListingEntity) {
            return const Scaffold(
              body: Center(child: Text('Service not found')),
            );
          }
          return ManagerApprovalScreen(service: service);
        },
      ),
      GoRoute(
        path: AdminServicesScreen.routePath,
        builder: (context, state) => const AdminServicesScreen(),
      ),
      GoRoute(
        path: AdminUsersScreen.routePath,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AdminReportsScreen.routePath,
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AdminAddManagerScreen.routePath,
        builder: (context, state) => const AdminAddManagerScreen(),
      ),
      GoRoute(
        path: AdminVerificationsScreen.routePath,
        builder: (context, state) => const AdminVerificationsScreen(),
      ),
      GoRoute(
        path: AdminNodalOfficersScreen.routePath,
        builder: (context, state) => const AdminNodalOfficersScreen(),
      ),
      GoRoute(
        path: AdminRecommendationsScreen.routePath,
        builder: (context, state) => const AdminRecommendationsScreen(),
      ),
      GoRoute(
        path: AdminServiceCategoriesScreen.routePath,
        builder: (context, state) => const AdminServiceCategoriesScreen(),
      ),
      GoRoute(
        path: AdminFormFieldsScreen.routePath,
        builder: (context, state) => const AdminFormFieldsScreen(),
      ),
      GoRoute(
        path: AdminVerificationCheckpointsScreen.routePath,
        builder: (context, state) => const AdminVerificationCheckpointsScreen(),
      ),
      GoRoute(
        path: VerificationProgressScreen.routePath,
        builder: (context, state) {
          final service = state.extra;
          if (service is! ServiceListingEntity) {
            return const Scaffold(
              body: Center(child: Text('Service not found')),
            );
          }
          return VerificationProgressScreen(service: service);
        },
      ),
      GoRoute(
        path: ManagerNodalOfficersScreen.routePath,
        builder: (context, state) => const ManagerNodalOfficersScreen(),
      ),
    ],
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path.startsWith('/auth');
      final isPublicRoute = path == LandingScreen.routePath ||
          path == BrowseServicesScreen.routePath;

      // Don't redirect while restoring session - wait for it to complete
      // This prevents premature redirects during token validation
      if (authState.isRestoring) {
        return null; // Stay on current page while restoring
      }

      final roles = authState.user?.roles ?? const <RoleEntity>[];
      final hasElevatedRole = roles.any((role) =>
          role.type == RoleType.admin ||
          role.type == RoleType.manager ||
          role.type == RoleType.provider);
      final defaultRoute = hasElevatedRole
          ? DashboardScreen.routePath
          : BrowseServicesScreen.routePath;

      // Only redirect to login if not authenticated AND not restoring AND not on public/auth routes
      if (!authState.isAuthenticated && !isAuthRoute && !isPublicRoute) {
        return LoginScreen.routePath;
      }

      if (authState.isAuthenticated && isAuthRoute) {
        return defaultRoute;
      }

      if (authState.isAuthenticated &&
          !hasElevatedRole &&
          path == DashboardScreen.routePath) {
        return BrowseServicesScreen.routePath;
      }

      if (authState.isAuthenticated &&
          hasElevatedRole &&
          path == LandingScreen.routePath) {
        return DashboardScreen.routePath;
      }

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
