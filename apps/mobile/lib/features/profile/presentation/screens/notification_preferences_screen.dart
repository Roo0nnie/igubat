import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/repositories/notification_preferences_repository.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  NotificationPreferences _preferences = NotificationPreferences.defaults();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPreferences);
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await ref
          .read(notificationPreferencesRepositoryProvider)
          .fetch();
      if (!mounted) return;
      setState(() {
        _preferences = preferences;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar('Could not load saved preferences. Showing defaults.');
    }
  }

  Future<void> _savePreferences(NotificationPreferences next) async {
    final previous = _preferences;
    setState(() {
      _preferences = next;
      _saving = true;
    });

    try {
      final saved = await ref
          .read(notificationPreferencesRepositoryProvider)
          .update(next);
      if (!mounted) return;
      setState(() => _preferences = saved);
      _showSnackBar('Notification preferences saved.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _preferences = previous);
      _showSnackBar('Could not save preferences. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final disabled = _loading || _saving;

    return GlassScaffold(
      title: 'Notification Preferences',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          GlassCard(
            child: Column(
              children: [
                _switchTile(
                  'News and announcements',
                  _preferences.news,
                  disabled,
                  (value) =>
                      _savePreferences(_preferences.copyWith(news: value)),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Service request updates',
                  _preferences.serviceRequests,
                  disabled,
                  (value) => _savePreferences(
                    _preferences.copyWith(serviceRequests: value),
                  ),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Issue report updates',
                  _preferences.issueReports,
                  disabled,
                  (value) => _savePreferences(
                    _preferences.copyWith(issueReports: value),
                  ),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Emergency broadcasts',
                  _preferences.emergencyBroadcasts,
                  disabled,
                  (value) => _savePreferences(
                    _preferences.copyWith(emergencyBroadcasts: value),
                  ),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Transparency disclosures',
                  _preferences.transparency,
                  disabled,
                  (value) => _savePreferences(
                    _preferences.copyWith(transparency: value),
                  ),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Push notifications',
                  _preferences.pushEnabled,
                  disabled,
                  (value) => _savePreferences(
                    _preferences.copyWith(pushEnabled: value),
                  ),
                  glass,
                ),
                _divider(glass),
                _switchTile(
                  'Email notifications',
                  _preferences.emailEnabled,
                  disabled,
                  (value) => _savePreferences(
                    _preferences.copyWith(emailEnabled: value),
                  ),
                  glass,
                ),
              ],
            ),
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                'Saving changes...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: glass.textOnGlass, fontSize: 14),
      ),
      value: value,
      activeTrackColor: AppTheme.secondaryColor,
      onChanged: disabled ? null : onChanged,
    );
  }

  Widget _divider(GlassTheme glass) => Divider(height: 1, color: glass.border);
}
