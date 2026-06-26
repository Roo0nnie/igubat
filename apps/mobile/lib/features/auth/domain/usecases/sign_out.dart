import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

part 'sign_out.g.dart';

/// Signs the citizen out and clears local credentials.
class SignOut extends UseCase<Unit, NoParams> {
  SignOut(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<Unit> call(NoParams params) => _repository.signOut();
}

@riverpod
SignOut signOutUseCase(Ref ref) => SignOut(ref.watch(authRepositoryProvider));
