// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_service_types.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getServiceTypesUseCase)
const getServiceTypesUseCaseProvider = GetServiceTypesUseCaseProvider._();

final class GetServiceTypesUseCaseProvider
    extends
        $FunctionalProvider<GetServiceTypes, GetServiceTypes, GetServiceTypes>
    with $Provider<GetServiceTypes> {
  const GetServiceTypesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getServiceTypesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getServiceTypesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetServiceTypes> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetServiceTypes create(Ref ref) {
    return getServiceTypesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetServiceTypes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetServiceTypes>(value),
    );
  }
}

String _$getServiceTypesUseCaseHash() =>
    r'929f334bea573bc91db7cffbd581236b4c41d7d5';
