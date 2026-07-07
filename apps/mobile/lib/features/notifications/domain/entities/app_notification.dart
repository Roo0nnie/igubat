import 'notification_category.dart';
import 'notification_kind.dart';

/// A notification delivered to the citizen's inbox (`/me/notifications`).
///
/// Domain entity — pure Dart, no serialization. Named [AppNotification] (not
/// `Notification`) to avoid clashing with the Flutter framework's
/// `Notification` class. [metadata] stays a raw map so each row can read
/// type-specific deep-link fields without a rigid model.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.category,
    required this.isRead,
    this.readAt,
    this.metadata,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final NotificationKind type;
  final NotificationCategory category;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
}
