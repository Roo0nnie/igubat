import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/mock/seed_data.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/session.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/providers/auth_redirect_provider.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';

/// Fake repository so the auth funnel runs without hitting the network.
/// `getCurrentSession` returns null (guest), `signUp` registers without a
/// session (unverified), and the session is only minted once `verifyEmailOtp`
/// runs.
class _FakeAuthRepository implements AuthRepository {
  Session _session() => const Session(
        token: SessionToken(value: 'test-token'),
        user: User(id: 'u1', name: 'Juan', email: 'juan@example.com'),
      );

  @override
  FutureResult<Session?> getCurrentSession() async => const Right(null);

  @override
  FutureResult<Session?> signIn({
    required String email,
    required String password,
  }) async =>
      Right(_session());

  @override
  FutureResult<Unit> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String barangay,
    required String address,
    required bool dpaConsent,
  }) async =>
      const Right(unit);

  @override
  FutureResult<Unit> sendVerificationOtp({required String email}) async =>
      const Right(unit);

  @override
  FutureResult<Session?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async =>
      Right(_session());

  @override
  FutureResult<Unit> signOut() async => const Right(unit);
}

/// Minimal authenticated destination that surfaces the resumed continuation,
/// standing in for [MainScaffold] so the test can assert the original
/// destination survived the full auth funnel.
class _ContinuationProbe extends ConsumerWidget {
  const _ContinuationProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continuation = ref.watch(authContinuationProvider);
    return Scaffold(
      body: Center(child: Text('continuation:$continuation')),
    );
  }
}

void main() {
  testWidgets(
    'guest → guarded surface → register → OTP preserves original destination',
    (WidgetTester tester) async {
      // Use a tall viewport so the long auth forms fit without scrolling,
      // keeping every button on-screen and tappable.
      tester.view.physicalSize = const Size(1080, 3600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        // A guest who tapped a guarded surface (Business Permit) arrives at
        // login carrying the continuation target.
        initialLocation:
            AppRoutes.loginWithRedirect(AppRoutes.redirectBusinessPermit),
        routes: [
          GoRoute(
            path: AppRoutes.login,
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (_, __) => const RegisterScreen(),
          ),
          GoRoute(
            path: AppRoutes.otp,
            builder: (_, __) => const OtpScreen(),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const _ContinuationProbe(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      // The glass background animates continuously, so `pumpAndSettle` never
      // settles — drive the funnel with fixed-duration pumps instead.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Login → Register must forward the redirect query.
      final signUpButton = find.widgetWithText(TextButton, 'Sign up');
      await tester.ensureVisible(signUpButton);
      await tester.pump();
      await tester.tap(signUpButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Fill the registration form. TextFormFields in build order:
      // 0 name, 1 mobile, 2 email, 3 address, 4 password (barangay is a
      // separate dropdown).
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Juan Dela Cruz');
      await tester.enterText(find.byType(TextFormField).at(1), '09171234567');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'juan@example.com');
      await tester.enterText(
          find.byType(TextFormField).at(3), '123 Rizal St, Purok 1');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.pump();

      // Select a barangay from the dropdown.
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.pump();
      await tester.tap(dropdown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(SeedData.barangays.first).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Consent to the DPA notice.
      final dpaCheckbox = find.byType(Checkbox);
      await tester.ensureVisible(dpaCheckbox);
      await tester.pump();
      await tester.tap(dpaCheckbox);
      await tester.pump();

      // Register → OTP must forward the redirect query.
      final registerButton = find.widgetWithText(ElevatedButton, 'Register');
      await tester.ensureVisible(registerButton);
      await tester.pump();
      await tester.tap(registerButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(OtpScreen), findsOneWidget);
      expect(find.text('Verify Code'), findsOneWidget);

      // Enter the 6-digit code and verify.
      for (var i = 0; i < 6; i++) {
        await tester.enterText(find.byType(TextField).at(i), '1');
        await tester.pump();
      }
      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify');
      await tester.ensureVisible(verifyButton);
      await tester.pump();
      await tester.tap(verifyButton);
      await tester.pump(); // kick off server-side OTP verification
      await tester.pump(const Duration(milliseconds: 100)); // future resolves
      await tester.pump(); // navigate to home
      await tester.pump(); // build home

      // The original destination survived the entire funnel and is resumed.
      expect(
        find.text('continuation:${AuthContinuation.businessPermit}'),
        findsOneWidget,
      );
    },
  );
}
