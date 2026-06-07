import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mobile/core/theme/glass_tokens.dart';
import 'package:mobile/core/widgets/igubat_logo.dart';
import 'package:mobile/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile/shared/widgets/glass/glass_background.dart';
import 'package:mobile/shared/widgets/glass/glass_card.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassBackground(
      child: IntroductionScreen(
        globalBackgroundColor: Colors.transparent,
        pages: [
          _buildPage(
            theme: theme,
            icon: CupertinoIcons.building_2_fill,
            gradientColors: [colorScheme.primary, colorScheme.tertiary],
            title: 'Welcome to iGubat',
            body:
                'Your digital gateway to municipal services.\n'
                'Access permits, news, and emergency hotlines in one app.',
          ),
          _buildPage(
            theme: theme,
            icon: CupertinoIcons.doc_text_fill,
            gradientColors: [colorScheme.tertiary, colorScheme.secondary],
            title: 'Apply Online',
            body:
                'Submit business permits, certificates, and\n'
                'service requests from your phone.',
          ),
          _buildPage(
            theme: theme,
            icon: CupertinoIcons.shield_fill,
            gradientColors: [colorScheme.secondary, colorScheme.primary],
            title: 'Secure & Trusted',
            body:
                'Verified citizen accounts keep your data safe\n'
                'and your transactions secure.',
          ),
        ],
        showSkipButton: true,
        skip: Text(
          'Skip',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        next: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.arrow_right,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        done: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Start',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        onDone: () {
          ref.read(onboardingStateProvider.notifier).completeOnboarding();
        },
        onSkip: () {
          ref.read(onboardingStateProvider.notifier).completeOnboarding();
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(8.0),
          activeSize: const Size(24.0, 8.0),
          activeColor: colorScheme.primary,
          color: colorScheme.outlineVariant.withOpacity(0.5),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          spacing: const EdgeInsets.symmetric(horizontal: 4),
        ),
        isProgressTap: false,
        curve: Curves.easeOutCubic,
        scrollPhysics: const BouncingScrollPhysics(),
        controlsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  PageViewModel _buildPage({
    required ThemeData theme,
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String body,
  }) {
    return PageViewModel(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 48), // Generous spacing
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.w600, // Semibold Apple style
            color: theme.colorScheme.onSurface.withOpacity(0.9),
            letterSpacing: 0,
            height: 1.1,
          ),
        ),
      ),
      bodyWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            height: 1.47,
          ),
        ),
      ),
      image: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const IgubatLogo(height: 42),
            const SizedBox(height: 18),
            GlassCard(
              intensity: GlassIntensity.prominent,
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: GlassTokens.accentGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      decoration: PageDecoration(
        imagePadding: EdgeInsets.zero,
        bodyPadding: const EdgeInsets.symmetric(horizontal: 8),
        titlePadding: const EdgeInsets.only(bottom: 0),
        bodyAlignment: Alignment.center,
        imageAlignment: Alignment.center,
      ),
    );
  }
}
