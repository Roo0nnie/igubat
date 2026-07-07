// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationPreferencesLocalDataSource)
const notificationPreferencesLocalDataSourceProvider =
    NotificationPreferencesLocalDataSourceProvider._();

final class NotificationPreferencesLocalDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationPreferencesLocalDataSource,
          NotificationPreferencesLocalDataSource,
          NotificationPreferencesLocalDataSource
        >
    with $Provider<NotificationPreferencesLocalDataSource> {
  const NotificationPreferencesLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationPreferencesLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPreferencesLocalDataSource create(Ref ref) {
    return notificationPreferencesLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferencesLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<NotificationPreferencesLocalDataSource>(value),
    );
  }
}

String _$notificationPreferencesLocalDataSourceHash() =>
    r'0f4645f62f45c837979f7c5e9827064725e342d7';
