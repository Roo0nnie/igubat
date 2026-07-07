import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

part 'get_news_article.g.dart';

class GetNewsArticle extends UseCase<NewsArticle, String> {
  GetNewsArticle(this._repository);

  final NewsRepository _repository;

  @override
  FutureResult<NewsArticle> call(String slug) => _repository.getBySlug(slug);
}

@riverpod
GetNewsArticle getNewsArticleUseCase(Ref ref) =>
    GetNewsArticle(ref.watch(newsRepositoryProvider));
