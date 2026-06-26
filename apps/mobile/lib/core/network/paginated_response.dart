import 'api_response.dart';

/// A page of results.
///
/// The backend does not return pagination metadata today. For cursor-based
/// endpoints (only transparency accepts `cursor`, used server-side as a filter),
/// [nextCursor] is **derived client-side** from the last item's id and
/// end-of-list is inferred when fewer than `limit` items come back.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    this.meta,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<T> items;

  /// Offset metadata when the server provides it (null today).
  final PageMeta? meta;

  /// Cursor for the next page (id of the last item) when more may exist.
  final int? nextCursor;

  final bool hasMore;

  /// Builds a response, deriving the cursor/hasMore from [items] and [limit].
  factory PaginatedResponse.fromItems(
    List<T> items, {
    required int limit,
    required int? Function(T last) cursorOf,
    PageMeta? meta,
  }) {
    final hasMore = items.length >= limit && items.isNotEmpty;
    return PaginatedResponse<T>(
      items: items,
      meta: meta,
      hasMore: hasMore,
      nextCursor: items.isEmpty ? null : cursorOf(items.last),
    );
  }

  PaginatedResponse<R> map<R>(R Function(T) transform) => PaginatedResponse<R>(
    items: items.map(transform).toList(),
    meta: meta,
    nextCursor: nextCursor,
    hasMore: hasMore,
  );
}
