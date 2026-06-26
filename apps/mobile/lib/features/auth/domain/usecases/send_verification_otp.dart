import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

part 'send_verification_otp.g.dart';

/// (Re)dispatches the email-verification OTP.
class SendVerificationOtp extends UseCase<Unit, EmailParams> {
  SendVerificationOtp(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<Unit> call(EmailParams params) =>
      _repository.sendVerificationOtp(email: params.email);
}

@riverpod
SendVerificationOtp sendVerificationOtpUseCase(Ref ref) =>
    SendVerificationOtp(ref.watch(authRepositoryProvider));
