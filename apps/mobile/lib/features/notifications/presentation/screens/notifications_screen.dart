import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_category.dart';
import '../providers/notifications_provider.dart';

/// Citizen notification inbox, backed by live `/me/notifications` data.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$m/$d';
  }

  ({IconData icon, Color color}) _visual(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.emergency:
        return (icon: Icons.warning_rounded, color: const Color(0xFFB91C1C));
      case NotificationCategory.serviceRequest:
        return (icon: Icons.check_circle, color: AppTheme.primaryColor);
      case NotificationCategory.issueReport:
        return (icon: Icons.report_problem_outlined, color: const Color(0xFFD97706));
      case NotificationCategory.news:
        return (icon: Icons.campaign_outlined, color: AppTheme.secondaryColor);
      case NotificationCategory.transparency:
        return (icon: Icons.account_balance_outlined, color: const Color(0xFF2563EB));
      case NotificationCategory.general:
      case NotificationCategory.unknown:
        return (icon: Icons.notifications, color: AppTheme.secondaryColor);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    final hasUnread = ref.watch(unreadNotificationCountProvider) > 0;

    return GlassScaffold(
      title: 'Notifications',
      bottomPadding: false,
      useShellBackground: false,
      onRefresh: () =>
          ref.read(notificationsControllerProvider.notifier).reload(),
      actions: [
        if (hasUnread)
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () =>
                ref.read(notificationsControllerProvider.notifier).markAllRead(),
          ),
      ],
      body: notificationsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => _message(
          context,
          'Could not load notifications. Pull down to retry.',
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _message(context, 'You have no notifications yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _tile(context, ref, notifications[index], index),
          );
        },
      ),
    );
  }

  Widget _message(BuildContext context, String text) {
    final glass = glassThemeOf(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.notifications_off_outlined, size: 56, color: glass.textOnGlassMuted),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: glass.textOnGlassMuted),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    AppNotification notif,
    int index,
  ) {
    final glass = glassThemeOf(context);
    final visual = _visual(notif.category);

    return GlassCard(
      intensity: notif.isRead ? GlassIntensity.subtle : GlassIntensity.medium,
      tint: notif.isRead ? null : AppTheme.secondaryColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(16),
      onTap: () =>
          ref.read(notificationsControllerProvider.notifier).markRead(notif.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSurface(
            intensity: GlassIntensity.subtle,
            borderRadius: BorderRadius.circular(999),
            tint: visual.color.withValues(alpha: 0.12),
            boxShadow: const [],
            padding: const EdgeInsets.all(10),
            child: Icon(visual.icon, color: visual.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 15,
                          color: glass.textOnGlass,
                        ),
                      ),
                    ),
                    if (!notif.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      _formatDate(notif.createdAt),
                      style: TextStyle(fontSize: 11, color: glass.textOnGlassMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: notif.isRead ? glass.textOnGlassMuted : glass.textOnGlass,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn();
  }
}
