import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/service_controller.dart';
import '../../providers/app_providers.dart';

class ProviderOnboardingScreen extends ConsumerStatefulWidget {
  const ProviderOnboardingScreen({super.key});

  static const routePath = '/provider/onboard';

  @override
  ConsumerState<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState
    extends ConsumerState<ProviderOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kycController = TextEditingController();
  final _pricingController = TextEditingController();
  final _photosController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _kycController.dispose();
    _pricingController.dispose();
    _photosController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final photoUrls = _photosController.text
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    try {
      await ref.read(serviceUseCasesProvider).onboardProvider(
            kycDocumentUrl: _kycController.text.trim(),
            pricingDetails: _pricingController.text.trim(),
            photoUrls: photoUrls,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding submitted for review')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit provider KYC',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kycController,
                        decoration: const InputDecoration(
                          labelText: 'KYC document URL',
                          prefixIcon: Icon(Icons.file_present_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Provide a document URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pricingController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Pricing details',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Provide pricing information';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _photosController,
                        decoration: const InputDecoration(
                          labelText: 'Photo URLs (comma separated)',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Submit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
