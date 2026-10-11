import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/entities/service_request_status.dart';

/// Badge/accent color for a request status, shared by every request list.
extension ServiceRequestStatusColor on ServiceRequestStatus {
  Color get color => switch (this) {
    ServiceRequestStatus.approved ||
    ServiceRequestStatus.completed => AppTheme.primaryColor,
    ServiceRequestStatus.forPickup => const Color(0xFF2563EB),
    ServiceRequestStatus.pending ||
    ServiceRequestStatus.inReview => const Color(0xFFD97706),
    ServiceRequestStatus.rejected => const Color(0xFFB91C1C),
    ServiceRequestStatus.unknown => Colors.grey,
  };
}
