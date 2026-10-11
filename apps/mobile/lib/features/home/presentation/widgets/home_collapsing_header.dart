import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/widgets/igubat_logo.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_search_bar.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

/// Dark forest greens — aligned with [AppTheme.primaryColor] / bottom nav tint.
LinearGradient _igubatHeaderGradient({required bool isDark}) {
  if (isDark) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0A1F14),
        Color(0xFF0F3D26),
        Color(0xFF1B5E3C),
        Color(0xFF0F3D26),
      ],
      stops: [0.0, 0.3, 0.65, 1.0],
    );
  }

  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A2E1C),
      AppTheme.primaryColor,
      Color(0xFF1B5E3C),
      Color(0xFF2D6A4F),
      AppTheme.primaryColor,
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
}

/// Pinned collapsing header for the Home feed. The expanded gradient header
/// (sign-in CTA, search) scrolls away; only profile + greeting + notification
/// remain pinned in a Services-style toolbar bar.
class HomeCollapsingHeader extends ConsumerWidget {
  const HomeCollapsingHeader({super.key, this.onLogoTap});

  /// Tapping the brand logo shown in the collapsed bar (e.g. scroll to top).
  final VoidCallback? onLogoTap;

  static const _horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final greeting = _timeOfDayGreeting();

    return SliverAppBar(
      expandedHeight: _expandedBodyHeight(isAuthenticated),
      pinned: true,
      stretch: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      // Transparent so the mint body shows through the rounded bottom corners.
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      // Profile row lives only in [flexibleSpace] to avoid duplicating with title.
      flexibleSpace: _HomeFlexibleSpace(
        isAuthenticated: isAuthenticated,
        userName: user?.name,
        greeting: greeting,
        onLogoTap: onLogoTap,
      ),
    );
  }

  /// Body height below the status bar + toolbar (flexible area only).
  static double _expandedBodyHeight(bool isAuthenticated) {
    const topContentPadding = 12.0;
    const expandedRowHeight = 72.0;
    const sectionGap = 12.0;
    const guestBannerHeight = 104.0;
    const searchBarHeight = 52.0;
    const bottomPadding = 20.0;

    return topContentPadding +
        expandedRowHeight +
        (isAuthenticated ? 0 : sectionGap + guestBannerHeight) +
        sectionGap +
        searchBarHeight +
        bottomPadding;
  }
}

String _timeOfDayGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Maayong Buntag';
  if (hour < 13) return 'Maayong Udto';
  if (hour < 18) return 'Maayong Hapon';
  return 'Maayong Gabii';
}

class _HomeFlexibleSpace extends StatelessWidget {
  const _HomeFlexibleSpace({
    required this.isAuthenticated,
    required this.userName,
    required this.greeting,
    this.onLogoTap,
  });

  final bool isAuthenticated;
  final String? userName;
  final String greeting;
  final VoidCallback? onLogoTap;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final t = settings == null
        ? 1.0
        : () {
            final delta = settings.maxExtent - settings.minExtent;
            if (delta <= 0) return 0.0;
            return ((settings.currentExtent - settings.minExtent) / delta)
                .clamp(0.0, 1.0);
          }();

