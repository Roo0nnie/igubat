import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../entities/notification_preferences.dart';
import '../repositories/notification_preferences_repository.dart';

part 'get_notification_preferences.g.dart';

class GetNotificationPreferences
    extends UseCase<NotificationPreferences, NoParams> {
  GetNotificationPreferences(this._repository);

  final NotificationPreferencesRepository _repository;

  @override
  FutureResult<NotificationPreferences> call(NoParams params) =>
      _repository.getPreferences();
}

@riverpod
GetNotificationPreferences getNotificationPreferencesUseCase(Ref ref) =>
    GetNotificationPreferences(
      ref.watch(notificationPreferencesRepositoryProvider),
    );
