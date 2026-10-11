import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_preferences.dart';

part 'notification_preferences_model.freezed.dart';
part 'notification_preferences_model.g.dart';

@freezed
abstract class NotificationPreferencesModel
    with _$NotificationPreferencesModel {
  const NotificationPreferencesModel._();

  const factory NotificationPreferencesModel({
    @Default(true) bool news,
    @Default(true) bool serviceRequests,
    @Default(true) bool issueReports,
    @Default(true) bool emergencyBroadcasts,
    @Default(true) bool discoverGubat,
    @Default(true) bool transparency,
    @Default(true) bool pushEnabled,
    @Default(true) bool emailEnabled,
  }) = _NotificationPreferencesModel;

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);

  factory NotificationPreferencesModel.fromEntity(NotificationPreferences e) =>
      NotificationPreferencesModel(
        news: e.news,
        serviceRequests: e.serviceRequests,
        issueReports: e.issueReports,
        emergencyBroadcasts: e.emergencyBroadcasts,
        discoverGubat: e.discoverGubat,
        transparency: e.transparency,
        pushEnabled: e.pushEnabled,
        emailEnabled: e.emailEnabled,
      );

  NotificationPreferences toEntity() => NotificationPreferences(
    news: news,
    serviceRequests: serviceRequests,
    issueReports: issueReports,
    emergencyBroadcasts: emergencyBroadcasts,
    discoverGubat: discoverGubat,
    transparency: transparency,
    pushEnabled: pushEnabled,
    emailEnabled: emailEnabled,
  );
}
