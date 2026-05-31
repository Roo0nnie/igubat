import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _loading = false);
    });
  }

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

  String _formatDate(String iso) => iso.substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    Announcement? featured;
    for (final a in SeedData.announcements) {
      if (a.isFeatured) {
        featured = a;
        break;
      }
    }

    return GlassScaffold(
      title: 'Community News',
      onRefresh: () async => Future.delayed(const Duration(milliseconds: 600)),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          AppLayout.scrollBottomPadding(context),
        ),
        itemCount: _loading ? 3 : SeedData.announcements.length + (featured != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (_loading) {
            return GlassCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
              ),
            );
          }

          if (featured != null && index == 0) {
            return _buildFeaturedHero(featured, glass);
          }

          final newsIndex = featured != null ? index - 1 : index;
          final news = SeedData.announcements[newsIndex];
          return _buildNewsCard(news, glass, newsIndex);
        },
      ),
    );
  }

  Widget _buildFeaturedHero(Announcement news, GlassTheme glass) {
    return GlassCard(
      padding: EdgeInsets.zero,
      intensity: GlassIntensity.prominent,
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
        child: SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _categoryColor(news.category),
                      _categoryColor(news.category).withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: GlassBadge(label: 'Municipality Highlight', color: Colors.white),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassSurface(
                  intensity: GlassIntensity.medium,
                  borderRadius: BorderRadius.zero,
                  tint: Colors.black.withValues(alpha: 0.35),
                  boxShadow: const [],
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildNewsCard(Announcement news, GlassTheme glass, int index) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _categoryColor(news.category).withValues(alpha: 0.3),
                  _categoryColor(news.category).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(Icons.image_outlined, size: 48, color: _categoryColor(news.category).withValues(alpha: 0.5)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassBadge(label: news.category, color: _categoryColor(news.category), compact: true),
                    Text(
                      _formatDate(news.datePublished),
                      style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  news.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: glass.textOnGlass,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  news.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: glass.textOnGlassMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 14, color: glass.textOnGlassMuted),
                    const SizedBox(width: 4),
                    Text('${news.views}', style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted)),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite_border, size: 14, color: glass.textOnGlassMuted),
                    const SizedBox(width: 4),
                    Text('${news.likes}', style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}
