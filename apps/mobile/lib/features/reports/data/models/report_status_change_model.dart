import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/citizen_report_status.dart';
import '../../domain/entities/report_status_change.dart';

/// DTO for a status-history entry. Maps to the [ReportStatusChange] entity.
class ReportStatusChangeModel {
  const ReportStatusChangeModel({
    required this.id,
    required this.status,
    this.remarks,
    this.createdAt,
  });

  final int id;
  final CitizenReportStatus status;
  final String? remarks;
  final DateTime? createdAt;

  factory ReportStatusChangeModel.fromJson(Map<String, dynamic> json) {
    return ReportStatusChangeModel(
      id: JsonUtils.asInt(json['id']),
      status: CitizenReportStatus.fromApi(json['status'] as String?),
      remarks: json['remarks'] as String?,
      createdAt: tryParseDate(json['createdAt']),
    );
  }

  ReportStatusChange toEntity() => ReportStatusChange(
    id: id,
    status: status,
    remarks: remarks,
    createdAt: createdAt,
  );
}
