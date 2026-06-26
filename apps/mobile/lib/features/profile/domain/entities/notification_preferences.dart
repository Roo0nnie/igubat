import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences.freezed.dart';

/// Citizen notification preference toggles (backend `notificationPreferences`).
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const NotificationPreferences._();

  const factory NotificationPreferences({
    @Default(true) bool news,
    @Default(true) bool serviceRequests,
    @Default(true) bool issueReports,
    @Default(true) bool emergencyBroadcasts,
    @Default(true) bool transparency,
    @Default(true) bool pushEnabled,
    @Default(true) bool emailEnabled,
  }) = _NotificationPreferences;

  /// All channels on — the optimistic default before the server responds.
  static NotificationPreferences defaults() => const NotificationPreferences();
}
