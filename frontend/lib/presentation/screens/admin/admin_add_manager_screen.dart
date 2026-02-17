import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/admin_controller.dart';

class AdminAddManagerScreen extends ConsumerStatefulWidget {
  const AdminAddManagerScreen({super.key});

  static const routePath = '/admin/managers/new';

  @override
  ConsumerState<AdminAddManagerScreen> createState() =>
      _AdminAddManagerScreenState();
}

class _AdminAddManagerScreenState extends ConsumerState<AdminAddManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _areaController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _regionController = TextEditingController();
  final _notesController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final success =
          await ref.read(adminControllerProvider.notifier).createManager(
                email: _emailController.text.trim(),
                fullName: _fullNameController.text.trim(),
                password: _passwordController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
                area: _areaController.text.trim(),
                location: _locationController.text.trim(),
                address: _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
                pincode: _pincodeController.text.trim().isEmpty
                    ? null
                    : _pincodeController.text.trim(),
                region: _regionController.text.trim().isEmpty
                    ? null
                    : _regionController.text.trim(),
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('System manager created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Pop back to dashboard - it will automatically refresh because loadDashboard was called
          context.pop();
        }
      } else {
        if (mounted) {
          final error = ref.read(adminControllerProvider).errorMessage ??
              'Failed to create manager';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add System Manager')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Onboard a new system manager',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter the manager name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter an email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Temporary password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Region Assignment',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assign this manager to a specific region/area to see nodal officers from that area',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _areaController,
                        decoration: const InputDecoration(
                          labelText: 'Area *',
                          hintText: 'e.g., Downtown, North Zone',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Area is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location *',
                          hintText: 'City/District',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address (optional)',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode (optional)',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _regionController,
                        decoration: const InputDecoration(
                          labelText: 'Region (optional)',
                          hintText: 'State/Province',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          prefixIcon: Icon(Icons.note_outlined),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () {
                                    if (context.canPop()) {
                                      context.pop();
                                    }
                                  },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Create manager'),
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
