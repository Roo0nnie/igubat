import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../../domain/entities/news_article.dart';
import '../news_category_style.dart';
import '../providers/news_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final articleAsync = ref.watch(newsArticleProvider(slug));

    return GlassScaffold(
      title: 'News Details',
      bottomPadding: false,
      useShellBackground: false,
      onRefresh: () async => ref.refresh(newsArticleProvider(slug).future),
      body: articleAsync.when(
        loading: () => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: LoadingStateView(
            message: 'Loading article...',
            skeleton: const GlassSkeletonDetail(),
            onRetry: () => ref.invalidate(newsArticleProvider(slug)),
          ),
        ),
        error: (error, _) => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: ErrorStateView(
            title: 'Unable to load this article',
            error: error,
            onRetry: () => ref.invalidate(newsArticleProvider(slug)),
          ),
        ),
        data: (article) => _buildContent(context, article, glass),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    NewsArticle article,
    GlassTheme glass,
  ) {
    final color = newsCategoryColor(article.category);
    final hasExcerpt = article.excerpt != null && article.excerpt!.isNotEmpty;
    final body = article.body.isNotEmpty ? article.body : (article.excerpt ?? '');
    final showExcerpt = hasExcerpt && article.body.isNotEmpty && article.excerpt != article.body;
    final hasImage = article.imageUrl != null && article.imageUrl!.isNotEmpty;

    final cover = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.35)!],
        ),
      ),
      child: Center(
        child: Icon(
          newsCategoryIcon(article.category),
          size: 64,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
          child: SizedBox(
            height: hasImage ? 220 : 140,
            child: hasImage
                ? Image.network(
                    article.imageUrl!,
                    fit: BoxFit.cover,
                    semanticLabel: article.title,
                    errorBuilder: (_, _, _) => cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : cover,
                  )
                : cover,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassBadge(
              label: article.category,
              color: color,
              icon: newsCategoryIcon(article.category),
            ),
            if (article.publishedAt != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: glass.textOnGlassMuted),
                  const SizedBox(width: 6),
                  Text(
                    formatNewsDate(article.publishedAt),
                    style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            article.title,
            style: TextStyle(
              color: glass.textOnGlass,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ),
        if (showExcerpt) ...[
          const SizedBox(height: 10),
          Text(
            article.excerpt!,
            style: TextStyle(
              color: glass.textOnGlassMuted,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            body,
            style: TextStyle(
              color: glass.textOnGlass,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
