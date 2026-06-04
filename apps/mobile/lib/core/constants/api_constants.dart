import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static String get versionedUrl => '$baseUrl/$apiVersion';

  // Auth endpoints (Better Auth - no envelope)
  static String get signIn => '$versionedUrl/auth/sign-in/email';
  static String get signUp => '$versionedUrl/auth/sign-up/email';
  static String get signOut => '$versionedUrl/auth/sign-out';
  static String get getSession => '$versionedUrl/auth/get-session';

  // Email OTP verification (Better Auth emailOTP plugin - no envelope).
  // `sendVerificationOtp` (re)dispatches a code; `verifyEmailOtp` validates it
  // server-side and establishes the authenticated session.
  static String get sendVerificationOtp =>
      '$versionedUrl/auth/email-otp/send-verification-otp';
  static String get verifyEmailOtp => '$versionedUrl/auth/email-otp/verify-email';

  // Todo endpoints (NestJS - oRPC)
  static String get todos => '$versionedUrl/example/todos';
  static String todoById(int id) => '$versionedUrl/example/todos/$id';
}
