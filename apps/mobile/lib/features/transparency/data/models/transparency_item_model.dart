import '../../domain/entities/transparency_item.dart';
import 'transparency_attachment_model.dart';
import 'transparency_type.dart';

/// DTO for a transparency disclosure. Mirrors the backend
/// `TransparencyItemDetailSchema` and maps to/from the [TransparencyItem]
/// entity.
class TransparencyItemModel {
  const TransparencyItemModel({
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
  final List<TransparencyAttachmentModel> attachments;

  factory TransparencyItemModel.fromJson(Map<String, dynamic> json) {
    return TransparencyItemModel(
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
            (item) => TransparencyAttachmentModel.fromJson(
              (item as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  factory TransparencyItemModel.fromEntity(TransparencyItem e) =>
      TransparencyItemModel(
        id: e.id,
        type: e.type,
        title: e.title,
        slug: e.slug,
        referenceNumber: e.referenceNumber,
        summary: e.summary,
        body: e.body,
        fiscalYear: e.fiscalYear,
        effectiveDate: e.effectiveDate,
        barangay: e.barangay,
        status: e.status,
        coverImageUrl: e.coverImageUrl,
        metadata: e.metadata,
        publishedAt: e.publishedAt,
        attachments: e.attachments
            .map(TransparencyAttachmentModel.fromEntity)
            .toList(),
      );

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

  TransparencyItem toEntity() => TransparencyItem(
    id: id,
    type: type,
    title: title,
    slug: slug,
    referenceNumber: referenceNumber,
    summary: summary,
    body: body,
    fiscalYear: fiscalYear,
    effectiveDate: effectiveDate,
    barangay: barangay,
    status: status,
    coverImageUrl: coverImageUrl,
    metadata: metadata,
    publishedAt: publishedAt,
    attachments: attachments.map((a) => a.toEntity()).toList(),
  );
}
