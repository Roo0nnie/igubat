// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_emergency_directory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getEmergencyDirectoryUseCase)
const getEmergencyDirectoryUseCaseProvider =
    GetEmergencyDirectoryUseCaseProvider._();

final class GetEmergencyDirectoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetEmergencyDirectory,
          GetEmergencyDirectory,
          GetEmergencyDirectory
        >
    with $Provider<GetEmergencyDirectory> {
  const GetEmergencyDirectoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getEmergencyDirectoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getEmergencyDirectoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetEmergencyDirectory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetEmergencyDirectory create(Ref ref) {
    return getEmergencyDirectoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetEmergencyDirectory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetEmergencyDirectory>(value),
    );
  }
}

String _$getEmergencyDirectoryUseCaseHash() =>
    r'7885251595aeee25e8347a4269649b3b47e6f8b2';
