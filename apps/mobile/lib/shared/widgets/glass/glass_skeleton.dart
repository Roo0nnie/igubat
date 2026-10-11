import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassSkeleton extends StatefulWidget {
  const GlassSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  const GlassSkeleton.circle({super.key, double size = 44})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<GlassSkeleton> createState() => _GlassSkeletonState();
}

class _GlassSkeletonState extends State<GlassSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller.value = 1;
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: GlassSurface(
        intensity: GlassIntensity.subtle,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        tint: glass.isDark
            ? Colors.white.withValues(alpha: 0.12)
            : GlassTokens.primaryGreen.withValues(alpha: 0.09),
        boxShadow: const [],
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }
}

class GlassSkeletonCard extends StatelessWidget {
  const GlassSkeletonCard({super.key, this.imageHeight = 120});

  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      intensity: GlassIntensity.medium,
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageHeight > 0) ...[
            GlassSkeleton(
              width: double.infinity,
              height: imageHeight,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(height: 12),
          ],
          const GlassSkeleton(width: 200, height: 18),
          const SizedBox(height: 8),
          const GlassSkeleton(width: double.infinity, height: 14),
          const SizedBox(height: 4),
          const GlassSkeleton(width: 160, height: 14),
        ],
      ),
    );
  }
}

/// Mirrors a [GlassListTile]: leading icon bubble, title and subtitle lines.
class GlassSkeletonListTile extends StatelessWidget {
  const GlassSkeletonListTile({super.key, this.showTrailing = true});

  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      intensity: GlassIntensity.medium,
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const GlassSkeleton.circle(size: 46),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSkeleton(width: 180, height: 15),
                SizedBox(height: 8),
                GlassSkeleton(width: 110, height: 12),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 12),
            const GlassSkeleton(width: 22, height: 22),
          ],
        ],
      ),
    );
  }
}

/// Mirrors the two-column service tile grid.
class GlassSkeletonGridTile extends StatelessWidget {
  const GlassSkeletonGridTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      intensity: GlassIntensity.medium,
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSkeleton.circle(size: 48),
          SizedBox(height: 12),
          GlassSkeleton(width: 110, height: 14),
          SizedBox(height: 8),
          GlassSkeleton(width: double.infinity, height: 11),
          SizedBox(height: 4),
          GlassSkeleton(width: 80, height: 11),
          Spacer(),
          GlassSkeleton(width: 70, height: 10),
        ],
      ),
    );
  }
}

class GlassSkeletonList extends StatelessWidget {
  const GlassSkeletonList({
    super.key,
    this.count = 5,
    this.itemBuilder,
    this.spacing = 12,
    this.showTrailing = true,
  });

  final int count;
  final WidgetBuilder? itemBuilder;
  final double spacing;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          itemBuilder?.call(context) ?? GlassSkeletonListTile(showTrailing: showTrailing),
        ],
      ],
    );
  }
}

class GlassSkeletonGrid extends StatelessWidget {
  const GlassSkeletonGrid({
    super.key,
    this.count = 6,
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.childAspectRatio = 0.92,
  });

  final int count;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: count,
      itemBuilder: (_, _) => const GlassSkeletonGridTile(),
    );
  }
}

/// Mirrors an article/event/detail page: hero image, title, meta and body.
class GlassSkeletonDetail extends StatelessWidget {
  const GlassSkeletonDetail({super.key, this.showHero = true});

  final bool showHero;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHero) ...[
          const GlassSkeleton(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(GlassTokens.radiusGlassSm)),
          ),
          const SizedBox(height: 20),
        ],
        const GlassSkeleton(width: 90, height: 22, borderRadius: BorderRadius.all(Radius.circular(999))),
        const SizedBox(height: 14),
        const GlassSkeleton(width: double.infinity, height: 24),
        const SizedBox(height: 8),
        const GlassSkeleton(width: 220, height: 24),
        const SizedBox(height: 16),
        const GlassSkeleton(width: 160, height: 12),
        const SizedBox(height: 24),
        for (var i = 0; i < 6; i++) ...[
          GlassSkeleton(width: i == 5 ? 180 : double.infinity, height: 13),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
