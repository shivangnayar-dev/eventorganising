import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/verification_controller.dart';
import '../../../domain/entities/verification_assignment.dart';

class ProviderVerificationDetailScreen extends ConsumerStatefulWidget {
  const ProviderVerificationDetailScreen({
    super.key,
    required this.assignment,
  });

  static const routePath = '/provider/verification-detail';

  final VerificationAssignmentEntity assignment;

  @override
  ConsumerState<ProviderVerificationDetailScreen> createState() =>
      _ProviderVerificationDetailScreenState();
}

class _ProviderVerificationDetailScreenState
    extends ConsumerState<ProviderVerificationDetailScreen> {
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleDecision(String decision) async {
    setState(() => _isProcessing = true);
    final success = await ref
        .read(verificationControllerProvider.notifier)
        .submitVerification(
          serviceId: widget.assignment.serviceId,
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
    }
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service ID: ${widget.assignment.serviceId}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Assigned by: ${widget.assignment.assignedById}'),
                const SizedBox(height: 8),
                Text(
                    'Current status: ${widget.assignment.status.name.toUpperCase()}'),
                const SizedBox(height: 24),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Additional info',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleDecision('INFO_REQUESTED'),
                      child: const Text('Request Info'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleDecision('REJECTED'),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleDecision('APPROVED'),
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
