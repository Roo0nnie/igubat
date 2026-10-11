import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile/features/discover_gubat/presentation/screens/discover_gubat_detail_screen.dart';
import 'package:mobile/features/discover_gubat/presentation/screens/discover_gubat_list_screen.dart';
import 'package:mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:mobile/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:mobile/features/transparency/data/models/transparency_type.dart';
import 'package:mobile/features/transparency/presentation/screens/transparency_category_list_screen.dart';
import 'package:mobile/features/transparency/presentation/screens/transparency_item_detail_screen.dart';
import 'package:mobile/shared/widgets/main_scaffold.dart';

part 'app_router.g.dart';

/// Named route paths used across the app.
class AppRoutes {
  AppRoutes._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const home = '/';

  /// Query parameter carrying the post-authentication continuation target
  /// through the login → OTP flow, so a guest who signs in from a guarded
  /// surface resumes the action they attempted instead of landing on Home.
  static const redirectQueryParam = 'redirect';
  static const redirectNotifications = 'notifications';
  static const redirectProfile = 'profile';
  static const redirectBusinessPermit = 'businessPermit';

  /// Query parameter carrying the email being verified into the OTP screen,
  /// so server-side OTP validation/resend target the right account.
  static const emailQueryParam = 'email';

  /// Builds a `/login?redirect=<target>` location for the given continuation.
  static String loginWithRedirect(String target) =>
      '$login?$redirectQueryParam=$target';

  /// Appends the active `redirect` continuation (if any) to [path] so the
  /// post-authentication target survives every hop of the auth funnel
  /// (login → register → OTP), not just the login path.
  static String withRedirect(String path, String? redirect) =>
      redirect != null ? '$path?$redirectQueryParam=$redirect' : path;

  /// Builds the OTP location carrying the [email] under verification plus any
  /// active post-authentication [redirect] continuation, so server-side OTP
  /// validation and resend target the right account.
  static String otpWith(String email, String? redirect) {
    final params = <String, String>{
      emailQueryParam: email,
      if (redirect != null) redirectQueryParam: redirect,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$otp?$query';
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provides the [GoRouter] instance configured with redirect logic
/// based on onboarding and authentication state.
///
/// Uses [refreshListenable] so the **same** GoRouter instance re-evaluates
/// its redirect whenever auth or onboarding state changes, instead of
/// recreating the router (which would not trigger a navigation).
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // A notifier that fires whenever auth or onboarding state changes,
  // telling GoRouter to re-run its redirect callback.
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(authStateProvider, (_, _) {
    refreshNotifier.value++;
  });
  ref.listen(hasCompletedOnboardingProvider, (_, _) {
    refreshNotifier.value++;
  });

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isOnboardingDone = ref.read(hasCompletedOnboardingProvider);
      final authState = ref.read(authStateProvider);
      final isAuthenticated = !authState.isLoading && authState.value != null;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnRegister = state.matchedLocation == AppRoutes.register;
      final isOnOtp = state.matchedLocation == AppRoutes.otp;
      final isOnAuthRoute = isOnLogin || isOnRegister || isOnOtp;

      // 1. Not done with onboarding → force onboarding
      if (!isOnboardingDone) {
        return isOnOnboarding ? null : AppRoutes.onboarding;
      }

      // 2. Done with onboarding but still on onboarding page → go to the
      //    public Home. Guests land on the public surfaces (Home, News,
      //    Emergency, Services) without being forced to authenticate first.
      if (isOnOnboarding) {
        return AppRoutes.home;
      }

      // 3. Authenticated but sitting on a (non-OTP) auth route → go home.
      //    Unauthenticated Guests are intentionally NOT redirected to login
      //    here: public surfaces stay open, and only authenticated actions
      //    (submissions, notifications, profile) are gated downstream.
      if (isAuthenticated && isOnAuthRoute && !isOnOtp) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/discover-gubat',
        builder: (context, state) => const DiscoverGubatListScreen(),
        routes: [
          GoRoute(
            path: ':slug',
            builder: (context, state) => DiscoverGubatDetailScreen(
              slug: state.pathParameters['slug'] ?? '',
            ),
          ),
        ],
      ),
      // Transparency & Good Governance deep links. `:type` is a route slug
      // (e.g. "legislative-ordinances"); push notifications carrying
      // `metadata.slug` land directly on the item detail route.
      GoRoute(
        path: '/transparency/:type',
        builder: (context, state) {
          final type =
              TransparencyTypeX.fromRouteSlug(
                state.pathParameters['type'] ?? '',
              ) ??
              TransparencyType.programProject;
          return TransparencyCategoryListScreen(type: type);
        },
        routes: [
          GoRoute(
            path: ':slug',
            builder: (context, state) => TransparencyItemDetailScreen(
              slug: state.pathParameters['slug'] ?? '',
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );

  ref.onDispose(() {
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
}
