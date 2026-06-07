import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final UpcomingEvent event;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Event Details',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            intensity: GlassIntensity.prominent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassBadge(label: event.category, color: AppTheme.secondaryColor),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: TextStyle(color: glass.textOnGlass, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _detailRow(Icons.calendar_today, 'Date', event.date, glass),
                const SizedBox(height: 12),
                _detailRow(Icons.location_on_outlined, 'Location', event.location, glass),
                const SizedBox(height: 20),
                Text(
                  'This event is published by the Municipality of Gubat. Follow official LGU channels for final venue updates and reminders.',
                  style: TextStyle(color: glass.textOnGlassMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, GlassTheme glass) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryColor),
        const SizedBox(width: 10),
        SizedBox(width: 72, child: Text(label, style: TextStyle(color: glass.textOnGlassMuted))),
        Expanded(child: Text(value, style: TextStyle(color: glass.textOnGlass, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
