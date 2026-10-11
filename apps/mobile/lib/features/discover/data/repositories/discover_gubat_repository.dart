import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:mobile/services/storage/theme_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/discover_gubat_entry.dart';

class DiscoverGubatRepository {
  DiscoverGubatRepository({Dio? dio, SharedPreferences? prefs})
    : _dio = dio,
      _prefs = prefs;

  final Dio? _dio;
  final SharedPreferences? _prefs;

  final Map<DiscoverGubatType, DateTime> _lastUpdated = {};
  final Map<DiscoverGubatType, bool> _servedFromCache = {};

  DateTime? lastUpdatedFor(DiscoverGubatType type) => _lastUpdated[type];

  bool wasCachedFor(DiscoverGubatType type) => _servedFromCache[type] ?? false;

  Future<List<DiscoverGubatEntry>> listByType(DiscoverGubatType type) async {
    final dio = _dio;
    if (dio == null) return _seedListByType(type);

    try {
      final response = await dio.get(
        ApiConstants.publicDiscoverGubat,
        queryParameters: {'type': type.apiValue, 'limit': 20},
      );
      final items = _parseEntryList(_unwrap(response.data));
      await _cacheList(type, items);
      _servedFromCache[type] = false;
      return items;
    } on DioException {
      final cached = _readCachedList(type);
      if (cached != null) return cached;
      return _seedListByType(type);
    } on FormatException {
      final cached = _readCachedList(type);
      if (cached != null) return cached;
      return _seedListByType(type);
    }
  }

  Future<DiscoverGubatEntry?> getBySlug(String slug) async {
    final dio = _dio;
    if (dio == null) return seedBySlug(slug);

    try {
      final response = await dio.get(
        ApiConstants.publicDiscoverGubatItem(slug),
      );
      final item = _parseEntry(_unwrap(response.data));
      await _cacheDetail(item);
      return item;
    } on DioException {
      return _readCachedDetail(slug) ?? seedBySlug(slug);
    } on FormatException {
      return _readCachedDetail(slug) ?? seedBySlug(slug);
    }
  }

  static String _listCacheKey(DiscoverGubatType type) =>
      'discover_gubat.list.${type.apiValue}';

  static String _listUpdatedKey(DiscoverGubatType type) =>
      'discover_gubat.list.${type.apiValue}.updated_at';

  static String _detailCacheKey(String slug) => 'discover_gubat.detail.$slug';

  dynamic _unwrap(dynamic data) {
    if (data is Map && data.containsKey('data')) return data['data'];
    return data;
  }

  DiscoverGubatEntry _parseEntry(dynamic data) {
    if (data is! Map) {
      throw const FormatException(
        'Discover Gubat entry response was not an object',
      );
    }
    return DiscoverGubatEntry.fromJson(Map<String, dynamic>.from(data));
  }

  List<DiscoverGubatEntry> _parseEntryList(dynamic data) {
    if (data is! List) {
      throw const FormatException(
        'Discover Gubat list response was not a list',
      );
    }
    final items =
        data
            .whereType<Map>()
            .map(
              (item) =>
                  DiscoverGubatEntry.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          ..sort(
            (a, b) => (b.publishedAt ?? DateTime(0)).compareTo(
              a.publishedAt ?? DateTime(0),
            ),
          );
    return items;
  }

  Future<void> _cacheList(
    DiscoverGubatType type,
    List<DiscoverGubatEntry> items,
  ) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final now = DateTime.now();
    _lastUpdated[type] = now;
    await Future.wait([
      prefs.setString(
        _listCacheKey(type),
        jsonEncode(items.map((item) => item.toJson()).toList()),
      ),
      prefs.setString(_listUpdatedKey(type), now.toIso8601String()),
    ]);
  }

