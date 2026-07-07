// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transparency_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transparencyRepository)
const transparencyRepositoryProvider = TransparencyRepositoryProvider._();

final class TransparencyRepositoryProvider
    extends
        $FunctionalProvider<
          TransparencyRepository,
          TransparencyRepository,
          TransparencyRepository
        >
    with $Provider<TransparencyRepository> {
  const TransparencyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transparencyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transparencyRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransparencyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransparencyRepository create(Ref ref) {
    return transparencyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransparencyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransparencyRepository>(value),
    );
  }
}

String _$transparencyRepositoryHash() =>
    r'e7fd15c5982424f9f678810eb3b68bf512eb4975';
