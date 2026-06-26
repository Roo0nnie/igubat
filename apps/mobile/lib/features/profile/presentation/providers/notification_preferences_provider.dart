import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/usecases/get_notification_preferences.dart';
import '../../domain/usecases/update_notification_preferences.dart';

part 'notification_preferences_provider.g.dart';

/// Holds the citizen's notification preferences. Falls back to defaults when
/// the network and cache are both unavailable; updates optimistically and rolls
/// back on failure.
@riverpod
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  @override
  Future<NotificationPreferences> build() async {
    final result = await ref
        .read(getNotificationPreferencesUseCaseProvider)
        .call(const NoParams());
    return result.fold(
      (_) => NotificationPreferences.defaults(),
      (preferences) => preferences,
    );
  }

  /// Persists [next]. Returns `true` on success. Optimistically reflects [next]
  /// and rolls back to the prior value on failure.
  Future<bool> savePreferences(NotificationPreferences next) async {
    final previous = state;
    state = AsyncData(next);
    final result = await ref
        .read(updateNotificationPreferencesUseCaseProvider)
        .call(next);
    return result.fold(
      (_) {
        state = previous;
        return false;
      },
      (saved) {
        state = AsyncData(saved);
        return true;
      },
    );
  }
}
