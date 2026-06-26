import 'service_request_status.dart';

/// A single status transition in a request's history timeline.
///
/// Domain entity — pure Dart, no serialization. Empty in list responses; only
/// the detail endpoint populates history.
class RequestStatusChange {
  const RequestStatusChange({
    required this.id,
    required this.status,
    this.remarks,
    this.createdAt,
  });

  final int id;
  final ServiceRequestStatus status;
  final String? remarks;
  final DateTime? createdAt;
}
