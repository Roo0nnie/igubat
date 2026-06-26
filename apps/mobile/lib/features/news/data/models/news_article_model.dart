import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/content_status.dart';
import '../../domain/entities/news_article.dart';

/// DTO for a Community News article. Mirrors the backend public news schema and
/// maps to the [NewsArticle] entity. List payloads omit [body]; the by-slug
/// detail payload includes it.
class NewsArticleModel {
  const NewsArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.slug,
    this.excerpt,
    this.body = '',
    this.imageUrl,
    this.isFeatured = false,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? slug;
  final String? excerpt;
  final String body;
  final String category;
  final ContentStatus status;
  final String? imageUrl;
  final bool isFeatured;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: JsonUtils.asInt(json['id']),
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String?,
      excerpt: json['excerpt'] as String?,
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: ContentStatus.fromApi(json['status'] as String?),
      imageUrl: json['imageUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      publishedAt: tryParseDate(json['publishedAt']),
      createdAt: tryParseDate(json['createdAt']),
      updatedAt: tryParseDate(json['updatedAt']),
    );
  }

  NewsArticle toEntity() => NewsArticle(
    id: id,
    title: title,
    slug: slug,
    excerpt: excerpt,
    body: body,
    category: category,
    status: status,
    imageUrl: imageUrl,
    isFeatured: isFeatured,
    publishedAt: publishedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
