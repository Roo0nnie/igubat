import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/news_article_model.dart';

part 'news_remote_data_source.g.dart';

/// Talks to the public news endpoints. List + by-slug detail, read-only.
class NewsRemoteDataSource with BaseRemoteDataSource {
  NewsRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<NewsArticleModel>> list() => guard(
    () => _client.getList(ApiConstants.publicNews, NewsArticleModel.fromJson),
  );

  Future<NewsArticleModel> getBySlug(String slug) => guard(
    () => _client.getOne(
      ApiConstants.publicArticle(slug),
      NewsArticleModel.fromJson,
    ),
  );
}

@riverpod
NewsRemoteDataSource newsRemoteDataSource(Ref ref) =>
    NewsRemoteDataSource(ref.watch(dioClientProvider));
