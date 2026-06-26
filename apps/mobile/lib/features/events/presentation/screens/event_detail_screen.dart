import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.slug});

  final String slug;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return 'To be announced';
    final local = date.toLocal();
    return '${_months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final eventAsync = ref.watch(eventDetailProvider(slug));

    return GlassScaffold(
      title: 'Event Details',
      bottomPadding: false,
      useShellBackground: false,
      body: eventAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 80),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Could not load this event. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: glass.textOnGlassMuted),
            ),
          ),
        ),
        data: (event) => _buildContent(context, event, glass),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Event event, GlassTheme glass) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        GlassCard(
          intensity: GlassIntensity.prominent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassBadge(
                label: event.category ?? 'Event',
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                event.title,
                style: TextStyle(color: glass.textOnGlass, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow(
                Icons.calendar_today,
                'Date',
                _formatDate(event.startsAt),
                glass,
              ),
              if (event.endsAt != null) ...[
                const SizedBox(height: 12),
                _detailRow(
                  Icons.event_available_outlined,
                  'Ends',
                  _formatDate(event.endsAt),
                  glass,
                ),
              ],
              const SizedBox(height: 12),
              _detailRow(
                Icons.location_on_outlined,
                'Location',
                (event.location != null && event.location!.isNotEmpty)
                    ? event.location!
                    : 'To be announced',
                glass,
              ),
              const SizedBox(height: 20),
              Text(
                event.description.isNotEmpty
                    ? event.description
                    : 'This event is published by the Municipality of Gubat. Follow official LGU channels for final venue updates and reminders.',
                style: TextStyle(color: glass.textOnGlassMuted, height: 1.5),
              ),
            ],
          ),
        ),
      ],
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
