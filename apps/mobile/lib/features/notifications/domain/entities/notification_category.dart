/// Subject area of a notification, mirroring the backend `category` enum. Used
/// to pick the leading icon/accent in the inbox. [unknown] is a
/// forward-compatible fallback.
enum NotificationCategory {
  news,
  serviceRequest,
  issueReport,
  emergency,
  general,
  transparency,
  unknown;

  /// Maps the backend wire value (snake_case) to an enum member.
  static NotificationCategory fromApi(String? value) => switch (value) {
    'news' => NotificationCategory.news,
    'service_request' => NotificationCategory.serviceRequest,
    'issue_report' => NotificationCategory.issueReport,
    'emergency' => NotificationCategory.emergency,
    'general' => NotificationCategory.general,
    'transparency' => NotificationCategory.transparency,
    _ => NotificationCategory.unknown,
  };
}
