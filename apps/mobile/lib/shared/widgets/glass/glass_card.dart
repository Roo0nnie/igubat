import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.intensity = GlassIntensity.medium,
    this.borderRadius,
    this.onTap,
    this.padding,
    this.margin,
    this.tint,
    this.animateEntry = false,
  });

  final Widget child;
  final GlassIntensity intensity;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final bool animateEntry;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        BorderRadius.circular(GlassTokens.radiusGlassSm);

    Widget card = GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: AppMotion.durationFast,
        curve: AppMotion.enterCurve,
        child: GlassSurface(
          intensity: widget.intensity,
          borderRadius: radius,
          tint: widget.tint,
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.s16),
          margin: widget.margin,
          onTap: null,
          boxShadow: _pressed
              ? []
              : GlassTokens.ambientShadow(opacity: 0.1),
          child: widget.child,
        ),
      ),
    );

    if (widget.animateEntry) {
      card = card
          .animate()
          .fadeIn(duration: AppMotion.durationStandard, curve: AppMotion.enterCurve);
    }

    return card;
  }
}
