import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/admin_controller.dart';
import '../../../domain/entities/service_listing.dart';
import '../user/submit_service_screen.dart';
import 'admin_verifications_screen.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  static const routePath = '/admin/services';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(SubmitServiceScreen.routePath),
            icon: const Icon(Icons.add),
            label: const Text('Add property'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.push(AdminVerificationsScreen.routePath),
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Publish flow'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: switch (adminState.status) {
        AdminStatus.loading => const Center(child: CircularProgressIndicator()),
        AdminStatus.error => Center(
            child: Text(adminState.errorMessage ?? 'Failed to load services'),
          ),
        _ => RefreshIndicator(
            onRefresh: () async =>
                ref.read(adminControllerProvider.notifier).loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Only published properties appear on the website. '
                          'Use Publish flow to verify and publish.',
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(AdminVerificationsScreen.routePath),
                        child: const Text('Go to Publish flow'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Owner')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final service in adminState.services)
                  DataRow(
                    cells: [
                      DataCell(Text(service.title)),
                      DataCell(
                        service.owner != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    service.owner!.fullName.isNotEmpty
                                        ? service.owner!.fullName
                                        : service.owner!.email,
                                  ),
                                  if (service.owner!.email.isNotEmpty &&
                                      service.owner!.fullName.isNotEmpty)
                                    Text(
                                      service.owner!.email,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              )
                            : Text(service.ownerId),
                      ),
                      DataCell(Text(service.status.name.toUpperCase())),
                      DataCell(Text(service.location)),
                      DataCell(Text('₹${service.price.toStringAsFixed(2)}')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _showServiceDetails(
                                      context,
                                      service,
                                    ),
                                    child: const Text('View'),
                                  ),
                                  TextButton(
                                    onPressed: () => _togglePublishService(
                                      context,
                                      ref,
                                      service,
                                    ),
                                    child: Text(
                                      service.status == ServiceStatus.published
                                          ? 'Unpublish'
                                          : 'Publish',
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => _showEditServiceDialog(
                                      context,
                                      ref,
                                      service,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDeleteService(
                                      context,
                                      ref,
                                      service,
                                    ),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  ),
              ],
            ),
          ),
      },
    );
  }
}

Future<void> _togglePublishService(
  BuildContext context,
  WidgetRef ref,
  ServiceListingEntity service,
) async {
  final isPublished = service.status == ServiceStatus.published;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isPublished ? 'Unpublish property' : 'Publish property'),
      content: Text(
        isPublished
            ? 'Remove "${service.title}" from the website?'
            : 'Publish "${service.title}" to show on the website?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(isPublished ? 'Unpublish' : 'Publish'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final updated = await ref.read(adminControllerProvider.notifier).updateService(
        id: service.id,
        status: isPublished ? 'VERIFIED' : 'PUBLISHED',
      );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated
            ? isPublished
                ? 'Service unpublished'
                : 'Service published'
            : 'Update failed'),
      ),
    );
  }
}

void _showServiceDetails(
  BuildContext context,
  ServiceListingEntity service,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(service.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description),
            const SizedBox(height: 12),
            Text('Location: ${service.location}'),
            if (service.address != null) Text('Address: ${service.address}'),
            if (service.pincode != null) Text('Pincode: ${service.pincode}'),
            if (service.propertyType != null)
              Text('Property type: ${service.propertyType}'),
            if (service.capacity != null)
              Text('Capacity: ${service.capacity}'),
            if (service.eventTypes != null)
              Text('Event types: ${service.eventTypes}'),
            if (service.amenities != null)
              Text('Amenities: ${service.amenities}'),
            const SizedBox(height: 8),
            Text('Price: ₹${service.price.toStringAsFixed(2)}'),
            Text('Status: ${service.status.name.toUpperCase()}'),
            if (service.photos != null && service.photos!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Photos'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: service.photos!
                    .map(
                      (url) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 120,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            width: 120,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showEditServiceDialog(
  BuildContext context,
  WidgetRef ref,
  ServiceListingEntity service,
) async {
  final titleController = TextEditingController(text: service.title);
  final descriptionController = TextEditingController(text: service.description);
  final locationController = TextEditingController(text: service.location);
  final addressController = TextEditingController(text: service.address ?? '');
  final pincodeController = TextEditingController(text: service.pincode ?? '');
  final eventTypesController = TextEditingController(text: service.eventTypes ?? '');
  final propertyTypeController = TextEditingController(text: service.propertyType ?? '');
  final capacityController =
      TextEditingController(text: service.capacity?.toString() ?? '');
  final amenitiesController = TextEditingController(text: service.amenities ?? '');
  final priceController =
      TextEditingController(text: service.price.toStringAsFixed(2));
  final photosController = TextEditingController(
    text: service.photos?.join(', ') ?? '',
  );
  var selectedStatus = service.status;

  String? cleanValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Edit ${service.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: pincodeController,
              decoration: const InputDecoration(labelText: 'Pincode'),
            ),
            TextField(
              controller: eventTypesController,
              decoration: const InputDecoration(labelText: 'Event types'),
            ),
            TextField(
              controller: propertyTypeController,
              decoration: const InputDecoration(labelText: 'Property type'),
            ),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: amenitiesController,
              decoration: const InputDecoration(labelText: 'Amenities'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: photosController,
              decoration: const InputDecoration(
                labelText: 'Photo URLs (comma separated)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceStatus>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ServiceStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedStatus = value;
                }
              },
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
            final capacity = int.tryParse(capacityController.text.trim());
            final price = double.tryParse(priceController.text.trim());
            final photosRaw = photosController.text.trim();
            final photos = photosRaw.isEmpty
                ? null
                : photosRaw
                    .split(',')
                    .map((value) => value.trim())
                    .where((value) => value.isNotEmpty)
                    .toList();
            final updated = await ref
                .read(adminControllerProvider.notifier)
                .updateService(
                  id: service.id,
                  title: cleanValue(titleController.text),
                  description: cleanValue(descriptionController.text),
                  location: cleanValue(locationController.text),
                  address: cleanValue(addressController.text),
                  pincode: cleanValue(pincodeController.text),
                  eventTypes: cleanValue(eventTypesController.text),
                  propertyType: cleanValue(propertyTypeController.text),
                  capacity: capacity,
                  amenities: cleanValue(amenitiesController.text),
                  photos: photos,
                  price: price,
                  status: selectedStatus.name.toUpperCase(),
                );
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    updated ? 'Service updated' : 'Update failed',
                  ),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _confirmDeleteService(
  BuildContext context,
  WidgetRef ref,
  ServiceListingEntity service,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete property'),
      content: Text('Delete "${service.title}"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final deleted =
      await ref.read(adminControllerProvider.notifier).deleteService(service.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? 'Service deleted' : 'Delete failed'),
      ),
    );
  }
}
