// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_requests_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceRequestsRepository)
const serviceRequestsRepositoryProvider = ServiceRequestsRepositoryProvider._();

final class ServiceRequestsRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceRequestsRepository,
          ServiceRequestsRepository,
          ServiceRequestsRepository
        >
    with $Provider<ServiceRequestsRepository> {
  const ServiceRequestsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceRequestsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceRequestsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceRequestsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceRequestsRepository create(Ref ref) {
    return serviceRequestsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceRequestsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceRequestsRepository>(value),
    );
  }
}

String _$serviceRequestsRepositoryHash() =>
    r'cbf4879b17f180acb0c4997900a92c682823b233';
