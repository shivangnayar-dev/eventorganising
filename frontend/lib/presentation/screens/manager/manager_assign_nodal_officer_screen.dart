import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../domain/entities/service_listing.dart';
import '../../../domain/entities/nodal_officer_assignment.dart';
import '../../../domain/entities/nodal_officer_recommendation.dart';
import '../../../data/models/nodal_officer_assignment_model.dart';
import '../../controllers/service_controller.dart';
import '../../providers/app_providers.dart';

class ManagerAssignNodalOfficerScreen extends ConsumerStatefulWidget {
  const ManagerAssignNodalOfficerScreen({super.key, required this.service});

  static const routePath = '/manager/assign-nodal-officer';

  final ServiceListingEntity service;

  @override
  ConsumerState<ManagerAssignNodalOfficerScreen> createState() =>
      _ManagerAssignNodalOfficerScreenState();
}

class _ManagerAssignNodalOfficerScreenState
    extends ConsumerState<ManagerAssignNodalOfficerScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<NodalOfficerAssignmentEntity> _availableOfficers = [];
  String? _selectedOfficerId;
  bool _needsRecommendation = false;
  String? _serviceLocation;
  String? _servicePincode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableOfficers();
    });
  }

  Future<void> _loadAvailableOfficers() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(serviceUseCasesProvider)
          .fetchAvailableNodalOfficersForService(widget.service.id);

      setState(() {
        _availableOfficers = (result['availableOfficers'] as List?)
                ?.map((o) => NodalOfficerAssignmentModel.fromJson(o as Map<String, dynamic>))
                .toList() ??
            [];
        _needsRecommendation = result['needsRecommendation'] as bool? ?? false;
        _serviceLocation = result['serviceLocation'] as String?;
        _servicePincode = result['servicePincode'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load nodal officers: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignNodalOfficer() async {
    if (_needsRecommendation && _selectedOfficerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nodal officer or recommend one first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // If no officer selected but officers exist, auto-select first one
    if (!_needsRecommendation && _selectedOfficerId == null && _availableOfficers.isNotEmpty) {
      _selectedOfficerId = _availableOfficers[0].officerId;
    }

    if (_selectedOfficerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nodal officer.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(serviceControllerProvider.notifier)
          .assignNodalOfficer(
            serviceId: widget.service.id,
            nodalOfficerId: _selectedOfficerId!,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nodal officer assigned successfully! They will receive login credentials via email/SMS.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pop(true); // Return success
      } else if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to assign nodal officer. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
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

  Future<void> _showRecommendDialog() async {
    // Show dialog to recommend a nodal officer for this service
    if (!mounted) return;

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Load all nodal officers to choose from (without filters to get all)
      await ref.read(serviceControllerProvider.notifier).loadNodalOfficers(
            location: null,
            area: null,
            pincode: null,
          );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      final serviceState = ref.read(serviceControllerProvider);
      final allOfficers = serviceState.nodalOfficers;

      // Always show dialog, even if no officers (will show message inside)
      if (mounted) {
        _showRecommendOfficerDialog(allOfficers);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        // Show error but still show dialog with empty list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading nodal officers: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        // Still show dialog even on error
        _showRecommendOfficerDialog([]);
      }
    }
  }

  void _showRecommendOfficerDialog(List<NodalOfficerAssignmentEntity> officers) {
    if (!mounted) return;
    
    final formKey = GlobalKey<FormState>();
    bool isNewUser = true; // Default to new user registration
    NodalOfficerAssignmentEntity? selectedOfficer;
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final areaController = TextEditingController(text: widget.service.location);
    final locationController = TextEditingController(text: widget.service.location);
    final addressController = TextEditingController();
    final pincodeController = TextEditingController(text: widget.service.pincode);
    final regionController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Recommend Nodal Officer'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle between existing officer and new user
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Register New Officer')),
                      ButtonSegment(value: false, label: Text('Select Existing')),
                    ],
                    selected: {isNewUser},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setDialogState(() {
                        isNewUser = newSelection.first;
                        selectedOfficer = null;
                        emailController.clear();
                        fullNameController.clear();
                        phoneController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isNewUser) ...[
                    const Text(
                      'Register a new nodal officer:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value?.isEmpty ?? true ? 'Email is required' : (value!.contains('@') ? null : 'Invalid email'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ] else ...[
                    if (officers.isEmpty) ...[
                      const Text(
                        'No nodal officers are currently assigned to any area.',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Switch to "Register New Officer" to recommend a new user.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      const Text(
                        'Select an existing nodal officer:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<NodalOfficerAssignmentEntity>(
                        decoration: const InputDecoration(
                          labelText: 'Nodal Officer *',
                          border: OutlineInputBorder(),
                        ),
                        items: officers.map((officer) {
                          return DropdownMenuItem(
                            value: officer,
                            child: Text('${officer.officer?.fullName ?? 'Unknown'} (${officer.officer?.email ?? ''})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedOfficer = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select an officer' : null,
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: areaController,
                    decoration: const InputDecoration(
                      labelText: 'Area *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Area is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: regionController,
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for recommendation *',
                      helperText: 'Why should this officer be assigned to this area?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty ?? true ? 'Reason is required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  // Validate based on mode
                  if (!isNewUser && selectedOfficer == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a nodal officer'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    return;
                  }

                  if (isNewUser && (emailController.text.isEmpty || fullNameController.text.isEmpty)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    return;
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  setState(() => _isSubmitting = true);

                  try {
                    final success = await ref
                        .read(serviceControllerProvider.notifier)
                        .recommendNodalOfficer(
                          officerId: isNewUser ? null : selectedOfficer?.officerId,
                          newUserEmail: isNewUser ? emailController.text : null,
                          newUserFullName: isNewUser ? fullNameController.text : null,
                          newUserPhone: isNewUser ? (phoneController.text.isEmpty ? null : phoneController.text) : null,
                          area: areaController.text,
                          location: locationController.text,
                          address: addressController.text.isEmpty ? null : addressController.text,
                          pincode: pincodeController.text.isEmpty ? null : pincodeController.text,
                          region: regionController.text.isEmpty ? null : regionController.text,
                          reason: reasonController.text,
                        );

                    setState(() => _isSubmitting = false);

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isNewUser 
                            ? 'New nodal officer registration submitted! Admin will review and approve it.'
                            : 'Recommendation submitted successfully! Admin will review it.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Reload available officers
                      _loadAvailableOfficers();
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ref.read(serviceControllerProvider).errorMessage ?? 'Failed to submit recommendation'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => _isSubmitting = false);
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
              },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit Recommendation'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Nodal Officer'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

                // Available officers or recommendation message
                Expanded(
                  child: _needsRecommendation
                      ? _buildRecommendationView()
                      : _buildOfficersList(),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
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
                          onPressed: _isSubmitting ||
                                  (_needsRecommendation && _selectedOfficerId == null) ||
                                  (!_needsRecommendation && _selectedOfficerId == null && _availableOfficers.isEmpty)
                              ? null
                              : _assignNodalOfficer,
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
                              : const Text('Assign Nodal Officer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecommendationView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Nodal Officers Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No nodal officers are assigned to ${widget.service.location}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showRecommendDialog,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Recommend Nodal Officer'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A5AE0),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin will review and approve your recommendation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficersList() {
    if (_availableOfficers.isEmpty) {
      return _buildRecommendationView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Nodal Officers',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a nodal officer for ${widget.service.location}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _showRecommendDialog,
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Recommend Officer'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _availableOfficers.length,
            itemBuilder: (context, index) {
              final assignment = _availableOfficers[index];
              final officer = assignment.officer;
              final isSelected = _selectedOfficerId == assignment.officerId;

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
                      _selectedOfficerId = assignment.officerId;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xFF6A5AE0).withOpacity(0.1),
                          child: Text(
                            (officer?.fullName.isNotEmpty ?? false)
                                ? officer!.fullName[0].toUpperCase()
                                : 'N',
                            style: const TextStyle(
                              color: Color(0xFF6A5AE0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                officer?.fullName ?? 'Unknown',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                officer?.email ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${assignment.area}, ${assignment.location}',
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
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6A5AE0),
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

