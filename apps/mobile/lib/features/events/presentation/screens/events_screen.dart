import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

Widget _eventSkeleton(BuildContext context) => const GlassSkeletonCard(imageHeight: 0);

/// Full list of published municipal events, opened from Home's
/// "Upcoming Events → View All".
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return 'To be announced';
    final local = date.toLocal();
    return '${_months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final eventsAsync = ref.watch(eventsListProvider);

    return GlassScaffold(
      title: 'Upcoming Events',
      bottomPadding: false,
      useShellBackground: false,
      onRefresh: () async => ref.refresh(eventsListProvider.future),
      body: eventsAsync.when(
        loading: () => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: LoadingStateView(
            message: 'Loading upcoming events...',
            onRetry: () => ref.invalidate(eventsListProvider),
            skeleton: const GlassSkeletonList(count: 5, itemBuilder: _eventSkeleton),
          ),
        ),
        error: (error, _) => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: ErrorStateView(
            title: 'Unable to load events',
            error: error,
            onRetry: () => ref.invalidate(eventsListProvider),
          ),
        ),
        data: (events) => events.isEmpty
            ? const StateScrollView(
                padding: EdgeInsets.all(24),
                child: EmptyStateView(
                  icon: Icons.event_busy_outlined,
                  title: 'No upcoming events',
                  message: 'Check back soon for community activities.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildEventCard(context, events[index], glass, index),
              ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    Event event,
    GlassTheme glass,
    int index,
  ) {
    final location = (event.location != null && event.location!.isNotEmpty)
        ? event.location!
        : 'To be announced';

    return GlassCard(
      onTap: () => Navigator.push(
        context,
        GlassPageRoute(page: EventDetailScreen(slug: event.slug)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassBadge(label: event.category ?? 'Event', compact: true),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: glass.textOnGlass,
                  ),
                ),
                const SizedBox(height: 8),
                _infoRow(
                  Icons.calendar_today,
                  _formatDate(event.startsAt),
                  glass,
                ),
                const SizedBox(height: 4),
                _infoRow(Icons.location_on_outlined, location, glass),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.secondaryColor,
          ),
        ],
      ),
    ).animate(delay: (index * 40).ms).fadeIn();
  }

  Widget _infoRow(IconData icon, String text, GlassTheme glass) {
    return Row(
      children: [
        Icon(icon, size: 12, color: glass.textOnGlassMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted),
          ),
        ),
      ],
    );
  }
}