    final scrollAwayHeight =
        (isAuthenticated ? 0.0 : 104.0 + 12.0) + 52.0 + 20.0;
    final scrollContentOpacity = Curves.easeIn.transform(t);
    final bottomRadius = lerpDouble(0, GlassTokens.radiusGlassLg, t)!;

    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(bottomRadius),
        bottomRight: Radius.circular(bottomRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(t, isDark),
          // Single profile row: slides up when expanded, pins at toolbar when collapsed.
          Positioned(
            left: HomeCollapsingHeader._horizontalPadding,
            right: HomeCollapsingHeader._horizontalPadding,
            bottom: scrollAwayHeight * t,
            child: _HomeToolbarRow(
              isAuthenticated: isAuthenticated,
              userName: userName,
              greeting: greeting,
              expandRatio: t,
              onLogoTap: onLogoTap,
            ),
          ),
          // Sign-in + search — fade out early as the header collapses.
          if (scrollContentOpacity > 0.01)
            Positioned(
              left: HomeCollapsingHeader._horizontalPadding,
              right: HomeCollapsingHeader._horizontalPadding,
              bottom: 20,
              child: Opacity(
                opacity: scrollContentOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isAuthenticated) ...[
                      _GuestSignInBanner(),
                      const SizedBox(height: 12),
                    ],
                    const GlassSearchBar(
                      floating: true,
                      margin: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground(double t, bool isDark) {
    if (t <= 0.01) {
      return GlassToolbarShell(isDark: isDark, child: const SizedBox.expand());
    }

    final gradient = _igubatHeaderGradient(isDark: isDark);

    if (t >= 0.99) {
      return DecoratedBox(decoration: BoxDecoration(gradient: gradient));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
        Opacity(
          opacity: 1 - t,
          child: GlassToolbarShell(
            isDark: isDark,
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _HomeToolbarRow extends StatelessWidget {
  const _HomeToolbarRow({
    required this.isAuthenticated,
    required this.userName,
    required this.greeting,
    required this.expandRatio,
    this.onLogoTap,
  });

  final bool isAuthenticated;
  final String? userName;
  final String greeting;
  final double expandRatio;
  final VoidCallback? onLogoTap;

  String get _firstName => (userName ?? SeedData.currentUser.name)
      .trim()
      .split(RegExp(r'\s+'))
      .first;

  String get _primaryGreetingLine =>
      isAuthenticated ? '$greeting, $_firstName!' : '$greeting, Igubat!';

  String? get _subtitleLine => isAuthenticated
      ? (userName ?? SeedData.currentUser.name)
      : 'Sign in to access your account';

  @override
  Widget build(BuildContext context) {
    final t = expandRatio.clamp(0.0, 1.0);
    final avatarRadius = lerpDouble(18, 26, t)!;
    final avatarIconSize = lerpDouble(22, 28, t)!;
    final greetingFontSize = lerpDouble(16, 22, t)!;
    final avatarSpacing = lerpDouble(8, 16, t)!;
    final rowHeight = lerpDouble(kToolbarHeight, 72, t)!;
    final showSubtitle = t > 0.55;
    // Greeting fades out while collapsing; the brand logo takes its place in
    // the pinned bar so it can act as a "back to top" control.
    final greetingOpacity = ((t - 0.2) / 0.3).clamp(0.0, 1.0);
    final logoOpacity = (1 - t / 0.2).clamp(0.0, 1.0);

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: avatarIconSize,
              ),
            ),
          ),
          SizedBox(width: avatarSpacing),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (greetingOpacity > 0)
                  Opacity(
                    opacity: greetingOpacity,
                    child: _buildGreeting(t, greetingFontSize, showSubtitle),
                  ),
                if (logoOpacity > 0)
                  IgnorePointer(
                    ignoring: logoOpacity < 0.5,
                    child: Opacity(
                      opacity: logoOpacity,
                      child: IgubatLogo(
                        height: 34,
                        onTap: onLogoTap,
                        tapHint: 'Back to top',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _NotificationButton(isAuthenticated: isAuthenticated, expandRatio: t),
        ],
      ),
    );
  }

  Widget _buildGreeting(double t, double greetingFontSize, bool showSubtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _primaryGreetingLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: greetingFontSize,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        if (showSubtitle) ...[
          SizedBox(height: 4 * t),
          Opacity(
            opacity: ((t - 0.55) / 0.45).clamp(0.0, 1.0),
            child: Text(
              _subtitleLine!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.isAuthenticated,
    required this.expandRatio,
  });

  final bool isAuthenticated;
  final double expandRatio;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      onPressed: () {
        if (!isAuthenticated) {
          context.push(
            AppRoutes.loginWithRedirect(AppRoutes.redirectNotifications),
          );
          return;
        }
        Navigator.push(
          context,
          GlassPageRoute(page: const NotificationsScreen()),
        );
      },
    );

    if (expandRatio < 0.35) return button;

    return Opacity(
      opacity: ((expandRatio - 0.35) / 0.65).clamp(0.0, 1.0),
      child: GlassSurface(
        intensity: GlassIntensity.subtle,
        borderRadius: BorderRadius.circular(999),
        tint: Colors.white.withValues(alpha: 0.15),
        boxShadow: const [],
        padding: EdgeInsets.zero,
        child: button,
      ),
    );
  }
}

class _GuestSignInBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      intensity: GlassIntensity.subtle,
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      tint: Colors.white.withValues(alpha: 0.15),
      boxShadow: const [],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sign in to submit requests and view your notifications.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
