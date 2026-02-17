import 'package:flutter/material.dart';

import '../models/event_venue.dart';

enum _SortOption { none, capacity, price }

class EventVenuesDialog extends StatefulWidget {
  const EventVenuesDialog(
      {super.key, required this.eventType, required this.venues});

  final String eventType;
  final List<EventVenue> venues;

  @override
  State<EventVenuesDialog> createState() => _EventVenuesDialogState();
}

class _EventVenuesDialogState extends State<EventVenuesDialog> {
  final TextEditingController _searchController = TextEditingController();
  _SortOption _sortOption = _SortOption.none;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventVenue> _filteredVenues() {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = widget.venues.where((venue) {
      if (query.isEmpty) return true;
      return venue.name.toLowerCase().contains(query) ||
          venue.location.toLowerCase().contains(query);
    }).toList();

    switch (_sortOption) {
      case _SortOption.capacity:
        filtered.sort((a, b) => a.capacity.compareTo(b.capacity));
        break;
      case _SortOption.price:
        filtered.sort((a, b) => (a.minPrice ?? 0).compareTo(b.minPrice ?? 0));
        break;
      case _SortOption.none:
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxDialogWidth = media.size.width * 0.9;
    final maxDialogHeight = media.size.height * 0.85;
    final venues = _filteredVenues();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth.clamp(320.0, 980.0),
          maxHeight: maxDialogHeight.clamp(320.0, 760.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF5E9), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.eventType,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.venues.length} curated venues',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search venue or location',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<_SortOption>(
                        value: _sortOption,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(16),
                        items: const [
                          DropdownMenuItem(
                              value: _SortOption.none,
                              child: Text('Sort: Default')),
                          DropdownMenuItem(
                              value: _SortOption.capacity,
                              child: Text('Capacity')),
                          DropdownMenuItem(
                              value: _SortOption.price, child: Text('Price')),
                        ],
                        onChanged: (option) {
                          if (option != null) {
                            setState(() => _sortOption = option);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 900
                            ? 3
                            : constraints.maxWidth >= 600
                                ? 2
                                : 1;
                        final aspectRatio = constraints.maxWidth >= 900
                            ? 0.78
                            : constraints.maxWidth >= 600
                                ? 0.72
                                : 0.65;
                        return GridView.builder(
                          itemCount: venues.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final venue = venues[index];
                            return _VenueCard(venue: venue);
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue});

  final EventVenue venue;

  static const Color _gold = Color(0xFFC6A056);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFFFAF3),
        border: Border.all(color: const Color(0xFFF2E3D3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBD6), Color(0xFFFEF5EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: venue.image != null
                  ? Image.asset(
                      venue.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.weekend, color: _gold, size: 48),
                    )
                  : const Icon(Icons.weekend, color: _gold, size: 48),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            venue.name,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            venue.location,
            style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(venue.capacityLabel,
              style: textTheme.bodySmall?.copyWith(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            venue.priceLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: _gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _gold,
              side: const BorderSide(color: _gold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: () {},
            child: const Text('View Details'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: () {},
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}
