/// Publication state shared by news articles and events.
///
/// Mirrors the backend `status` enum. The mobile app only ever displays
/// `published` content, but the field is surfaced so screens can render a
/// dedicated empty/withdrawn state if a deep link points at archived content.
enum ContentStatus {
  draft,
  published,
  archived,
  unknown;

  /// Maps the wire value to a [ContentStatus], tolerating nulls/unknowns.
  static ContentStatus fromApi(String? v) => switch (v) {
    'draft' => ContentStatus.draft,
    'published' => ContentStatus.published,
    'archived' => ContentStatus.archived,
    _ => ContentStatus.unknown,
  };
}
