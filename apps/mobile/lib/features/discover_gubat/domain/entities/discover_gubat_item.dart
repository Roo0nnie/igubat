class DiscoverGubatItem {
  const DiscoverGubatItem({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.slug,
    required this.status,
    this.summary,
    this.body = '',
    this.featuredImageUrl,
    this.locationName,
    this.locationAddress,
    this.whereToBuy,
    this.priceRange,
    this.contactInfo,
    this.publishedAt,
  });

  final int id;
  final String type;
  final String category;
  final String title;
  final String slug;
  final String? summary;
  final String body;
  final String status;
  final String? featuredImageUrl;
  final String? locationName;
  final String? locationAddress;
  final String? whereToBuy;
  final String? priceRange;
  final String? contactInfo;
  final DateTime? publishedAt;
}
