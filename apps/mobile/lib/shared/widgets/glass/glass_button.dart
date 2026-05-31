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
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonVariant variant;
  final bool expanded;
  final EdgeInsetsGeometry? padding;

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
    final isOutline = widget.variant == GlassButtonVariant.outline;
    final fgColor = isOutline
        ? (widget.variant == GlassButtonVariant.emergency
            ? const Color(0xFFB91C1C)
            : GlassTokens.primaryGreen)
        : Colors.white;

    Widget child = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: AppMotion.durationFast,
      child: GlassSurface(
        intensity: GlassIntensity.medium,
        borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
        tint: _backgroundColor().withValues(alpha: isOutline ? 0.08 : 0.95),
        border: isOutline
            ? Border.all(color: fgColor.withValues(alpha: 0.5))
            : null,
        padding: widget.padding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        onTap: widget.onPressed,
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fgColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.expanded) {
      child = SizedBox(width: double.infinity, child: child);
    }

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: child,
    );
  }
}
