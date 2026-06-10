/// A downloadable file attached to a transparency item (PDF/JPG/PNG). The
/// [fileUrl] is opened on demand via a signed URL; previously-opened files
/// remain available in the device cache per the offline-support spec.
class TransparencyAttachment {
  const TransparencyAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.sizeBytes,
    this.sortOrder = 0,
  });

  final int id;
  final String fileName;
  final String fileUrl;
  final String mimeType;
  final int sizeBytes;
  final int sortOrder;

  /// Human-readable size used in the attachment row (e.g. "412 KB").
  String get readableSize {
    if (sizeBytes <= 0) return '';
    if (sizeBytes < 1024) return '$sizeBytes B';
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  bool get isPdf => mimeType == 'application/pdf';

  factory TransparencyAttachment.fromJson(Map<String, dynamic> json) {
    return TransparencyAttachment(
      id: (json['id'] as num).toInt(),
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'sortOrder': sortOrder,
      };
}
