import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/entities/notification_preferences.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final prefsAsync = ref.watch(notificationPreferencesControllerProvider);
    final controller = ref.read(
      notificationPreferencesControllerProvider.notifier,
    );

    final preferences = prefsAsync.value ?? NotificationPreferences.defaults();
    final loading = prefsAsync.isLoading;

    Future<void> save(NotificationPreferences next) async {
      final ok = await controller.savePreferences(next);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? 'Notification preferences saved.'
                  : 'Could not save preferences. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    return GlassScaffold(
      title: 'Notification Preferences',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          GlassCard(
            child: Column(
              children: [
                _switchTile(
                  'News and announcements',
                  preferences.news,
                  loading,
                  (value) => save(preferences.copyWith(news: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Service request updates',
                  preferences.serviceRequests,
                  loading,
                  (value) => save(preferences.copyWith(serviceRequests: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Issue report updates',
                  preferences.issueReports,
                  loading,
                  (value) => save(preferences.copyWith(issueReports: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Emergency broadcasts',
                  preferences.emergencyBroadcasts,
                  loading,
                  (value) =>
                      save(preferences.copyWith(emergencyBroadcasts: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Discover Gubat updates',
                  preferences.discoverGubat,
                  loading,
                  (value) => save(preferences.copyWith(discoverGubat: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Transparency disclosures',
                  preferences.transparency,
                  loading,
                  (value) => save(preferences.copyWith(transparency: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Push notifications',
                  preferences.pushEnabled,
                  loading,
                  (value) => save(preferences.copyWith(pushEnabled: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Email notifications',
                  preferences.emailEnabled,
                  loading,
                  (value) => save(preferences.copyWith(emailEnabled: value)),
                  glass,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(
    String title,
    bool value,
    bool disabled,
    ValueChanged<bool> onChanged,
    GlassTheme glass,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(color: glass.textOnGlass, fontSize: 14),
        ),
        value: value,
        activeTrackColor: AppTheme.secondaryColor,
        onChanged: disabled ? null : onChanged,
      ),
    );
  }

  Widget _divider(GlassTheme glass) => Divider(height: 1, color: glass.border);
}
