import '../error/error_mapper.dart';
import '../error/exceptions.dart';
import '../usecases/result.dart';

/// Mixin for repository implementations. `execute` turns a data-source call
/// (which may throw [AppException]) into an `Either<Failure, T>`, with an
/// optional cache fallback.
///
/// This generalises the ad-hoc `try { remote } catch { cached ?? seed }`
/// pattern previously hand-written in the transparency/notification repos.
mixin BaseRepository {
  /// Runs [call]; on failure, optionally tries [cache] before mapping the
  /// exception to a [Failure].
  FutureResult<T> execute<T>(
    Future<T> Function() call, {
    Future<T?> Function()? cache,
  }) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      if (cache != null) {
        try {
          final cached = await cache();
          if (cached != null) return Right(cached);
        } on AppException {
          // fall through to the original failure
        }
      }
      return Left(mapExceptionToFailure(e));
    }
  }
}
