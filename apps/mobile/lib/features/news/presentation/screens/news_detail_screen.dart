import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.announcement});

  final Announcement announcement;

  Color _categoryColor(String category) {
    switch (category) {
      case 'Business':
        return AppTheme.primaryColor;
      case 'Health':
        return const Color(0xFF059669);
      case 'Infrastructure':
        return const Color(0xFFD97706);
      default:
        return AppTheme.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final color = _categoryColor(announcement.category);

    return GlassScaffold(
      title: 'News Details',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            padding: EdgeInsets.zero,
            intensity: GlassIntensity.prominent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.article_outlined, size: 72, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassBadge(label: announcement.category, color: color),
                const SizedBox(height: 12),
                Text(
                  announcement.title,
                  style: TextStyle(
                    color: glass.textOnGlass,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.datePublished.substring(0, 10),
                  style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Text(
                  announcement.content,
                  style: TextStyle(
                    color: glass.textOnGlass,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: glass.textOnGlassMuted),
                    const SizedBox(width: 6),
                    Text('${announcement.views}', style: TextStyle(color: glass.textOnGlassMuted)),
                    const SizedBox(width: 18),
                    Icon(Icons.favorite_border, size: 16, color: glass.textOnGlassMuted),
                    const SizedBox(width: 6),
                    Text('${announcement.likes}', style: TextStyle(color: glass.textOnGlassMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
