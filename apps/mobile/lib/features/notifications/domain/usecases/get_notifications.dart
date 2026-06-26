import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

part 'get_notifications.g.dart';

class GetNotifications extends UseCase<List<AppNotification>, NoParams> {
  GetNotifications(this._repository);

  final NotificationsRepository _repository;

  @override
  FutureResult<List<AppNotification>> call(NoParams params) =>
      _repository.getNotifications();
}

@riverpod
GetNotifications getNotificationsUseCase(Ref ref) =>
    GetNotifications(ref.watch(notificationsRepositoryProvider));
