import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/service_listing.dart';
import '../../controllers/service_controller.dart';
import '../../providers/app_providers.dart';

class ManagerAssignScreen extends ConsumerStatefulWidget {
  const ManagerAssignScreen({
    super.key,
    required this.service,
    this.nodalOfficerId,
  });

  static const routePath = '/manager/assign';

  final ServiceListingEntity service;
  final String? nodalOfficerId;

  @override
  ConsumerState<ManagerAssignScreen> createState() =>
      _ManagerAssignScreenState();
}

class _ManagerAssignScreenState extends ConsumerState<ManagerAssignScreen> {
  bool _isSubmitting = false;
  List<String> _selectedProviderIds = [];

  @override
  void initState() {
    super.initState();
    // Load providers when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviders();
    });
  }

  Future<void> _loadProviders() async {
    try {
      await ref.read(serviceUseCasesProvider).fetchProviders();
    } catch (e) {
      // Handle error silently or show message
    }
  }

  Future<void> _submit() async {
    if (_selectedProviderIds.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 3 providers for verification.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final success = await ref.read(serviceControllerProvider.notifier).assignAgents(
            serviceId: widget.service.id,
            agentIds: _selectedProviderIds,
            nodalOfficerId: widget.nodalOfficerId,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Providers assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign providers: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(serviceControllerProvider).providers;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Verification Providers'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Service details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF6A5AE0).withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A5AE0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_city_outlined,
                        color: Color(0xFF6A5AE0),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6A5AE0),
                                ),
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
                                widget.service.location,
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
                  ],
                ),
              ],
            ),
          ),
          
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select exactly 3 approved providers to verify this service.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Provider selection
          Expanded(
            child: providers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No approved providers available',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Approved providers will appear here.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      final isSelected = _selectedProviderIds.contains(provider.id);
                      
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF6A5AE0)
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedProviderIds.remove(provider.id);
                              } else {
                                if (_selectedProviderIds.length < 3) {
                                  _selectedProviderIds.add(provider.id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Maximum 3 providers can be selected'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF6A5AE0).withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    provider.user?.email != null
                                        ? Icons.person
                                        : Icons.business_center,
                                    color: isSelected
                                        ? const Color(0xFF6A5AE0)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.user?.fullName ?? 'Provider',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? const Color(0xFF6A5AE0)
                                                  : Colors.grey.shade800,
                                            ),
                                      ),
                                      if (provider.user?.email != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            provider.user!.email,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        if (_selectedProviderIds.length < 3) {
                                          _selectedProviderIds.add(provider.id);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Maximum 3 providers can be selected'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      } else {
                                        _selectedProviderIds.remove(provider.id);
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF6A5AE0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Selection counter and submit button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedProviderIds.length == 3
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedProviderIds.length == 3
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: _selectedProviderIds.length == 3
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedProviderIds.length}/3 providers selected',
                        style: TextStyle(
                          color: _selectedProviderIds.length == 3
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : _selectedProviderIds.length == 3
                                ? _submit
                                : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6A5AE0),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Assign Providers'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
