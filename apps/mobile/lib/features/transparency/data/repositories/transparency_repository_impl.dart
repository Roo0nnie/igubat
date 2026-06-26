import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/transparency_attachment.dart';
import '../../domain/entities/transparency_item.dart';
import '../../domain/repositories/transparency_repository.dart';
import '../datasources/transparency_local_data_source.dart';
import '../datasources/transparency_remote_data_source.dart';
import '../models/transparency_type.dart';

part 'transparency_repository_impl.g.dart';

class TransparencyRepositoryImpl
    with BaseRepository
    implements TransparencyRepository {
  TransparencyRepositoryImpl(this._remote, this._local);

  final TransparencyRemoteDataSource _remote;
  final TransparencyLocalDataSource _local;

  @override
  FutureResult<List<TransparencyItem>> listByType(TransparencyType type) =>
      execute(
        () async {
          final models = await _remote.listByType(type);
          final items = models.map((m) => m.toEntity()).toList()
            ..sort(
              (a, b) => (b.publishedAt ?? DateTime(0))
                  .compareTo(a.publishedAt ?? DateTime(0)),
            );
          await _local.cacheList(type, items);
          return items;
        },
        // Offline fallback: cache, then seed (always non-null → never fails).
        cache: () async =>
            _local.readCachedList(type) ?? _local.seedListByType(type),
      );

  @override
  FutureResult<TransparencyItem?> getBySlug(String slug) => execute(
    () async {
      final item = (await _remote.getBySlug(slug)).toEntity();
      await _local.cacheDetail(item);
      return item;
    },
    cache: () async => _local.readCachedDetail(slug) ?? _local.seedBySlug(slug),
  );

  @override
  FutureResult<Uri> cacheAttachment(TransparencyAttachment attachment) =>
      execute(
        () => _remote.downloadAttachment(
          id: attachment.id,
          fileName: attachment.fileName,
          fileUrl: attachment.fileUrl,
          sizeBytes: attachment.sizeBytes,
        ),
      );

  @override
  DateTime? lastUpdatedFor(TransparencyType type) => _local.lastUpdatedFor(type);

  @override
  bool wasCachedFor(TransparencyType type) => _local.wasCachedFor(type);
}

@Riverpod(keepAlive: true)
TransparencyRepository transparencyRepository(Ref ref) =>
    TransparencyRepositoryImpl(
      ref.watch(transparencyRemoteDataSourceProvider),
      ref.watch(transparencyLocalDataSourceProvider),
    );
