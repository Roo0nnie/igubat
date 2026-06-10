import 'transparency_attachment.dart';
import 'transparency_type.dart';

/// A single Transparency & Good Governance disclosure (read-only on mobile).
/// Mirrors the backend `TransparencyItemDetailSchema`; list views use the same
/// model with [body]/[attachments] left empty.
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
  ///
  /// The backend validates the metadata shape per [type]. Mobile keeps it as a
  /// map so list/detail screens can read only the fields they render.
  T? metadataAs<T>() {
    return metadata is T ? metadata as T : null;
  }

  factory TransparencyItem.fromJson(Map<String, dynamic> json) {
    return TransparencyItem(
      id: (json['id'] as num).toInt(),
      type: TransparencyTypeX.fromApiValue(json['type'] as String),
      title: json['title'] as String,
      slug: json['slug'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String?,
      summary: json['summary'] as String?,
      body: json['body'] as String? ?? '',
      fiscalYear: (json['fiscalYear'] as num?)?.toInt(),
      effectiveDate: json['effectiveDate'] == null
          ? null
          : DateTime.tryParse(json['effectiveDate'].toString()),
      barangay: json['barangay'] as String?,
      status: json['status'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'].toString()),
      attachments: ((json['attachments'] as List?) ?? const [])
          .map(
            (item) => TransparencyAttachment.fromJson(
              (item as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.apiValue,
    'title': title,
    'slug': slug,
    'referenceNumber': referenceNumber,
    'summary': summary,
    'body': body,
    'fiscalYear': fiscalYear,
    'effectiveDate': effectiveDate?.toIso8601String(),
    'barangay': barangay,
    'status': status,
    'coverImageUrl': coverImageUrl,
    'metadata': metadata,
    'publishedAt': publishedAt?.toIso8601String(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
  };
}
