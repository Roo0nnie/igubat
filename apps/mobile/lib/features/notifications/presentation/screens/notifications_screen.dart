import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDate(String dateStr) => dateStr.substring(5, 10).replaceAll('-', '/');

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Notifications',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: SeedData.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = SeedData.notifications[index];
          final glass = glassThemeOf(context);

          IconData iconData = Icons.notifications;
          Color iconColor = AppTheme.secondaryColor;

          if (notif.type == 'Emergency') {
            iconData = Icons.warning_rounded;
            iconColor = const Color(0xFFB91C1C);
          } else if (notif.type == 'Status Update') {
            iconData = Icons.check_circle;
            iconColor = AppTheme.primaryColor;
          }

          return GlassCard(
            intensity: notif.isRead ? GlassIntensity.subtle : GlassIntensity.medium,
            tint: notif.isRead ? null : AppTheme.secondaryColor.withValues(alpha: 0.08),
            padding: const EdgeInsets.all(16),
            onTap: () {},
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSurface(
                  intensity: GlassIntensity.subtle,
                  borderRadius: BorderRadius.circular(999),
                  tint: iconColor.withValues(alpha: 0.12),
                  boxShadow: const [],
                  padding: const EdgeInsets.all(10),
                  child: Icon(iconData, color: iconColor, size: 20),
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
                          Text(
                            _formatDate(notif.dateSent),
                            style: TextStyle(fontSize: 11, color: glass.textOnGlassMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif.message,
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
        },
      ),
    );
  }
}
