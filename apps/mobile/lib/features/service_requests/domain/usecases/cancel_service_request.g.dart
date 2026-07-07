// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_service_request.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cancelServiceRequestUseCase)
const cancelServiceRequestUseCaseProvider =
    CancelServiceRequestUseCaseProvider._();

final class CancelServiceRequestUseCaseProvider
    extends
        $FunctionalProvider<
          CancelServiceRequest,
          CancelServiceRequest,
          CancelServiceRequest
        >
    with $Provider<CancelServiceRequest> {
  const CancelServiceRequestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelServiceRequestUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelServiceRequestUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelServiceRequest> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelServiceRequest create(Ref ref) {
    return cancelServiceRequestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelServiceRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelServiceRequest>(value),
    );
  }
}

String _$cancelServiceRequestUseCaseHash() =>
    r'93644ce37a028e9cba79f7dcdaa98149717d0abc';
