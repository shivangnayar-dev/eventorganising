import 'package:flutter/material.dart';

import '../../domain/entities/service_listing.dart';

const _primaryColor = Color(0xFF6A5AE0);

class ProviderVenueCard extends StatelessWidget {
  const ProviderVenueCard({
    super.key,
    required this.service,
    this.onEdit,
    this.onView,
  });

  final ServiceListingEntity service;
  final VoidCallback? onEdit;
  final VoidCallback? onView;

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.published:
        return Colors.green;
      case ServiceStatus.verified:
        return Colors.blue;
      case ServiceStatus.assigned:
        return Colors.orange;
      case ServiceStatus.rejected:
        return Colors.red;
      case ServiceStatus.pending:
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.published:
        return 'Live';
      case ServiceStatus.verified:
        return 'Verified';
      case ServiceStatus.assigned:
        return 'Under Review';
      case ServiceStatus.rejected:
        return 'Rejected';
      case ServiceStatus.pending:
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(service.status);
    final statusLabel = _getStatusLabel(service.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: service.photos != null && service.photos!.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      service.photos!.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor, width: 1.5),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        service.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                  ],
                ),
                if (service.capacity != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Capacity: ${service.capacity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onView,
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Details'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No image',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
