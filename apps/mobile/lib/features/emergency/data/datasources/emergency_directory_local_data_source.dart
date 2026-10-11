import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/storage/theme_storage_service.dart';
import '../../domain/entities/emergency_directory_entry.dart';
import '../models/emergency_directory_entry_model.dart';

/// SharedPreferences-backed copy of the last successfully fetched Emergency
/// Directory, so hotlines stay reachable without a connection (e.g. during a
/// typhoon when data service is down).
class EmergencyDirectoryLocalDataSource {
  EmergencyDirectoryLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _listKey = AppConstants.emergencyDirectoryCacheKey;
  static const _updatedKey = '${AppConstants.emergencyDirectoryCacheKey}.updated_at';

  DateTime? _lastUpdated;
  bool _servedFromCache = false;

  DateTime? get lastUpdated => _lastUpdated;

  bool get servedFromCache => _servedFromCache;

  Future<void> cache(List<EmergencyDirectoryEntry> entries) async {
    final now = DateTime.now();
    _lastUpdated = now;
    _servedFromCache = false;
    await Future.wait([
      _prefs.setString(
        _listKey,
        jsonEncode(
          entries.map((e) => EmergencyDirectoryEntryModel.fromEntity(e).toJson()).toList(),
        ),
      ),
      _prefs.setString(_updatedKey, now.toIso8601String()),
    ]);
  }

  List<EmergencyDirectoryEntry>? readCached() {
    final raw = _prefs.getString(_listKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! List) return null;
      _lastUpdated = DateTime.tryParse(_prefs.getString(_updatedKey) ?? '');
      _servedFromCache = true;
      return data
          .whereType<Map>()
          .map((e) => EmergencyDirectoryEntryModel.fromJson(e.cast<String, dynamic>()).toEntity())
          .toList();
    } on FormatException {
      return null;
    }
  }
}

final emergencyDirectoryLocalDataSourceProvider = Provider<EmergencyDirectoryLocalDataSource>(
  (ref) => EmergencyDirectoryLocalDataSource(ref.watch(sharedPreferencesProvider)),
);
