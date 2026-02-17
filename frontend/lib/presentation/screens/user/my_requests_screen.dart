import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/service_controller.dart';
import '../../widgets/provider_venue_card.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  static const routePath = '/user/my-requests';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () =>
                ref.read(serviceControllerProvider.notifier).loadUserServices(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(serviceControllerProvider.notifier).loadUserServices(),
        child: serviceState.myServices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No venues submitted yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start by submitting your first venue',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1000
                            ? 3
                            : constraints.maxWidth > 700
                                ? 2
                                : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: serviceState.myServices.length,
                          itemBuilder: (context, index) {
                            final service = serviceState.myServices[index];
                            return ProviderVenueCard(
                              service: service,
                              onEdit: () {},
                              onView: () {},
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
