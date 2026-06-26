import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/session.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/transparency/data/models/transparency_type.dart';
import 'package:mobile/features/transparency/presentation/widgets/transparency_tile.dart';

class _GuestAuthRepository implements AuthRepository {
  @override
  FutureResult<Session?> getCurrentSession() async => const Right(null);

  @override
  FutureResult<Session?> signIn({
    required String email,
    required String password,
  }) async => const Right(null);

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

void main() {
  testWidgets('Home renders the Transparency and Good Governance tile grid', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_GuestAuthRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Transparency & Good Governance'), findsOneWidget);
    expect(find.text('Know where your taxes go'), findsOneWidget);
    expect(find.byType(TransparencyTile), findsNWidgets(6));

    for (final type in TransparencyType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
  });
}
