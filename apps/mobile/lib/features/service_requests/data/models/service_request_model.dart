import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/entities/service_request_status.dart';
import 'request_attachment_model.dart';
import 'request_status_change_model.dart';

/// DTO for a citizen service request. Mirrors the backend response and maps to
/// the [ServiceRequest] entity. List responses omit [attachments]/[history];
/// the detail response populates them.
class ServiceRequestModel {
  const ServiceRequestModel({
    required this.id,
    required this.trackingNumber,
    required this.serviceType,
    required this.description,
    required this.status,
    this.serviceTypeId,
    this.preferredDate,
    this.publicRemarks,
    this.barangay,
    this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.history = const [],
  });

  final int id;
  final String trackingNumber;
  final int? serviceTypeId;
  final String serviceType;
  final String description;
  final DateTime? preferredDate;
  final ServiceRequestStatus status;
  final String? publicRemarks;
  final String? barangay;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<RequestAttachmentModel> attachments;
  final List<RequestStatusChangeModel> history;

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: JsonUtils.asInt(json['id']),
      trackingNumber: json['trackingNumber'] as String? ?? '',
      serviceTypeId: json['serviceTypeId'] == null
          ? null
          : JsonUtils.asInt(json['serviceTypeId']),
      serviceType: json['serviceType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      preferredDate: tryParseDate(json['preferredDate']),
      status: ServiceRequestStatus.fromApi(json['status'] as String?),
      publicRemarks: json['publicRemarks'] as String?,
      barangay: json['barangay'] as String?,
      createdAt: tryParseDate(json['createdAt']),
      updatedAt: tryParseDate(json['updatedAt']),
      attachments: ((json['attachments'] as List?) ?? const [])
          .map((e) => RequestAttachmentModel.fromJson(JsonUtils.asMap(e)))
          .toList(),
      history: ((json['history'] as List?) ?? const [])
          .map((e) => RequestStatusChangeModel.fromJson(JsonUtils.asMap(e)))
          .toList(),
    );
  }

  ServiceRequest toEntity() => ServiceRequest(
    id: id,
    trackingNumber: trackingNumber,
    serviceTypeId: serviceTypeId,
    serviceType: serviceType,
    description: description,
    preferredDate: preferredDate,
    status: status,
    publicRemarks: publicRemarks,
    barangay: barangay,
    createdAt: createdAt,
    updatedAt: updatedAt,
    attachments: attachments.map((a) => a.toEntity()).toList(),
    history: history.map((h) => h.toEntity()).toList(),
  );
}
