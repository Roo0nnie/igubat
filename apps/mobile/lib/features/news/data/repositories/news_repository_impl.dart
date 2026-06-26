import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

part 'news_repository_impl.g.dart';

class NewsRepositoryImpl with BaseRepository implements NewsRepository {
  NewsRepositoryImpl(this._remote);

  final NewsRemoteDataSource _remote;

  @override
  FutureResult<List<NewsArticle>> list() => execute(
    () async => (await _remote.list()).map((m) => m.toEntity()).toList(),
  );

  @override
  FutureResult<NewsArticle> getBySlug(String slug) =>
      execute(() async => (await _remote.getBySlug(slug)).toEntity());
}

@riverpod
NewsRepository newsRepository(Ref ref) =>
    NewsRepositoryImpl(ref.watch(newsRemoteDataSourceProvider));
