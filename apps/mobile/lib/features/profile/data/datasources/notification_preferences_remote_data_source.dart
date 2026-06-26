import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_preferences_model.dart';

part 'notification_preferences_remote_data_source.g.dart';

class NotificationPreferencesRemoteDataSource with BaseRemoteDataSource {
  NotificationPreferencesRemoteDataSource(this._client);

  final DioClient _client;

  Future<NotificationPreferencesModel> fetch() => guard(
    () => _client.getOne(
      ApiConstants.notificationPreferences,
      NotificationPreferencesModel.fromJson,
    ),
  );

  Future<NotificationPreferencesModel> update(
    NotificationPreferencesModel preferences,
  ) => guard(
    () => _client.patch(
      ApiConstants.notificationPreferences,
      NotificationPreferencesModel.fromJson,
      data: preferences.toJson(),
    ),
  );
}

@riverpod
NotificationPreferencesRemoteDataSource notificationPreferencesRemoteDataSource(
  Ref ref,
) => NotificationPreferencesRemoteDataSource(ref.watch(dioClientProvider));
