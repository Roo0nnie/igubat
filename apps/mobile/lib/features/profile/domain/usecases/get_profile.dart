import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../repositories/profile_repository.dart';

part 'get_profile.g.dart';

class GetProfile extends UseCase<User, NoParams> {
  GetProfile(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<User> call(NoParams params) => _repository.getProfile();
}

@riverpod
GetProfile getProfileUseCase(Ref ref) =>
    GetProfile(ref.watch(profileRepositoryProvider));
