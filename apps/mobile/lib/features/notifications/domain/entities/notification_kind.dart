/// Delivery channel of a notification, mirroring the backend `type` enum.
/// [unknown] is a forward-compatible fallback.
enum NotificationKind {
  inApp,
  push,
  email,
  unknown;

  /// Maps the backend wire value to an enum member.
  static NotificationKind fromApi(String? value) => switch (value) {
    'in_app' => NotificationKind.inApp,
    'push' => NotificationKind.push,
    'email' => NotificationKind.email,
    _ => NotificationKind.unknown,
  };
}
