import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import 'package:eventorganising/domain/entities/role.dart';
import '../../providers/app_providers.dart';
import '../user/browse_services_screen.dart';
import '../user/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routePath = '/auth/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    
    try {
      final notifier = ref.read(authControllerProvider.notifier);
      await notifier.login(_emailController.text.trim(), _passwordController.text.trim());
      
      if (!mounted) return;
      
      // Wait a bit for state to update and router to process
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!mounted) return;
      
      // Check if authenticated - if router didn't redirect, do it manually
      final authState = ref.read(authControllerProvider);
      if (kIsWeb) {
        print('[Login Screen] After login - Status: ${authState.status}, Authenticated: ${authState.isAuthenticated}, User: ${authState.user?.email ?? "null"}');
      }
      if (authState.isAuthenticated) {
        final List<RoleEntity> roles = authState.user?.roles ?? <RoleEntity>[];
        final bool hasElevatedRole =
            roles.any((role) => role.type != RoleType.user);
        final targetPath = hasElevatedRole
            ? DashboardScreen.routePath
            : BrowseServicesScreen.routePath;
        
        // Use a post-frame callback to ensure navigation happens safely
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              context.go(targetPath);
            } catch (e) {
              // Navigation failed, try again after delay
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  try {
                    context.go(targetPath);
                  } catch (_) {
                    // Navigation failed - user can manually navigate
                  }
                }
              });
            }
          }
        });
      }
    } catch (e) {
      // Error is already handled by auth controller
      if (kIsWeb) {
        print('[Login Screen] Exception caught: $e');
      }
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your services and bookings.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.go(ForgotPasswordScreen.routePath);
                          },
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      if (authState.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          authState.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _submit,
                          child: authState.status == AuthStatus.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () =>
                                context.go(RegisterScreen.routePath),
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
