/// Backward-compatibility shim.
///
/// The Dio client + cookie interceptors moved to `core/network/` as part of the
/// clean-architecture refactor. This re-export keeps not-yet-migrated callers
/// (`*_repository.dart`) compiling until they switch to `core/network/...`.
/// Remove once nothing imports this path.
library;

export '../../core/network/dio_factory.dart'
    show ApiClient, createApiClient, dioProvider, cookieJarProvider;
