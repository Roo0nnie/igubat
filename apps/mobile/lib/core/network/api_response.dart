import '../error/exceptions.dart';
import '../utils/json_utils.dart';

/// Unwraps backend response bodies into their data payload.
///
/// The iGubat/NestJS backend returns **bare** arrays/objects for success
/// responses (no `{ success, data, meta }` envelope) and Better Auth returns
/// raw bodies. This unwrapper is deliberately tolerant of all three shapes so
/// the data layer never has to special-case them, and it remains correct if a
/// success-envelope interceptor is added server-side later.
class ApiEnvelope {
  ApiEnvelope._();

  /// Returns the inner data payload whether [body] is bare, `{success,data}`,
  /// or a legacy oRPC `{ data: ... }` wrapper.
  static Object? payload(Object? body) {
    if (body is Map && body['success'] == true && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Unwraps [body] into a JSON object.
  static Map<String, dynamic> unwrapMap(Object? body) =>
      JsonUtils.asMap(payload(body));

  /// Unwraps [body] into a JSON array.
  static List<dynamic> unwrapList(Object? body) {
    final data = payload(body);
    if (data is List) return data;
    throw ParsingException('Expected a list payload but got ${data.runtimeType}.');
  }
}

/// Offset-style pagination metadata. The current backend never emits this, but
/// it is modelled for forward-compatibility.
class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
    page: JsonUtils.asInt(json['page']),
    limit: JsonUtils.asInt(json['limit']),
    total: JsonUtils.asInt(json['total']),
    totalPages: JsonUtils.asInt(json['totalPages']),
  );
}
