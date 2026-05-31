import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.intensity = GlassIntensity.medium,
    this.borderRadius,
    this.tint,
    this.onTap,
    this.padding,
    this.margin,
    this.border,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final GlassIntensity intensity;
  final BorderRadius? borderRadius;
  final Color? tint;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final radius = borderRadius ?? BorderRadius.circular(GlassTokens.radiusGlassSm);
    final surfaceColor = tint ?? glass.surfaceFor(intensity);
    final blur = glass.blurFor(intensity);

    Widget content = ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: radius,
            border: border ?? Border.all(color: glass.border, width: 1),
            boxShadow: boxShadow ?? GlassTokens.ambientShadow(),
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: GlassTokens.secondaryGreen.withValues(alpha: 0.1),
          highlightColor: GlassTokens.secondaryGreen.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }
}

GlassTheme glassThemeOf(BuildContext context) {
  return Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
}
