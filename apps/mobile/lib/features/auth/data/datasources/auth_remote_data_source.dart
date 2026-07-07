import 'dart:developer' as developer;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../services/storage/secure_storage_service.dart';
import '../models/session_model.dart';

part 'auth_remote_data_source.g.dart';

/// Talks to the Better Auth backend. Returns DTOs ([SessionModel]) and owns the
/// session token / cookie side effects. All transport errors are normalised to
/// [AppException] via [guard].
class AuthRemoteDataSource with BaseRemoteDataSource {
  AuthRemoteDataSource(this._dio, this._storage, this._cookieJar);

  final Dio _dio;
  final SecureStorageService _storage;
  final PersistCookieJar _cookieJar;

  Map<String, dynamic>? _parseJsonBody(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  Future<SessionModel?> signIn({
    required String email,
    required String password,
  }) => guard(() async {
    final response = await _dio.post(
      ApiConstants.signIn,
      data: {'email': email, 'password': password},
    );
    final body = _parseJsonBody(response);
    if (response.statusCode == 200 && body != null) {
      final session = SessionModel.fromAuthResponse(body);
      await _storage.setSessionToken(session.session.token);
      return session;
    }
    return null;
  });

  /// Registers a citizen. `/sign-up/email` creates the account **unverified**
  /// and dispatches an OTP; no session is returned.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String barangay,
    required String address,
    required bool dpaConsent,
  }) => guard(() async {
    await _dio.post(
      ApiConstants.signUp,
      data: {
        'email': email,
        'password': password,
        'name': name,
        'mobileNumber': mobileNumber,
        'barangay': barangay,
        'address': address,
        'dpaConsent': dpaConsent,
      },
    );
  });

  /// (Re)dispatches an email-verification OTP for [email].
  Future<void> sendVerificationOtp({required String email}) => guard(() async {
    await _dio.post(
      ApiConstants.sendVerificationOtp,
      data: {'email': email, 'type': 'email-verification'},
    );
  });

  Future<SessionModel?> verifyEmailOtp({
    required String email,
    required String otp,
  }) => guard(() async {
    final response = await _dio.post(
      ApiConstants.verifyEmailOtp,
      data: {'email': email, 'otp': otp},
    );
    final body = _parseJsonBody(response);
    if (response.statusCode == 200 && body != null && body['user'] != null) {
      if (body['token'] == null && body['session'] == null) {
        // Verified, but Better Auth returned no session — force a manual login.
        throw const UnauthorizedException(
          'Email verified, but no session was returned. Please sign in.',
        );
      }
      final session = SessionModel.fromAuthResponse(body);
      await _storage.setSessionToken(session.session.token);
      return session;
    }
    return null;
  });

  Future<void> signOut() => guard(() async {
    try {
      await _dio.post(ApiConstants.signOut);
    } finally {
      await _storage.deleteSessionToken();
      await _storage.deleteCookie();
      await _cookieJar.deleteAll();
    }
  });

  Future<SessionModel?> getSession() => guard(() async {
    final response = await _dio.get(ApiConstants.getSession);
    developer.log(
      'getSession status=${response.statusCode}',
      name: 'AuthRemoteDataSource',
    );
    final body = _parseJsonBody(response);
    if (response.statusCode == 200 && body != null && body['user'] != null) {
      return SessionModel.fromAuthResponse(body);
    }
    return null;
  });
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) => AuthRemoteDataSource(
  ref.watch(dioProvider),
  ref.watch(secureStorageProvider),
  ref.watch(cookieJarProvider),
);
