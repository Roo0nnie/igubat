import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/report_attachment.dart';

/// DTO for a citizen-report attachment. Maps to the [ReportAttachment] entity.
class ReportAttachmentModel {
  const ReportAttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
  });

  final int id;
  final String fileName;
  final String fileUrl;

  factory ReportAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ReportAttachmentModel(
      id: JsonUtils.asInt(json['id']),
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
    );
  }

  ReportAttachment toEntity() =>
      ReportAttachment(id: id, fileName: fileName, fileUrl: fileUrl);
}
