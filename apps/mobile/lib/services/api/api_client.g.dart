// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [Dio].
///
/// Overridden in main.dart with an eagerly created instance so the client
/// is available synchronously via `ref.read`.

@ProviderFor(dio)
const dioProvider = DioProvider._();

/// Provider for [Dio].
///
/// Overridden in main.dart with an eagerly created instance so the client
/// is available synchronously via `ref.read`.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provider for [Dio].
  ///
  /// Overridden in main.dart with an eagerly created instance so the client
  /// is available synchronously via `ref.read`.
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'2ef0206054767ce9629e26a8223f386ed0a3475d';

/// Provider for the persistent [PersistCookieJar] used by [dio].
///
/// Overridden in main.dart alongside [dioProvider].

@ProviderFor(cookieJar)
const cookieJarProvider = CookieJarProvider._();

/// Provider for the persistent [PersistCookieJar] used by [dio].
///
/// Overridden in main.dart alongside [dioProvider].

final class CookieJarProvider
    extends
        $FunctionalProvider<
          PersistCookieJar,
          PersistCookieJar,
          PersistCookieJar
        >
    with $Provider<PersistCookieJar> {
  /// Provider for the persistent [PersistCookieJar] used by [dio].
  ///
  /// Overridden in main.dart alongside [dioProvider].
  const CookieJarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cookieJarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cookieJarHash();

  @$internal
  @override
  $ProviderElement<PersistCookieJar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PersistCookieJar create(Ref ref) {
    return cookieJar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PersistCookieJar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PersistCookieJar>(value),
    );
  }
}

String _$cookieJarHash() => r'1c4c46cda5b35f4ad4ab8572b2ac640901a3ded8';
