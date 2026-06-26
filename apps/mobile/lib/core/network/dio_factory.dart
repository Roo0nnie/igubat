import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_constants.dart';
import '../../services/storage/secure_storage_service.dart';
import 'interceptors/cookie_interceptor.dart';

part 'dio_factory.g.dart';

/// Dio instance and persistent cookie jar created once at app startup.
class ApiClient {
  ApiClient({required this.dio, required this.cookieJar});

  final Dio dio;
  final PersistCookieJar cookieJar;
}

/// Creates a configured [Dio] client and [PersistCookieJar].
///
/// - Sets the base URL from [ApiConstants].
/// - Attaches a [PersistCookieJar] backed by the app's document directory so
///   Better Auth session cookies survive app restarts.
/// - Attaches [cookieHeaderInterceptor] which reads/persists the session cookie
///   via [SecureStorageService].
Future<ApiClient> createApiClient(SecureStorageService storage) async {
  // Better Auth performs CSRF validation on POST requests by checking the
  // Origin header against its trustedOrigins list. Native mobile HTTP clients
  // don't send an Origin header by default, so we set one explicitly to the
  // backend's own (already trusted) address.
  final backendOrigin = Uri.parse(ApiConstants.baseUrl).origin;

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': backendOrigin,
      },
    ),
  );

  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${appDocDir.path}/.cookies/'),
  );
  dio.interceptors.add(CookieManager(cookieJar));
  dio.interceptors.add(cookieHeaderInterceptor(storage));

  return ApiClient(dio: dio, cookieJar: cookieJar);
}

/// Provider for [Dio].
///
/// Overridden in main.dart with an eagerly created instance so the client is
/// available synchronously via `ref.read`.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  throw UnimplementedError('dioProvider must be overridden in ProviderScope');
}

/// Provider for the persistent [PersistCookieJar] used by [dio].
///
/// Overridden in main.dart alongside [dioProvider].
@Riverpod(keepAlive: true)
PersistCookieJar cookieJar(Ref ref) {
  throw UnimplementedError('cookieJarProvider must be overridden in ProviderScope');
}
