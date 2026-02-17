class EventVenue {
  const EventVenue({
    required this.name,
    required this.location,
    required this.capacity,
    required this.priceLabel,
    this.minPrice,
    this.image,
  });

  final String name;
  final String location;
  final int capacity;
  final int? minPrice;
  final String priceLabel;
  final String? image;

  String get capacityLabel => 'Capacity: $capacity guests';
}
