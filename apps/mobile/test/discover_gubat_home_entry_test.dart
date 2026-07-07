import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/session.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/discover/data/models/discover_gubat_entry.dart';
import 'package:mobile/features/discover/data/repositories/discover_gubat_repository.dart';
import 'package:mobile/features/discover/presentation/screens/discover_gubat_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/onboarding/presentation/providers/onboarding_provider.dart';

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

class _RouterShell extends ConsumerWidget {
  const _RouterShell({required this.onRouter});

  final ValueChanged<GoRouter> onRouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    onRouter(router);
    return MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router);
  }
}

class _DetailFetchingDiscoverGubatRepository extends DiscoverGubatRepository {
  int detailRequests = 0;

  @override
  Future<List<DiscoverGubatEntry>> listByType(DiscoverGubatType type) async {
    if (type != DiscoverGubatType.touristSpot) return const [];
    return const [
      DiscoverGubatEntry(
        id: 21,
        type: DiscoverGubatType.touristSpot,
        title: 'Buenavista Beach',
        slug: 'buenavista-beach',
        category: 'Beach',
        summary: 'Short card summary only.',
        mapLocation: 'Buenavista, Gubat, Sorsogon',
      ),
    ];
  }

  @override
  Future<DiscoverGubatEntry?> getBySlug(String slug) async {
    detailRequests += 1;
    return const DiscoverGubatEntry(
      id: 21,
      type: DiscoverGubatType.touristSpot,
      title: 'Buenavista Beach',
      slug: 'buenavista-beach',
      category: 'Beach',
      summary: 'Short card summary only.',
      body: 'Full Buenavista guide body from the detail endpoint.',
      coverImageUrl: 'https://files.gubat.gov.ph/buenavista-cover.jpg',
      mapLocation: 'Buenavista, Gubat, Sorsogon',
      photos: [
        DiscoverGubatPhoto(
          id: 11,
          imageUrl: 'https://files.gubat.gov.ph/buenavista-surf.jpg',
          altText: 'Buenavista Beach surf break',
        ),
      ],
    );
  }
}

void main() {
  testWidgets('Home Discover Gubat action opens the public discover surface', (
    tester,
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

    expect(find.text('Discover Gubat'), findsOneWidget);

    await tester.tap(find.text('Discover Gubat'));
    await tester.pumpAndSettle();

    expect(find.text('Tourist Spots'), findsOneWidget);
    expect(find.text('Festivals & Culture'), findsOneWidget);
    expect(find.text('Local Delicacies & Products'), findsOneWidget);
    expect(find.text('Nature & Eco-Tourism'), findsOneWidget);
    expect(find.text('Delicacies/Kakanin'), findsOneWidget);
    expect(find.text('Pasalubong'), findsOneWidget);
    expect(find.text('Handicrafts/OTOP'), findsOneWidget);
    expect(find.text('Seafood'), findsOneWidget);
    expect(find.text('Pili Products'), findsOneWidget);
  });

  testWidgets('Discover Gubat items open read-only detail screens', (
    tester,
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
    await tester.tap(find.text('Discover Gubat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buenavista Beach'));
    await tester.pumpAndSettle();
    expect(find.text('Map location'), findsOneWidget);
    expect(find.text('Coastal Gubat, Sorsogon'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ginubat Festival'));
    await tester.pumpAndSettle();
    expect(find.text('Culture note'), findsOneWidget);
    expect(find.textContaining('annual town celebration'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Timitim'));
    await tester.tap(find.text('Timitim'));
    await tester.pumpAndSettle();
    expect(find.text('Where to buy'), findsOneWidget);
    expect(
      find.text('Public market and local pasalubong stalls'),
      findsOneWidget,
    );
  });

  testWidgets('Discover Gubat list and detail are public app routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late GoRouter router;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_GuestAuthRepository()),
          hasCompletedOnboardingProvider.overrideWithValue(true),
        ],
        child: _RouterShell(onRouter: (value) => router = value),
      ),
    );

    await tester.pump();
    router.go('/discover');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Discover Gubat'), findsOneWidget);
    expect(find.text('Tourist Spots'), findsOneWidget);

    router.go('/discover/timitim');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Where to buy'), findsOneWidget);
    expect(
      find.text('Public market and local pasalubong stalls'),
      findsOneWidget,
    );
  });

  testWidgets('Discover Gubat cards fetch full detail and show photos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _DetailFetchingDiscoverGubatRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoverGubatRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DiscoverGubatScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Short card summary only.'), findsOneWidget);
    expect(
      find.text('Full Buenavista guide body from the detail endpoint.'),
      findsNothing,
    );

    await tester.tap(find.text('Buenavista Beach'));
    await tester.pumpAndSettle();

    expect(repository.detailRequests, 1);
    expect(
      find.text('Full Buenavista guide body from the detail endpoint.'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsOneWidget,
    );
  });
}
