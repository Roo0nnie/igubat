import 'citizen_report_status.dart';

/// A single entry in a citizen report's status history timeline.
///
/// Domain entity — pure Dart, no serialization.
class ReportStatusChange {
  const ReportStatusChange({
    required this.id,
    required this.status,
    this.remarks,
    this.createdAt,
  });

  final int id;
  final CitizenReportStatus status;
  final String? remarks;
  final DateTime? createdAt;
}
