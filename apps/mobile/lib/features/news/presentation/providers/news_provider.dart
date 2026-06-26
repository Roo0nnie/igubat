import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/usecases/get_news_article.dart';
import '../../domain/usecases/list_news.dart';

/// Published Community News articles, most recent first. Backed by the public
/// news endpoint.
final newsListProvider = FutureProvider.autoDispose<List<NewsArticle>>((
  ref,
) async {
  final result = await ref.watch(listNewsUseCaseProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (articles) => articles);
});

/// A single news article resolved by [slug], used by the detail screen.
final newsArticleProvider = FutureProvider.autoDispose
    .family<NewsArticle, String>((ref, slug) async {
      final result =
          await ref.watch(getNewsArticleUseCaseProvider).call(slug);
      return result.fold((failure) => throw failure, (article) => article);
    });
