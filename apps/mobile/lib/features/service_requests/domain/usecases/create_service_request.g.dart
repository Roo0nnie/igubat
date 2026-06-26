// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_service_request.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createServiceRequestUseCase)
const createServiceRequestUseCaseProvider =
    CreateServiceRequestUseCaseProvider._();

final class CreateServiceRequestUseCaseProvider
    extends
        $FunctionalProvider<
          CreateServiceRequest,
          CreateServiceRequest,
          CreateServiceRequest
        >
    with $Provider<CreateServiceRequest> {
  const CreateServiceRequestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createServiceRequestUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createServiceRequestUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateServiceRequest> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateServiceRequest create(Ref ref) {
    return createServiceRequestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateServiceRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateServiceRequest>(value),
    );
  }
}

String _$createServiceRequestUseCaseHash() =>
    r'48d6a78d94e35fe3e2747edfe309abac3d38b553';
