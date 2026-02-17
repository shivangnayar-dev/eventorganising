import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/form_field_config.dart';
import '../../../data/models/form_field_config_model.dart';
import '../../controllers/admin_controller.dart';

class AdminFormFieldsScreen extends ConsumerStatefulWidget {
  const AdminFormFieldsScreen({super.key});

  static const routePath = '/admin/form-fields';

  @override
  ConsumerState<AdminFormFieldsScreen> createState() =>
      _AdminFormFieldsScreenState();
}

class _AdminFormFieldsScreenState
    extends ConsumerState<AdminFormFieldsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFormFields();
    });
  }

  Future<void> _loadFormFields() async {
    await ref.read(adminControllerProvider.notifier).loadFormFieldConfigs();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Field Configurations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadFormFields,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Field',
            onPressed: () => _showAddFieldDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFieldDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Field'),
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
                      child: const Icon(Icons.text_fields_outlined,
                          color: Color(0xFF2196F3)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Form Fields',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure which fields appear in the venue submission form',
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
          // Form Fields List
          Expanded(
            child: switch (adminState.status) {
              AdminStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
              AdminStatus.error => Center(
                  child: Text(adminState.errorMessage ?? 'Failed to load form fields'),
                ),
              _ => adminState.formFieldConfigs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.text_fields_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No form fields configured',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new field to get started',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => _showAddFieldDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Field'),
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
                      itemCount: adminState.formFieldConfigs.length,
                      itemBuilder: (context, index) {
                        final field = adminState.formFieldConfigs[index];
                        return _buildFieldCard(context, field);
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(BuildContext context, FormFieldConfigModel field) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Icon(
          _getFieldTypeIcon(field.fieldType),
          color: field.isEnabled
              ? (field.isRequired ? Colors.red : Colors.blue)
              : Colors.grey,
        ),
        title: Text(
          field.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: field.isEnabled ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${field.fieldKey} • ${field.fieldType.name}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (field.isRequired)
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
              value: field.isEnabled,
              onChanged: (value) => _toggleFieldEnabled(field),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditFieldDialog(context, field),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _showDeleteDialog(context, field),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Field Key', field.fieldKey),
                _buildDetailRow('Field Type', field.fieldType.name),
                _buildDetailRow('Step', field.step ?? 'Not set'),
                _buildDetailRow('Display Order', field.displayOrder.toString()),
                if (field.placeholder != null)
                  _buildDetailRow('Placeholder', field.placeholder!),
                if (field.hint != null) _buildDetailRow('Hint', field.hint!),
                if (field.options != null && field.options!.isNotEmpty)
                  _buildDetailRow('Options', field.options!.join(', ')),
                if (field.validation != null)
                  _buildDetailRow(
                      'Validation', field.validation!.toString()),
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
            width: 100,
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

  IconData _getFieldTypeIcon(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.textarea:
        return Icons.notes;
      case FieldType.number:
        return Icons.numbers;
      case FieldType.dropdown:
        return Icons.arrow_drop_down;
      case FieldType.multiselect:
        return Icons.checklist;
      case FieldType.url:
        return Icons.link;
      case FieldType.pincode:
        return Icons.pin;
    }
  }

  Future<void> _showAddFieldDialog(BuildContext context) async {
    final fieldKeyController = TextEditingController();
    final labelController = TextEditingController();
    String? selectedFieldType = 'text';
    bool isRequired = false;
    bool isEnabled = true;
    int displayOrder = 0;
    final placeholderController = TextEditingController();
    final hintController = TextEditingController();
    String? selectedStep;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Form Field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: fieldKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Field Key *',
                    hintText: 'e.g., title, location',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label *',
                    hintText: 'e.g., Property/Venue Name',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFieldType,
                  decoration: const InputDecoration(
                    labelText: 'Field Type *',
                  ),
                  items: FieldType.values
                      .map((type) => DropdownMenuItem(
                            value: type.name,
                            child: Text(type.name),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedFieldType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStep,
                  decoration: const InputDecoration(
                    labelText: 'Step',
                    hintText: 'Which step this field belongs to',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'basic_info', child: Text('Basic Info')),
                    DropdownMenuItem(value: 'location', child: Text('Location')),
                    DropdownMenuItem(value: 'amenities', child: Text('Amenities')),
                  ],
                  onChanged: (value) => setState(() => selectedStep = value),
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
                  onChanged: (value) => setState(() => isRequired = value ?? false),
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
                if (fieldKeyController.text.trim().isNotEmpty &&
                    labelController.text.trim().isNotEmpty &&
                    selectedFieldType != null) {
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
        fieldKeyController.text.trim().isNotEmpty &&
        labelController.text.trim().isNotEmpty) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .createFormFieldConfig(
            fieldKey: fieldKeyController.text.trim(),
            label: labelController.text.trim(),
            fieldType: selectedFieldType!,
            isRequired: isRequired,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            placeholder: placeholderController.text.trim().isEmpty
                ? null
                : placeholderController.text.trim(),
            hint: hintController.text.trim().isEmpty
                ? null
                : hintController.text.trim(),
            step: selectedStep,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form field created')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to create form field';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _showEditFieldDialog(
      BuildContext context, FormFieldConfigModel field) async {
    final labelController = TextEditingController(text: field.label);
    String? selectedFieldType = field.fieldType.name;
    bool isRequired = field.isRequired;
    bool isEnabled = field.isEnabled;
    int displayOrder = field.displayOrder;
    final placeholderController =
        TextEditingController(text: field.placeholder ?? '');
    final hintController = TextEditingController(text: field.hint ?? '');
    String? selectedStep = field.step;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Form Field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Field Key: ${field.fieldKey}',
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
                DropdownButtonFormField<String>(
                  value: selectedFieldType,
                  decoration: const InputDecoration(
                    labelText: 'Field Type *',
                  ),
                  items: FieldType.values
                      .map((type) => DropdownMenuItem(
                            value: type.name,
                            child: Text(type.name),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedFieldType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStep,
                  decoration: const InputDecoration(
                    labelText: 'Step',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'basic_info', child: Text('Basic Info')),
                    DropdownMenuItem(value: 'location', child: Text('Location')),
                    DropdownMenuItem(value: 'amenities', child: Text('Amenities')),
                  ],
                  onChanged: (value) => setState(() => selectedStep = value),
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
                  onChanged: (value) => setState(() => isRequired = value ?? false),
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
                    selectedFieldType != null) {
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
          .updateFormFieldConfig(
            field.id,
            label: labelController.text.trim(),
            fieldType: selectedFieldType!,
            isRequired: isRequired,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            placeholder: placeholderController.text.trim().isEmpty
                ? null
                : placeholderController.text.trim(),
            hint: hintController.text.trim().isEmpty
                ? null
                : hintController.text.trim(),
            step: selectedStep,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form field updated')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to update form field';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _toggleFieldEnabled(FormFieldConfigModel field) async {
    final success = await ref
        .read(adminControllerProvider.notifier)
        .updateFormFieldConfig(
          field.id,
          isEnabled: !field.isEnabled,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(field.isEnabled
              ? 'Field disabled'
              : 'Field enabled'),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, FormFieldConfigModel field) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Form Field'),
        content: Text(
            'Are you sure you want to delete "${field.label}"? This action cannot be undone.'),
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
          .deleteFormFieldConfig(field.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form field deleted')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to delete form field';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }
}

