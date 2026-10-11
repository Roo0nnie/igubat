import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_router.dart';
import '../../core/navigation/glass_page_route.dart';
import '../../core/theme/app_styles.dart';
import 'glass/glass_background.dart';
import 'glass/glass_floating_nav_bar.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_redirect_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/services/presentation/screens/business_permit_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  static const int homeTab = 0;
  static const int servicesTab = 1;
  static const int newsTab = 2;
  static const int emergencyTab = 3;
  static const int profileTab = 4;

  /// Switches the bottom-nav tab from any screen hosted inside the shell.
  /// Applies the same guards as tapping the tab (e.g. Profile requires login).
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainScaffoldState>()?._onTabTapped(index);
  }

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  /// Index of the Profile tab. Profile management is an authenticated-only
  /// action (TOR Module 9), so Guests tapping it are sent to login instead.
  static const int _profileIndex = MainScaffold.profileTab;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // The OTP screen writes the continuation *before* navigating here, so by
    // the time this shell mounts the value is already pending. `ref.listen`
    // (registered in build) only fires on *subsequent* changes, never the
    // existing one, so the pending continuation must be consumed explicitly at
    // mount — otherwise the guest always stays on Home.
    final pending = ref.read(authContinuationProvider);
    if (pending != null && ref.read(isAuthenticatedProvider)) {
      ref.read(authContinuationProvider.notifier).state = null;
      _resumeContinuation(pending);
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ServicesScreen(),
    NewsScreen(),
    EmergencyScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    // Public surfaces (Home, Services, News, Emergency) are open to Guests.
    // The Profile tab manages an authenticated account, so unauthenticated
    // Guests are routed to login instead of switching to the Profile tab.
    if (index == _profileIndex && !ref.read(isAuthenticatedProvider)) {
      // Pass the intended Profile destination so successful sign-in lands the
      // user on Profile rather than Home.
      context.push(AppRoutes.loginWithRedirect(AppRoutes.redirectProfile));
      return;
    }
    setState(() => _currentIndex = index);
  }

  /// Resumes the surface a guest attempted before being routed to sign-in.
  /// Runs after the authenticated shell is mounted (post-frame) so nested
  /// pushes happen on the live navigator.
  void _resumeContinuation(AuthContinuation continuation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (continuation) {
        case AuthContinuation.profile:
          setState(() => _currentIndex = _profileIndex);
          break;
        case AuthContinuation.notifications:
          Navigator.push(
            context,
            GlassPageRoute(page: const NotificationsScreen()),
          );
          break;
        case AuthContinuation.businessPermit:
          Navigator.push(
            context,
            GlassPageRoute(page: const BusinessPermitScreen()),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // When the session ends, never leave the user stranded on an
    // authenticated-only tab (Profile): reset to the public Home surface.
    ref.listen(authStateProvider, (previous, next) {
      final isAuthed = !next.isLoading && next.value != null;
      if (!isAuthed && _currentIndex == _profileIndex) {
        setState(() => _currentIndex = 0);
      }
    });

    // Resume any pending post-authentication continuation once the user is
    // signed in, then clear it so it fires exactly once.
    ref.listen(authContinuationProvider, (previous, next) {
      if (next == null || !ref.read(isAuthenticatedProvider)) return;
      ref.read(authContinuationProvider.notifier).state = null;
      _resumeContinuation(next);
    });

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        showBlobs: true,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: AppMotion.durationStandard,
                switchInCurve: AppMotion.pageTransitionCurve,
                switchOutCurve: AppMotion.transitionCurve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassFloatingNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: GlassFloatingNavBar.defaultItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
