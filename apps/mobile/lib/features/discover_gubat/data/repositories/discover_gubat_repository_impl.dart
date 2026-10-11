import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/discover_gubat_item.dart';
import '../../domain/repositories/discover_gubat_repository.dart';
import '../datasources/discover_gubat_remote_data_source.dart';

class DiscoverGubatRepositoryImpl
    with BaseRepository
    implements DiscoverGubatRepository {
  DiscoverGubatRepositoryImpl(this._remote);

  final DiscoverGubatRemoteDataSource _remote;

  @override
  FutureResult<List<DiscoverGubatItem>> list() => execute(
    () async => (await _remote.list()).map((item) => item.toEntity()).toList(),
  );

  @override
  FutureResult<DiscoverGubatItem> getBySlug(String slug) =>
      execute(() async => (await _remote.getBySlug(slug)).toEntity());
}

final discoverGubatRepositoryProvider = Provider<DiscoverGubatRepository>(
  (ref) => DiscoverGubatRepositoryImpl(
    ref.watch(discoverGubatRemoteDataSourceProvider),
  ),
);
