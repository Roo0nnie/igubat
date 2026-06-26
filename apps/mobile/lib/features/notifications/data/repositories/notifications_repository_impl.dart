import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

part 'notifications_repository_impl.g.dart';

class NotificationsRepositoryImpl
    with BaseRepository
    implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  FutureResult<List<AppNotification>> getNotifications() => execute(() async {
    final models = await _remote.list();
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  FutureResult<Unit> markRead(int id) => execute(() async {
    await _remote.markRead(id);
    return unit;
  });

  @override
  FutureResult<Unit> markAllRead() => execute(() async {
    await _remote.markAllRead();
    return unit;
  });
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) =>
    NotificationsRepositoryImpl(
      ref.watch(notificationsRemoteDataSourceProvider),
    );
