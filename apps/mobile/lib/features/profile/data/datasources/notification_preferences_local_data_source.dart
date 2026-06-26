import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/storage/theme_storage_service.dart';
import '../models/notification_preferences_model.dart';

part 'notification_preferences_local_data_source.g.dart';

/// SharedPreferences-backed cache for the citizen's notification preferences,
/// used as an offline fallback when the network is unavailable.
class NotificationPreferencesLocalDataSource {
  NotificationPreferencesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const _key = AppConstants.notificationPrefsCacheKey;

  NotificationPreferencesModel? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      return NotificationPreferencesModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> write(NotificationPreferencesModel model) =>
      _prefs.setString(_key, jsonEncode(model.toJson()));
}

@riverpod
NotificationPreferencesLocalDataSource notificationPreferencesLocalDataSource(
  Ref ref,
) => NotificationPreferencesLocalDataSource(ref.watch(sharedPreferencesProvider));
