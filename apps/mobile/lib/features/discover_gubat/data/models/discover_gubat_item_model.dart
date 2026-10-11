import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/discover_gubat_item.dart';

class DiscoverGubatItemModel {
  const DiscoverGubatItemModel({
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

  factory DiscoverGubatItemModel.fromJson(Map<String, dynamic> json) {
    return DiscoverGubatItemModel(
      id: JsonUtils.asInt(json['id']),
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String?,
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? '',
      featuredImageUrl: json['featuredImageUrl'] as String?,
      locationName: json['locationName'] as String?,
      locationAddress: json['locationAddress'] as String?,
      whereToBuy: json['whereToBuy'] as String?,
      priceRange: json['priceRange'] as String?,
      contactInfo: json['contactInfo'] as String?,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
    );
  }

  DiscoverGubatItem toEntity() => DiscoverGubatItem(
    id: id,
    type: type,
    category: category,
    title: title,
    slug: slug,
    summary: summary,
    body: body,
    status: status,
    featuredImageUrl: featuredImageUrl,
    locationName: locationName,
    locationAddress: locationAddress,
    whereToBuy: whereToBuy,
    priceRange: priceRange,
    contactInfo: contactInfo,
    publishedAt: publishedAt,
  );
}
