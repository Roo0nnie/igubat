import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

part 'sign_up.g.dart';

/// Registers a citizen; dispatches a verification OTP (no session yet).
class SignUp extends UseCase<Unit, SignUpParams> {
  SignUp(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<Unit> call(SignUpParams params) => _repository.signUp(
    email: params.email,
    password: params.password,
    name: params.name,
    mobileNumber: params.mobileNumber,
    barangay: params.barangay,
    address: params.address,
    dpaConsent: params.dpaConsent,
  );
}

@riverpod
SignUp signUpUseCase(Ref ref) => SignUp(ref.watch(authRepositoryProvider));
