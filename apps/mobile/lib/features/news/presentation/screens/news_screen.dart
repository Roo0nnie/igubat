import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../domain/entities/news_article.dart';
import '../news_category_style.dart';
import '../providers/news_provider.dart';
import 'news_detail_screen.dart';

Widget _newsSkeleton(BuildContext context) => const GlassSkeletonCard(imageHeight: 160);

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

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
        loading: () => StateScrollView(
          child: LoadingStateView(
            message: 'Loading the latest news...',
            onRetry: () => ref.invalidate(newsListProvider),
            skeleton: const GlassSkeletonList(
              count: 3,
              spacing: 16,
              itemBuilder: _newsSkeleton,
            ),
          ),
        ),
        error: (error, _) => StateScrollView(
          child: ErrorStateView(
            title: 'Unable to load news',
            error: error,
            onRetry: () => ref.invalidate(newsListProvider),
          ),
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return const StateScrollView(
              child: EmptyStateView(
                icon: Icons.article_outlined,
                title: 'No news yet',
                message: 'Check back soon for community updates.',
              ),
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
            separatorBuilder: (_, _) => const SizedBox(height: 16),
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
              _NewsCover(news: news, iconSize: 96),
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
          if (_hasImage(news))
            SizedBox(
              height: 160,
              width: double.infinity,
              child: _NewsCover(news: news, iconSize: 56),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_hasImage(news)) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: _NewsCover(news: news, iconSize: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GlassBadge(
                            label: news.category,
                            color: newsCategoryColor(news.category),
                            compact: true,
                          ),
                          Text(
                            formatNewsDate(news.publishedAt),
                            style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3,
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Read more',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: glass.brandOnGlass,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: glass.brandOnGlass),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }

  bool _hasImage(NewsArticle news) =>
      news.imageUrl != null && news.imageUrl!.isNotEmpty;
}

/// Article image, or a category-colored cover with the category icon when the
/// article has no image (or it fails to load).
class _NewsCover extends StatelessWidget {
  const _NewsCover({required this.news, required this.iconSize});

  final NewsArticle news;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final color = newsCategoryColor(news.category);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.35)!],
        ),
      ),
      child: Center(
        child: Icon(
          newsCategoryIcon(news.category),
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );

    final url = news.imageUrl;
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      semanticLabel: news.title,
      errorBuilder: (_, _, _) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}
