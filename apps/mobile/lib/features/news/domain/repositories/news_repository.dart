import '../../../../core/usecases/result.dart';
import '../entities/news_article.dart';

/// Community News contract (public endpoints, read-only on mobile).
abstract interface class NewsRepository {
  /// Published articles, most recent first.
  FutureResult<List<NewsArticle>> list();

  /// A single article resolved by [slug] (with full [NewsArticle.body]).
  FutureResult<NewsArticle> getBySlug(String slug);
}
