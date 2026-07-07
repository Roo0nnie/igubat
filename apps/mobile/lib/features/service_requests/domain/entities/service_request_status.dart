/// Lifecycle states of a citizen service request, mirroring the backend
/// `status` enum. [unknown] is a forward-compatible fallback for any value the
/// app does not yet recognise, so a new backend state never crashes the UI.
enum ServiceRequestStatus {
  pending,
  inReview,
  approved,
  rejected,
  forPickup,
  completed,
  unknown;

  /// Maps the backend wire value (snake_case) to an enum member.
  static ServiceRequestStatus fromApi(String? value) => switch (value) {
    'pending' => ServiceRequestStatus.pending,
    'in_review' => ServiceRequestStatus.inReview,
    'approved' => ServiceRequestStatus.approved,
    'rejected' => ServiceRequestStatus.rejected,
    'for_pickup' => ServiceRequestStatus.forPickup,
    'completed' => ServiceRequestStatus.completed,
    _ => ServiceRequestStatus.unknown,
  };

  /// Human-readable label for badges and timelines.
  String get label => switch (this) {
    ServiceRequestStatus.pending => 'Pending',
    ServiceRequestStatus.inReview => 'In Review',
    ServiceRequestStatus.approved => 'Approved',
    ServiceRequestStatus.rejected => 'Rejected',
    ServiceRequestStatus.forPickup => 'For Pickup',
    ServiceRequestStatus.completed => 'Completed',
    ServiceRequestStatus.unknown => 'Unknown',
  };
}
