import 'citizen_report_status.dart';
import 'report_attachment.dart';
import 'report_status_change.dart';

/// A citizen-submitted community issue report (`/me/reports`).
///
/// Domain entity — pure Dart, no serialization. List views reuse the same
/// entity with [attachments]/[history] left empty.
class CitizenReport {
  const CitizenReport({
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
  final double? latitude;
  final double? longitude;
  final String? publicRemarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ReportAttachment> attachments;
  final List<ReportStatusChange> history;
}
