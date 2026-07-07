/// A file attached to a citizen report (photo / document).
///
/// Domain entity — pure Dart, no serialization.
class ReportAttachment {
  const ReportAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
  });

  final int id;
  final String fileName;
  final String fileUrl;
}
