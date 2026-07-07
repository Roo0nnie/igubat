import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

part 'profile_remote_data_source.g.dart';

/// Talks to `/me/profile`. Returns the shared [UserModel] DTO.
class ProfileRemoteDataSource with BaseRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final DioClient _client;

  Future<UserModel> fetch() =>
      guard(() => _client.getOne(ApiConstants.profile, UserModel.fromJson));

  Future<UserModel> update(Map<String, dynamic> body) => guard(
    () => _client.patch(ApiConstants.profile, UserModel.fromJson, data: body),
  );
}

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) =>
    ProfileRemoteDataSource(ref.watch(dioClientProvider));
