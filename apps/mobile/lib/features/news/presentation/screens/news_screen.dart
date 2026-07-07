import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../domain/entities/news_article.dart';
import '../providers/news_provider.dart';
import 'news_detail_screen.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

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

  String _formatDate(DateTime? date) =>
      date == null ? '' : date.toIso8601String().substring(0, 10);

  String _summaryOf(NewsArticle news) =>
      (news.excerpt != null && news.excerpt!.isNotEmpty)
          ? news.excerpt!
          : news.body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final newsAsync = ref.watch(newsListProvider);

    return GlassScaffold(
      title: 'Community News',
      onRefresh: () async => ref.refresh(newsListProvider.future),
      body: newsAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            AppLayout.scrollBottomPadding(context),
          ),
          children: [
            GlassCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        error: (error, _) => ListView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            AppLayout.scrollBottomPadding(context),
          ),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 40,
                    color: glass.textOnGlassMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We could not load the latest news.',
                    style: TextStyle(
                      color: glass.textOnGlass,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please check your connection and pull to refresh.',
                    style: TextStyle(
                      color: glass.textOnGlassMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return ListView(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                AppLayout.scrollBottomPadding(context),
              ),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 40,
                        color: glass.textOnGlassMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No news yet.',
                        style: TextStyle(
                          color: glass.textOnGlass,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Check back soon for community updates.',
                        style: TextStyle(
                          color: glass.textOnGlassMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          NewsArticle? featured;
          for (final a in articles) {
            if (a.isFeatured) {
              featured = a;
              break;
            }
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              AppLayout.scrollBottomPadding(context),
            ),
            itemCount: articles.length + (featured != null ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (featured != null && index == 0) {
                return _buildFeaturedHero(context, featured, glass);
              }

              final newsIndex = featured != null ? index - 1 : index;
              final news = articles[newsIndex];
              return _buildNewsCard(context, news, glass, newsIndex);
            },
          );
        },
      ),
    );
  }

  Widget _buildFeaturedHero(
    BuildContext context,
    NewsArticle news,
    GlassTheme glass,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      intensity: GlassIntensity.prominent,
      onTap: () {
        Navigator.push(
          context,
          GlassPageRoute(page: NewsDetailScreen(slug: news.slug ?? '')),
        );
      },
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
                        _summaryOf(news),
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

  Widget _buildNewsCard(
    BuildContext context,
    NewsArticle news,
    GlassTheme glass,
    int index,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          GlassPageRoute(page: NewsDetailScreen(slug: news.slug ?? '')),
        );
      },
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
                      _formatDate(news.publishedAt),
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
                  _summaryOf(news),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: glass.textOnGlassMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}
