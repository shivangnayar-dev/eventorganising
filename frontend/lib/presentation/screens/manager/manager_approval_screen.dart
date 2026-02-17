import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/service_listing.dart';
import '../../controllers/service_controller.dart';

class ManagerApprovalScreen extends ConsumerStatefulWidget {
  const ManagerApprovalScreen({super.key, required this.service});

  static const routePath = '/manager/approval';

  final ServiceListingEntity service;

  @override
  ConsumerState<ManagerApprovalScreen> createState() =>
      _ManagerApprovalScreenState();
}

class _ManagerApprovalScreenState extends ConsumerState<ManagerApprovalScreen> {
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _decide(String decision) async {
    setState(() => _isProcessing = true);
    final success =
        await ref.read(serviceControllerProvider.notifier).verifyService(
              serviceId: widget.service.id,
              decision: decision,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service $decision successfully')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve or Reject Service')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(widget.service.description),
                const SizedBox(height: 12),
                Text('Price: ₹${widget.service.price.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                Text('Status: ${widget.service.status.name.toUpperCase()}'),
                const SizedBox(height: 24),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Manager notes (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.tonal(
                      onPressed:
                          _isProcessing ? null : () => _decide('REJECTED'),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed:
                          _isProcessing ? null : () => _decide('APPROVED'),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
