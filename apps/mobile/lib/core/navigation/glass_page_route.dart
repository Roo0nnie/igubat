import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

class GlassPageRoute<T> extends PageRouteBuilder<T> {
  GlassPageRoute({required Widget page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppMotion.durationStandard,
          reverseTransitionDuration: AppMotion.durationStandard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: AppMotion.pageTransitionCurve,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
