// Lenient ISO-8601 parsing helpers for JSON date fields.
//
// The backend emits ISO date strings, but many fields are nullable
// (`preferredDate`, `publishedAt`, `effectiveDate`, `endsAt`, `readAt`, ...).
// `json_serializable` would call `DateTime.parse` and throw on null/garbage,
// so DTOs use [tryParseDate] via `@JsonKey(fromJson: tryParseDate)` for
// nullable dates.

/// Parses a nullable [DateTime] from a dynamic JSON value, never throwing.
DateTime? tryParseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  if (value is int) {
    // Tolerate epoch millis just in case.
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return null;
}

/// Parses a non-null [DateTime], falling back to epoch zero on failure.
DateTime parseDate(Object? value) =>
    tryParseDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

extension DateTimeX on DateTime {
  /// Serialises to an ISO-8601 string for request bodies / caches.
  String toIso() => toUtc().toIso8601String();
}
