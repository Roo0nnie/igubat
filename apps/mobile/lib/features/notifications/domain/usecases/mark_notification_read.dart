import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../repositories/notifications_repository.dart';

part 'mark_notification_read.g.dart';

class MarkNotificationRead extends UseCase<Unit, int> {
  MarkNotificationRead(this._repository);

  final NotificationsRepository _repository;

  @override
  FutureResult<Unit> call(int id) => _repository.markRead(id);
}

@riverpod
MarkNotificationRead markNotificationReadUseCase(Ref ref) =>
    MarkNotificationRead(ref.watch(notificationsRepositoryProvider));
