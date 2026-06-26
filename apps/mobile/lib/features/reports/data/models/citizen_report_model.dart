import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/citizen_report.dart';
import '../../domain/entities/citizen_report_status.dart';
import 'report_attachment_model.dart';
import 'report_status_change_model.dart';

/// DTO for a citizen report. Mirrors the backend `/me/reports` shape and maps
/// to the [CitizenReport] entity.
///
/// NOTE: `latitude`/`longitude` arrive as STRINGS on the wire, so they stay
/// `String?` here and are coerced to `double?` via [JsonUtils.asDoubleOrNull]
/// in [toEntity].
class CitizenReportModel {
  const CitizenReportModel({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
    this.barangay,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.publicRemarks,
    this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.history = const [],
  });

  final int id;
  final String category;
  final String description;
  final CitizenReportStatus status;
  final String? barangay;
  final String? locationAddress;
  final String? latitude;
  final String? longitude;
  final String? publicRemarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ReportAttachmentModel> attachments;
  final List<ReportStatusChangeModel> history;

  factory CitizenReportModel.fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: JsonUtils.asInt(json['id']),
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: CitizenReportStatus.fromApi(json['status'] as String?),
      barangay: json['barangay'] as String?,
      locationAddress: json['locationAddress'] as String?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      publicRemarks: json['publicRemarks'] as String?,
      createdAt: tryParseDate(json['createdAt']),
      updatedAt: tryParseDate(json['updatedAt']),
      attachments: ((json['attachments'] as List?) ?? const [])
          .map((e) => ReportAttachmentModel.fromJson(JsonUtils.asMap(e)))
          .toList(),
      history: ((json['history'] as List?) ?? const [])
          .map((e) => ReportStatusChangeModel.fromJson(JsonUtils.asMap(e)))
          .toList(),
    );
  }

  CitizenReport toEntity() => CitizenReport(
    id: id,
    category: category,
    description: description,
    status: status,
    barangay: barangay,
    locationAddress: locationAddress,
    latitude: JsonUtils.asDoubleOrNull(latitude),
    longitude: JsonUtils.asDoubleOrNull(longitude),
    publicRemarks: publicRemarks,
    createdAt: createdAt,
    updatedAt: updatedAt,
    attachments: attachments.map((a) => a.toEntity()).toList(),
    history: history.map((h) => h.toEntity()).toList(),
  );
}
