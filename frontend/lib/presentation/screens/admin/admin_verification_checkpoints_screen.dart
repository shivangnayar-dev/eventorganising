import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/verification_checkpoint_config.dart';
import '../../../data/models/verification_checkpoint_config_model.dart';
import '../../controllers/admin_controller.dart';

class AdminVerificationCheckpointsScreen extends ConsumerStatefulWidget {
  const AdminVerificationCheckpointsScreen({super.key});

  static const routePath = '/admin/verification-checkpoints';

  @override
  ConsumerState<AdminVerificationCheckpointsScreen> createState() =>
      _AdminVerificationCheckpointsScreenState();
}

class _AdminVerificationCheckpointsScreenState
    extends ConsumerState<AdminVerificationCheckpointsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckpoints();
    });
  }

  Future<void> _loadCheckpoints() async {
    await ref.read(adminControllerProvider.notifier).loadVerificationCheckpointConfigs();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Checkpoints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCheckpoints,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Checkpoint',
            onPressed: () => _showAddCheckpointDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCheckpointDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Checkpoint'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade100),
              ),
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
                      child: const Icon(Icons.checklist_rtl_outlined,
                          color: Color(0xFF2196F3)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Verification Checkpoints',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure what nodal officers need to verify and submit',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
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
          // Checkpoints List
          Expanded(
            child: switch (adminState.status) {
              AdminStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
              AdminStatus.error => Center(
                  child: Text(adminState.errorMessage ?? 'Failed to load checkpoints'),
                ),
              _ => adminState.verificationCheckpointConfigs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checklist_rtl_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No verification checkpoints configured',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new checkpoint to get started',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => _showAddCheckpointDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Checkpoint'),
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
                      itemCount: adminState.verificationCheckpointConfigs.length,
                      itemBuilder: (context, index) {
                        final checkpoint = adminState.verificationCheckpointConfigs[index];
                        return _buildCheckpointCard(context, checkpoint);
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointCard(BuildContext context, VerificationCheckpointConfigModel checkpoint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Icon(
          _getCheckpointTypeIcon(checkpoint.checkpointType),
          color: checkpoint.isEnabled
              ? (checkpoint.isRequired ? Colors.red : Colors.blue)
              : Colors.grey,
        ),
        title: Text(
          checkpoint.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: checkpoint.isEnabled ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${checkpoint.checkpointKey} • ${checkpoint.checkpointType.value}${checkpoint.category != null ? ' • ${checkpoint.category}' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checkpoint.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Switch(
              value: checkpoint.isEnabled,
              onChanged: (value) => _toggleCheckpointEnabled(checkpoint),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditCheckpointDialog(context, checkpoint),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _showDeleteDialog(context, checkpoint),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Checkpoint Key', checkpoint.checkpointKey),
                _buildDetailRow('Checkpoint Type', checkpoint.checkpointType.value),
                if (checkpoint.category != null)
                  _buildDetailRow('Category', checkpoint.category!),
                if (checkpoint.description != null)
                  _buildDetailRow('Description', checkpoint.description!),
                _buildDetailRow('Display Order', checkpoint.displayOrder.toString()),
                if (checkpoint.placeholder != null)
                  _buildDetailRow('Placeholder', checkpoint.placeholder!),
                if (checkpoint.hint != null) _buildDetailRow('Hint', checkpoint.hint!),
                if (checkpoint.options != null && checkpoint.options!.isNotEmpty)
                  _buildDetailRow('Options', checkpoint.options!.join(', ')),
                if (checkpoint.validation != null)
                  _buildDetailRow(
                      'Validation', checkpoint.validation!.toString()),
              ],
            ),
          ),
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

  IconData _getCheckpointTypeIcon(CheckpointType checkpointType) {
    switch (checkpointType) {
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

  Future<void> _showAddCheckpointDialog(BuildContext context) async {
    final checkpointKeyController = TextEditingController();
    final labelController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedCheckpointType = 'text';
    bool isRequired = true;
    bool isEnabled = true;
    int displayOrder = 0;
    final placeholderController = TextEditingController();
    final hintController = TextEditingController();
    String? selectedCategory;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Verification Checkpoint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: checkpointKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Checkpoint Key *',
                    hintText: 'e.g., venue_exists, details_accuracy',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label *',
                    hintText: 'e.g., Venue Exists at Location',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Detailed description of the checkpoint',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCheckpointType,
                  decoration: const InputDecoration(
                    labelText: 'Checkpoint Type *',
                  ),
                  items: CheckpointType.values
                      .map((type) => DropdownMenuItem(
                            value: type.value,
                            child: Text(type.value),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCheckpointType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Group this checkpoint',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'credibility', child: Text('Credibility')),
                    DropdownMenuItem(value: 'details', child: Text('Details')),
                    DropdownMenuItem(value: 'safety', child: Text('Safety')),
                    DropdownMenuItem(value: 'documentation', child: Text('Documentation')),
                    DropdownMenuItem(value: 'feedback', child: Text('Feedback')),
                  ],
                  onChanged: (value) => setState(() => selectedCategory = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                      text: displayOrder.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Display Order',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    displayOrder = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: placeholderController,
                  decoration: const InputDecoration(
                    labelText: 'Placeholder',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hintController,
                  decoration: const InputDecoration(
                    labelText: 'Hint',
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Required'),
                  value: isRequired,
                  onChanged: (value) => setState(() => isRequired = value ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Enabled'),
                  value: isEnabled,
                  onChanged: (value) => setState(() => isEnabled = value ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (checkpointKeyController.text.trim().isNotEmpty &&
                    labelController.text.trim().isNotEmpty &&
                    selectedCheckpointType != null) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true &&
        checkpointKeyController.text.trim().isNotEmpty &&
        labelController.text.trim().isNotEmpty) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .createVerificationCheckpointConfig(
            checkpointKey: checkpointKeyController.text.trim(),
            label: labelController.text.trim(),
            checkpointType: selectedCheckpointType!,
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            isRequired: isRequired,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            placeholder: placeholderController.text.trim().isEmpty
                ? null
                : placeholderController.text.trim(),
            hint: hintController.text.trim().isEmpty
                ? null
                : hintController.text.trim(),
            category: selectedCategory,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification checkpoint created')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to create verification checkpoint';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _showEditCheckpointDialog(
      BuildContext context, VerificationCheckpointConfigModel checkpoint) async {
    final labelController = TextEditingController(text: checkpoint.label);
    final descriptionController = TextEditingController(text: checkpoint.description ?? '');
    String? selectedCheckpointType = checkpoint.checkpointType.value;
    bool isRequired = checkpoint.isRequired;
    bool isEnabled = checkpoint.isEnabled;
    int displayOrder = checkpoint.displayOrder;
    final placeholderController =
        TextEditingController(text: checkpoint.placeholder ?? '');
    final hintController = TextEditingController(text: checkpoint.hint ?? '');
    String? selectedCategory = checkpoint.category;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Verification Checkpoint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkpoint Key: ${checkpoint.checkpointKey}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label *',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCheckpointType,
                  decoration: const InputDecoration(
                    labelText: 'Checkpoint Type *',
                  ),
                  items: CheckpointType.values
                      .map((type) => DropdownMenuItem(
                            value: type.value,
                            child: Text(type.value),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCheckpointType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'credibility', child: Text('Credibility')),
                    DropdownMenuItem(value: 'details', child: Text('Details')),
                    DropdownMenuItem(value: 'safety', child: Text('Safety')),
                    DropdownMenuItem(value: 'documentation', child: Text('Documentation')),
                    DropdownMenuItem(value: 'feedback', child: Text('Feedback')),
                  ],
                  onChanged: (value) => setState(() => selectedCategory = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                      text: displayOrder.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Display Order',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    displayOrder = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: placeholderController,
                  decoration: const InputDecoration(
                    labelText: 'Placeholder',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hintController,
                  decoration: const InputDecoration(
                    labelText: 'Hint',
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Required'),
                  value: isRequired,
                  onChanged: (value) => setState(() => isRequired = value ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Enabled'),
                  value: isEnabled,
                  onChanged: (value) => setState(() => isEnabled = value ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (labelController.text.trim().isNotEmpty &&
                    selectedCheckpointType != null) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true && labelController.text.trim().isNotEmpty) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .updateVerificationCheckpointConfig(
            checkpoint.id,
            label: labelController.text.trim(),
            checkpointType: selectedCheckpointType!,
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            isRequired: isRequired,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            placeholder: placeholderController.text.trim().isEmpty
                ? null
                : placeholderController.text.trim(),
            hint: hintController.text.trim().isEmpty
                ? null
                : hintController.text.trim(),
            category: selectedCategory,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification checkpoint updated')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to update verification checkpoint';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _toggleCheckpointEnabled(VerificationCheckpointConfigModel checkpoint) async {
    final success = await ref
        .read(adminControllerProvider.notifier)
        .updateVerificationCheckpointConfig(
          checkpoint.id,
          isEnabled: !checkpoint.isEnabled,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkpoint.isEnabled
              ? 'Checkpoint disabled'
              : 'Checkpoint enabled'),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, VerificationCheckpointConfigModel checkpoint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Verification Checkpoint'),
        content: Text(
            'Are you sure you want to delete "${checkpoint.label}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .deleteVerificationCheckpointConfig(checkpoint.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification checkpoint deleted')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to delete verification checkpoint';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }
}

