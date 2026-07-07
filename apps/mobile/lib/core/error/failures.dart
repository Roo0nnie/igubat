/// Domain-layer failures.
///
/// These are the ONLY error type the presentation layer should ever see.
/// Data-layer [AppException]s are mapped into [Failure]s at the repository
/// boundary (see `core/error/error_mapper.dart`).
library;

/// Base type for every recoverable error surfaced to the domain/presentation.
sealed class Failure {
  const Failure(this.message, {this.code, this.details});

  /// Human-readable message safe to show in the UI.
  final String message;

  /// Optional machine code (e.g. the backend error code).
  final String? code;

  /// Optional structured details (validation payloads, etc.).
  final Object? details;

  @override
  String toString() => '$runtimeType($message, code: $code)';
}

/// 5xx, unexpected 4xx, or contract/parse problems the user can't fix.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

/// No connectivity, timeouts, TLS issues — the UI should offer a retry.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

/// 401/403 — the UI may force a re-login.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

/// 400/422 — the UI can map [fieldErrors] back onto form inputs.
class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors,
    super.code,
    super.details,
  });

  final Map<String, List<String>>? fieldErrors;
}

/// Local cache (SharedPreferences / file) read/write failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}

/// 404 — useful for detail screens to render a dedicated empty state.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.details});
}

/// Anything that didn't map to a more specific failure.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.details});
}
