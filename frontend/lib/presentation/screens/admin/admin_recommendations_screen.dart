import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/nodal_officer_recommendation.dart';
import '../../controllers/admin_controller.dart';

class AdminRecommendationsScreen extends ConsumerStatefulWidget {
  const AdminRecommendationsScreen({super.key});

  static const routePath = '/admin/recommendations';

  @override
  ConsumerState<AdminRecommendationsScreen> createState() =>
      _AdminRecommendationsScreenState();
}

class _AdminRecommendationsScreenState
    extends ConsumerState<AdminRecommendationsScreen> {
  RecommendationStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  Future<void> _loadRecommendations() async {
    // Load all recommendations by default, or filtered by status
    await ref.read(adminControllerProvider.notifier).loadRecommendations(
          status: _filterStatus?.name.toUpperCase(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Recommendations'),
      ),
      body: Column(
        children: [
          // Status Filter
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Filter by status: '),
                  const SizedBox(width: 12),
                  ChoiceChips(
                    selected: _filterStatus,
                    options: const [
                      RecommendationStatus.pending,
                      RecommendationStatus.approved,
                      RecommendationStatus.rejected,
                    ],
                    onSelected: (status) {
                      setState(() {
                        _filterStatus = status == _filterStatus ? null : status;
                      });
                      _loadRecommendations();
                    },
                  ),
                  const Spacer(),
                  if (_filterStatus != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _filterStatus = null);
                        _loadRecommendations();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                ],
              ),
            ),
          ),
          // Recommendations List
          Expanded(
            child: switch (adminState.status) {
              AdminStatus.loading => const Center(child: CircularProgressIndicator()),
              AdminStatus.error => Center(
                  child: Text(adminState.errorMessage ?? 'Failed to load recommendations'),
                ),
              _ => adminState.recommendations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist_rtl_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No recommendations found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: adminState.recommendations.length,
                      itemBuilder: (context, index) {
                        final recommendation = adminState.recommendations[index];
                        return _buildRecommendationCard(context, recommendation);
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, NodalOfficerRecommendationEntity recommendation) {
    final officer = recommendation.officer;
    final manager = recommendation.manager;
    final isNewUser = recommendation.officerId == null && recommendation.newUserEmail != null;
    final displayName = isNewUser 
        ? (recommendation.newUserFullName ?? 'New User')
        : (officer?.fullName ?? 'Unknown Officer');
    final displayEmail = isNewUser 
        ? recommendation.newUserEmail 
        : officer?.email;

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
                  backgroundColor: isNewUser 
                      ? Colors.orange.withOpacity(0.1)
                      : const Color(0xFF2196F3).withOpacity(0.1),
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: isNewUser ? Colors.orange : const Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (isNewUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (displayEmail != null)
                        Text(
                          displayEmail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      Text(
                        'Recommended by ${manager?.fullName ?? 'Manager'}',
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
                    color: _getStatusColor(recommendation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recommendation.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(recommendation.status),
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
                    recommendation.area,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    recommendation.location,
                  ),
                ),
              ],
            ),
            if (recommendation.reason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reason for recommendation:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation.reason!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (recommendation.status == RecommendationStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, recommendation),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _approveRecommendation(recommendation),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ],
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

  Color _getStatusColor(RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.pending:
        return Colors.orange;
      case RecommendationStatus.approved:
        return Colors.green;
      case RecommendationStatus.rejected:
        return Colors.red;
    }
  }

  Future<void> _approveRecommendation(
      NodalOfficerRecommendationEntity recommendation) async {
    final success = await ref
        .read(adminControllerProvider.notifier)
        .approveRecommendation(recommendation.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Recommendation approved. Officer assigned to area.'
              : 'Failed to approve recommendation'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        _loadRecommendations();
      }
    }
  }

  void _showRejectDialog(
      BuildContext context, NodalOfficerRecommendationEntity recommendation) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Recommendation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this recommendation?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Rejection reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await ref
                  .read(adminControllerProvider.notifier)
                  .rejectRecommendation(
                    recommendation.id,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Recommendation rejected'
                        : 'Failed to reject recommendation'),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
                if (success) {
                  _loadRecommendations();
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class ChoiceChips extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final RecommendationStatus? selected;
  final List<RecommendationStatus> options;
  final ValueChanged<RecommendationStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((status) {
        final isSelected = selected == status;
        return ChoiceChip(
          label: Text(status.name.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) => onSelected(selected ? status : null),
        );
      }).toList(),
    );
  }
}

