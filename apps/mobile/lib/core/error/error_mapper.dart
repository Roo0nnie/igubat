import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Maps a raw [DioException] (or any error caught in a data source) into a
/// typed [AppException].
///
/// Branching is by **HTTP status**, not by the backend `error.code` string —
/// the backend sets `error.code` to the NestJS exception class name
/// (`http-exception.filter.ts`), which is implementation-coupled and may change.
///
/// The error envelope used by the iGubat/NestJS backend is:
/// ```json
/// { "success": false, "error": { "code": "...", "message": "...", "details": ... }, "timestamp": "..." }
/// ```
/// Better Auth (`/auth/*`) instead returns un-enveloped errors like
/// `{ "message": "..." }` (sometimes `{ "code", "message" }`), so we fall back
/// to those shapes when the standard envelope is absent.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException('No connection. Please try again.');
    case DioExceptionType.badCertificate:
      return const NetworkException('Secure connection failed.');
    case DioExceptionType.cancel:
      return const NetworkException('Request was cancelled.');
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      final response = e.response;
      final status = response?.statusCode ?? 0;
      final data = response?.data;

      final envelope = (data is Map && data['error'] is Map)
          ? data['error'] as Map
          : null;
      final message =
          envelope?['message']?.toString() ??
          _rawMessage(data) ??
          e.message ??
          'Unexpected error occurred.';
      final code = envelope?['code']?.toString();
      final details = envelope?['details'];

      return switch (status) {
        400 || 422 => ValidationException(
          message,
          statusCode: status,
          code: code,
          details: details,
        ),
        401 || 403 => UnauthorizedException(message, statusCode: status, code: code),
        404 => NotFoundException(message, statusCode: status, code: code),
        _ => ServerException(message, statusCode: status, code: code, details: details),
      };
  }
}

/// Extracts a message from a non-enveloped Better Auth error body.
String? _rawMessage(Object? data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}

/// Maps a data-layer [AppException] into the domain [Failure] the UI consumes.
Failure mapExceptionToFailure(AppException e) {
  return switch (e) {
    NetworkException() => NetworkFailure(e.message, code: e.code),
    UnauthorizedException() => AuthFailure(e.message, code: e.code),
    ValidationException() => ValidationFailure(
      e.message,
      fieldErrors: _coerceFieldErrors(e.details),
      code: e.code,
      details: e.details,
    ),
    NotFoundException() => NotFoundFailure(e.message, code: e.code),
    CacheException() => CacheFailure(e.message, code: e.code),
    // A bad contract is, to the user, a server-side problem.
    ParsingException() => ServerFailure(e.message, code: e.code),
    ServerException() => ServerFailure(e.message, code: e.code, details: e.details),
  };
}

/// Best-effort coercion of a backend validation `details` payload into a
/// `field -> [messages]` map. Returns null when the shape is unrecognised.
Map<String, List<String>>? _coerceFieldErrors(Object? details) {
  if (details is! Map) return null;
  final result = <String, List<String>>{};
  details.forEach((key, value) {
    final field = key.toString();
    if (value is List) {
      result[field] = value.map((e) => e.toString()).toList();
    } else if (value != null) {
      result[field] = [value.toString()];
    }
  });
  return result.isEmpty ? null : result;
}
