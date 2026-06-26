import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/emergency_directory_entry_model.dart';

part 'emergency_directory_remote_data_source.g.dart';

/// Talks to `/public/emergency-directory`. Returns the bare list of entries.
class EmergencyDirectoryRemoteDataSource with BaseRemoteDataSource {
  EmergencyDirectoryRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<EmergencyDirectoryEntryModel>> list() => guard(
    () => _client.getList(
      ApiConstants.emergencyDirectory,
      EmergencyDirectoryEntryModel.fromJson,
    ),
  );
}

@riverpod
EmergencyDirectoryRemoteDataSource emergencyDirectoryRemoteDataSource(Ref ref) =>
    EmergencyDirectoryRemoteDataSource(ref.watch(dioClientProvider));
