// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_requests_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceRequestsRemoteDataSource)
const serviceRequestsRemoteDataSourceProvider =
    ServiceRequestsRemoteDataSourceProvider._();

final class ServiceRequestsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ServiceRequestsRemoteDataSource,
          ServiceRequestsRemoteDataSource,
          ServiceRequestsRemoteDataSource
        >
    with $Provider<ServiceRequestsRemoteDataSource> {
  const ServiceRequestsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceRequestsRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceRequestsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServiceRequestsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceRequestsRemoteDataSource create(Ref ref) {
    return serviceRequestsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceRequestsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceRequestsRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$serviceRequestsRemoteDataSourceHash() =>
    r'fb28552f30dbfabfc589a3a17f3ec960b294c73c';
