/// Data-layer exceptions.
///
/// Thrown by data sources (remote/local). They never escape the repository:
/// `BaseRepository.execute` catches them and maps them to a [Failure].
library;

/// Base type for every exception raised inside the data layer.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.code, this.details});

  final String message;

  /// HTTP status when the exception originated from a response.
  final int? statusCode;

  /// Backend `error.code` (NestJS exception class name) when present.
  final String? code;

  /// Structured details (validation field errors, etc.).
  final Object? details;

  @override
  String toString() => '$runtimeType($message, status: $statusCode)';
}

/// 5xx or otherwise unclassified server response.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.code, super.details});
}

/// 404.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode, super.code, super.details});
}

/// 400 / 422 — carries field-level details when the backend provides them.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode, super.code, super.details});
}

/// 401 / 403.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode, super.code, super.details});
}

/// Connectivity / timeout / cancelled — no usable response.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.code, super.details});
}

/// Local cache read/write problem.
class CacheException extends AppException {
  const CacheException(super.message, {super.statusCode, super.code, super.details});
}

/// `fromJson` / `FormatException` / `TypeError` while decoding a payload.
class ParsingException extends AppException {
  const ParsingException(super.message, {super.statusCode, super.code, super.details});
}
