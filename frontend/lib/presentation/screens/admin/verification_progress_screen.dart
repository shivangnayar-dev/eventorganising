import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/service_listing.dart';
import '../../../domain/entities/verification_assignment.dart';
import '../../../domain/entities/verification_checkpoint_config.dart';
import '../../providers/app_providers.dart';

class VerificationProgressScreen extends ConsumerStatefulWidget {
  const VerificationProgressScreen({
    super.key,
    required this.service,
  });

  static const routePath = '/verification-progress';

  final ServiceListingEntity service;

  @override
  ConsumerState<VerificationProgressScreen> createState() =>
      _VerificationProgressScreenState();
}

class _VerificationProgressScreenState
    extends ConsumerState<VerificationProgressScreen> {
  List<VerificationAssignmentEntity> _assignments = [];
  List<VerificationCheckpointConfigEntity> _checkpoints = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final useCases = ref.read(serviceUseCasesProvider);
      
      // Load verification assignments for this service
      final assignments = await useCases.fetchServiceVerificationAssignments(widget.service.id);
      
      // Load checkpoint configurations
      final checkpoints = await useCases.fetchVerificationCheckpointConfigs();
      
      setState(() {
        _assignments = assignments;
        _checkpoints = checkpoints.where((c) => c.isEnabled).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading verification progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _assignments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No verification assignments found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No nodal officers have been assigned to verify this service yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Service Info Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.blue.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.location_city_outlined,
                                          color: Colors.blue),
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
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.service.location,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
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
                        ),
                        const SizedBox(height: 24),
                        // Assignments List
                        ..._assignments.map((assignment) =>
                            _buildAssignmentCard(context, assignment)),
                      ],
                    ),
    );
  }

  Widget _buildAssignmentCard(
      BuildContext context, VerificationAssignmentEntity assignment) {
    final statusColor = _getStatusColor(assignment.status);
    final statusLabel = _getStatusLabel(assignment.status);
    
    // Calculate progress
    final totalCheckpoints = _checkpoints.length;
    final completedCheckpoints = assignment.checkpointResponses?.length ?? 0;
    final progress = totalCheckpoints > 0
        ? (completedCheckpoints / totalCheckpoints)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(assignment.status),
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          'Nodal Officer Assignment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Status: $statusLabel',
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (totalCheckpoints > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${completedCheckpoints}/$totalCheckpoints',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assignment Details
                _buildDetailRow('Assignment ID', assignment.id),
                _buildDetailRow('Provider ID', assignment.providerId),
                _buildDetailRow('Assigned By', assignment.assignedById),
                if (assignment.createdAt != null)
                  _buildDetailRow(
                      'Created',
                      '${assignment.createdAt!.day}/${assignment.createdAt!.month}/${assignment.createdAt!.year}'),
                if (assignment.submittedAt != null)
                  _buildDetailRow(
                      'Submitted',
                      '${assignment.submittedAt!.day}/${assignment.submittedAt!.month}/${assignment.submittedAt!.year}'),
                if (assignment.notes != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(assignment.notes!),
                ],
                
                // Overall Rating
                if (assignment.overallRating != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Overall Rating: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < assignment.overallRating!.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${assignment.overallRating!.toStringAsFixed(1)}/5',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Credibility Score
                if (assignment.credibilityScore != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Credibility Score: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getScoreColor(assignment.credibilityScore!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(assignment.credibilityScore! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(assignment.credibilityScore!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Checkpoint Responses
                if (assignment.checkpointResponses != null &&
                    assignment.checkpointResponses!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Checkpoint Responses',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...assignment.checkpointResponses!.entries.map((entry) {
                    final checkpointKey = entry.key;
                    final response = entry.value;
                    final checkpoint = _checkpoints.firstWhere(
                      (c) => c.checkpointKey == checkpointKey,
                      orElse: () => _checkpoints.first,
                    );
                    
                    return _buildCheckpointResponseCard(
                        context, checkpoint, response);
                  }),
                ],
                
                // Images
                if (assignment.images != null &&
                    assignment.images!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Images',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: assignment.images!.map((imageUrl) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                // Videos
                if (assignment.videos != null &&
                    assignment.videos!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Videos',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...assignment.videos!.map((videoUrl) {
                    return ListTile(
                      leading: const Icon(Icons.video_library),
                      title: Text(
                        videoUrl.split('/').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          // Open video URL
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointResponseCard(
    BuildContext context,
    VerificationCheckpointConfigEntity checkpoint,
    dynamic response,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCheckpointTypeIcon(checkpoint.checkpointType),
                size: 18,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  checkpoint.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (checkpoint.checkpointType == CheckpointType.rating) ...[
            Row(
              children: [
                ...List.generate(5, (index) {
                  final rating = response is num ? response.toInt() : 0;
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  response.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ] else if (response is List) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (response as List)
                  .map((item) => Chip(
                        label: Text(item.toString()),
                        labelStyle: const TextStyle(fontSize: 12),
                        padding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ] else ...[
            Text(
              response.toString(),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.infoRequested:
        return Colors.blue;
    }
  }

  String _getStatusLabel(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.infoRequested:
        return 'Info Requested';
    }
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.pending_outlined;
      case VerificationStatus.approved:
        return Icons.check_circle_outline;
      case VerificationStatus.rejected:
        return Icons.cancel_outlined;
      case VerificationStatus.infoRequested:
        return Icons.info_outline;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getCheckpointTypeIcon(CheckpointType type) {
    switch (type) {
      case CheckpointType.boolean:
        return Icons.toggle_on;
      case CheckpointType.text:
        return Icons.text_fields;
      case CheckpointType.textarea:
        return Icons.notes;
      case CheckpointType.rating:
        return Icons.star;
      case CheckpointType.image:
        return Icons.image;
      case CheckpointType.video:
        return Icons.video_library;
      case CheckpointType.multiImage:
        return Icons.photo_library;
      case CheckpointType.dropdown:
        return Icons.arrow_drop_down;
      case CheckpointType.number:
        return Icons.numbers;
    }
  }
}

