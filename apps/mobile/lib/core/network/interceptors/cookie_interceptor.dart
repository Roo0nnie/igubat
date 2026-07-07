import 'package:dio/dio.dart';

import '../../../services/storage/secure_storage_service.dart';

/// Interceptor that bridges Better Auth's cookie session with secure storage.
///
/// - On each request: injects the persisted session cookie header when present.
/// - On each response: persists any `set-cookie` header so subsequent requests
///   (and the next app launch) remain authenticated.
///
/// This complements the `dio_cookie_manager` [PersistCookieJar]; secure storage
/// is the durable fallback the auth flow reads from.
InterceptorsWrapper cookieHeaderInterceptor(SecureStorageService storage) {
  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      final cookie = await storage.getCookie();
      if (cookie != null && cookie.isNotEmpty) {
        options.headers['cookie'] = cookie;
      }
      handler.next(options);
    },
    onResponse: (response, handler) async {
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        await storage.setCookie(setCookie.join('; '));
      }
      handler.next(response);
    },
  );
}
