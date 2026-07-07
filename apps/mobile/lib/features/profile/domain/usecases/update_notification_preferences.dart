import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../entities/notification_preferences.dart';
import '../repositories/notification_preferences_repository.dart';

part 'update_notification_preferences.g.dart';

class UpdateNotificationPreferences
    extends UseCase<NotificationPreferences, NotificationPreferences> {
  UpdateNotificationPreferences(this._repository);

  final NotificationPreferencesRepository _repository;

  @override
  FutureResult<NotificationPreferences> call(NotificationPreferences params) =>
      _repository.updatePreferences(params);
}

@riverpod
UpdateNotificationPreferences updateNotificationPreferencesUseCase(Ref ref) =>
    UpdateNotificationPreferences(
      ref.watch(notificationPreferencesRepositoryProvider),
    );
