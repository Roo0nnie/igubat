import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile.dart';
import '../datasources/profile_remote_data_source.dart';

part 'profile_repository_impl.g.dart';

class ProfileRepositoryImpl with BaseRepository implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  FutureResult<User> getProfile() => execute(() async {
    final model = await _remote.fetch();
    return model.toEntity();
  });

  @override
  FutureResult<User> updateProfile(UpdateProfileParams params) =>
      execute(() async {
        final model = await _remote.update(params.toJson());
        return model.toEntity();
      });
}

@riverpod
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
