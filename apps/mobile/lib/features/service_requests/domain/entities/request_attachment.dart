/// A file attached to a service request (uploaded by the citizen at submission).
///
/// Domain entity — pure Dart, no serialization. Empty in list responses; only
/// the detail endpoint populates attachments.
class RequestAttachment {
  const RequestAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
  });

  final int id;
  final String fileName;
  final String fileUrl;
}
