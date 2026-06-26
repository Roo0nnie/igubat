import '../../data/models/transparency_type.dart';
import 'transparency_attachment.dart';

/// A single Transparency & Good Governance disclosure (read-only on mobile).
///
/// Domain entity — pure Dart, no serialization. List views use the same entity
/// with [body]/[attachments] left empty. [metadata] stays a raw map so each
/// screen reads only the type-specific fields it renders.
class TransparencyItem {
  const TransparencyItem({
    required this.id,
    required this.type,
    required this.title,
    required this.slug,
    this.referenceNumber,
    this.summary,
    this.body = '',
    this.fiscalYear,
    this.effectiveDate,
    this.barangay,
    this.status,
    this.coverImageUrl,
    this.metadata = const {},
    this.publishedAt,
    this.attachments = const [],
  });

  final int id;
  final TransparencyType type;
  final String title;
  final String slug;
  final String? referenceNumber;
  final String? summary;
  final String body;
  final int? fiscalYear;
  final DateTime? effectiveDate;
  final String? barangay;
  final String? status;
  final String? coverImageUrl;
  final Map<String, dynamic> metadata;
  final DateTime? publishedAt;
  final List<TransparencyAttachment> attachments;

  /// Returns the raw metadata map when callers need type-specific fields.
  T? metadataAs<T>() {
    return metadata is T ? metadata as T : null;
  }
}
