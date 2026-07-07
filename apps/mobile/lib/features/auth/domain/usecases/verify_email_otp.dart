import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

part 'verify_email_otp.g.dart';

/// Validates the OTP; on success returns the authenticated session.
class VerifyEmailOtp extends UseCase<Session?, VerifyOtpParams> {
  VerifyEmailOtp(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<Session?> call(VerifyOtpParams params) =>
      _repository.verifyEmailOtp(email: params.email, otp: params.otp);
}

@riverpod
VerifyEmailOtp verifyEmailOtpUseCase(Ref ref) =>
    VerifyEmailOtp(ref.watch(authRepositoryProvider));
