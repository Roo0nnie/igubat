import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/app_notification_model.dart';

part 'notifications_remote_data_source.g.dart';

/// Talks to the citizen `/me/notifications` endpoints. Returns
/// [AppNotificationModel] DTOs.
class NotificationsRemoteDataSource with BaseRemoteDataSource {
  NotificationsRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<AppNotificationModel>> list() => guard(
    () => _client.getList(
      ApiConstants.notifications,
      AppNotificationModel.fromJson,
    ),
  );

  Future<void> markRead(int id) =>
      guard(() => _client.postVoid(ApiConstants.markNotificationRead(id)));

  Future<void> markAllRead() =>
      guard(() => _client.postVoid(ApiConstants.markAllNotificationsRead));
}

@riverpod
NotificationsRemoteDataSource notificationsRemoteDataSource(Ref ref) =>
    NotificationsRemoteDataSource(ref.watch(dioClientProvider));
