// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notification_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getNotificationPreferencesUseCase)
const getNotificationPreferencesUseCaseProvider =
    GetNotificationPreferencesUseCaseProvider._();

final class GetNotificationPreferencesUseCaseProvider
    extends
        $FunctionalProvider<
          GetNotificationPreferences,
          GetNotificationPreferences,
          GetNotificationPreferences
        >
    with $Provider<GetNotificationPreferences> {
  const GetNotificationPreferencesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNotificationPreferencesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getNotificationPreferencesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetNotificationPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetNotificationPreferences create(Ref ref) {
    return getNotificationPreferencesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetNotificationPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetNotificationPreferences>(value),
    );
  }
}

String _$getNotificationPreferencesUseCaseHash() =>
    r'e0194d40e1fabfdbd0905af1bb6bf5c00fbb2903';
