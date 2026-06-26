import '../error/exceptions.dart';

/// Defensive coercions for loosely-typed JSON coming off the wire.
///
/// The backend returns bare arrays/objects (no success envelope) and some
/// fields are typed loosely (e.g. ids as `num`, lat/lng as `String`), so these
/// helpers normalise the shapes the data layer relies on.
class JsonUtils {
  JsonUtils._();

  /// Coerces [value] to `Map<String, dynamic>`, throwing [ParsingException]
  /// when it isn't a JSON object.
  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    throw ParsingException('Expected a JSON object but got ${value.runtimeType}.');
  }

  /// Coerces [value] to `List<dynamic>`, throwing [ParsingException] otherwise.
  static List<dynamic> asList(Object? value) {
    if (value is List) return value;
    throw ParsingException('Expected a JSON array but got ${value.runtimeType}.');
  }

  /// Parses an int from `int`, `num`, or numeric `String`.
  static int asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Parses a nullable double from `num` or `String` (backend sends lat/lng
  /// as strings).
  static double? asDoubleOrNull(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
