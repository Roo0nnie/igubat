/// Non-URL app-wide constants: page sizes, cache keys, TTLs.
class AppConstants {
  AppConstants._();

  /// Default page size for list endpoints (server trims; we derive paging).
  static const int defaultPageLimit = 20;

  /// How long a cached list/detail stays "fresh" before a background refresh.
  static const Duration cacheTtl = Duration(hours: 6);

  // ── SharedPreferences cache keys ─────────────────────────────────────────
  static const String transparencyCachePrefix = 'cache.transparency';
  static const String notificationPrefsCacheKey = 'cache.notification_prefs';
  static const String profileCacheKey = 'cache.profile';
  static const String newsCacheKey = 'cache.news';
  static const String eventsCacheKey = 'cache.events';
  static const String servicesCacheKey = 'cache.services';
  static const String emergencyDirectoryCacheKey = 'cache.emergency_directory';
  static const String dashboardCacheKey = 'cache.dashboard';
}
