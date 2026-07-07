import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/profile/data/repositories/notification_preferences_repository.dart';
import 'package:mobile/features/profile/presentation/screens/notification_preferences_screen.dart';

class _FakeNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  _FakeNotificationPreferencesRepository(this.preferences);

  NotificationPreferences preferences;

  @override
  Future<NotificationPreferences> fetch() async => preferences;

  @override
  Future<NotificationPreferences> update(
    NotificationPreferences preferences,
  ) async {
    this.preferences = preferences;
    return preferences;
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
