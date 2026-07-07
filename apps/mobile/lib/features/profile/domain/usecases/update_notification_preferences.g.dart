// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_notification_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateNotificationPreferencesUseCase)
const updateNotificationPreferencesUseCaseProvider =
    UpdateNotificationPreferencesUseCaseProvider._();

final class UpdateNotificationPreferencesUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateNotificationPreferences,
          UpdateNotificationPreferences,
          UpdateNotificationPreferences
        >
    with $Provider<UpdateNotificationPreferences> {
  const UpdateNotificationPreferencesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateNotificationPreferencesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$updateNotificationPreferencesUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateNotificationPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateNotificationPreferences create(Ref ref) {
    return updateNotificationPreferencesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateNotificationPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateNotificationPreferences>(
        value,
      ),
    );
  }
}

String _$updateNotificationPreferencesUseCaseHash() =>
    r'5892d5862a95ed5a8237afaa51ac2f39f95aff67';
