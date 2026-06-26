/// A downloadable file attached to a transparency item (PDF/JPG/PNG).
///
/// Domain entity — pure Dart, no serialization. The [fileUrl] is opened on
/// demand; previously-opened files remain available in the device cache.
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
}
