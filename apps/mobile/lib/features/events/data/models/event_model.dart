import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../news/domain/entities/content_status.dart';
import '../../domain/entities/event.dart';

/// DTO for a municipal Event. Mirrors the backend public events schema and maps
/// to the [Event] entity. [ContentStatus] is shared with the news feature.
class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.status,
    this.category,
    this.location,
    this.imageUrl,
    this.startsAt,
    this.endsAt,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String slug;
  final String description;
  final String? category;
  final String? location;
  final String? imageUrl;
  final ContentStatus status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? publishedAt;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: JsonUtils.asInt(json['id']),
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: ContentStatus.fromApi(json['status'] as String?),
      startsAt: tryParseDate(json['startsAt']),
      endsAt: tryParseDate(json['endsAt']),
      publishedAt: tryParseDate(json['publishedAt']),
    );
  }

  Event toEntity() => Event(
    id: id,
    title: title,
    slug: slug,
    description: description,
    category: category,
    location: location,
    imageUrl: imageUrl,
    status: status,
    startsAt: startsAt,
    endsAt: endsAt,
    publishedAt: publishedAt,
  );
}
