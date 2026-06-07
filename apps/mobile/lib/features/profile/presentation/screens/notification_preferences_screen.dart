import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _news = true;
  bool _requests = true;
  bool _reports = true;
  bool _emergency = true;
  bool _push = true;
  bool _email = true;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Notification Preferences',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            child: Column(
              children: [
                _switchTile('News and announcements', _news, (value) => setState(() => _news = value), glass),
                _switchTile('Service request updates', _requests, (value) => setState(() => _requests = value), glass),
                _switchTile('Issue report updates', _reports, (value) => setState(() => _reports = value), glass),
                _switchTile('Emergency broadcasts', _emergency, (value) => setState(() => _emergency = value), glass),
                _switchTile('Push notifications', _push, (value) => setState(() => _push = value), glass),
                _switchTile('Email notifications', _email, (value) => setState(() => _email = value), glass),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged, GlassTheme glass) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: glass.textOnGlass, fontSize: 14)),
      value: value,
      activeTrackColor: AppTheme.secondaryColor,
      onChanged: onChanged,
    );
  }
}
