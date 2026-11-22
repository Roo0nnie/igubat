import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/session.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';

/// Records sign-in calls and answers with a configurable result, so the login
/// screen can be exercised without a backend.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInResult = const Right(null)});

  final Either<Failure, Session?> signInResult;
  final List<String> signInEmails = [];

  @override
  FutureResult<Session?> getCurrentSession() async => const Right(null);

  @override
  FutureResult<Session?> signIn({
    required String email,
    required String password,
  }) async {
    signInEmails.add(email);
    return signInResult;
  }

  @override
  FutureResult<Unit> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String barangay,
    required String address,
    required bool dpaConsent,
  }) async => const Right(unit);

  @override
  FutureResult<Unit> sendVerificationOtp({required String email}) async =>
      const Right(unit);

  @override
  FutureResult<Session?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async => const Right(null);

  @override
  FutureResult<Unit> signOut() async => const Right(unit);
}

Future<void> _pumpLogin(WidgetTester tester, _FakeAuthRepository repo) async {
  // Tall viewport keeps the whole form on-screen and tappable.
  tester.view.physicalSize = const Size(1080, 3600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  // GlassBackground animates forever, so pumpAndSettle would never return.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tapLogIn(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Log In');
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('shows required-field errors and does not call the API', (
    tester,
  ) async {
    final repo = _FakeAuthRepository();
    await _pumpLogin(tester, repo);

    await _tapLogIn(tester);

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(repo.signInEmails, isEmpty);
  });

  testWidgets('rejects a malformed email and a short password', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpLogin(tester, repo);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await _tapLogIn(tester);

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(repo.signInEmails, isEmpty);
  });

  testWidgets('trims the email and shows the server error when sign-in fails', (
    tester,
  ) async {
    final repo = _FakeAuthRepository(
      signInResult: const Left(AuthFailure('Invalid email or password')),
    );
    await _pumpLogin(tester, repo);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      '  juan@example.com ',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret-pass');
    await _tapLogIn(tester);

    expect(repo.signInEmails, ['juan@example.com']);
    expect(find.text('Sign In Failed'), findsOneWidget);
    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
