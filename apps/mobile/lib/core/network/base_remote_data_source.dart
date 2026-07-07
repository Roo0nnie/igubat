import 'package:dio/dio.dart';

import '../error/error_mapper.dart';
import '../error/exceptions.dart';

/// Mixin for remote data sources. `guard` runs a Dio call and converts any
/// transport/decoding error into a typed [AppException], so each data-source
/// method body is just the request itself.
mixin BaseRemoteDataSource {
  Future<T> guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      throw mapDioException(e);
    } on AppException {
      rethrow;
    } on FormatException catch (e) {
      throw ParsingException(e.message);
    } on TypeError catch (e) {
      throw ParsingException('Malformed response: $e');
    }
  }
}
