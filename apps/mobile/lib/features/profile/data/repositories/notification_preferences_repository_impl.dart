import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../datasources/notification_preferences_local_data_source.dart';
import '../datasources/notification_preferences_remote_data_source.dart';
import '../models/notification_preferences_model.dart';

part 'notification_preferences_repository_impl.g.dart';

class NotificationPreferencesRepositoryImpl
    with BaseRepository
    implements NotificationPreferencesRepository {
  NotificationPreferencesRepositoryImpl(this._remote, this._local);

  final NotificationPreferencesRemoteDataSource _remote;
  final NotificationPreferencesLocalDataSource _local;

  @override
  FutureResult<NotificationPreferences> getPreferences() => execute(
    () async {
      final model = await _remote.fetch();
      await _local.write(model);
      return model.toEntity();
    },
    cache: () async => _local.read()?.toEntity(),
  );

  @override
  FutureResult<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) => execute(() async {
    final saved = await _remote.update(
      NotificationPreferencesModel.fromEntity(preferences),
    );
    await _local.write(saved);
    return saved.toEntity();
  });
}

@riverpod
NotificationPreferencesRepository notificationPreferencesRepository(Ref ref) =>
    NotificationPreferencesRepositoryImpl(
      ref.watch(notificationPreferencesRemoteDataSourceProvider),
      ref.watch(notificationPreferencesLocalDataSourceProvider),
    );
