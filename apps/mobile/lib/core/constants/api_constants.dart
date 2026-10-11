import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central registry of backend endpoint URLs.
///
/// Base/version come from `.env`. Better Auth routes (`/auth/*`) return raw,
/// un-enveloped bodies; iGubat routes (`/igubat/*`) return bare arrays/objects
/// (no success envelope) — see `core/network/api_response.dart`.
class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static String get versionedUrl => '$baseUrl/$apiVersion';

  static String get _igubat => '$versionedUrl/igubat';

  // ── Auth (Better Auth — no envelope) ──────────────────────────────────────
  static String get signIn => '$versionedUrl/auth/sign-in/email';
  static String get signUp => '$versionedUrl/auth/sign-up/email';
  static String get signOut => '$versionedUrl/auth/sign-out';
  static String get getSession => '$versionedUrl/auth/get-session';

  /// `sendVerificationOtp` (re)dispatches a code; `verifyEmailOtp` validates it
  /// server-side and establishes the authenticated session.
  static String get sendVerificationOtp =>
      '$versionedUrl/auth/email-otp/send-verification-otp';
  static String get verifyEmailOtp =>
      '$versionedUrl/auth/email-otp/verify-email';

  // ── Example (todos) ───────────────────────────────────────────────────────
  static String get todos => '$versionedUrl/example/todos';
  static String todoById(int id) => '$versionedUrl/example/todos/$id';

  // ── iGubat public (no auth) ───────────────────────────────────────────────
  static String get publicDashboard => '$_igubat/public/dashboard';

  static String get publicNews => '$_igubat/public/news';
  static String publicArticle(String slug) => '$_igubat/public/news/$slug';

  static String get publicEvents => '$_igubat/public/events';
  static String publicEvent(String slug) => '$_igubat/public/events/$slug';

  static String get publicDiscoverGubat => '$_igubat/public/discover-gubat';
  static String publicDiscoverGubatItem(String slug) =>
      '$_igubat/public/discover-gubat/$slug';

  static String get publicPlacements => '$_igubat/public/placements';

  static String get serviceCategories => '$_igubat/public/service-categories';
  static String get services => '$_igubat/public/services';
  static String service(String slug) => '$_igubat/public/services/$slug';

  static String get emergencyDirectory => '$_igubat/public/emergency-directory';

  static String get publicTransparency => '$_igubat/public/transparency';
  static String publicTransparencyItem(String slug) =>
      '$_igubat/public/transparency/$slug';

  // ── iGubat citizen (`/me/*`, auth required) ───────────────────────────────
  static String get myRequests => '$_igubat/me/requests';
  static String myRequest(int id) => '$_igubat/me/requests/$id';
  static String cancelRequest(int id) => '$_igubat/me/requests/$id/cancel';

  static String get myReports => '$_igubat/me/reports';
  static String myReport(int id) => '$_igubat/me/reports/$id';

  static String get notifications => '$_igubat/me/notifications';
  static String markNotificationRead(int id) =>
      '$_igubat/me/notifications/$id/read';
  static String get markAllNotificationsRead =>
      '$_igubat/me/notifications/read-all';

  static String get profile => '$_igubat/me/profile';
  static String get notificationPreferences =>
      '$_igubat/me/notification-preferences';
}
