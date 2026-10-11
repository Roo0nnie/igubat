import 'package:flutter/material.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

enum GlassButtonVariant { primary, secondary, emergency, outline }

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = GlassButtonVariant.primary,
    this.expanded = false,
    this.padding,
    this.isLoading = false,
    this.loadingLabel,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonVariant variant;
  final bool expanded;
  final EdgeInsetsGeometry? padding;

  /// Shows a spinner with [loadingLabel] (falls back to [label]) and ignores taps.
  final bool isLoading;
  final String? loadingLabel;

  /// Overrides the label/icon/outline color, e.g. white on a colored card.
  final Color? foregroundColor;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  Color _backgroundColor() {
    switch (widget.variant) {
      case GlassButtonVariant.primary:
        return GlassTokens.secondaryGreen;
      case GlassButtonVariant.secondary:
        return GlassTokens.primaryGreen;
      case GlassButtonVariant.emergency:
        return const Color(0xFFB91C1C);
      case GlassButtonVariant.outline:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final isOutline = widget.variant == GlassButtonVariant.outline;
    final fgColor = widget.foregroundColor ??
        (isOutline ? glass.brandOnGlass : Colors.white);
    final loading = widget.isLoading;
    final label = loading ? (widget.loadingLabel ?? widget.label) : widget.label;

    Widget child = AnimatedScale(
      scale: _pressed && !loading ? 0.97 : 1.0,
      duration: AppMotion.durationFast,
      child: GlassSurface(
        intensity: GlassIntensity.medium,
        borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
        tint: isOutline
            ? fgColor.withValues(alpha: 0.08)
            : _backgroundColor().withValues(alpha: loading ? 0.75 : 0.95),
        border: isOutline
            ? Border.all(color: fgColor.withValues(alpha: 0.6), width: 1.5)
            : null,
        boxShadow: isOutline ? const [] : null,
        padding: widget.padding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        onTap: loading ? null : widget.onPressed,
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
              ),
              const SizedBox(width: 10),
            ] else if (widget.icon != null) ...[
              Icon(widget.icon, color: fgColor, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.expanded) {
      child = SizedBox(width: double.infinity, child: child);
    }

    return Semantics(
      button: true,
      enabled: widget.onPressed != null && !loading,
      liveRegion: loading,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: child,
      ),
    );
  }
}
