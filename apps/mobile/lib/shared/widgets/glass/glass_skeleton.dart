import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassSkeleton extends StatelessWidget {
  const GlassSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassSurface(
      intensity: GlassIntensity.subtle,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      tint: glass.surfaceLight,
      boxShadow: const [],
      child: SizedBox(
        width: width,
        height: height,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: Colors.white.withValues(alpha: 0.4),
        );
  }
}

class GlassSkeletonCard extends StatelessWidget {
  const GlassSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      intensity: GlassIntensity.medium,
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSkeleton(width: double.infinity, height: 120, borderRadius: BorderRadius.all(Radius.circular(12))),
          SizedBox(height: 12),
          GlassSkeleton(width: 200, height: 18),
          SizedBox(height: 8),
          GlassSkeleton(width: double.infinity, height: 14),
          SizedBox(height: 4),
          GlassSkeleton(width: 160, height: 14),
        ],
      ),
    );
  }
}
