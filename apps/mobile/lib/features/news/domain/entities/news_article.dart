import 'content_status.dart';

/// A single Community News / Announcement article (read-only on mobile).
///
/// Domain entity — pure Dart, no serialization. List views use the same entity
/// with [body] left empty; the detail screen fills it in via the by-slug fetch.
class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.slug,
    this.excerpt,
    this.body = '',
    this.imageUrl,
    this.isFeatured = false,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? slug;
  final String? excerpt;
  final String body;
  final String category;
  final ContentStatus status;
  final String? imageUrl;
  final bool isFeatured;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
