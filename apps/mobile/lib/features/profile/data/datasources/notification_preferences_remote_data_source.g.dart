// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationPreferencesRemoteDataSource)
const notificationPreferencesRemoteDataSourceProvider =
    NotificationPreferencesRemoteDataSourceProvider._();

final class NotificationPreferencesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationPreferencesRemoteDataSource,
          NotificationPreferencesRemoteDataSource,
          NotificationPreferencesRemoteDataSource
        >
    with $Provider<NotificationPreferencesRemoteDataSource> {
  const NotificationPreferencesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationPreferencesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPreferencesRemoteDataSource create(Ref ref) {
    return notificationPreferencesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferencesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<NotificationPreferencesRemoteDataSource>(value),
    );
  }
}

String _$notificationPreferencesRemoteDataSourceHash() =>
    r'96e9ff89e651d3d4f5e68d8f3ca0f2687f33dc30';
