import '../../../../core/usecases/result.dart';
import '../entities/session.dart';

/// Auth contract the domain depends on. Implemented in
/// `data/repositories/auth_repository_impl.dart`. Returns domain [Session]
/// entities, never DTOs.
abstract interface class AuthRepository {
  /// Email/password sign-in. Resolves to a [Session] (Better Auth returns one
  /// immediately) or `null` when no session was established.
  FutureResult<Session?> signIn({
    required String email,
    required String password,
  });

  /// Registers a citizen. The account is created **unverified** and an OTP is
  /// dispatched; no session is returned.
  FutureResult<Unit> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String barangay,
    required String address,
    required bool dpaConsent,
  });

  /// (Re)dispatches the email-verification OTP.
  FutureResult<Unit> sendVerificationOtp({required String email});

  /// Validates the OTP; on success returns the authenticated [Session].
  FutureResult<Session?> verifyEmailOtp({
    required String email,
    required String otp,
  });

  /// Signs out and clears local credentials.
  FutureResult<Unit> signOut();

  /// Restores the current session from the backend cookie, or `null`.
  FutureResult<Session?> getCurrentSession();
}
