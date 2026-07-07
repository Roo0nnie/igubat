import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/request_attachment.dart';

/// DTO for a service-request attachment. Maps to the [RequestAttachment]
/// entity.
class RequestAttachmentModel {
  const RequestAttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
  });

  final int id;
  final String fileName;
  final String fileUrl;

  factory RequestAttachmentModel.fromJson(Map<String, dynamic> json) {
    return RequestAttachmentModel(
      id: JsonUtils.asInt(json['id']),
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
    );
  }

  RequestAttachment toEntity() =>
      RequestAttachment(id: id, fileName: fileName, fileUrl: fileUrl);
}
