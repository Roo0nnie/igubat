import '../../../../core/usecases/result.dart';
import '../entities/app_notification.dart';

/// Notifications contract. Implemented in
/// `data/repositories/notifications_repository_impl.dart`.
abstract interface class NotificationsRepository {
  FutureResult<List<AppNotification>> getNotifications();

  FutureResult<Unit> markRead(int id);

  FutureResult<Unit> markAllRead();
}
