import '../../../../core/extensions/date_time_x.dart';

/// Parameter object for creating a service request.
///
/// [toJson] produces the POST body for `/me/requests`, omitting optional fields
/// the backend treats as absent (preferred date, attachments).
class CreateServiceRequestParams {
  const CreateServiceRequestParams({
    required this.serviceTypeId,
    required this.description,
    this.preferredDate,
    this.attachments = const [],
  });

  final int serviceTypeId;
  final String description;
  final DateTime? preferredDate;
  final List<RequestAttachmentInput> attachments;

  Map<String, dynamic> toJson() => {
    'serviceTypeId': serviceTypeId,
    'description': description,
    if (preferredDate != null) 'preferredDate': preferredDate!.toIso(),
    if (attachments.isNotEmpty)
      'attachments': attachments.map((a) => a.toJson()).toList(),
  };
}

/// A file the citizen attaches to a new request. The mobile client uploads to
/// storage first, then submits the resulting filename + URL.
class RequestAttachmentInput {
  const RequestAttachmentInput({required this.fileName, required this.fileUrl});

  final String fileName;
  final String fileUrl;

  Map<String, dynamic> toJson() => {'fileName': fileName, 'fileUrl': fileUrl};
}
