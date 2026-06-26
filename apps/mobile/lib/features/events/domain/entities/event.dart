import '../../../news/domain/entities/content_status.dart';

/// A single municipal Event (read-only on mobile).
///
/// Domain entity — pure Dart, no serialization. List views use the same entity
/// with [description] possibly truncated; the detail screen fills it via the
/// by-slug fetch. [ContentStatus] is shared with the news feature.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.status,
    this.category,
    this.location,
    this.imageUrl,
    this.startsAt,
    this.endsAt,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String slug;
  final String description;
  final String? category;
  final String? location;
  final String? imageUrl;
  final ContentStatus status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? publishedAt;
}
