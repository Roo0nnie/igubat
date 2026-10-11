import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/emergency_directory_entry.dart';
import '../../domain/repositories/emergency_directory_repository.dart';
import '../datasources/emergency_directory_local_data_source.dart';
import '../datasources/emergency_directory_remote_data_source.dart';

part 'emergency_directory_repository_impl.g.dart';

class EmergencyDirectoryRepositoryImpl
    with BaseRepository
    implements EmergencyDirectoryRepository {
  EmergencyDirectoryRepositoryImpl(this._remote, this._local);

  final EmergencyDirectoryRemoteDataSource _remote;
  final EmergencyDirectoryLocalDataSource _local;

  @override
  FutureResult<List<EmergencyDirectoryEntry>> getDirectory() => execute(
    () async {
      final entries = (await _remote.list()).map((m) => m.toEntity()).toList();
      await _local.cache(entries);
      return entries;
    },
    cache: () async => _local.readCached(),
  );

  @override
  DateTime? get lastUpdated => _local.lastUpdated;

  @override
  bool get servedFromCache => _local.servedFromCache;
}

@riverpod
EmergencyDirectoryRepository emergencyDirectoryRepository(Ref ref) =>
    EmergencyDirectoryRepositoryImpl(
      ref.watch(emergencyDirectoryRemoteDataSourceProvider),
      ref.watch(emergencyDirectoryLocalDataSourceProvider),
    );
