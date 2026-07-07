// Parameter objects for the citizen report use cases.

/// A single attachment to include when creating a report.
class ReportAttachmentInput {
  const ReportAttachmentInput({required this.fileName, required this.fileUrl});

  final String fileName;
  final String fileUrl;

  Map<String, dynamic> toJson() => {'fileName': fileName, 'fileUrl': fileUrl};
}

/// Body for creating a citizen report (`POST /me/reports`).
///
/// `latitude`/`longitude` are sent to the backend as STRINGS (the API stores
/// them as decimal strings), so they are serialised via [toString] in
/// [toJson]. Optional fields are omitted from the body when null.
class CreateCitizenReportParams {
  const CreateCitizenReportParams({
    required this.category,
    required this.description,
    this.barangay,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.attachments = const [],
  });

  final String category;
  final String description;
  final String? barangay;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final List<ReportAttachmentInput> attachments;

  Map<String, dynamic> toJson() => {
    'category': category,
    'description': description,
    if (barangay != null) 'barangay': barangay,
    if (locationAddress != null) 'locationAddress': locationAddress,
    if (latitude != null) 'latitude': latitude.toString(),
    if (longitude != null) 'longitude': longitude.toString(),
    if (attachments.isNotEmpty)
      'attachments': attachments.map((a) => a.toJson()).toList(),
  };
}
