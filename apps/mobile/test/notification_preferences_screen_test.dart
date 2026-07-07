import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/profile/data/repositories/notification_preferences_repository_impl.dart';
import 'package:mobile/features/profile/domain/entities/notification_preferences.dart';
import 'package:mobile/features/profile/domain/repositories/notification_preferences_repository.dart';
import 'package:mobile/features/profile/presentation/screens/notification_preferences_screen.dart';

class _FakeNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  _FakeNotificationPreferencesRepository(this.preferences);

  NotificationPreferences preferences;

  @override
  FutureResult<NotificationPreferences> getPreferences() async =>
      Right(preferences);

  @override
  FutureResult<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    this.preferences = preferences;
    return Right(preferences);
  }
}

void main() {
  testWidgets('shows Discover Gubat notification preference', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPreferencesRepositoryProvider.overrideWithValue(
            _FakeNotificationPreferencesRepository(
              NotificationPreferences.defaults(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const NotificationPreferencesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Discover Gubat updates'), findsOneWidget);
    expect(find.text('Transparency disclosures'), findsOneWidget);
  });
}
