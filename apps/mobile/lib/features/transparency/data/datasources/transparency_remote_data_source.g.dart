// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transparency_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transparencyRemoteDataSource)
const transparencyRemoteDataSourceProvider =
    TransparencyRemoteDataSourceProvider._();

final class TransparencyRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          TransparencyRemoteDataSource,
          TransparencyRemoteDataSource,
          TransparencyRemoteDataSource
        >
    with $Provider<TransparencyRemoteDataSource> {
  const TransparencyRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transparencyRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transparencyRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TransparencyRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransparencyRemoteDataSource create(Ref ref) {
    return transparencyRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransparencyRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransparencyRemoteDataSource>(value),
    );
  }
}

String _$transparencyRemoteDataSourceHash() =>
    r'e2ea2de120efd5ce20c52a88820f2f92a5de154d';
