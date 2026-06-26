// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and mutates the citizen's `/me/notifications` inbox. Read-state
/// mutations apply optimistically and roll back on failure.

@ProviderFor(NotificationsController)
const notificationsControllerProvider = NotificationsControllerProvider._();

/// Loads and mutates the citizen's `/me/notifications` inbox. Read-state
/// mutations apply optimistically and roll back on failure.
final class NotificationsControllerProvider
    extends
        $AsyncNotifierProvider<NotificationsController, List<AppNotification>> {
  /// Loads and mutates the citizen's `/me/notifications` inbox. Read-state
  /// mutations apply optimistically and roll back on failure.
  const NotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();
}

String _$notificationsControllerHash() =>
    r'db9aafcc145bdf5fec9b80ec4c05c9045996570b';

/// Loads and mutates the citizen's `/me/notifications` inbox. Read-state
/// mutations apply optimistically and roll back on failure.

abstract class _$NotificationsController
    extends $AsyncNotifier<List<AppNotification>> {
  FutureOr<List<AppNotification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AppNotification>>,
                List<AppNotification>
              >,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Count of unread notifications, derived from [notificationsControllerProvider].
/// Returns 0 while loading or on error so badges never block on the inbox.

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Count of unread notifications, derived from [notificationsControllerProvider].
/// Returns 0 while loading or on error so badges never block on the inbox.

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Count of unread notifications, derived from [notificationsControllerProvider].
  /// Returns 0 while loading or on error so badges never block on the inbox.
  const UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadNotificationCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadNotificationCountHash() =>
    r'89cedb64e1d36704815662c6fd2f1471cdc6efde';
