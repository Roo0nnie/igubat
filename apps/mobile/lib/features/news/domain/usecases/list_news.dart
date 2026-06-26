import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

part 'list_news.g.dart';

class ListNews extends UseCase<List<NewsArticle>, NoParams> {
  ListNews(this._repository);

  final NewsRepository _repository;

  @override
  FutureResult<List<NewsArticle>> call(NoParams params) => _repository.list();
}

@riverpod
ListNews listNewsUseCase(Ref ref) =>
    ListNews(ref.watch(newsRepositoryProvider));
