import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/json_utils.dart';
import 'api_response.dart';
import 'dio_factory.dart';
import 'paginated_response.dart';

part 'dio_client.g.dart';

/// Thin wrapper over [Dio] that routes every call through the response
/// [ApiEnvelope] unwrapper and parses payloads into DTOs, so data sources never
/// touch `Response.data` directly.
///
/// Exposes [raw] for cases that need the bare client (file downloads, multipart
/// uploads, manual cookie handling).
class DioClient {
  const DioClient(this._dio);

  final Dio _dio;

  /// The underlying client, for downloads / multipart / advanced use.
  Dio get raw => _dio;

  /// GET a single object and parse it with [parse].
  Future<T> getOne<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<dynamic>(path, queryParameters: query);
    return parse(ApiEnvelope.unwrapMap(res.data));
  }

  /// GET a list and parse each element with [parse].
  Future<List<T>> getList<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<dynamic>(path, queryParameters: query);
    return ApiEnvelope.unwrapList(res.data)
        .map((e) => parse(JsonUtils.asMap(e)))
        .toList();
  }

  /// GET a list and wrap it in a [PaginatedResponse] with a client-derived
  /// cursor (the backend never returns pagination metadata).
  Future<PaginatedResponse<T>> getPaginated<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    required int limit,
    required int? Function(T last) cursorOf,
    Map<String, dynamic>? query,
  }) async {
    final items = await getList<T>(path, parse, query: query);
    return PaginatedResponse<T>.fromItems(items, limit: limit, cursorOf: cursorOf);
  }

  /// POST [data] and parse the object response.
  Future<T> post<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.post<dynamic>(path, data: data, queryParameters: query);
    return parse(ApiEnvelope.unwrapMap(res.data));
  }

  /// POST without caring about the response body (e.g. read-all, cancel).
  Future<void> postVoid(String path, {Object? data}) async {
    await _dio.post<dynamic>(path, data: data);
  }

  /// PUT [data] and parse the object response.
  Future<T> put<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Object? data,
  }) async {
    final res = await _dio.put<dynamic>(path, data: data);
    return parse(ApiEnvelope.unwrapMap(res.data));
  }

  /// PATCH [data] and parse the object response.
  Future<T> patch<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Object? data,
  }) async {
    final res = await _dio.patch<dynamic>(path, data: data);
    return parse(ApiEnvelope.unwrapMap(res.data));
  }

  /// DELETE without parsing a response body.
  Future<void> delete(String path, {Object? data}) async {
    await _dio.delete<dynamic>(path, data: data);
  }
}

/// Provider for [DioClient], layered on top of [dioProvider].
@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) => DioClient(ref.watch(dioProvider));
