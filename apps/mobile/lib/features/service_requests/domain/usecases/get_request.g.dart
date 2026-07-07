// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_request.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getRequestUseCase)
const getRequestUseCaseProvider = GetRequestUseCaseProvider._();

final class GetRequestUseCaseProvider
    extends $FunctionalProvider<GetRequest, GetRequest, GetRequest>
    with $Provider<GetRequest> {
  const GetRequestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRequestUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRequestUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRequest> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetRequest create(Ref ref) {
    return getRequestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRequest>(value),
    );
  }
}

String _$getRequestUseCaseHash() => r'c79c2d1343918fa5c0b72032172995e71a81459d';
