import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../domain/entities/service_listing.dart';
import '../../providers/app_providers.dart';

class BrowseServicesScreen extends ConsumerWidget {
  const BrowseServicesScreen({super.key});

  static const routePath = '/browse';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(publicServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Verified Services'),
      ),
      body: servicesAsync.when(
        data: (services) => _ServicesList(services: services),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load services',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
                Text(error.toString()),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: AppLoader()),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.services});

  final List<ServiceListingEntity> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No verified services yet. Check back soon!'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            title: service.title,
            subtitle:
                '${service.location} • ₹${service.price.toStringAsFixed(2)}',
            icon: Icons.place_outlined,
            onTap: () {},
          ),
        );
      },
    );
  }
}
