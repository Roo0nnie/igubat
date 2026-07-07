import '../../../../core/usecases/result.dart';
import '../entities/notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  FutureResult<NotificationPreferences> getPreferences();

  FutureResult<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  );
}
