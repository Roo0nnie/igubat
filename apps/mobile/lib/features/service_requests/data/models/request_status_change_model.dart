import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/request_status_change.dart';
import '../../domain/entities/service_request_status.dart';

/// DTO for a single status change in a request's history. Maps to the
/// [RequestStatusChange] entity.
class RequestStatusChangeModel {
  const RequestStatusChangeModel({
    required this.id,
    required this.status,
    this.remarks,
    this.createdAt,
  });

  final int id;
  final ServiceRequestStatus status;
  final String? remarks;
  final DateTime? createdAt;

  factory RequestStatusChangeModel.fromJson(Map<String, dynamic> json) {
    return RequestStatusChangeModel(
      id: JsonUtils.asInt(json['id']),
      status: ServiceRequestStatus.fromApi(json['status'] as String?),
      remarks: json['remarks'] as String?,
      createdAt: tryParseDate(json['createdAt']),
    );
  }

  RequestStatusChange toEntity() => RequestStatusChange(
    id: id,
    status: status,
    remarks: remarks,
    createdAt: createdAt,
  );
}
