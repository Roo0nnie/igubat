import 'request_attachment.dart';
import 'request_status_change.dart';
import 'service_request_status.dart';

/// A citizen-submitted LGU service request (`/me/requests`).
///
/// Domain entity — pure Dart, no serialization. List views use the same entity
/// with [attachments]/[history] left empty; only the detail endpoint populates
/// them.
class ServiceRequest {
  const ServiceRequest({
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
  final List<RequestAttachment> attachments;
  final List<RequestStatusChange> history;
}
