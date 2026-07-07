// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getProfileUseCase)
const getProfileUseCaseProvider = GetProfileUseCaseProvider._();

final class GetProfileUseCaseProvider
    extends $FunctionalProvider<GetProfile, GetProfile, GetProfile>
    with $Provider<GetProfile> {
  const GetProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetProfile create(Ref ref) {
    return getProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProfile>(value),
    );
  }
}

String _$getProfileUseCaseHash() => r'a707773df09928ef6e36a02f1f53db2ddab99cf3';
