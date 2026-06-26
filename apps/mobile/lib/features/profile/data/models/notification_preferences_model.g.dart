// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferencesModel(
  news: json['news'] as bool? ?? true,
  serviceRequests: json['serviceRequests'] as bool? ?? true,
  issueReports: json['issueReports'] as bool? ?? true,
  emergencyBroadcasts: json['emergencyBroadcasts'] as bool? ?? true,
  transparency: json['transparency'] as bool? ?? true,
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  emailEnabled: json['emailEnabled'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPreferencesModelToJson(
  _NotificationPreferencesModel instance,
) => <String, dynamic>{
  'news': instance.news,
  'serviceRequests': instance.serviceRequests,
  'issueReports': instance.issueReports,
  'emergencyBroadcasts': instance.emergencyBroadcasts,
  'transparency': instance.transparency,
  'pushEnabled': instance.pushEnabled,
  'emailEnabled': instance.emailEnabled,
};
