// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(servicesRemoteDataSource)
const servicesRemoteDataSourceProvider = ServicesRemoteDataSourceProvider._();

final class ServicesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ServicesRemoteDataSource,
          ServicesRemoteDataSource,
          ServicesRemoteDataSource
        >
    with $Provider<ServicesRemoteDataSource> {
  const ServicesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicesRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServicesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServicesRemoteDataSource create(Ref ref) {
    return servicesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServicesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServicesRemoteDataSource>(value),
    );
  }
}

String _$servicesRemoteDataSourceHash() =>
    r'ff5129cf1132ec8b5686413c9c1a9b69487969a6';
