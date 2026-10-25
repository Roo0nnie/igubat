import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/auto_dispose_cache.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import '../../domain/usecases/mark_notification_read.dart';

part 'notifications_provider.g.dart';

/// Loads and mutates the citizen's `/me/notifications` inbox. Read-state
/// mutations apply optimistically and roll back on failure.
@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  Future<List<AppNotification>> build() async {
    final result =
        await ref.read(getNotificationsUseCaseProvider).call(const NoParams());
    final items = result.fold((failure) => throw failure, (value) => value);
    cacheAutoDisposeResult(ref);
    return items;
  }

  /// Marks a single notification read, optimistically updating its row.
  Future<void> markRead(int id) async {
    final previous = state;
    final items = List<AppNotification>.from(state.value ?? const []);
    final index = items.indexWhere((n) => n.id == id);
    if (index == -1 || items[index].isRead) return;

    items[index] = _copyAsRead(items[index]);
    state = AsyncData(items);

    final result =
        await ref.read(markNotificationReadUseCaseProvider).call(id);
    result.fold((_) => state = previous, (_) {});
  }

  /// Marks every notification read, optimistically updating all rows.
  Future<void> markAllRead() async {
    final previous = state;
    final items = (state.value ?? const <AppNotification>[])
        .map((n) => n.isRead ? n : _copyAsRead(n))
        .toList();
    state = AsyncData(items);

    final result = await ref
        .read(markAllNotificationsReadUseCaseProvider)
        .call(const NoParams());
    result.fold((_) => state = previous, (_) {});
  }

  /// Re-fetches the inbox from the backend.
  Future<void> reload() async {
    state = const AsyncLoading();
    final result =
        await ref.read(getNotificationsUseCaseProvider).call(const NoParams());
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData.new,
    );
  }

  AppNotification _copyAsRead(AppNotification n) => AppNotification(
    id: n.id,
    title: n.title,
    body: n.body,
    type: n.type,
    category: n.category,
    isRead: true,
    readAt: n.readAt ?? DateTime.now(),
    metadata: n.metadata,
    createdAt: n.createdAt,
  );
}

/// Count of unread notifications, derived from [notificationsControllerProvider].
/// Returns 0 while loading or on error so badges never block on the inbox.
@riverpod
int unreadNotificationCount(Ref ref) {
  final async = ref.watch(notificationsControllerProvider);
  return async.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
}
