import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/nodal_officer_assignment.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/admin_controller.dart';
import 'admin_recommendations_screen.dart';

class AdminNodalOfficersScreen extends ConsumerStatefulWidget {
  const AdminNodalOfficersScreen({super.key});

  static const routePath = '/admin/nodal-officers';

  @override
  ConsumerState<AdminNodalOfficersScreen> createState() =>
      _AdminNodalOfficersScreenState();
}

class _AdminNodalOfficersScreenState
    extends ConsumerState<AdminNodalOfficersScreen> {
  String? _filterLocation;
  String? _filterArea;
  String? _filterPincode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOfficers();
    });
  }

  Future<void> _loadOfficers() async {
    await ref.read(adminControllerProvider.notifier).loadNodalOfficers(
          location: _filterLocation,
          area: _filterArea,
          pincode: _filterPincode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nodal Officers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'Recommendations',
            onPressed: () => context.push(AdminRecommendationsScreen.routePath),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Officer',
            onPressed: () => _showAddOfficerDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOfficerDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Officer'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Column(
        children: [
          // Quick action card
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade100),
              ),
              child: InkWell(
                onTap: () => _showAddOfficerDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add_outlined,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Nodal Officer',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a new nodal officer and assign them to an area',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Filters
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
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
                    label: const Text('Filter'),
                  ),
                ],
              ),
            ),
          ),
          // Officers List
          Expanded(
            child: switch (adminState.status) {
              AdminStatus.loading => const Center(child: CircularProgressIndicator()),
              AdminStatus.error => Center(
                  child: Text(adminState.errorMessage ?? 'Failed to load officers'),
                ),
              _ => adminState.nodalOfficers.isEmpty
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
                              'No nodal officers found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new nodal officer to get started',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => _showAddOfficerDialog(context),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add First Officer'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: adminState.nodalOfficers.length,
                      itemBuilder: (context, index) {
                        final assignment = adminState.nodalOfficers[index];
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(assignment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(assignment.status),
                    ),
                  ),
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
            if (assignment.address != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.home, 'Address', assignment.address!),
            ],
            if (assignment.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        assignment.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
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

  Color _getStatusColor(NodalOfficerStatus status) {
    switch (status) {
      case NodalOfficerStatus.active:
        return Colors.green;
      case NodalOfficerStatus.inactive:
        return Colors.grey;
      case NodalOfficerStatus.suspended:
        return Colors.red;
    }
  }

  void _showAddOfficerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final areaController = TextEditingController();
    final locationController = TextEditingController();
    final addressController = TextEditingController();
    final pincodeController = TextEditingController();
    final regionController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Nodal Officer'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Email is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Full name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Password is required' : null,
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
                const SizedBox(height: 12),
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
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                    .read(adminControllerProvider.notifier)
                    .createNodalOfficer(
                      email: emailController.text,
                      fullName: fullNameController.text,
                      password: passwordController.text,
                      phone: phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
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
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Officer created successfully')),
                    );
                    _loadOfficers();
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

