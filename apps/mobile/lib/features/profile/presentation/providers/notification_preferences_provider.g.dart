// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the citizen's notification preferences. Falls back to defaults when
/// the network and cache are both unavailable; updates optimistically and rolls
/// back on failure.

@ProviderFor(NotificationPreferencesController)
const notificationPreferencesControllerProvider =
    NotificationPreferencesControllerProvider._();

/// Holds the citizen's notification preferences. Falls back to defaults when
/// the network and cache are both unavailable; updates optimistically and rolls
/// back on failure.
final class NotificationPreferencesControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationPreferencesController,
          NotificationPreferences
        > {
  /// Holds the citizen's notification preferences. Falls back to defaults when
  /// the network and cache are both unavailable; updates optimistically and rolls
  /// back on failure.
  const NotificationPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesControllerHash();

  @$internal
  @override
  NotificationPreferencesController create() =>
      NotificationPreferencesController();
}

String _$notificationPreferencesControllerHash() =>
    r'db4b7bbc36abdb8c44117572a529f0f428fd83a2';

/// Holds the citizen's notification preferences. Falls back to defaults when
/// the network and cache are both unavailable; updates optimistically and rolls
/// back on failure.

abstract class _$NotificationPreferencesController
    extends $AsyncNotifier<NotificationPreferences> {
  FutureOr<NotificationPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<NotificationPreferences>,
              NotificationPreferences
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationPreferences>,
                NotificationPreferences
              >,
              AsyncValue<NotificationPreferences>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
