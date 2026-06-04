import 'package:flutter_riverpod/legacy.dart';

/// Post-authentication continuation target.
///
/// A guarded surface (Stories 3.x, 5.1, Module 9) records where the guest was
/// trying to go before being sent to sign-in. The OTP screen writes the
/// resolved continuation here on a successful verification, and [MainScaffold]
/// consumes it to resume the attempted action instead of leaving the user on
/// the default Home tab.
enum AuthContinuation {
  /// Open the notifications inbox (home notification bell).
  notifications,

  /// Switch to the Profile tab.
  profile,

  /// Return to the Business Permit service so the citizen can submit/apply.
  businessPermit,
}

/// Pending continuation, or `null` when there is nothing to resume.
final authContinuationProvider =
    StateProvider<AuthContinuation?>((ref) => null);
