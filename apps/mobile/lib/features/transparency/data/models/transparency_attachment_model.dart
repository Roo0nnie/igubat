import '../../domain/entities/transparency_attachment.dart';

/// DTO for a transparency attachment. Maps to/from the
/// [TransparencyAttachment] entity.
class TransparencyAttachmentModel {
  const TransparencyAttachmentModel({
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

  factory TransparencyAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TransparencyAttachmentModel(
      id: (json['id'] as num).toInt(),
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  factory TransparencyAttachmentModel.fromEntity(TransparencyAttachment e) =>
      TransparencyAttachmentModel(
        id: e.id,
        fileName: e.fileName,
        fileUrl: e.fileUrl,
        mimeType: e.mimeType,
        sizeBytes: e.sizeBytes,
        sortOrder: e.sortOrder,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'mimeType': mimeType,
    'sizeBytes': sizeBytes,
    'sortOrder': sortOrder,
  };

  TransparencyAttachment toEntity() => TransparencyAttachment(
    id: id,
    fileName: fileName,
    fileUrl: fileUrl,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    sortOrder: sortOrder,
  );
}
