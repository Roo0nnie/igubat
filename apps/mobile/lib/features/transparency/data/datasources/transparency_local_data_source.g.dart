// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transparency_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transparencyLocalDataSource)
const transparencyLocalDataSourceProvider =
    TransparencyLocalDataSourceProvider._();

final class TransparencyLocalDataSourceProvider
    extends
        $FunctionalProvider<
          TransparencyLocalDataSource,
          TransparencyLocalDataSource,
          TransparencyLocalDataSource
        >
    with $Provider<TransparencyLocalDataSource> {
  const TransparencyLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transparencyLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transparencyLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<TransparencyLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransparencyLocalDataSource create(Ref ref) {
    return transparencyLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransparencyLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransparencyLocalDataSource>(value),
    );
  }
}

String _$transparencyLocalDataSourceHash() =>
    r'b37dd1f5cc9f426b9cd448fbd0ea68f2a820b545';
