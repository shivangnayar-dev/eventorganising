import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_loader.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/service_controller.dart' hide ServiceStatus;

class BookServiceScreen extends ConsumerWidget {
  const BookServiceScreen({super.key});

  static const routePath = '/user/book-service';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceControllerProvider);
    final bookingState = ref.watch(bookingControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Service')),
      body: switch (serviceState.status) {
        ServiceControllerStatus.loading => const Center(child: AppLoader()),
        ServiceControllerStatus.error => Center(
            child: Text(serviceState.errorMessage ?? 'Failed to load services'),
          ),
        _ => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: serviceState.approvedServices.length,
            itemBuilder: (context, index) {
              final service = serviceState.approvedServices[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.home_work_outlined),
                  title: Text(service.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.description),
                      const SizedBox(height: 4),
                      Text('Location: ${service.location}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹${service.price.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _openBookingDialog(
                          context,
                          ref,
                          service.id,
                        ),
                        child: const Text('Book'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      },
      bottomNavigationBar: bookingState.status == BookingStatusState.success
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Booking confirmed for ${bookingState.lastBooking?.scheduledDate.toLocal().toString().split(' ').first ?? ''}',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _openBookingDialog(
    BuildContext context,
    WidgetRef ref,
    String serviceId,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule booking'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Preferred date (YYYY-MM-DD)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a date';
              }
              if (DateTime.tryParse(value) == null) {
                return 'Enter date in YYYY-MM-DD format';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final scheduledDate = DateTime.parse(controller.text.trim());
              final success = await ref
                  .read(bookingControllerProvider.notifier)
                  .createBooking(
                    serviceId: serviceId,
                    scheduledDate: scheduledDate,
                  );
              if (success && ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking created')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
