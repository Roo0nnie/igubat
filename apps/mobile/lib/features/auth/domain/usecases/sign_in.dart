import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

part 'sign_in.g.dart';

/// Signs a citizen in with email + password.
class SignIn extends UseCase<Session?, SignInParams> {
  SignIn(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<Session?> call(SignInParams params) =>
      _repository.signIn(email: params.email, password: params.password);
}

@riverpod
SignIn signInUseCase(Ref ref) => SignIn(ref.watch(authRepositoryProvider));
