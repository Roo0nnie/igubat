import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_params.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/send_verification_otp.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/verify_email_otp.dart';

part 'auth_provider.g.dart';

/// Authentication state machine. Drives the auth use cases and folds their
/// `Either<Failure, Session?>` results into [AsyncValue] so a failed call lands
/// in [AsyncError] carrying the typed `Failure`.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  Future<Session?> build() async {
    final result =
        await ref.read(getCurrentSessionUseCaseProvider).call(const NoParams());
    // A failed session restore simply means "not authenticated".
    return result.fold((_) => null, (session) => session);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInUseCaseProvider)
        .call(SignInParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData.new,
    );
  }

  /// Registers a citizen. The account is created unverified and a verification
  /// OTP is dispatched; **no session is established here**. Returns `true` when
  /// registration succeeded (caller routes to OTP), `false` otherwise (the
  /// failure is exposed via [AsyncError]).
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String barangay,
    required String address,
    required bool dpaConsent,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(signUpUseCaseProvider).call(
      SignUpParams(
        email: email,
        password: password,
        name: name,
        mobileNumber: mobileNumber,
        barangay: barangay,
        address: address,
        dpaConsent: dpaConsent,
      ),
    );
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        // Registered but unverified — explicitly not authenticated yet.
        state = const AsyncData(null);
        return true;
      },
    );
  }

  /// Re-dispatches the email-verification OTP. Throws the `Failure` on error so
  /// the OTP screen's try/catch can surface a message.
  Future<void> resendVerificationOtp({required String email}) async {
    final result = await ref
        .read(sendVerificationOtpUseCaseProvider)
        .call(EmailParams(email: email));
    result.fold((failure) => throw failure, (_) {});
  }

  /// Validates the [otp]. On success the session is published and the citizen
  /// is authenticated. Returns `true` when a session was established.
  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(verifyEmailOtpUseCaseProvider)
        .call(VerifyOtpParams(email: email, otp: otp));
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (session) {
        state = AsyncData(session);
        return session != null;
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    // Always clear local session even if the backend call fails.
    await ref.read(signOutUseCaseProvider).call(const NoParams());
    state = const AsyncData(null);
  }
}

@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
}

@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.user;
}
