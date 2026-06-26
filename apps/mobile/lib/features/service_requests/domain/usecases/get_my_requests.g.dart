// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_my_requests.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getMyRequestsUseCase)
const getMyRequestsUseCaseProvider = GetMyRequestsUseCaseProvider._();

final class GetMyRequestsUseCaseProvider
    extends $FunctionalProvider<GetMyRequests, GetMyRequests, GetMyRequests>
    with $Provider<GetMyRequests> {
  const GetMyRequestsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyRequestsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyRequestsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyRequests> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetMyRequests create(Ref ref) {
    return getMyRequestsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyRequests value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyRequests>(value),
    );
  }
}

String _$getMyRequestsUseCaseHash() =>
    r'ced44783b942b3e023491c57a03966839291922c';
