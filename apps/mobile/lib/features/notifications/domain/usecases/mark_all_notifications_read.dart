import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../repositories/notifications_repository.dart';

part 'mark_all_notifications_read.g.dart';

class MarkAllNotificationsRead extends UseCase<Unit, NoParams> {
  MarkAllNotificationsRead(this._repository);

  final NotificationsRepository _repository;

  @override
  FutureResult<Unit> call(NoParams params) => _repository.markAllRead();
}

@riverpod
MarkAllNotificationsRead markAllNotificationsReadUseCase(Ref ref) =>
    MarkAllNotificationsRead(ref.watch(notificationsRepositoryProvider));
