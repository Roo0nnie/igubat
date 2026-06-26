// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateProfileUseCase)
const updateProfileUseCaseProvider = UpdateProfileUseCaseProvider._();

final class UpdateProfileUseCaseProvider
    extends $FunctionalProvider<UpdateProfile, UpdateProfile, UpdateProfile>
    with $Provider<UpdateProfile> {
  const UpdateProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProfile create(Ref ref) {
    return updateProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfile>(value),
    );
  }
}

String _$updateProfileUseCaseHash() =>
    r'6cddabec5a36250ecde72577ac28cdbd8c47212a';
