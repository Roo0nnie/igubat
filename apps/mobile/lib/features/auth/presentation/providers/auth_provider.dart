import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/data/models/session_model.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  Future<SessionModel?> build() async {
    return ref.read(authRepositoryProvider).getSession();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          ),
    );
  }

  /// Registers a citizen. The account is created in an unverified state and a
  /// verification OTP is dispatched server-side; **no authenticated session is
  /// established here**. The session remains `null` so route guards keep the
  /// citizen out of protected surfaces until [verifyEmailOtp] succeeds.
  ///
  /// Returns `true` when registration succeeded (caller should route to OTP),
  /// or `false` when it failed (error is exposed via [AsyncError] state).
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
    try {
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            name: name,
            mobileNumber: mobileNumber,
            barangay: barangay,
            address: address,
            dpaConsent: dpaConsent,
          );
      // Registered but unverified — explicitly not authenticated yet.
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  /// Re-dispatches the email-verification OTP for [email].
  Future<void> resendVerificationOtp({required String email}) {
    return ref.read(authRepositoryProvider).sendVerificationOtp(email: email);
  }

  /// Validates the [otp] for [email] server-side. On success the returned
  /// session is published, authenticating the citizen. Returns `true` when a
  /// session was established. On failure the [AsyncError] state carries the
  /// backend message and `false` is returned.
  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifyEmailOtp(
            email: email,
            otp: otp,
          ),
    );
    state = result;
    return result.hasValue && result.value != null;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      // Always clear local session even if the backend call fails,
      // so the user is logged out on the device.
      state = const AsyncData(null);
    }
  }
}

@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
}

@riverpod
UserModel? currentUser(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.user;
}
