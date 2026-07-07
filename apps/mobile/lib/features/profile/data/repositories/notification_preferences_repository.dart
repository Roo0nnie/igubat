import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:mobile/services/storage/theme_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.news,
    required this.serviceRequests,
    required this.issueReports,
    required this.emergencyBroadcasts,
    required this.discoverGubat,
    required this.transparency,
    required this.pushEnabled,
    required this.emailEnabled,
  });

  factory NotificationPreferences.defaults() => const NotificationPreferences(
    news: true,
    serviceRequests: true,
    issueReports: true,
    emergencyBroadcasts: true,
    discoverGubat: true,
    transparency: true,
    pushEnabled: true,
    emailEnabled: true,
  );

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      news: json['news'] as bool? ?? true,
      serviceRequests: json['serviceRequests'] as bool? ?? true,
      issueReports: json['issueReports'] as bool? ?? true,
      emergencyBroadcasts: json['emergencyBroadcasts'] as bool? ?? true,
      discoverGubat: json['discoverGubat'] as bool? ?? true,
      transparency: json['transparency'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
    );
  }

  final bool news;
  final bool serviceRequests;
  final bool issueReports;
  final bool emergencyBroadcasts;
  final bool discoverGubat;
  final bool transparency;
  final bool pushEnabled;
  final bool emailEnabled;

  NotificationPreferences copyWith({
    bool? news,
    bool? serviceRequests,
    bool? issueReports,
    bool? emergencyBroadcasts,
    bool? discoverGubat,
    bool? transparency,
    bool? pushEnabled,
    bool? emailEnabled,
  }) {
    return NotificationPreferences(
      news: news ?? this.news,
      serviceRequests: serviceRequests ?? this.serviceRequests,
      issueReports: issueReports ?? this.issueReports,
      emergencyBroadcasts: emergencyBroadcasts ?? this.emergencyBroadcasts,
      discoverGubat: discoverGubat ?? this.discoverGubat,
      transparency: transparency ?? this.transparency,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'news': news,
    'serviceRequests': serviceRequests,
    'issueReports': issueReports,
    'emergencyBroadcasts': emergencyBroadcasts,
    'discoverGubat': discoverGubat,
    'transparency': transparency,
    'pushEnabled': pushEnabled,
    'emailEnabled': emailEnabled,
  };
}

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._dio, this._prefs);

  static const _cacheKey = 'notification.preferences';

  final Dio _dio;
  final SharedPreferences _prefs;

  Future<NotificationPreferences> fetch() async {
    final cached = _readCache();
    try {
      final response = await _dio.get(ApiConstants.notificationPreferences);
      final preferences = _parse(response.data);
      await _writeCache(preferences);
      return preferences;
    } on DioException {
      if (cached != null) return cached;
      rethrow;
    } on FormatException {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<NotificationPreferences> update(
    NotificationPreferences preferences,
  ) async {
    final response = await _dio.patch(
      ApiConstants.notificationPreferences,
      data: preferences.toJson(),
    );
    final saved = _parse(response.data);
    await _writeCache(saved);
    return saved;
  }

  NotificationPreferences? _readCache() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      return NotificationPreferences.fromJson(Map<String, dynamic>.from(data));
    } on FormatException {
      return null;
    }
  }

  Future<void> _writeCache(NotificationPreferences preferences) {
    return _prefs.setString(_cacheKey, jsonEncode(preferences.toJson()));
  }

  NotificationPreferences _parse(dynamic data) {
    final payload = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    if (payload is! Map) {
      throw const FormatException(
        'Notification preferences response was not an object',
      );
    }
    return NotificationPreferences.fromJson(Map<String, dynamic>.from(payload));
  }
}

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      return NotificationPreferencesRepository(
        ref.watch(dioProvider),
        ref.watch(sharedPreferencesProvider),
      );
    });
