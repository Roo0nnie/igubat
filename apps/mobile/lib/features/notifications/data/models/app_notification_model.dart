import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_category.dart';
import '../../domain/entities/notification_kind.dart';

/// DTO for an inbox notification. Mirrors the backend response and maps to the
/// [AppNotification] entity.
class AppNotificationModel {
  const AppNotificationModel({
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

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['metadata'];
    return AppNotificationModel(
      id: JsonUtils.asInt(json['id']),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationKind.fromApi(json['type'] as String?),
      category: NotificationCategory.fromApi(json['category'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      readAt: tryParseDate(json['readAt']),
      metadata: rawMeta is Map ? JsonUtils.asMap(rawMeta) : null,
      createdAt: tryParseDate(json['createdAt']),
    );
  }

  AppNotification toEntity() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    category: category,
    isRead: isRead,
    readAt: readAt,
    metadata: metadata,
    createdAt: createdAt,
  );
}
