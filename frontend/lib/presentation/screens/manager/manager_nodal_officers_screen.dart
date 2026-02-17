import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/nodal_officer_assignment.dart';
import '../../../domain/entities/nodal_officer_recommendation.dart';
import '../../../domain/entities/manager_assignment.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/service_controller.dart';

class ManagerNodalOfficersScreen extends ConsumerStatefulWidget {
  const ManagerNodalOfficersScreen({super.key});

  static const routePath = '/manager/nodal-officers';

  @override
  ConsumerState<ManagerNodalOfficersScreen> createState() =>
      _ManagerNodalOfficersScreenState();
}

class _ManagerNodalOfficersScreenState
    extends ConsumerState<ManagerNodalOfficersScreen> {
  String? _filterLocation;
  String? _filterArea;
  String? _filterPincode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadManagerAssignment();
      _loadOfficers();
    });
  }

  Future<void> _loadManagerAssignment() async {
    await ref.read(serviceControllerProvider.notifier).loadManagerAssignment();
  }

  Future<void> _loadOfficers() async {
    await ref.read(serviceControllerProvider.notifier).loadNodalOfficers(
          location: _filterLocation,
          area: _filterArea,
          pincode: _filterPincode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceControllerProvider);
    final managerAssignment = serviceState.managerAssignment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nodal Officers in Your Area'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _loadManagerAssignment();
              _loadOfficers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Manager Assignment Info Card
          if (managerAssignment != null)
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade200, width: 2),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Assigned Region',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${managerAssignment.area}, ${managerAssignment.location}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade800,
                                  ),
                            ),
                            if (managerAssignment.pincode != null ||
                                managerAssignment.region != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (managerAssignment.pincode != null)
                                    'Pincode: ${managerAssignment.pincode}',
                                  if (managerAssignment.region != null)
                                    managerAssignment.region,
                                ].join(' • '),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue.shade700,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (serviceState.status != ServiceControllerStatus.loading)
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.orange.shade300),
                ),
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Region Not Assigned',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please contact admin to assign you to a region',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Filters
          Card(
            margin: EdgeInsets.fromLTRB(16, managerAssignment != null ? 0 : 16, 16, 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    managerAssignment != null
                        ? 'Filter officers within your region (optional)'
                        : 'Filter officers by area',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (managerAssignment != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Officers are automatically filtered by your assigned region',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() => _filterLocation = value.isEmpty ? null : value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Area',
                            prefixIcon: Icon(Icons.map),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() => _filterArea = value.isEmpty ? null : value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Pincode',
                            prefixIcon: Icon(Icons.pin),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() => _filterPincode = value.isEmpty ? null : value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _loadOfficers,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Officers List
          Expanded(
            child: switch (serviceState.status) {
              ServiceControllerStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
              ServiceControllerStatus.error => Center(
                  child: Text(serviceState.errorMessage ?? 'Failed to load officers'),
                ),
              _ => serviceState.nodalOfficers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No nodal officers found in your region',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if (managerAssignment != null)
                              Text(
                                'No officers are currently assigned to ${managerAssignment.area}, ${managerAssignment.location}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              )
                            else
                              Text(
                                'Please contact admin to assign you to a region',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: serviceState.nodalOfficers.length,
                      itemBuilder: (context, index) {
                        final assignment = serviceState.nodalOfficers[index];
                        return _buildOfficerCard(context, assignment);
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(
      BuildContext context, NodalOfficerAssignmentEntity assignment) {
    final officer = assignment.officer;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                  child: Text(
                    (officer?.fullName.isNotEmpty ?? false)
                        ? officer!.fullName[0].toUpperCase()
                        : 'N',
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        officer?.fullName ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        officer?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Recommend this officer',
                  onPressed: () => _showRecommendDialog(context, assignment),
                  color: const Color(0xFF2196F3),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.map,
                    'Area',
                    assignment.area,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    assignment.location,
                  ),
                ),
              ],
            ),
            if (assignment.pincode != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.pin, 'Pincode', assignment.pincode!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showRecommendDialog(
      BuildContext context, NodalOfficerAssignmentEntity assignment) {
    final formKey = GlobalKey<FormState>();
    final areaController = TextEditingController(text: assignment.area);
    final locationController = TextEditingController(text: assignment.location);
    final addressController = TextEditingController(text: assignment.address);
    final pincodeController = TextEditingController(text: assignment.pincode);
    final regionController = TextEditingController(text: assignment.region);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                (assignment.officer?.fullName.isNotEmpty ?? false)
                    ? assignment.officer!.fullName[0].toUpperCase()
                    : 'N',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Recommend Officer'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Officer: ${assignment.officer?.fullName ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: areaController,
                  decoration: const InputDecoration(
                    labelText: 'Area *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Area is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Location is required' : null,
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Reason is required' : null,
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
                final success = await ref
                    .read(serviceControllerProvider.notifier)
                    .recommendNodalOfficer(
                      officerId: assignment.officerId,
                      area: areaController.text,
                      location: locationController.text,
                      address: addressController.text.isEmpty
                          ? null
                          : addressController.text,
                      pincode: pincodeController.text.isEmpty
                          ? null
                          : pincodeController.text,
                      region: regionController.text.isEmpty
                          ? null
                          : regionController.text,
                      reason: reasonController.text,
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Recommendation submitted. Awaiting admin approval.'
                          : 'Failed to submit recommendation'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) {
                    _loadOfficers();
                  }
                }
              }
            },
            child: const Text('Submit Recommendation'),
          ),
        ],
      ),
    );
  }
}

