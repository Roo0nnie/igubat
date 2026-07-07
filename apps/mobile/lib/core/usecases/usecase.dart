import 'result.dart';

/// A single business action.
///
/// Use cases are the only thing the presentation layer calls; they delegate to
/// a domain repository and return a [FutureResult].
///
/// ```dart
/// class GetMyRequests extends UseCase<List<ServiceRequest>, NoParams> {
///   GetMyRequests(this._repo);
///   final ServiceRequestRepository _repo;
///   @override
///   FutureResult<List<ServiceRequest>> call(NoParams params) => _repo.getMyRequests();
/// }
/// ```
abstract class UseCase<T, Params> {
  const UseCase();

  FutureResult<T> call(Params params);
}

/// A use case whose computation is synchronous.
abstract class SyncUseCase<T, Params> {
  const SyncUseCase();

  Result<T> call(Params params);
}

/// Marker for use cases that take no parameters.
final class NoParams {
  const NoParams();
}
