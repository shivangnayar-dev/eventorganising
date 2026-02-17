import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/service_category.dart';
import '../../../data/models/service_category_model.dart';
import '../../controllers/admin_controller.dart';

class AdminServiceCategoriesScreen extends ConsumerStatefulWidget {
  const AdminServiceCategoriesScreen({super.key});

  static const routePath = '/admin/service-categories';

  @override
  ConsumerState<AdminServiceCategoriesScreen> createState() =>
      _AdminServiceCategoriesScreenState();
}

class _AdminServiceCategoriesScreenState
    extends ConsumerState<AdminServiceCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    await ref.read(adminControllerProvider.notifier).loadServiceCategories();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCategories,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
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
                      child: const Icon(Icons.category_outlined,
                          color: Color(0xFF2196F3)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Service Categories',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Control which service categories appear in the navbar dropdown',
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
          // Categories List
          Expanded(
            child: switch (adminState.status) {
              AdminStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
              AdminStatus.error => Center(
                  child: Text(adminState.errorMessage ?? 'Failed to load categories'),
                ),
              _ => adminState.serviceCategories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No service categories found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new category to get started',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => _showAddCategoryDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Category'),
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
                      itemCount: adminState.serviceCategories.length,
                      itemBuilder: (context, index) {
                        final category = adminState.serviceCategories[index];
                        return _buildCategoryCard(context, category);
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ServiceCategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: category.showInNavbar
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          if (category.showInNavbar)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility,
                                      size: 14, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'In Navbar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!category.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Inactive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (category.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          category.description!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditCategoryDialog(context, category);
                        break;
                      case 'toggle_navbar':
                        _toggleNavbarVisibility(category);
                        break;
                      case 'toggle_active':
                        _toggleActiveStatus(category);
                        break;
                      case 'delete':
                        _deleteCategory(context, category);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_navbar',
                      child: Row(
                        children: [
                          Icon(
                            category.showInNavbar
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(category.showInNavbar
                              ? 'Hide from Navbar'
                              : 'Show in Navbar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_active',
                      child: Row(
                        children: [
                          Icon(
                            category.isActive
                                ? Icons.block
                                : Icons.check_circle,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(category.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.sort, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Order: ${category.displayOrder}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final displayOrderController = TextEditingController(text: '0');
    bool showInNavbar = false;
    bool isActive = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Service Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Wedding Planning',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: displayOrderController,
                  decoration: const InputDecoration(
                    labelText: 'Display Order',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Show in Navbar'),
                  subtitle: const Text('Display in navbar dropdown'),
                  value: showInNavbar,
                  onChanged: (value) {
                    setDialogState(() => showInNavbar = value ?? false);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Category is active'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() => isActive = value ?? true);
                  },
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
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .createServiceCategory(
            name: nameController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            showInNavbar: showInNavbar,
            displayOrder: int.tryParse(displayOrderController.text) ?? 0,
            isActive: isActive,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service category created')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to create category';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _showEditCategoryDialog(
      BuildContext context, ServiceCategoryModel category) async {
    final nameController = TextEditingController(text: category.name);
    final descriptionController =
        TextEditingController(text: category.description ?? '');
    final displayOrderController =
        TextEditingController(text: category.displayOrder.toString());
    bool showInNavbar = category.showInNavbar;
    bool isActive = category.isActive;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Service Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: displayOrderController,
                  decoration: const InputDecoration(
                    labelText: 'Display Order',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Show in Navbar'),
                  subtitle: const Text('Display in navbar dropdown'),
                  value: showInNavbar,
                  onChanged: (value) {
                    setDialogState(() => showInNavbar = value ?? false);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Category is active'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() => isActive = value ?? true);
                  },
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
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .updateServiceCategory(
            category.id,
            name: nameController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            showInNavbar: showInNavbar,
            displayOrder: int.tryParse(displayOrderController.text) ?? 0,
            isActive: isActive,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service category updated')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to update category';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _toggleNavbarVisibility(ServiceCategoryModel category) async {
    final success = await ref
        .read(adminControllerProvider.notifier)
        .updateServiceCategory(
          category.id,
          showInNavbar: !category.showInNavbar,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(category.showInNavbar
              ? 'Category hidden from navbar'
              : 'Category shown in navbar'),
        ),
      );
    }
  }

  Future<void> _toggleActiveStatus(ServiceCategoryModel category) async {
    final success = await ref
        .read(adminControllerProvider.notifier)
        .updateServiceCategory(
          category.id,
          isActive: !category.isActive,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(category.isActive
              ? 'Category deactivated'
              : 'Category activated'),
        ),
      );
    }
  }

  Future<void> _deleteCategory(
      BuildContext context, ServiceCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
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

    if (confirmed == true) {
      final success = await ref
          .read(adminControllerProvider.notifier)
          .deleteServiceCategory(category.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service category deleted')),
        );
      } else {
        final error = ref.read(adminControllerProvider).errorMessage ??
            'Failed to delete category';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }
}

