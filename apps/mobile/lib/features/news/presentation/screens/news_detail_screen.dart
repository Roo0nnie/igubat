import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/entities/news_article.dart';
import '../providers/news_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.slug});

  final String slug;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final articleAsync = ref.watch(newsArticleProvider(slug));

    return GlassScaffold(
      title: 'News Details',
      bottomPadding: false,
      useShellBackground: false,
      body: articleAsync.when(
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
              'Could not load this article. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: glass.textOnGlassMuted),
            ),
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
    final color = _categoryColor(article.category);
    final summary = (article.excerpt != null && article.excerpt!.isNotEmpty)
        ? article.excerpt!
        : article.body;

    return ListView(
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
              GlassBadge(label: article.category, color: color),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: TextStyle(
                  color: glass.textOnGlass,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              if (article.publishedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  article.publishedAt!.toIso8601String().substring(0, 10),
                  style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                article.body.isNotEmpty ? article.body : summary,
                style: TextStyle(
                  color: glass.textOnGlass,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
