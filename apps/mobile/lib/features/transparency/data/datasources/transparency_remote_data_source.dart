import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transparency_item_model.dart';
import '../models/transparency_type.dart';

part 'transparency_remote_data_source.g.dart';

/// Talks to the public transparency endpoints and downloads attachments.
class TransparencyRemoteDataSource with BaseRemoteDataSource {
  TransparencyRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<TransparencyItemModel>> listByType(TransparencyType type) => guard(
    () => _client.getList(
      ApiConstants.publicTransparency,
      TransparencyItemModel.fromJson,
      query: {'type': type.apiValue, 'limit': AppConstants.defaultPageLimit},
    ),
  );

  Future<TransparencyItemModel> getBySlug(String slug) => guard(
    () => _client.getOne(
      ApiConstants.publicTransparencyItem(slug),
      TransparencyItemModel.fromJson,
    ),
  );

  /// Downloads [fileUrl] to the app cache and returns the local file URI,
  /// falling back to the remote URI if the download fails.
  Future<Uri> downloadAttachment({
    required int id,
    required String fileName,
    required String fileUrl,
    required int sizeBytes,
  }) async {
    final remoteUri = Uri.tryParse(fileUrl);
    if (remoteUri == null || !remoteUri.hasScheme) {
      throw FormatException('Invalid attachment URL: $fileUrl');
    }

    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory(
        '${baseDir.path}${Platform.pathSeparator}transparency_attachments',
      );
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final file = File(
        '${cacheDir.path}${Platform.pathSeparator}${id}_${_safeFileName(fileName)}',
      );

      if (await file.exists()) {
        if (sizeBytes <= 0 || await file.length() == sizeBytes) {
          return file.uri;
        }
      }

      try {
        await _client.raw.download(fileUrl, file.path);
        return file.uri;
      } on DioException {
        if (await file.exists()) await file.delete();
        return remoteUri;
      }
    } on FileSystemException {
      return remoteUri;
    }
  }

  static String _safeFileName(String value) {
    final safe = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return safe.isEmpty ? 'attachment' : safe;
  }
}

@Riverpod(keepAlive: true)
TransparencyRemoteDataSource transparencyRemoteDataSource(Ref ref) =>
    TransparencyRemoteDataSource(ref.watch(dioClientProvider));
