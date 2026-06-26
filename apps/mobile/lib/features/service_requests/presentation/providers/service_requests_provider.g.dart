// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_requests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and mutates the citizen's `/me/requests` list. Mutations refresh
/// optimistically where safe and fall back to a full reload otherwise.

@ProviderFor(ServiceRequestsController)
const serviceRequestsControllerProvider = ServiceRequestsControllerProvider._();

/// Loads and mutates the citizen's `/me/requests` list. Mutations refresh
/// optimistically where safe and fall back to a full reload otherwise.
final class ServiceRequestsControllerProvider
    extends
        $AsyncNotifierProvider<
          ServiceRequestsController,
          List<ServiceRequest>
        > {
  /// Loads and mutates the citizen's `/me/requests` list. Mutations refresh
  /// optimistically where safe and fall back to a full reload otherwise.
  const ServiceRequestsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceRequestsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceRequestsControllerHash();

  @$internal
  @override
  ServiceRequestsController create() => ServiceRequestsController();
}

String _$serviceRequestsControllerHash() =>
    r'96079ee761820d530facd58c0b1745e2689df64c';

/// Loads and mutates the citizen's `/me/requests` list. Mutations refresh
/// optimistically where safe and fall back to a full reload otherwise.

abstract class _$ServiceRequestsController
    extends $AsyncNotifier<List<ServiceRequest>> {
  FutureOr<List<ServiceRequest>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ServiceRequest>>, List<ServiceRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ServiceRequest>>,
                List<ServiceRequest>
              >,
              AsyncValue<List<ServiceRequest>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Loads a single request's detail (with attachments + history) by id.

@ProviderFor(serviceRequestDetail)
const serviceRequestDetailProvider = ServiceRequestDetailFamily._();

/// Loads a single request's detail (with attachments + history) by id.

final class ServiceRequestDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServiceRequest>,
          ServiceRequest,
          FutureOr<ServiceRequest>
        >
    with $FutureModifier<ServiceRequest>, $FutureProvider<ServiceRequest> {
  /// Loads a single request's detail (with attachments + history) by id.
  const ServiceRequestDetailProvider._({
    required ServiceRequestDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'serviceRequestDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceRequestDetailHash();

  @override
  String toString() {
    return r'serviceRequestDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServiceRequest> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServiceRequest> create(Ref ref) {
    final argument = this.argument as int;
    return serviceRequestDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceRequestDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceRequestDetailHash() =>
    r'8012a9789755016e4833bfbd53b41d86bf5a87bc';

/// Loads a single request's detail (with attachments + history) by id.

final class ServiceRequestDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServiceRequest>, int> {
  const ServiceRequestDetailFamily._()
    : super(
        retry: null,
        name: r'serviceRequestDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads a single request's detail (with attachments + history) by id.

  ServiceRequestDetailProvider call(int id) =>
      ServiceRequestDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'serviceRequestDetailProvider';
}