  List<DiscoverGubatEntry>? _readCachedList(DiscoverGubatType type) {
    final prefs = _prefs;
    if (prefs == null) return null;
    final raw = prefs.getString(_listCacheKey(type));
    if (raw == null) return null;
    try {
      final updatedAt = DateTime.tryParse(
        prefs.getString(_listUpdatedKey(type)) ?? '',
      );
      if (updatedAt != null) _lastUpdated[type] = updatedAt;
      final items = _parseEntryList(jsonDecode(raw));
      _servedFromCache[type] = true;
      return items;
    } on FormatException {
      return null;
    }
  }

  Future<void> _cacheDetail(DiscoverGubatEntry item) async {
    final prefs = _prefs;
    if (prefs == null || item.slug.isEmpty) return;
    await prefs.setString(
      _detailCacheKey(item.slug),
      jsonEncode(item.toJson()),
    );
  }

  DiscoverGubatEntry? _readCachedDetail(String slug) {
    final prefs = _prefs;
    if (prefs == null) return null;
    final raw = prefs.getString(_detailCacheKey(slug));
    if (raw == null) return null;
    try {
      return _parseEntry(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  List<DiscoverGubatEntry> _seedListByType(DiscoverGubatType type) {
    _lastUpdated.remove(type);
    _servedFromCache[type] = false;
    final items = _seed.where((item) => item.type == type).toList()
      ..sort(
        (a, b) => (b.publishedAt ?? DateTime(0)).compareTo(
          a.publishedAt ?? DateTime(0),
        ),
      );
    return items;
  }

  static DiscoverGubatEntry? seedBySlug(String slug) {
    for (final item in _seed) {
      if (item.slug == slug) return item;
    }
    return null;
  }

  static final List<DiscoverGubatEntry> _seed = [
    DiscoverGubatEntry(
      id: 1,
      type: DiscoverGubatType.touristSpot,
      slug: 'buenavista-beach',
      title: 'Buenavista Beach',
      category: 'Beaches & Surfing',
      summary:
          'A public coastal destination known for surf breaks and sunrise views.',
      mapLocation: 'Coastal Gubat, Sorsogon',
      metadata: {'type': 'tourist_spot', 'mapLocation': 'Coastal Gubat'},
      publishedAt: DateTime(2026, 1, 1),
    ),
    DiscoverGubatEntry(
      id: 2,
      type: DiscoverGubatType.touristSpot,
      slug: 'castillo-de-gubat',
      title: 'Castillo de Gubat',
      category: 'Heritage & Landmarks',
      summary: 'Spanish-era watchtower ruins tied to the municipality history.',
      mapLocation: 'Poblacion, Gubat, Sorsogon',
      metadata: {
        'type': 'tourist_spot',
        'mapLocation': 'Poblacion, Gubat, Sorsogon',
      },
      publishedAt: DateTime(2026, 1, 2),
    ),
    DiscoverGubatEntry(
      id: 3,
      type: DiscoverGubatType.touristSpot,
      slug: 'dulangan-nasipit-estuary',
      title: 'Dulangan-Nasipit Estuary',
      category: 'Nature & Eco-Tourism',
      summary:
          'Coastal wetland and river-mouth area for nature walks and wildlife viewing.',
      mapLocation: 'Dulangan-Nasipit, Gubat, Sorsogon',
      metadata: {
        'type': 'tourist_spot',
        'mapLocation': 'Dulangan-Nasipit, Gubat, Sorsogon',
      },
      publishedAt: DateTime(2026, 1, 3),
    ),
    DiscoverGubatEntry(
      id: 4,
      type: DiscoverGubatType.festivalCulture,
      slug: 'ginubat-festival',
      title: 'Ginubat Festival',
      category: 'Festival',
      summary:
          'Annual celebration honoring Gubat history, faith, and community identity.',
      metadata: {
        'type': 'festival_culture',
        'culturalNote':
            'An annual town celebration connected to the feast of San Antonio de Padua.',
      },
      publishedAt: DateTime(2026, 1, 4),
    ),
    DiscoverGubatEntry(
      id: 5,
      type: DiscoverGubatType.festivalCulture,
      slug: 'san-antonio-de-padua-parish',
      title: 'San Antonio de Padua Parish',
      category: 'Heritage',
      summary:
          'A historic parish church and civic landmark in the town center.',
      metadata: {
        'type': 'festival_culture',
        'culturalNote':
            'A civic and religious landmark that anchors local heritage walking routes.',
      },
      publishedAt: DateTime(2026, 1, 5),
    ),
    DiscoverGubatEntry(
      id: 6,
      type: DiscoverGubatType.localProduct,
      slug: 'timitim',
      title: 'Timitim',
      category: 'Delicacies/Kakanin',
      summary: 'Cassava-and-pili local sweet commonly bought as pasalubong.',
      whereToBuy: 'Public market and local pasalubong stalls',
      metadata: {
        'type': 'local_product',
        'whereToBuy': 'Public market and local pasalubong stalls',
      },
      publishedAt: DateTime(2026, 1, 6),
    ),
    DiscoverGubatEntry(
      id: 7,
      type: DiscoverGubatType.localProduct,
      slug: 'pili-nuts',
      title: 'Pili Nuts',
      category: 'Pili Products',
      summary:
          'Locally sold pili snacks and sweets sourced from Sorsogon producers.',
      whereToBuy: 'Pasalubong stalls and local product fairs',
      metadata: {
        'type': 'local_product',
        'whereToBuy': 'Pasalubong stalls and local product fairs',
      },
      publishedAt: DateTime(2026, 1, 7),
    ),
    DiscoverGubatEntry(
      id: 8,
      type: DiscoverGubatType.localProduct,
      slug: 'dalu-dalo',
      title: 'Dalu-Dalo',
      category: 'Pasalubong',
      summary:
          'Local food item commonly brought home after town visits and family gatherings.',
      whereToBuy: 'Public market and neighborhood makers',
      metadata: {
        'type': 'local_product',
        'whereToBuy': 'Public market and neighborhood makers',
      },
      publishedAt: DateTime(2026, 1, 8),
    ),
    DiscoverGubatEntry(
      id: 9,
      type: DiscoverGubatType.localProduct,
      slug: 'salanigo',
      title: 'Salanigo',
      category: 'Handicrafts/OTOP',
      summary: 'Hand-woven abaca slippers produced by local makers.',
      whereToBuy: 'Local OTOP stalls and community product fairs',
      metadata: {
        'type': 'local_product',
        'whereToBuy': 'Local OTOP stalls and community product fairs',
      },
      publishedAt: DateTime(2026, 1, 9),
    ),
    DiscoverGubatEntry(
      id: 10,
      type: DiscoverGubatType.localProduct,
      slug: 'sikad-sikad',
      title: 'Sikad-Sikad',
      category: 'Seafood',
      summary:
          'Coastal shellfish delicacy associated with local fishing communities.',
      whereToBuy: 'Seafood vendors and wet market stalls',
      metadata: {
        'type': 'local_product',
        'whereToBuy': 'Seafood vendors and wet market stalls',
      },
      publishedAt: DateTime(2026, 1, 10),
    ),
  ];
}

final discoverGubatRepositoryProvider = Provider<DiscoverGubatRepository>((
  ref,
) {
  try {
    return DiscoverGubatRepository(
      dio: ref.watch(dioProvider),
      prefs: ref.watch(sharedPreferencesProvider),
    );
  } catch (_) {
    return DiscoverGubatRepository();
  }
});

final discoverGubatListProvider =
    FutureProvider.family<List<DiscoverGubatEntry>, DiscoverGubatType>((
      ref,
      type,
    ) {
      return ref.watch(discoverGubatRepositoryProvider).listByType(type);
    });

final discoverGubatDetailProvider =
    FutureProvider.family<DiscoverGubatEntry?, String>((ref, slug) {
      return ref.watch(discoverGubatRepositoryProvider).getBySlug(slug);
    });
